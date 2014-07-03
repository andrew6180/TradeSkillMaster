-- ------------------------------------------------------------------------------ --
--                                TradeSkillMaster                                --
--                http://www.curse.com/addons/wow/tradeskill-master               --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- This file contains code for scanning the auction house
local TSM = select(2, ...)
local AuctionScanning = TSM:NewModule("AuctionScanning", "AceEvent-3.0")
TSMAPI.AuctionScan = {}

local RETRY_DELAY = 2
local MAX_RETRIES = 4
local BASE_DELAY = 0.10 -- time to delay for before trying to scan a page again when it isn't fully loaded
local private = { callbackHandler = nil, query = {}, options = {}, data = {}, isScanning = nil }
TSMAPI:RegisterForTracing(private, "TradeSkillMaster.AuctionScanning_private")
local scanCache = {}

local CACHE_DECAY_PER_DAY = 5
local CACHE_AUTO_HIT_TIME = 10 * 60
local SECONDS_PER_DAY = 60 * 60 * 24


local function DoCallback(...)
	if type(private.callbackHandler) == "function" then
		private.callbackHandler(...)
	end
end

local function eventHandler(event)
	if event == "AUCTION_HOUSE_CLOSED" then
		-- auction house was closed, make sure all scanning is stopped
		AuctionScanning:UnregisterEvent("AUCTION_ITEM_LIST_UPDATE")
		private.auctionHouseShown = false
		DoCallback("INTERRUPTED")
		private:StopScanning()
	elseif event == "AUCTION_ITEM_LIST_UPDATE" then
		-- gets called whenever the AH window is updated (something is shown in the results section)
		AuctionScanning:UnregisterEvent("AUCTION_ITEM_LIST_UPDATE")
		TSMAPI:CancelFrame("updateDelay")
		-- now that our query was successful, we can get our data
		private:ScanAuctions()
	end
end

function AuctionScanning:OnEnable()
	AuctionScanning:RegisterEvent("AUCTION_HOUSE_CLOSED", eventHandler)
end

function private:ScanAuctionPage(resolveSellers)
	local shown = GetNumAuctionItems("list")
	local badData = false
	local auctions = {}

	for i = 1, shown do
		-- checks to make sure all the data has been sent to the client
		-- if not, the data is bad and we'll wait / try again
		local count, _, _, _, _, _, _, buyout, _, _, _, seller = select(3, GetAuctionItemInfo("list", i))
		local itemString = TSMAPI:GetItemString(GetAuctionItemLink("list", i))
		auctions[i] = { itemString = itemString, index = i, count = count, buyout = buyout, seller = seller }
		if not (itemString and buyout and count and (seller or not resolveSellers or buyout == 0)) then
			badData = true
		end
	end

	return badData, auctions
end

function IsDuplicatePage()
	if not private.pageTemp or GetNumAuctionItems("list") == 0 then return false end

	local numLinks, prevLink = 0, nil
	for i = 1, GetNumAuctionItems("list") do
		local _, _, count, _, _, _, _, minBid, minInc, buyout, bid, _, _, seller = GetAuctionItemInfo("list", i)
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
	private.pageTemp = { numShown = shown }

	for i = 1, shown do
		-- checks to make sure all the data has been sent to the client
		-- if not, the data is bad and we'll wait / try again
		local _, _, count, _, _, _, _, minBid, minInc, buyout, bid, _, seller = GetAuctionItemInfo("list", i)
		local link = GetAuctionItemLink("list", i)

		private.pageTemp[i] = { count = count, minBid = minBid, minInc = minInc, buyout = buyout, bid = bid, seller = seller, link = link }
	end
end

