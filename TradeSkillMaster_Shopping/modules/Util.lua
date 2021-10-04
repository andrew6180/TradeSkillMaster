-- ------------------------------------------------------------------------------ --
--                            TradeSkillMaster_Shopping                           --
--            http://www.curse.com/addons/wow/tradeskillmaster_shopping           --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

local TSM = select(2, ...)
local Util = TSM:NewModule("Util", "AceEvent-3.0", "AceHook-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster_Shopping") -- loads the localization table
local private = {auctions={}}
TSMAPI:RegisterForTracing(private, "TradeSkillMaster_Shopping_private")
Util.shoppingLog = {}


local function ControlCallback(event, ...)
	if event == "OnBuyout" then
		local auction = ...
		tinsert(Util.shoppingLog, {action="Buyout", link=auction.link, buyout=auction.buyout, count=auction.count})
		private:RemoveAuction(auction, event, TSMAPI:GetItemString(auction.link))
	elseif event == "OnCancel" then
		local auction = ...
		tinsert(Util.shoppingLog, {action="Cancel", link=auction.link, buyout=auction.buyout, count=auction.count})
		private:RemoveAuction(auction, event, TSMAPI:GetItemString(auction.link))
	elseif event == "OnPost" then
		local postInfo = ...
		local link = select(2, TSMAPI:GetSafeItemInfo(postInfo.itemString))
		for i=1, postInfo.numAuctions do
			tinsert(Util.shoppingLog, {auction="Post", link=link, buyout=postInfo.buyout, count=postInfo.stackSize})
		end
		private:AddPostedAuction(postInfo)
	end
	if TSM.searchCallback then
		TSM.searchCallback(event, ...)
	end
end

function private:HasInBags(baseItemString)
	for _, _, itemString in TSMAPI:GetBagIterator() do
		if TSMAPI:GetBaseItemString(itemString) == baseItemString then
			return true
		end
	end
end

function private:CreateSearchFrame()
	local function OnShow(self)
		if not self.info then return end
		if self.info.isDestroying then
			self.rtNormal:Hide()
			self.rtDestroying:Show()
			self.rt = private.searchFrame.rtDestroying
		else
			self.rtNormal:Show()
			self.rtDestroying:Hide()
			self.rt = private.searchFrame.rtNormal
		end
		self.rt:SetColHeadText(#self.rt.headCols, self.info.pctColName)
	end

	local frame = CreateFrame("Frame", nil, private.parent.content)
	frame:Hide()
	frame:SetAllPoints()
	frame:SetScript("OnShow", OnShow)
	
	local statusBarFrame = CreateFrame("Frame", nil, frame)
	statusBarFrame:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 165, -2)
	statusBarFrame:SetWidth(250)
	statusBarFrame:SetHeight(30)
	frame.statusBar = TSMAPI.GUI:CreateStatusBar(statusBarFrame, "TSMShoppingStatusBar")
	
	local handlers = {
		OnClick = function(_, data, self, button)
			-- they clicked on a data row
			if button == "LeftButton" then
				-- go to the page for this item
				local record = data.auctionRecord
				TSMAPI.AuctionScan:FindAuction(function() end, {itemString=data.itemString, buyout=record.buyout, count=record.count, seller=record.seller}, true)
				
				if data.auctionRecord:IsPlayer() then
					private.controlButtons.cancel:Enable()
					private.controlButtons.buyout:Disable()
					private.controlButtons.post:Disable()
				elseif data.auctionRecord.buyout == 0 then
					private.controlButtons.buyout:Disable()
					private.controlButtons.cancel:Disable()
					private.controlButtons.post:Disable()
				else
					private.controlButtons.buyout:Enable()
					private.controlButtons.cancel:Disable()
					private.controlButtons.post:Disable()
				end
				if private:HasInBags(TSMAPI:GetBaseItemString(data.itemString)) then
					private.controlButtons.post:Enable()
				end
			end
		end,
	}
	
	local rt = TSMAPI:CreateAuctionResultsTable(frame, handlers, true)
	rt:SetData({})
	rt:SetSort(8, true)
	frame.rtNormal = rt
	
	local rt2 = TSMAPI:CreateAuctionResultsTable(frame, handlers, true, true)
	rt2:SetData({})
	rt2:SetSort(5, true)
	frame.rtDestroying = rt2
	
	return frame
end

function Util:SetParent(parent)
	private.parent = parent
end

