
local MAJOR, MINOR = "LibAuctionScan-1.0", 2
local lib = LibStub:NewLibrary(MAJOR, MINOR)
if not lib then return end


lib.mixinTargets = lib.mixinTargets or {}
local mixins = {"StartScan", "StopScan", "GetAuctionQueryInfo", "GetCommonAuctionQueryInfo", "GetPageProgress", "FindAuction", "StopFindScan", "NewAuctionItem", "SortAuctions", "StartGetAllScan", "IsFindScanning"}

function lib:Embed(target)
	for _,name in pairs(mixins) do
		target[name] = lib[name]
	end
	lib.mixinTargets[target] = true
end





--[[-------------------------------------------------------------------------
	LibAuctionScan Utility Functions
---------------------------------------------------------------------------]]

local function GetSafeItemInfo(link)
	if type(link) ~= "string" then return end
	
	-- if strmatch(link, "battlepet:") then
		-- local _, speciesID, level, quality, health, power, speed, petID = strsplit(":", link)
		-- if not speciesID then return end
		-- level, quality, health, power, speed, petID = level or 0, quality or 0, health or 0, power or 0, speed or 0, petID or "0"
		
		-- local name, texture = C_PetJournal.GetPetInfoBySpeciesID(speciesID)
		-- level, quality = tonumber(level), tonumber(quality)
		-- petID = strsub(petID, 1, (strfind(petID, "|") or #petID)-1)
		-- link = ITEM_QUALITY_COLORS[quality].hex.."|Hbattlepet:"..speciesID..":"..level..":"..quality..":"..health..":"..power..":"..speed..":"..petID.."|h["..name.."]|h|r"
		-- local minLvl, iType, _, stackSize, _, _, vendorPrice = select(5, GetItemInfo(82800))
		-- local subType, equipLoc = 0, ""
		-- return name, link, quality, level, minLvl, iType, subType, stackSize, equipLoc, texture, vendorPrice
	-- elseif strmatch(link, "item:") then
	if strmatch(link, "item:") then
		return GetItemInfo(link)
	end
end

local BASE_DELAY = 0.10 -- time to delay for before trying to scan a page again when it isn't fully loaded

-- Converts an itemLink into an itemString
local function GetItemString(itemLink)
	if type(itemLink) ~= "string" and type(itemLink) ~= "number" then return end
	itemLink = select(2, GetSafeItemInfo(itemLink)) or itemLink
	
	-- it's an itemId and we couldn't get the itemLink so guess
	if tonumber(itemLink) then
		return "item:"..itemLink..":0:0:0:0:0:0"
	end
	
	local itemInfo = {strfind(itemLink, "|?c?f?f?(%x*)|?H?([^:]*):?(%d+):?(%d*):?(%d*):?(%d*):?(%d*):?(%d*):?(%-?%d*):?(%-?%d*):?(%-?%d*):?(%d*)|?h?%[?([^%[%]]*)%]?|?h?|?r?")}
	if not itemInfo[11] then return end
	itemInfo[11] = tonumber(itemInfo[11]) or 0
	
	return table.concat(itemInfo, ":", 4, 11)
end

local delays = {}

-- Cancels a time delay
local function CancelFrame(label)
	local delayFrame
	for i, frame in pairs(delays) do
		if frame.label == label then
			delayFrame = frame
		end
	end
	
	if delayFrame then
		delayFrame:Hide()
		delayFrame.label = nil
		delayFrame.inUse = false
		delayFrame.validate = nil
		delayFrame.timeLeft = nil
		delayFrame:SetScript("OnUpdate", nil)
	end
end

-- Creates a time delay
-- the callback is called after the specified amount of time has passed
local function CreateTimeDelay(label, duration, callback)
	if not (label and type(duration) == "number" and type(callback) == "function") then return end

	local frameNum
	for i, frame in pairs(delays) do
		if frame.label == label then return end
		if not frame.inUse then
			frameNum = i
		end
	end
	
	if not frameNum then
		local delay = CreateFrame("Frame")
		delay:Hide()
		tinsert(delays, delay)
		frameNum = #delays
	end
	
	local frame = delays[frameNum]
	frame.inUse = true
	frame.label = label
	frame.timeLeft = duration
	frame:SetScript("OnUpdate", function(self, elapsed)
		self.timeLeft = self.timeLeft - elapsed
		if self.timeLeft <= 0 then
			CancelFrame(self.label)
			callback()
		end
	end)
	frame:Show()
end

local function AuctionDataIsBad(temp, resolveSeller)
	local shown = GetNumAuctionItems("list")
	local badData = false

	for i=1, shown do
		-- checks to make sure all the data has been sent to the client
		-- if not, the data is bad and we'll wait / try again
		local count, _, _, _, _, _, _, buyout, _, _, seller = select(3, GetAuctionItemInfo("list", i))
		local itemString = GetItemString(GetAuctionItemLink("list", i))
		temp[i] = {itemString=itemString, index=i}
		if not (itemString and buyout and count and (seller or not resolveSeller)) then
			badData = true
		end
	end
	
	return badData
end



--[[-------------------------------------------------------------------------
	LibAuctionScan Scanning Functions (lib:StartScan, lib:StopScan)
---------------------------------------------------------------------------]]

do
	lib.scanFrame = lib.scanFrame or CreateFrame("Frame")

	local private = {}
	local status = {page=0, retries=0, timeDelay=0, AH=false, filterlist = {}}

	local function eventHandler(frame, event)
		if event == "AUCTION_HOUSE_SHOW" then
			-- auction house was opened
			status.AH = true
		elseif event == "AUCTION_HOUSE_CLOSED" then
			-- auction house was closed, make sure all scanning is stopped
			frame:UnregisterEvent("AUCTION_ITEM_LIST_UPDATE")
			status.AH = false
			if status.isScanning then -- stop scanning if we were scanning (pass true to specify it was interrupted)
				private:StopScanning(true)
			end
		elseif event == "AUCTION_ITEM_LIST_UPDATE" then
			-- gets called whenever the AH window is updated (something is shown in the results section)
			frame:UnregisterEvent("AUCTION_ITEM_LIST_UPDATE")
			if not status.isScanning then return end
			CancelFrame("updateDelay")
			
			-- now that our query was successful, we can get our data
			private:ScanAuctions()
		end
	end
	lib.scanFrame:SetScript("OnEvent", eventHandler)
	lib.scanFrame:RegisterEvent("AUCTION_HOUSE_CLOSED")
	lib.scanFrame:RegisterEvent("AUCTION_HOUSE_SHOW")

	local function DoCallback(...)
		if type(status.callbackHandler) == "function" then
			status.callbackHandler(...)
		end
	end

	-- gets the number of pages a certain query results in
	-- used to determine whether combined filters should be split up
	local function GetNumPages(filter, callbackFunc)
		lib:StopScan()
		if not status.AH then
			return
		elseif not CanSendAuctionQuery() then
			local delay = CreateFrame("Frame")
			delay:SetScript("OnUpdate", function(self)
					if CanSendAuctionQuery() then
						self:Hide()
						if status.isScanning == nil then return end
						GetNumPages(unpack(self.params))
					end
				end)
			delay:Show()
			delay.params = {filter, callbackFunc}
			return
		end

		local eventFrame = CreateFrame("Frame")
		eventFrame:RegisterEvent("AUCTION_ITEM_LIST_UPDATE")
		eventFrame:SetScript("OnEvent", function(self)
				local _, total = GetNumAuctionItems("list")
				local totalPages = math.ceil(total / 50)
				self:UnregisterAllEvents()
				self:Hide()
				if status.isScanning ~= false then return end
				callbackFunc(totalPages)
			end)
		eventFrame:Show()

		QueryAuctionItems(filter.name, filter.minLevel, filter.maxLevel, filter.invType, filter.class, filter.subClass, 0, filter.usable, filter.quality)
	end
	
	-- splits the combined filter into individual item filters
	local function SplitCurrentFilterItems()
		local newFilters = {}
		for _, item in ipairs(status.filter.arg) do
			local name = GetSafeItemInfo(item)
			local temp = CopyTable(status.filter)
			temp.arg = item
			temp.isCombinedFilter = nil
			temp.name = name
			tinsert(newFilters, temp)
		end

		tremove(status.filterList, 1)
		for _, filter in ipairs(newFilters) do
			tinsert(status.filterList, 1, filter)
		end
		status.filter = status.filterList[1]
		DoCallback("UPDATE_TOTAL_FILTERS", #status.filterList)
	end
	
	local function SortAuctionsAscending(header)
		SortAuctionItems("list", header)
		if IsAuctionSortReversed("list", header) then
			SortAuctionItems("list", header)
		end
	end

	local function IsDuplicatePage()
		if not private.pageTemp or GetNumAuctionItems("list") == 0 then return false end
		
		local numLinks, prevLink = 0, nil
		for i=1, GetNumAuctionItems("list") do
			local _, _, count, _, _, _, _, minBid, minInc, buyout, bid, _, seller = GetAuctionItemInfo("list", i)
			local link = GetAuctionItemLink("list", i)
			local temp = private.pageTemp[i]
			
			if not prevLink then
				prevLink = link
			elseif prevLink ~= link then
				prevLink = link
				numLinks = numLinks + 1
			end
			
			if not temp or temp.count ~= count or temp.minBid ~= minBid or temp.minInc ~= minInc or temp.buyout ~= buyout or temp.bid ~= bid or temp.seller ~= seller or temp.link ~= link then
				return false
			end
		end
		
		if numLinks > 1 and private.pageTemp.shown == GetNumAuctionItems("list") then
			return false
		end
		
		return true
	end
	
	local function PopulatePageTemp()
		local shown = GetNumAuctionItems("list")
		private.pageTemp = {numShown=shown}

		for i=1, shown do
			-- checks to make sure all the data has been sent to the client
			-- if not, the data is bad and we'll wait / try again
			local _, _, count, _, _, _, _, minBid, minInc, buyout, bid, _, seller = GetAuctionItemInfo("list", i)
			local link = GetAuctionItemLink("list", i)
			
			private.pageTemp[i] = {count=count, minBid=minBid, minInc=minInc, buyout=buyout, bid=bid, seller=seller, link=link}
		end
	end
	
	-- Starts a scan of the auction house.
	--		scanQueue - A list of queries. Each entry represents a unique set of QueryAuctionItem paramters:
	--			name, minLevel, maxLevel, invType, class, subClass, usable, quality
	-- 	options - special options for the scan (all optional)
	--			sellerResolution - resolve seller names
	--			missingSellerName - allows a missing seller (only applies if sellerResolution is set) and sets the name to this string
	--			passiveRequest - if there is a scan going on, ignore this request (otherwise stop it and run this request)
	--			maxRetries - sets the max number of retries, 3 by default
	--			retryDelay - how long the scan should wait before retrying the query, 4 sec by default
	function lib:StartScan(scanQueue, callbackHandler, scanOptions)
		lib:StopFindScan()
		if status.isScanning then
			if scanOptions.passiveRequest then
				return -4
			else
				lib:StopScan()
			end
		end

		if not status.AH then
			return -1 -- the auction house isn't open (return code -1)
		elseif type(scanQueue) ~= "table" or #scanQueue == 0 then
			return -2 -- the scan queue is empty or not a table (return code -2)
		elseif not CanSendAuctionQuery() then
			local delay = CreateFrame("Frame")
			delay:SetScript("OnUpdate", function(self)
					if CanSendAuctionQuery() then
						self:Hide()
						lib:StartScan(unpack(self.params))
					end
				end)
			delay:Show()
			delay.params = {scanQueue, callbackHandler, scanOptions}
			return 0 -- the query will start as soon as it can but did not start immediately (return code 0)
		end

		local filterList = {}
		for i=1, #scanQueue do
			if type(scanQueue[i]) ~= "table" then
				local entry = {}
				local isNum = tonumber(scanQueue[i]) and true
				local isItemIDFilter
				local itemString = GetItemString(scanQueue[i])
				if type(scanQueue[i]) == "string" and #{(":"):split(scanQueue[i])} == 2 then
					itemString = scanQueue[i]
					isItemIDFilter = true
				end
				if itemString then
					scanQueue[i] = lib:GetAuctionQueryInfo(itemString)
					if scanQueue[i] then
						scanQueue[i].exactOnly = not isNum
						scanQueue[i].arg = itemString
						scanQueue[i].scanTemp = {didCallback={}}
						scanQueue[i].isItemIDFilter = scanQueue[i].isItemIDFilter or isItemIDFilter
						tinsert(filterList, scanQueue[i])
					end
				else
					return -3 -- the scan queue contained invalid entries (return code -3)
				end
			else
				scanQueue[i].scanTemp = {didCallback={}}
				tinsert(filterList, scanQueue[i])
			end
		end
		
		if #filterList == 0 then
			return -2
		end
		
		-- set defaults
		scanOptions.maxRetries = scanOptions.maxRetries or 3
		scanOptions.retryDelay = scanOptions.retryDelay or 2

		-- initialize all the values of the status table
		-- filter = current category being scanned for {class, subClass, invSlot}
		-- filterList = queue of categories to scan for
		status.data = {} -- the data we've scanned so far
		status.page = 0 -- what page we are currently scanning (starts at 0)
		status.retries = 0 -- how many times we've done a hard retry so far
		status.hardRetry = nil -- if a page hasn't loaded after we've tried a delay, we'll do a hard retry and re-send the query
		status.filterList = filterList -- list of filters
		status.filter = filterList[1] -- current filter
		status.isScanning = true -- used to prevent functions from running when we're not supposed to be scanning
		status.callbackHandler = callbackHandler
		status.options = scanOptions -- any special options for this scan

		--starts scanning
		private:SendQuery()
		return 1 -- scan started successfully (return code 1)
	end

	-- sends a query to the AH frame once it is ready to be queried (uses frame as a delay)
	function private:SendQuery()
		if not status.isScanning then return end
		if CanSendAuctionQuery() then
			-- stop delay timer
			CancelFrame("queryDelay")

			if status.page == 0 and status.filter.isCombinedFilter and type(status.filter.arg) == "table" and not status.filter.scanTemp.checkedPages then
				status.filter.scanTemp.checkedPages = true
				status.isScanning = false
				GetNumPages(status.filter, function(numPages)
						if status.isScanning == nil then return end
						if numPages > #status.filter.arg then
							SplitCurrentFilterItems()
						end
						status.isScanning = true
						private:SendQuery()
					end)
				return
			end

			-- Query the auction house (then waits for AUCTION_ITEM_LIST_UPDATE to fire)
			lib.scanFrame:RegisterEvent("AUCTION_ITEM_LIST_UPDATE")
			QueryAuctionItems(status.filter.name, status.filter.minLevel, status.filter.maxLevel, status.filter.invType, status.filter.class, status.filter.subClass, status.page, status.filter.usable, status.filter.quality)
		else
			-- run delay timer then try again to scan
			CreateTimeDelay("queryDelay", 0.05, private.SendQuery)
		end
	end
	
	--scans the currently shown page of auctions and collects all the data
	function private:ScanAuctions()
		if not status.isScanning then return end
		
		local shown, total = GetNumAuctionItems("list")
		local totalPages = math.ceil(total / 50)
		local temp = {}
		local dataIsBad = AuctionDataIsBad(temp, status.options.sellerResolution)
		
		-- check that we have good data
		if dataIsBad or IsDuplicatePage() then
			if status.retries < status.options.maxRetries then
				if status.hardRetry then
					-- Hard retry
					-- re-sends the entire query
					status.retries = status.retries + 1
					status.timeDelay = 0
					status.hardRetry = nil
					private:SendQuery()
				else
					-- Soft retry
					-- runs a delay and then tries to scan the query again
					status.timeDelay = status.timeDelay + BASE_DELAY
					CreateTimeDelay("updateDelay", BASE_DELAY, private.ScanAuctions)

					-- If after 2 seconds of retrying we still don't have data, will go and requery to try and solve the issue
					-- if we still don't have data, we try to scan it anyway and move on.
					if status.timeDelay >= status.options.retryDelay then
						status.hardRetry = true
					end
				end
				return
			elseif dataIsBad and status.retries == status.options.maxRetries and status.options.sellerResolution and not status.options.missingSellerName then
				-- give up
				DoCallback("SCAN_TIMEOUT", status.filter)
				status.hardRetry = nil
				status.retries = 0
				status.timeDelay = 0
				private:RemoveCurrentFilter()
				return
			end
		end
		
		status.hardRetry = nil
		status.retries = 0
		status.timeDelay = 0
		DoCallback("SCAN_STATUS_UPDATE", status.page+1, totalPages, #status.filterList)
		PopulatePageTemp()
		
		-- now that we know our query is good, time to verify and then store our data
		for _, v in ipairs(temp) do
			private:AddAuctionRecord(v.index)
		end
		
		-- This query has more pages to scan
		-- increment the page # and send the new query
		if totalPages > (status.page + 1) then
			status.page = status.page + 1
			private:SendQuery()
			return
		end

		
		DoCallback("QUERY_FINISHED", {filter=status.filter, data=status.data, left=#status.filterList})
		
		-- done with this filter so remove it
		private:RemoveCurrentFilter()
	end
	
	-- called when we are done with the current filter
	function private:RemoveCurrentFilter()
		-- Removes the current filter from the filterList as we are done scanning for that item
		for i=1, #(status.filterList) do
			if status.filterList[i] == status.filter then
				tremove(status.filterList, i)
				break
			end
		end

		-- Query the next filter if we have one
		if status.filterList[1] then
			status.filter = status.filterList[1]
			status.page = 0
			private:SendQuery()
			return
		end

		-- we are done scanning!
		private:StopScanning()
	end

	-- Add a new record to the status.data table
	function private:AddAuctionRecord(index)
		local name, texture, count, _, _, _, _, minBid, minIncrement, buyout, bid, highBidder, seller = GetAuctionItemInfo("list", index)
		local timeLeft = GetAuctionItemTimeLeft("list", index)
		local link = GetAuctionItemLink("list", index)
		local itemString = GetItemString(link)
		
		if not itemString then return end
		if status.filter.isItemIDFilter then
			local stringType, itemID = (":"):split(itemString)
			itemString = stringType..":"..itemID
		end

		-- Create a new entry in the table
		if not status.data[itemString] then
			status.data[itemString] = lib:NewAuctionItem()
			status.data[itemString]:SetItemLink(link)
			status.data[itemString]:SetTexture(texture)
		end
		status.data[itemString]:AddAuctionRecord(count, minBid, minIncrement, buyout, bid, highBidder, seller or status.options.missingSellerName, timeLeft)
	end

	-- stops the scan when we are finished scanning, it was interrupted, or somebody stopped it
	function private:StopScanning(interrupted)
		if not status.isScanning then return end

		if interrupted then
			-- fires if the scan was interrupted
			DoCallback("SCAN_INTERRUPTED")
		else
			-- fires if the scan completed sucessfully
			DoCallback("SCAN_COMPLETE", status.data)
		end

		-- cancel any delays that might still be running
		CancelFrame("queryDelay")
		CancelFrame("updateDelay")
		status.isScanning = nil
		private.pageTemp = nil

		return true
	end
	
	-- gets the current page progress
	function lib:GetPageProgress()
		local shown, total = GetNumAuctionItems("list")
		local totalPages = ceil(total / 50)
		return status.page + 1, totalPages
	end

	-- API for stopping the scan
	-- returns true/false if we were/weren't actually scanning
	function lib:StopScan()
		lib:StopFindScan()
		return private:StopScanning(true)
	end
	
	
	do
		--[[-------------------------------------------------------------------------
			GetAll Scan Code
		---------------------------------------------------------------------------]]
		local function GetAllScanFrameUpdate(self)
			if not AuctionFrame:IsVisible() then self:Hide() end
			
			-- get data for at most 200 auctions per update to avoid excessive lag
			for i=1, 200 do
				local link = GetAuctionItemLink("list", self.num)
				local _, _, quantity, _, _, _, _, _, _, buyout = GetAuctionItemInfo("list", self.num)
				if self.tries == 0 or (link and quantity and buyout) then
					self.num = self.num + 1
					self.tries = 3
					if link then
						private:AddAuctionRecord(self.num)
					end
					
					DoCallback("GETALL_UPDATE", self.num, self.numShown)
					
					-- check if we are done scanning or not
					if self.num == self.numShown then
						-- bug with getall scan only being able to return a max of 42554 auctions
						if self.num ~= self.totalNum then
							DoCallback("GETALL_BUG")
						end
						
						self:Hide()
						private:StopScanning()
						break
					end
				else
					self.tries = self.tries - 1
					break
				end
			end
		end

		local scanFrame = CreateFrame("Frame")
		scanFrame:Hide()
		scanFrame:SetScript("OnUpdate", GetAllScanFrameUpdate)

		-- every half second we check to see if there are more than 50 auctions
		-- if so, we show the scan frame and start scanning the data
		local function DataAvailableFrameUpdate(self, elapsed)
			if not AuctionFrame:IsVisible() then self:Hide() end

			self.delay = self.delay - elapsed
			self.totalDelay = self.totalDelay - elapsed
			
			DoCallback("GETALL_WAITING", 20-self.totalDelay)
			
			if self.delay <= 0 then
				if GetNumAuctionItems("list") > 50 then
					-- data is ready to be scanned!
					scanFrame.numShown, scanFrame.totalNum = GetNumAuctionItems("list")
					self:Hide()
					scanFrame:Show()
				else
					-- wait another half second
					self.delay = 1
				end
			end
		end

		local	dataAvailableFrame = CreateFrame("Frame")
		dataAvailableFrame:Hide()
		dataAvailableFrame:SetScript("OnUpdate", DataAvailableFrameUpdate)

		function lib:StartGetAllScan(callbackHandler)
			lib:StopScan()

			if not status.AH then
				return -1 -- the auction house isn't open (return code -1)
			elseif not CanSendAuctionQuery() then
				local delay = CreateFrame("Frame")
				delay:SetScript("OnUpdate", function(self)
						if CanSendAuctionQuery() then
							self:Hide()
							lib:StartGetAllScan(unpack(self.params))
						end
					end)
				delay:Show()
				delay.params = {callbackHandler}
				return 0 -- the query will start as soon as it can but did not start immediately (return code 0)
			elseif not select(2, CanSendAuctionQuery()) then
				return -2 -- getall scan not ready
			end

			-- initialize all the values of the status table
			status.options = {}
			status.filter = {}
			status.data = {} -- the data we've scanned so far
			status.isScanning = "getAll" -- used to prevent functions from running when we're not supposed to be scanning
			status.callbackHandler = callbackHandler
		
			QueryAuctionItems("", 0, 0, 0, 0, 0, 0, 0, -1, true)
			
			scanFrame.num = 0
			scanFrame.tries = 3
			dataAvailableFrame.totalDelay = 20
			dataAvailableFrame.delay = 2
			dataAvailableFrame:Show()
			
			return 1 -- scan started successfully (return code 1)
		end
	end
end





--[[-------------------------------------------------------------------------
	LibAuctionScan Finding Functions (lib:FindAuction, lib:StopFindScan)
---------------------------------------------------------------------------]]

do
	lib.findFrame = lib.findFrame or CreateFrame("Frame")
	
	local equipLocLookup = {
		[INVTYPE_HEAD]=1, [INVTYPE_NECK]=2, [INVTYPE_SHOULDER]=3, [INVTYPE_BODY]=4, [INVTYPE_CHEST]=5,
		[INVTYPE_WAIST]=6, [INVTYPE_LEGS]=7, [INVTYPE_FEET]=8, [INVTYPE_WRIST]=9, [INVTYPE_HAND]=10,
		[INVTYPE_FINGER]=11, [INVTYPE_TRINKET]=12, [INVTYPE_CLOAK]=13, [INVTYPE_HOLDABLE]=14,
		[INVTYPE_WEAPONMAINHAND]=15, [INVTYPE_ROBE]=16, [INVTYPE_TABARD]=17, [INVTYPE_BAG]=18,
		[INVTYPE_2HWEAPON]=19, [INVTYPE_RANGED]=20, [INVTYPE_SHIELD]=21, [INVTYPE_WEAPON]=22
	}
	
	local private, status = {}, {}
	
	local function eventHandler(frame, event)
		if event == "AUCTION_HOUSE_SHOW" then
			-- auction house was opened
			status.AH = true
		elseif event == "AUCTION_HOUSE_CLOSED" then
			frame:UnregisterEvent("AUCTION_ITEM_LIST_UPDATE")
			status.AH = false
			if status.isScanning then -- stop scanning if we were scanning (pass true to specify it was interrupted)
				lib:StopFindScan()
			end
		elseif event == "AUCTION_ITEM_LIST_UPDATE" then
			frame:UnregisterEvent("AUCTION_ITEM_LIST_UPDATE")
			if status.isScanning then
				status.timeDelay = 0
				CancelFrame("auctionFindScanDelay")
				
				-- now that our query was successful we can get our data
				private:ScanAuctions()
			end
		end
	end
	lib.findFrame:SetScript("OnEvent", eventHandler)
	lib.findFrame:RegisterEvent("AUCTION_HOUSE_CLOSED")
	lib.findFrame:RegisterEvent("AUCTION_HOUSE_SHOW")

	function lib:GetAuctionQueryInfo(itemString)
		local name, _, rarity, _, minLevel, class, subClass, _, equipLoc = GetSafeItemInfo(itemString)
		if not name then return end
		return {name=name, minLevel=minLevel, maxLevel=minLevel, invType=(equipLocLookup[equipLoc] or 0), class=class, subClass=subClass, quality=rarity}
	end

	function lib:GetCommonAuctionQueryInfo(items, nameFilter)
		if not nameFilter or not items or #items == 0 then return end
		local result = {name=nameFilter, minLevel=nil, maxLevel=nil, invType=-1, class=-1, subClass=-1, quality=4}
		
		for _, itemString in ipairs(items) do
			local itemFilters = lib:GetAuctionQueryInfo(itemString)
			if not itemFilters or not strfind(strlower(itemFilters.name), nameFilter) then return end
			
			if not result.minLevel or itemFilters.minLevel < result.minLevel then
				result.minLevel = itemFilters.minLevel
			end
			
			if not result.maxLevel or itemFilters.maxLevel > result.maxLevel then
				result.maxLevel = itemFilters.maxLevel
			end
			
			if result.invType == -1 then
				result.invType = itemFilters.invType
			elseif result.invType ~= itemFilters.invType then
				result.invType = 0
			end
			
			if result.class == -1 then
				result.class = itemFilters.class
			elseif result.class ~= itemFilters.class then
				result.class = 0
			end
			
			if result.subClass == -1 then
				result.subClass = itemFilters.subClass
			elseif result.subClass ~= itemFilters.subClass then
				result.subClass = 0
			end
			
			if result.quality > itemFilters.quality then
				result.quality = itemFilters.quality
			end
		end
		
		return result
	end
	
	local function IsTargetAuction(index)
		local itemID = Get
		local itemString = GetItemString(GetAuctionItemLink("list", index))
		local _, _, count, _, _, _, _, minBid, bidIncrement, buyout, bidAmount, _, seller, _, itemID = GetAuctionItemInfo("list", index)
		local bid = bidAmount == 0 and minBid or bidAmount
		local info = status.targetInfo
		if type(info.itemString) == "number" then
			itemString = itemID
		end
		
		return (not info.itemString or itemString == info.itemString) and (not info.count or count == info.count) and (not info.bid or bid == info.bid) and (not info.buyout or buyout == info.buyout) and (not info.seller or seller == info.seller)
	end

	-- valid targetInfo keys: itemString, count, bid, buyout, seller
	function lib:FindAuction(callback, targetInfo)
		if status.isScanning then lib:StopFindScan() end
		
		local name, _, rarity, _, minLevel, class, subClass, _, equipLoc = GetSafeItemInfo(targetInfo.itemString)
		status.query = {name=name, minLevel=minLevel, maxLevel=minLevel, invSlot=(equipLocLookup[equipLoc] or 0), class=class, subClass=subClass, rarity=rarity}
		status.targetInfo = targetInfo
		status.callback = callback
		
		status.page = 0
		status.isScanning = true
		status.retries = 0
		status.hardRetry = nil
		
		-- check if the item is on the current page
		for i=1, GetNumAuctionItems("list") do
			if IsTargetAuction(i) then
				lib:StopFindScan()
				CreateTimeDelay("queryFoundDelay", 0.1, function() status.callback(i) end)
				return
			end
		end
		
		private:SendQuery()
	end

	-- sends a query to the AH frame once it is ready to be queried (uses frame as a delay)
	function private:SendQuery()
		if not status.isScanning then return end
		if CanSendAuctionQuery() then
			-- stop delay timer
			CancelFrame("auctionFindQueryDelay")
			
			-- query the auction house (then waits for AUCTION_ITEM_LIST_UPDATE to fire)
			lib.findFrame:RegisterEvent("AUCTION_ITEM_LIST_UPDATE")
			QueryAuctionItems(status.query.name, status.query.minLevel, status.query.maxLevel, status.query.invType, status.query.class, status.query.subClass, status.page, 0, status.query.rarity)
		else
			-- run delay timer then try again to scan
			CreateTimeDelay("auctionFindQueryDelay", 0.05, function() private:SendQuery() end)
		end
	end

	-- scans the currently shown page of auctions and collects all the data
	function private:ScanAuctions()
		if not status.isScanning then return end
		-- collects data on the query:
			-- # of auctions on current page
			-- # of pages total
		local shown, total = GetNumAuctionItems("list")
		local totalPages = math.ceil(total / 50)
		local temp = {}
		
		-- Check for bad data
		if status.retries < 3 then
			if AuctionDataIsBad(temp) then
				if status.hardRetry then
					-- Hard retry
					-- re-sends the entire query
					status.retries = status.retries + 1
					private:SendQuery()
				else
					-- Soft retry
					-- runs a delay and then tries to scan the query again
					status.timeDelay = status.timeDelay + BASE_DELAY
					CreateTimeDelay("auctionFindScanDelay", BASE_DELAY, private.ScanAuctions)
		
					-- If after 4 seconds of retrying we still don't have data, will go and requery to try and solve the issue
					-- if we still don't have data, we try to scan it anyway and move on.
					if status.timeDelay >= 4 then
						status.hardRetry = true
						status.retries = 0
					end
				end
				
				return
			end
		end
		
		status.hardRetry = nil
		status.retries = 0
		
		-- now that we know our query is good, time to verify and then store our data
		for i=1, shown do
			if IsTargetAuction(temp[i].index) then
				lib:StopFindScan()
				return status.callback(temp[i].index)
			end
		end

		-- This query has more pages to scan
		-- increment the page # and send the new query
		if totalPages > (status.page + 1) then
			status.page = status.page + 1
			private:SendQuery()
			return
		end
		
		-- we are done scanning!
		lib:StopFindScan()
		return status.callback()
	end

	-- stops the scan because it was either interrupted or it was completed successfully
	function lib:StopFindScan()
		lib.findFrame:UnregisterEvent("AUCTION_ITEM_LIST_UPDATE")
		status.isScanning = nil
		CancelFrame("auctionFindQueryDelay")
		CancelFrame("auctionFindScanDelay")
	end
	
	function lib:IsFindScanning()
		return status.isScanning and CopyTable(status.targetInfo)
	end
end




-- update the mixins
for target,_ in pairs(lib.mixinTargets) do
	lib:Embed(target)
end