-- Starts a scan of the auction house.
--		query - A single query containing QueryAuctionItem paramters:
--			name, minLevel, maxLevel, invType, class, subClass, usable, quality
--    resolveSellers - whether or not to resolve seller names
--    maxPrice - stop scanning when prices go above this price
function TSMAPI.AuctionScan:RunQuery(query, callbackHandler, resolveSellers, maxPrice, doCache)
	TSMAPI.AuctionScan:StopScan() -- stop any scan in progress

	if not AuctionFrame:IsVisible() then
		return -1 -- the auction house isn't open (return code -1)
	elseif type(query) ~= "table" then
		return -2 -- the scan queue is not a table (return code -2)
	elseif not CanSendAuctionQuery() then
		TSMAPI:CreateTimeDelay("cantSendAuctionQueryDelay", 0.1, function() TSMAPI.AuctionScan:RunQuery(query, callbackHandler, resolveSellers, maxPrice, doCache) end)
		return 0 -- the query will start as soon as it can but did not start immediately (return code 0)
	end

	-- sort by buyout
	SortAuctionItems("list", "buyout")
	if IsAuctionSortReversed("list", "buyout") then
		SortAuctionItems("list", "buyout")
	end

	-- setup the query
	private.query = CopyTable(query)
	private.query.page = 0 -- the current page of this query we're scanning
	private.query.timeDelay = 0 -- a delay used to wait for information to show up
	private.query.retries = 0 -- how many times we've done a hard retry so far
	private.query.hardRetry = nil -- if a page hasn't loaded after we've tried a delay, we'll do a hard retry and re-send the query
	private.cache = doCache and { query = CopyTable(query), items = {} } or nil

	-- setup other stuff
	wipe(private.data)
	private.isScanning = true
	private.callbackHandler = callbackHandler
	private.resolveSellers = resolveSellers
	private.scanType = "query"
	private.maxPrice = maxPrice or math.huge

	--starts scanning
	private:SendQuery()
	return 1 -- scan started successfully (return code 1)
end

function TSMAPI.AuctionScan:ScanLastPage(callbackHandler)
	private:StopScanning() -- stop any scan in progress

	if not AuctionFrame:IsVisible() then
		return -1 -- the auction house isn't open (return code -1)
	elseif not CanSendAuctionQuery() then
		TSMAPI:CreateTimeDelay("cantSendAuctionQueryDelay", 0.1, function() TSMAPI.AuctionScan:ScanLastPage(callbackHandler) end)
		return 0 -- the query will start as soon as it can but did not start immediately (return code 0)
	end

	-- clear the auction sort
	SortAuctionClearSort("list")
	
	-- setup the query
	private.query = {name="", page=0}
	private.query.timeDelay = 0 -- a delay used to wait for information to show up
	private.query.retries = 0 -- how many times we've done a hard retry so far
	private.query.hardRetry = nil -- if a page hasn't loaded after we've tried a delay, we'll do a hard retry and re-send the query

	-- setup other stuff
	wipe(private.data)
	private.isScanning = true
	private.callbackHandler = callbackHandler
	private.scanType = "lastPage"

	--starts scanning
	private:SendQuery()
	return 1 -- scan started successfully (return code 1)
end

-- sends a query to the AH frame once it is ready to be queried (uses frame as a delay)
function private:SendQuery()
	if not private.isScanning then return end

	if CanSendAuctionQuery() then
		-- stop delay timer
		TSMAPI:CancelFrame("queryDelay")

		-- Query the auction house (then waits for AUCTION_ITEM_LIST_UPDATE to fire)
		AuctionScanning:RegisterEvent("AUCTION_ITEM_LIST_UPDATE", eventHandler)
		QueryAuctionItems(private.query.name, private.query.minLevel, private.query.maxLevel, private.query.invType, private.query.class, private.query.subClass, private.query.page, private.query.usable, private.query.quality)
	else
		-- run delay timer then try again to scan
		TSMAPI:CreateTimeDelay("queryDelay", 0.05, private.SendQuery)
	end
end