function Util:ShowSearchFrame(isDestroying, pctColName, clearRT)
	if private.searchFrame and private.searchFrame:IsVisible() then
		Util:HideSearchFrame()
	end
	private.searchFrame = private.searchFrame or private:CreateSearchFrame()
	private.searchFrame.info = {isDestroying=isDestroying, pctColName=pctColName}
	private.searchFrame:Show()
	if clearRT then
		private.searchFrame.rtNormal:SetData({})
		private.searchFrame.rtDestroying:SetData({})
	end
	private.controlButtons = TSMAPI.AuctionControl:ShowControlButtons(private.parent, private.searchFrame.rt, ControlCallback, "Shopping", TSM.db.global.postBidPercent, TSM.db.global.postUndercut)
	private.controlButtons.buyout:Disable()
	private.controlButtons.cancel:Disable()
	private.controlButtons.post:Disable()
	TSMAPI.AuctionScan:StopScan()
	TSMAPI.AuctionScan:ClearCache()
	private.searchFrame.statusBar:SetStatusText("")
	private.searchFrame.statusBar:UpdateStatus(0, 0)
	private.mode = isDestroying and "destroy" or "normal"
	TSM.Search:SetMode(private.mode)
end

function Util:HideSearchFrame()
	private.searchFrame:Hide()
	TSMAPI.AuctionControl:HideControlButtons()
	TSMAPI.AuctionScan:StopScan()
	TSMAPI.AuctionScan:ClearCache()
end


function Util:StartItemScan(itemList, callback)
	if type(itemList) ~= "table" then return end
	private:PrepareForScan(callback)
	if #itemList == 1 then private.searchItem = itemList[1] end
	TSMAPI:GenerateQueries(itemList, private.ScanCallback)
end

function Util:StartFilterScan(filters, callback)
	if type(filters) ~= "table" then return end
	
	private:PrepareForScan(callback)
	if #filters == 1 then
		for _, _, itemString in TSMAPI:GetBagIterator() do
			local name = TSMAPI:GetSafeItemInfo(itemString)
			if name and filters[1].name and strlower(name) == strlower(filters[1].name) then
				private.searchItem = itemString
				break
			end 
		end
	end
	private.filterList = filters
	private.numFilters = #private.filterList
	private:ScanNextFilter()
end

function Util:StartLastPageScan(callback)
	private:PrepareForScan(callback, true)
	TSMAPI.AuctionScan:ScanLastPage(private.ScanCallback)
end

function Util:StopScan()
	TSMAPI:CancelFrame("shoppingRestartSniper")
	TSMAPI.AuctionScan:StopScan()
	private:ScanComplete()
end



function private:PrepareForScan(callback, isLastPageScan)
	TSMAPI:CancelFrame("shoppingRestartSniper")
	TSMAPI.AuctionScan:StopScan()
	private.searchItem = nil
	private.isLastPageScan = isLastPageScan
	private.callback = callback
	wipe(private.auctions)
	if private.isLastPageScan then
		private.searchFrame.statusBar:SetStatusText("Scanning last page...")
	else
		private.searchFrame.statusBar:SetStatusText(L["Preparing filters..."])
	end
	private.searchFrame.rt:SetData({})
	private.searchFrame.rt:SetDisabled(true)
	private.searchFrame.statusBar:UpdateStatus(0, 0)
	TSM.moduleAPICallback = nil
end

local scanStatus, pageStatus
function private.ScanCallback(event, ...)
	if event == "QUERY_COMPLETE" then
		private.filterList = ...
		private.numFilters = #private.filterList
		private:ScanNextFilter()
	elseif event == "QUERY_UPDATE" then
		local arg1, arg2 = ...
		private:UpdateStatus("query", arg1, arg2)
	elseif event == "SCAN_PAGE_UPDATE" then
		private:UpdateStatus("page", ...)
	elseif event == "SCAN_TIMEOUT" then
		tremove(private.filterList, 1)
		private:ScanNextFilter()
	elseif event == "SCAN_COMPLETE" then
		if not private.filterList or not private.filterList[1] then return end -- protect against sniper scan starts causing issues
		local data = ...
		if private.filterList[1].items then
			for _, itemString in ipairs(private.filterList[1].items) do
				if data[itemString] then
					if data[itemString].isBaseItem then
						for iString, auctionitem in pairs(data) do
							if iString ~= itemString and TSMAPI:GetBaseItemString(iString) == itemString then
								auctionitem.query = private.filterList[1]
								private:ProcessItem(iString, auctionitem)
							end
						end
					else
						data[itemString].query = private.filterList[1]
						private:ProcessItem(itemString, data[itemString])
					end
				end
			end
		else
			for itemString, auctionData in pairs(data) do
				if not auctionData.isBaseItem then
					auctionData.query = private.filterList[1]
					private:ProcessItem(itemString, auctionData)
				end
			end
		end
		private:UpdateRT()
		private.searchFrame.rt:ClearSelection()
		tremove(private.filterList, 1)
		private:ScanNextFilter()
	elseif event == "SCAN_LAST_PAGE_COMPLETE" then
		local data = ...
		for itemString, auctionData in pairs(data) do
			if not auctionData.isBaseItem then
				if auctionData and #auctionData.records > 0 then
					if private.auctions[itemString] then
						private.auctions[itemString].shouldCompact = true
						private.auctions[itemString]:PopulateCompactRecords()
						local existingRecords = {}
						for _, record in ipairs(private.auctions[itemString].compactRecords) do
							local key = strjoin("~", record.uniqueID, record.count, record.buyout, record.minBid, record.timeLeft)
							existingRecords[key] = true
						end
						for _, record in ipairs(auctionData.records) do
							local key = strjoin("~", record.uniqueID, record.count, record.buyout, record.minBid, record.timeLeft)
							if not existingRecords[key] then
								private.auctions[itemString]:AddRecord(record)
							else
								for _, record2 in ipairs(private.auctions[itemString].records) do
									local key2 = strjoin("~", record.uniqueID, record.count, record.buyout, record.minBid, record.timeLeft)
									if key2 == key and record2.seller ~= "?" then
										record2.seller = record.seller
										break
									end
								end
							end
						end
					else
						private.auctions[itemString] = auctionData
					end
					private.auctions[itemString] = private.callback("process", itemString, private.auctions[itemString])
				end
			end
		end
		private:UpdateRT()
		private.searchFrame.rt:ClearSelection()
		TSMAPI:CreateTimeDelay("shoppingRestartSniper", 0, function() TSMAPI.AuctionScan:ScanLastPage(private.ScanCallback) end)
	end