--scans the currently shown page of auctions and collects all the data
function private:ScanAuctions()
	if not private.isScanning then return end
	local shown, total = GetNumAuctionItems("list")
	local totalPages = ceil(total / NUM_AUCTION_ITEMS_PER_PAGE)

	if private.scanType == "numPages" then
		local cacheData = TSM.db.factionrealm.numPagesCache[private.query.cacheKey]
		cacheData.lastScan = time()
		local confidence = (120 - cacheData.confidence) / (CACHE_DECAY_PER_DAY * 2)
		local diff = abs(cacheData.avg - totalPages)
		if diff <= 1 and diff > 0.5 then
			confidence = floor(confidence * (1.5 - diff))
		elseif diff > 1 then
			confidence = floor(confidence - CACHE_DECAY_PER_DAY * diff)
		end
		cacheData.confidence = max(floor(cacheData.confidence + confidence), 0)
		cacheData.avg = (cacheData.avg * cacheData.numScans + totalPages) / (cacheData.numScans + 1)
		cacheData.numScans = cacheData.numScans + 1

		private:StopScanning()
		return DoCallback("NUM_PAGES", totalPages)
	elseif private.scanType == "lastPage" then
		local lastPage = floor(total / NUM_AUCTION_ITEMS_PER_PAGE)
		if private.query.page ~= lastPage then
			private.query.page = lastPage
			return private:SendQuery()
		end
	end

	local dataIsBad, auctions = private:ScanAuctionPage(private.resolveSellers)

	-- check that we have good data
	if dataIsBad or IsDuplicatePage() then
		if private.query.retries < MAX_RETRIES then
			if private.query.hardRetry then
				-- Hard retry
				-- re-sends the entire query
				private.query.retries = private.query.retries + 1
				private.query.timeDelay = 0
				private.query.hardRetry = nil
				private:SendQuery()
			else
				-- Soft retry
				-- runs a delay and then tries to scan the query again
				private.query.timeDelay = private.query.timeDelay + BASE_DELAY
				TSMAPI:CreateTimeDelay("updateDelay", BASE_DELAY, private.ScanAuctions)

				-- If after 2 seconds of retrying we still don't have data, will go and requery to try and solve the issue
				-- if we still don't have data, we try to scan it anyway and move on.
				if private.query.timeDelay >= RETRY_DELAY then
					private.query.hardRetry = true
				end
			end
			return
		end
	end

	if private.cache then
		-- store info in cache
		for i, v in ipairs(auctions) do
			local cacheTmp = CopyTable(v)
			cacheTmp.index = private.query.page * 50 + i
			tinsert(private.cache, cacheTmp)
			private.cache.items[cacheTmp.itemString] = true
		end
	end

	private.query.hardRetry = nil
	private.query.retries = 0
	private.query.timeDelay = 0
	if private.scanType ~= "lastPage" then
		private.query.page = private.query.page + 1 -- increment current page
		if totalPages > 0 then
			DoCallback("SCAN_PAGE_UPDATE", private.query.page, totalPages)
		end
	end
	PopulatePageTemp()

	-- now that we know our query is good, time to verify and then store our data
	for _, v in ipairs(auctions) do
		if private:AddAuctionRecord(v.index) then
			-- we've hit the max price so we're done scanning
			private:StopScanning()
			return DoCallback("SCAN_COMPLETE", private.data)
		end
	end

	if private.scanType == "lastPage" then
		return DoCallback("SCAN_LAST_PAGE_COMPLETE", private.data)
	elseif private.query.page >= totalPages then
		-- we have finished scanning this query
		private:StopScanning()
		return DoCallback("SCAN_COMPLETE", private.data)
	end

	-- query the next page and continue scanning
	private:SendQuery()
end