end

function private:ScanNextFilter()
	if #private.filterList == 0 then
		return private:ScanComplete()
	end
	pageStatus = {0, 1}
	private:UpdateStatus("scan", private.numFilters-#private.filterList+1, private.numFilters)
	TSMAPI.AuctionScan:RunQuery(private.filterList[1], private.ScanCallback, true, private.callback("filter", private.filterList[1]), true)
end

function private:UpdateStatus(statusType, ...)
	if statusType == "query" then
		private.searchFrame.statusBar:SetStatusText(format(L["Preparing Filter %d / %d"], ...))
		private.searchFrame.statusBar:UpdateStatus(0, 0)
	else
		if statusType == "scan" then
			scanStatus = {...}
		elseif statusType == "page" then
			pageStatus = {...}
		end
		private.searchFrame.statusBar:SetStatusText(format(L["Scanning %d / %d (Page %d / %d)"], scanStatus[1], scanStatus[2], pageStatus[1]+1, pageStatus[2]))
		private.searchFrame.statusBar:UpdateStatus(100*(scanStatus[1]-1)/scanStatus[2], 100*pageStatus[1]/pageStatus[2])
	end
end

function private:ScanComplete()
	if not private.callback then return end
	private.searchFrame.statusBar:SetStatusText(L["Done Scanning"])
	private.searchFrame.statusBar:UpdateStatus(100, 100)
	private.searchFrame.rt:SetDisabled(false)
	if #private.searchFrame.rt.auctionData == 1 then
		private.searchFrame.rt:SetExpanded(private.searchFrame.rt.auctionData[1]:GetItemString(), true)
		private.searchFrame.rt.rows[1].cols[1]:Click()
	elseif #private.searchFrame.rt.auctionData == 0 and private.searchItem and private:HasInBags(TSMAPI:GetBaseItemString(private.searchItem)) then
		private.controlButtons.post:Enable()
		local postPrice = TSM:GetMaxPrice(TSM.db.global.normalPostPrice, private.searchItem) or 0
		TSMAPI.AuctionControl:SetNoResultItem(private.searchItem, postPrice)
	end
	
	if #private.searchFrame.rt.auctionData == 0 and TSM.moduleAPICallback then
		TSM.moduleAPICallback()
	end
	private.callback("done", private.auctions)
	TSMAPI:FireEvent("SHOPPING:SEARCH:SCANDONE", #private.searchFrame.rt.auctionData)
end

-- processes scan data for a specific item
function private:ProcessItem(itemString, auctionItem)
	-- make sure we haven't already scanned this item (possible with common search terms)
	if private.auctions[itemString] then return end
	if not itemString or not auctionItem then return end
	local query = auctionItem.query
	query.minILevel = query.minILevel or 0
	query.maxILevel = query.maxILevel or 0
	query.minLevel = query.minLevel or 0
	query.maxLevel = query.maxLevel or 0
	local name, _, _, ilvl, lvl = TSMAPI:GetSafeItemInfo(itemString)
	
	-- check if this item is outside our level or ilvl filters
	if query.minILevel > 0 and (ilvl < query.minILevel or (query.maxILevel > 0 and ilvl > query.maxILevel)) then
		private.auctions[itemString] = nil
		return
	end
	if query.minLevel > 0 and (lvl < query.minLevel or (query.maxLevel > 0 and lvl > query.maxLevel)) then
		private.auctions[itemString] = nil
		return
	end
	
	-- check for /exact filter
	if query.exactOnly and strlower(name) ~= strlower(query.name) then
		private.auctions[itemString] = nil
		return
	end
	
	-- remove any records that don't have buyouts
	for i=#auctionItem.records, 1, -1 do
		local record = auctionItem.records[i]
		if not record.buyout or record.buyout == 0 then
			auctionItem:RemoveRecord(i)
		end
	end
	
	-- check if this auctionItem has records left
	if #auctionItem.records == 0 then return end
	
	auctionItem = private.callback("process", itemString, auctionItem)
	if not auctionItem or #auctionItem.records == 0 then return end
	
	-- store auctionItem
	auctionItem:PopulateCompactRecords()
	private.auctions[itemString] = auctionItem
end

function private:UpdateRT()
	local rtData = {}
	for _, obj in pairs(private.auctions) do
		tinsert(rtData, obj)
	end
	private.searchFrame.rt:SetData(rtData)
end

function private:RemoveAuction(auction, event, itemString)
	if private.auctions[itemString] then
		-- remove this record from the auctionItem
		for i, record in ipairs(private.auctions[itemString].records) do
			if record.parent.itemLink == auction.link and record.buyout == auction.buyout and record.count == auction.count and record.seller == auction.seller then
				private.auctions[itemString]:RemoveRecord(i)
				if #private.auctions[itemString].records == 0 then
					private.auctions[itemString] = nil
				else
					-- handle max quantities on queries
					local query = private.auctions[itemString].query
					if event == "OnBuyout" and query then
						if private.mode == "normal" and (query.maxQuantity or 0) > 0 then
							query.maxQuantity = query.maxQuantity - auction.count
							if TSM.moduleAPICallback then TSM.moduleAPICallback(max(query.maxQuantity, 0), itemString, auction.count) end
							for item, auctionItem in pairs(private.auctions) do
								if auctionItem.query and auctionItem.query.maxQuantity and auctionItem.query.maxQuantity <= 0 then
									private.auctions[item] = nil
								end
							end
							if not private.auctions[itemString] then
								private.controlButtons.buyout:Disable()
								TSMAPI.AuctionControl:HideConfirmation()
								TSM:Printf(L["Maximum quantity purchased for %s."], auction.link)
							end
						elseif private.mode == "destroy" and (TSM.Destroying.maxQuantity or 0) > 0 then
							TSM.Destroying.maxQuantity = TSM.Destroying.maxQuantity - auction.count / auction.destroyingNum
							if TSM.moduleAPICallback then TSM.moduleAPICallback(max(TSM.Destroying.maxQuantity, 0), itemString, auction.count) end
							if TSM.Destroying.maxQuantity <= 0 then
								private.controlButtons.buyout:Disable()
								TSMAPI.AuctionControl:HideConfirmation()
								TSM:Printf(L["Maximum quantity purchased for destroy search."])
							end
						end
					end
				end
				break
			end
		end
	end
	
	local baseItemString = TSMAPI:GetBaseItemString(itemString)
	if baseItemString ~= itemString then
		return private:RemoveAuction(auction, event, baseItemString)
	end
	
	private:UpdateRT()
	local selected = private.searchFrame.rt:GetSelectedAuction()
	if not TSMAPI.AuctionControl:IsConfirmationVisible() then
		-- select the auction that was previously selected
		if not private.searchFrame.rt:GetSelectedAuction() and selected then
			-- we bought all of this auction, so select the new first occurace of this item
			private.searchFrame.rt:SetSelectedAuction(selected.parent:GetItemString())
		end
	end
end

function private:AddPostedAuction(postInfo)
	local link = select(2, TSMAPI:GetSafeItemInfo(postInfo.itemString))
	local texture = select(10, TSMAPI:GetSafeItemInfo(postInfo.itemString))
	if not private.auctions[postInfo.itemString] then
		private.auctions[postInfo.itemString] = TSMAPI.AuctionScan:NewAuctionItem()
		private.auctions[postInfo.itemString]:SetItemLink(link)
		private.auctions[postInfo.itemString]:SetTexture(texture)
	end
	private.auctions[postInfo.itemString]:AddAuctionRecord(postInfo.stackSize, postInfo.bid, 0, postInfo.buyout, 0, nil, UnitName("player"), postInfo.duration)
	private.auctions[postInfo.itemString]:PopulateCompactRecords()
	private:UpdateRT()
	private.searchFrame.rt:SetSelectedAuction()
end