-- Add a new record to the private.data table
function private:AddAuctionRecord(index)
	local name, texture, count, _, _, _, _, minBid, minIncrement, buyout, bid, highBidder, highBidder_full, seller, seller_full = GetAuctionItemInfo("list", index)
	seller = TSM:GetAuctionPlayer(seller, seller_full)
	highBidder = TSM:GetAuctionPlayer(highBidder, highBidder_full)
	local timeLeft = GetAuctionItemTimeLeft("list", index)
	local link = GetAuctionItemLink("list", index)
	local itemString = TSMAPI:GetItemString(link)
	if not itemString then return end

	-- Create a new entry in the table
	if not private.data[itemString] then
		private.data[itemString] = TSMAPI.AuctionScan:NewAuctionItem()
		private.data[itemString]:SetItemLink(link)
		private.data[itemString]:SetTexture(texture)
	end
	private.data[itemString]:AddAuctionRecord(count, minBid, minIncrement, buyout, bid, highBidder, seller or "?", timeLeft)

	-- add the base item if necessary
	local baseItemString = TSMAPI:GetBaseItemString(itemString)
	if baseItemString ~= itemString then
		-- Create a new entry in the table
		if not private.data[baseItemString] then
			private.data[baseItemString] = TSMAPI.AuctionScan:NewAuctionItem()
			private.data[baseItemString]:SetItemLink(link)
			private.data[baseItemString]:SetTexture(texture)
		end
		private.data[baseItemString]:AddAuctionRecord(count, minBid, minIncrement, buyout, bid, highBidder, seller or "?", timeLeft)
		private.data[baseItemString].isBaseItem = true
	end

	if select(8, TSMAPI:GetSafeItemInfo(link)) == count then
		return (buyout or 0) / count > (private.maxPrice or math.huge)
	end
end

-- stops the scan when we are finished scanning, it was interrupted, or somebody stopped it
function private:StopScanning()
	TSMAPI:CancelFrame("cantSendAuctionQueryDelay")
	if not private.isScanning then return end

	if private.cache then
		-- store the cache info
		sort(private.cache, function(a, b) return a.index < b.index end)
		for itemString in pairs(private.cache.items) do
			scanCache[itemString] = private.cache
		end
		wipe(private.cache.items)
		private.cache = nil
	end

	-- cancel any delays that might still be running
	TSMAPI:CancelFrame("queryDelay")
	TSMAPI:CancelFrame("updateDelay")
	AuctionScanning:UnregisterEvent("AUCTION_ITEM_LIST_UPDATE")
	private.isScanning = nil
	private.pageTemp = nil
end

-- API for stopping the scan
-- returns true/false if we were/weren't actually scanning
function TSMAPI.AuctionScan:StopScan()
	private:StopScanning()
	TSM:StopGeneratingQueries()
end


-- Gets the number of pages for a given query
function TSMAPI.AuctionScan:GetNumPages(query, callbackHandler)
	private:StopScanning() -- stop any scan in progress

	if not AuctionFrame:IsVisible() then
		return -1 -- the auction house isn't open (return code -1)
	elseif type(query) ~= "table" then
		return -2 -- the scan queue is not a table (return code -2)
	elseif not CanSendAuctionQuery() then
		TSMAPI:CreateTimeDelay("cantSendAuctionQueryDelay", 0.1, function() TSMAPI.AuctionScan:GetNumPages(query, callbackHandler) end)
		return 0 -- the query will start as soon as it can but did not start immediately (return code 0)
	end

	-- fancy caching
	local temp = {}
	for i, field in ipairs({ "name", "minLevel", "maxLevel", "invType", "class", "subClass", "usable", "quality" }) do
		temp[i] = tostring(query[field])
	end
	local cacheKey = table.concat(temp, "~")
	local cacheData = TSM.db.factionrealm.numPagesCache[cacheKey]
	if cacheData then
		local cacheHit
		if time() - cacheData.lastScan < CACHE_AUTO_HIT_TIME then
			-- auto cache hit
			cacheHit = true
		elseif random(1, 100) <= cacheData.confidence then
			-- cache hit
			cacheData.confidence = cacheData.confidence - floor(((time() - cacheData.lastScan) / SECONDS_PER_DAY) * CACHE_DECAY_PER_DAY + 0.5)
			cacheData.confidence = max(cacheData.confidence, 0) -- ensure >= 0
			cacheHit = true
		end

		if cacheHit then
			local numPages = max(ceil(cacheData.avg), 1) -- round avg num of pages up and ensure >= 1
			TSMAPI:CreateTimeDelay("numPagesCacheDelay", 0, function() callbackHandler("NUM_PAGES", numPages) end)
			return 2
		end
	else
		TSM.db.factionrealm.numPagesCache[cacheKey] = { avg = 0, confidence = 0, numScans = 0, lastScan = 0 }
	end

	-- setup the query
	private.query = CopyTable(query)
	private.query.cacheKey = cacheKey

	-- setup other stuff
	wipe(private.data)
	private.isScanning = true
	private.callbackHandler = callbackHandler
	private.scanType = "numPages"

	--starts scanning
	private:SendQuery()
	return 1 -- scan started successfully (return code 1)
end

function TSMAPI.AuctionScan:CacheRemove(itemString, index)
	if scanCache[itemString] then
		tremove(scanCache[itemString], index)
	end
end

function TSMAPI.AuctionScan:ClearCache()
	wipe(scanCache)
end




local findPrivate = {}
findPrivate.findFrame = findPrivate.findFrame or CreateFrame("Frame")

local function eventHandler(frame, event)
	if event == "AUCTION_HOUSE_SHOW" then
		-- auction house was opened
	elseif event == "AUCTION_HOUSE_CLOSED" then
		frame:UnregisterEvent("AUCTION_ITEM_LIST_UPDATE")
		if findPrivate.isScanning then -- stop scanning if we were scanning (pass true to specify it was interrupted)
			TSMAPI.AuctionScan:StopFindScan()
		end
	elseif event == "AUCTION_ITEM_LIST_UPDATE" then
		frame:UnregisterEvent("AUCTION_ITEM_LIST_UPDATE")
		if findPrivate.isScanning then
			findPrivate.timeDelay = 0
			TSMAPI:CancelFrame("auctionFindScanDelay")

			-- now that our query was successful we can get our data
			findPrivate:ScanAuctions()
		end
	end
end

findPrivate.findFrame:SetScript("OnEvent", eventHandler)
findPrivate.findFrame:RegisterEvent("AUCTION_HOUSE_CLOSED")
findPrivate.findFrame:RegisterEvent("AUCTION_HOUSE_SHOW")

local function CompareTableKeys(tbl1, tbl2)
	for _, key in ipairs(findPrivate.keys) do
		if tbl1[key] ~= tbl2[key] then
			return
		end
	end
	return true
end

local function IsTargetAuction(index)
	local itemString = TSMAPI:GetItemString(GetAuctionItemLink("list", index))
	local _, _, count, _, _, _, _, minBid, bidIncrement, buyout, bidAmount, _, _, seller, seller_full = GetAuctionItemInfo("list", index)
	seller = TSM:GetAuctionPlayer(seller, seller_full)
	local bid = bidAmount == 0 and minBid or bidAmount
	local tmp = { itemString = itemString, count = count, bid = bid, buyout = buyout, seller = seller }
	return CompareTableKeys(tmp, findPrivate.targetInfo)
end

-- valid targetInfo keys: itemString, count, bid, buyout, seller
function TSMAPI.AuctionScan:FindAuction(callback, targetInfo, useCache)
	if findPrivate.isScanning then TSMAPI.AuctionScan:StopFindScan() end

	findPrivate.keys = { "itemString", "count", "bid", "buyout", "seller" }
	for i = #findPrivate.keys, 1, -1 do
		if not targetInfo[findPrivate.keys[i]] then
			tremove(findPrivate.keys, i)
		end
	end

	local cacheIndex
	if useCache and scanCache[targetInfo.itemString] then
		for i, v in ipairs(scanCache[targetInfo.itemString]) do
			if CompareTableKeys(v, targetInfo) then
				cacheIndex = i
				break
			end
		end
	end

	if cacheIndex then
		findPrivate.page = floor((cacheIndex - 1) / 50)
		findPrivate.query = scanCache[targetInfo.itemString].query
	else
		local name, _, rarity, _, minLevel, class, subClass = TSMAPI:GetSafeItemInfo(targetInfo.itemString)
		findPrivate.query = { name = name, minLevel = minLevel, maxLevel = minLevel, class = class, subClass = subClass, rarity = rarity }
		findPrivate.page = 0
	end
	findPrivate.targetInfo = targetInfo
	findPrivate.callback = callback
	findPrivate.cacheIndex = cacheIndex
	findPrivate.isScanning = targetInfo.itemString
	findPrivate.retries = 0
	findPrivate.hardRetry = nil

	-- check if the item is on the current page
	for i = 1, GetNumAuctionItems("list") do
		if IsTargetAuction(i) then
			TSMAPI.AuctionScan:StopFindScan()
			TSMAPI:CreateTimeDelay("queryFoundDelay", 0.1, function() findPrivate.callback(i) end)
			return
		end
	end

	findPrivate:SendQuery()
end

-- sends a query to the AH frame once it is ready to be queried (uses frame as a delay)
function findPrivate:SendQuery()
	if not findPrivate.isScanning then return end
	if CanSendAuctionQuery() then
		-- stop delay timer
		TSMAPI:CancelFrame("auctionFindQueryDelay")

		-- query the auction house (then waits for AUCTION_ITEM_LIST_UPDATE to fire)
		findPrivate.findFrame:RegisterEvent("AUCTION_ITEM_LIST_UPDATE")
		local q = findPrivate.query
		QueryAuctionItems(q.name, q.minLevel, q.maxLevel, q.invType, q.class, q.subClass, findPrivate.page, 0, q.rarity)
	else
		-- run delay timer then try again to scan
		TSMAPI:CreateTimeDelay("auctionFindQueryDelay", 0.05, function() findPrivate:SendQuery() end)
	end
end

-- scans the currently shown page of auctions and collects all the data
function findPrivate:ScanAuctions()
	if not findPrivate.isScanning then return end
	-- collects data on the query:
	-- # of auctions on current page
	-- # of pages total
	local shown, total = GetNumAuctionItems("list")
	local totalPages = math.ceil(total / 50)
	local dataIsBad, temp = private:ScanAuctionPage(findPrivate.targetInfo.seller)

	-- Check for bad data
	if findPrivate.retries < 3 then
		if dataIsBad then
			if findPrivate.hardRetry then
				-- Hard retry
				-- re-sends the entire query
				findPrivate.retries = findPrivate.retries + 1
				findPrivate:SendQuery()
			else
				-- Soft retry
				-- runs a delay and then tries to scan the query again
				findPrivate.timeDelay = findPrivate.timeDelay + BASE_DELAY
				TSMAPI:CreateTimeDelay("auctionFindScanDelay", BASE_DELAY, findPrivate.ScanAuctions)

				-- If after 4 seconds of retrying we still don't have data, will go and requery to try and solve the issue
				-- if we still don't have data, we try to scan it anyway and move on.
				if findPrivate.timeDelay >= 4 then
					findPrivate.hardRetry = true
					findPrivate.retries = 0
				end
			end

			return
		end
	end

	findPrivate.hardRetry = nil
	findPrivate.retries = 0

	-- now that we know our query is good, time to verify and then store our data
	for i = 1, shown do
		if IsTargetAuction(temp[i].index) then
			TSMAPI.AuctionScan:StopFindScan()
			return findPrivate.callback(temp[i].index, findPrivate.cacheIndex == findPrivate.page and findPrivate.page * 50 + temp[i].index)
		end
	end

	-- This query has more pages to scan
	-- increment the page # and send the new query
	if not findPrivate.cacheIndex and totalPages > (findPrivate.page + 1) then
		findPrivate.page = findPrivate.page + 1
		findPrivate:SendQuery()
		return
	end

	-- we are done scanning!
	TSMAPI.AuctionScan:StopFindScan()
	return findPrivate.callback()
end

-- returns whether or not we're currently doing a find scan
function TSMAPI.AuctionScan:IsFindScanning()
	return findPrivate.isScanning
end

-- stops the scan because it was either interrupted or it was completed successfully
function TSMAPI.AuctionScan:StopFindScan()
	findPrivate.findFrame:UnregisterEvent("AUCTION_ITEM_LIST_UPDATE")
	findPrivate.isScanning = nil
	TSMAPI:CancelFrame("auctionFindQueryDelay")
	TSMAPI:CancelFrame("auctionFindScanDelay")
end