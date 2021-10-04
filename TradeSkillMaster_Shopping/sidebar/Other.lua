local TSM = select(2, ...)
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster_Shopping") -- loads the localization table

local private = {}

function private.Create(parent)
	local frame = CreateFrame("Frame", nil, parent)
	frame:SetAllPoints()
	private.frame = frame

	frame:SetScript("OnShow", function()
		local lastScan = TSMAPI:ModuleAPI("AuctionDB", "lastCompleteScan")
		for itemID, data in pairs(lastScan or {}) do
			TSMAPI:GetSafeItemInfo(itemID) -- request item info from the server ahead of time
		end
	end)

	local helpText = TSMAPI.GUI:CreateLabel(frame)
	helpText:SetPoint("TOPLEFT")
	helpText:SetPoint("TOPRIGHT")
	helpText:SetHeight(35)
	helpText:SetJustifyH("CENTER")
	helpText:SetJustifyV("CENTER")
	helpText:SetText(L["The vendor search looks for items on the AH below their vendor sell price."])

	local startBtn = TSMAPI.GUI:CreateButton(frame, 16)
	startBtn:SetPoint("TOPLEFT", helpText, "BOTTOMLEFT", 3, -3)
	startBtn:SetPoint("TOPRIGHT", helpText, "BOTTOMRIGHT", -3, -3)
	startBtn:SetHeight(20)
	startBtn:SetText(L["Start Vendor Search"])
	startBtn:SetScript("OnClick", private.StartVendorSearch)

	TSMAPI.GUI:CreateHorizontalLine(frame, -75)


	local helpText2 = TSMAPI.GUI:CreateLabel(frame)
	helpText2:SetPoint("TOPLEFT", 0, -80)
	helpText2:SetPoint("TOPRIGHT", 0, -80)
	helpText2:SetHeight(75)
	helpText2:SetJustifyH("CENTER")
	helpText2:SetJustifyV("CENTER")
	helpText2:SetText(L["The disenchant search looks for items on the AH below their disenchant value. You can set the maximum percentage of disenchant value to search for in the Shopping General options"])

	local startBtn2 = TSMAPI.GUI:CreateButton(frame, 16)
	startBtn2:SetPoint("TOPLEFT", helpText2, "BOTTOMLEFT", 0, -3)
	startBtn2:SetPoint("TOPRIGHT", helpText2, "BOTTOMRIGHT", 0, -3)
	startBtn2:SetHeight(20)
	startBtn2:SetText(L["Start Disenchant Search"])
	startBtn2:SetScript("OnClick", private.StartDisenchantSearch)

	TSMAPI.GUI:CreateHorizontalLine(frame, -200)


	local helpText3 = TSMAPI.GUI:CreateLabel(frame)
	helpText3:SetPoint("TOPLEFT", 0, -225)
	helpText3:SetPoint("TOPRIGHT", 0, -225)
	helpText3:SetHeight(80)
	helpText3:SetJustifyH("CENTER")
	helpText3:SetJustifyV("CENTER")
	helpText3:SetText(L["The Sniper feature will look in real-time for items that have recently been posted to the AH which are worth snatching! You can configure the parameters of Sniper in the Shopping options."])

	local helpText4 = TSMAPI.GUI:CreateLabel(frame)
	helpText4:SetPoint("TOPLEFT", helpText3, "BOTTOMLEFT", 0, -5)
	helpText4:SetPoint("TOPRIGHT", helpText3, "BOTTOMRIGHT", 0, -5)
	helpText4:SetHeight(35)
	helpText4:SetJustifyH("CENTER")
	helpText4:SetJustifyV("CENTER")
	helpText4:SetText(L["NOTE: The scan must be stopped before you can buy anything."])

	local startBtn = TSMAPI.GUI:CreateButton(frame, 16)
	startBtn:SetPoint("TOPLEFT", helpText4, "BOTTOMLEFT", 0, -5)
	startBtn:SetWidth((frame:GetWidth() / 2) - 2.5)
	startBtn:SetHeight(20)
	startBtn:SetText(L["Start Sniper"])
	startBtn:SetScript("OnClick", private.StartSniperSearch)

	local stopBtn = TSMAPI.GUI:CreateButton(frame, 16)
	stopBtn:SetPoint("TOPRIGHT", helpText4, "BOTTOMRIGHT", 0, -5)
	stopBtn:SetWidth((frame:GetWidth() / 2) - 2.5)
	stopBtn:SetHeight(20)
	stopBtn:SetText(L["Stop Sniper"])
	stopBtn:SetScript("OnClick", private.StopSniperSearch)


	return frame
end

function private.VendorSearchCallback(event, ...)
	if event == "filter" then
		local filter = ...
		local maxPrice
		for _, itemString in ipairs(filter.items) do
			local vendor = select(11, TSMAPI:GetSafeItemInfo(itemString))
			maxPrice = maxPrice and max(maxPrice, vendor) or vendor
		end
		return maxPrice
	elseif event == "process" then
		local itemString, auctionItem = ...
		local vendor = select(11, TSMAPI:GetSafeItemInfo(itemString))
		if not vendor then return end
		auctionItem:FilterRecords(function(record)
			return (record:GetItemBuyout() or 0) >= vendor
		end)
		auctionItem:SetMarketValue(vendor)
		return auctionItem
	elseif event == "done" then
		local auctions = ...
		local profit = 0
		for itemString, data in pairs(auctions) do
			local link = select(2, TSMAPI:GetSafeItemInfo(itemString))
			local vendor = select(11, TSMAPI:GetSafeItemInfo(itemString))
			for _, record in ipairs(data.records) do
				profit = profit + vendor * record.count - record.buyout
			end
		end
		TSM:Printf(L["Vendor Search Profit: %s"], TSMAPI:FormatTextMoney(profit))
		TSM.Search:SetSearchBarDisabled(false)
		return
	end
end

function private:StartVendorSearch()
	local itemList = {}
	local lastScan = TSMAPI:ModuleAPI("AuctionDB", "lastCompleteScan")
	if not lastScan then
		TSM:Print(L["No recent AuctionDB scan data found."])
		return
	end

	local count = 0
	for itemID, data in pairs(lastScan) do
		-- this must be GetItemInfo since these are itemIDs
		local link = select(2, GetItemInfo(itemID))
		local vendor = select(11, GetItemInfo(itemID))
		if link and data.minBuyout and data.minBuyout < vendor then
			tinsert(itemList, TSMAPI:GetItemString(link))
		end
	end

	TSM.Search:SetSearchBarDisabled(true)
	TSM.Util:ShowSearchFrame(nil, L["% Vendor Price"])
	TSM.Util:StartItemScan(itemList, private.VendorSearchCallback)
	TSMAPI:FireEvent("SHOPPING:SEARCH:STARTVENDORSCAN", {num=#itemList})
end

do
	TSM:AddSidebarFeature(OTHER, private.Create)
end

function private:StartDisenchantSearch()
	local itemList = {}
	local lastScan = TSMAPI:ModuleAPI("AuctionDB", "lastCompleteScan")
	if not lastScan then
		TSM:Print(L["No recent AuctionDB scan data found."])
		return
	end


	for itemID, data in pairs(lastScan) do
		-- this must be GetItemInfo since these are itemIDs
		local _, link, _, iLvl = GetItemInfo(itemID)
		if iLvl and iLvl >= TSM.db.global.minDeSearchLvl and iLvl <= TSM.db.global.maxDeSearchLvl then
			local deValue = TSMAPI:ModuleAPI("TradeSkillMaster", "deValue", link)
--			if link and data.minBuyout and deValue * (TSM.db.global.maxDeSearchPercent or 1) > data.minBuyout then
			if link and data.minBuyout and (data.minBuyout / deValue) < (TSM.db.global.maxDeSearchPercent or 1) then
				tinsert(itemList, TSMAPI:GetItemString(link))
			end
		end
	end

	TSM.Search:SetSearchBarDisabled(true)
	TSM.Util:ShowSearchFrame(nil, L["% DE Value"])
	TSM.Util:StartItemScan(itemList, private.DisenchantSearchCallback)
end

function private.DisenchantSearchCallback(event, ...)
	if event == "filter" then
		local filter = ...
		local maxPrice
		for _, itemString in ipairs(filter.items) do
			local deValue = TSMAPI:ModuleAPI("TradeSkillMaster", "deValue", itemString)
			maxPrice = maxPrice and max(maxPrice, deValue) or deValue
		end
		return maxPrice
	elseif event == "process" then
		local itemString, auctionItem = ...
		local deValue = TSMAPI:ModuleAPI("TradeSkillMaster", "deValue", itemString)
		if not deValue then return end
		auctionItem:FilterRecords(function(record)
			return (record:GetItemBuyout() or 0) >= deValue
		end)
		auctionItem:SetMarketValue(deValue)
		return auctionItem
	elseif event == "done" then
		local auctions = ...
		local profit = 0
		for itemString, data in pairs(auctions) do
			local link = select(2, TSMAPI:GetSafeItemInfo(itemString))
			local deValue = TSMAPI:ModuleAPI("TradeSkillMaster", "deValue", itemString)
			for _, record in ipairs(data.records) do
				profit = profit + deValue * record.count - record.buyout
			end
		end
		TSM:Printf(L["Disenchant Search Profit: %s"], TSMAPI:FormatTextMoney(profit))
		TSM.Search:SetSearchBarDisabled(false)
		return
	end
end



function private:StartSniperSearch()
	TSM.Util:ShowSearchFrame(nil, L["% Market Value"])
	TSM.Search:SetSearchBarDisabled(true)
	TSM.Util:StartLastPageScan(private.SniperScanCallback)
	TSMAPI:FireEvent("SHOPPING:SEARCH:STARTSNIPER")
end

function private:StopSniperSearch()
	TSM.Search:SetSearchBarDisabled(false)
	TSM.Util:StopScan()
end

function private.SniperScanCallback(event, itemString, auctionItem)
	if event == "process" then
		local vendorPrice, maxPrice, customPrice
		do
			local vendor = select(11, TSMAPI:GetSafeItemInfo(itemString))
			if vendor then
				vendorPrice = vendor
			end
			local operations = TSMAPI:GetItemOperation(itemString, "Shopping")
			local opSettings = operations and operations[1] and TSM.operations[operations[1]]
			if opSettings and opSettings.maxPrice then
				maxPrice = TSM:GetMaxPrice(opSettings.maxPrice, itemString)
			end
			customPrice = TSM:GetMaxPrice(TSM.db.global.sniperCustomPrice, itemString)
		end
		auctionItem:FilterRecords(function(record)
			local itemBuyout = record:GetItemBuyout()
			if not itemBuyout or itemBuyout == 0 then return true end
			if TSM.db.global.sniperVendorPrice and vendorPrice and itemBuyout <= vendorPrice then
				return false
			end
			if TSM.db.global.sniperMaxPrice and maxPrice and itemBuyout <= maxPrice then
				return false
			end
			if customPrice and itemBuyout <= customPrice then
				return false
			end
			return true
		end)
		auctionItem:SetMarketValue(TSM:GetMaxPrice(TSM.db.global.marketValueSource, itemString))
		if #auctionItem.records == 0 then return end
		auctionItem.shouldCompact = true
		auctionItem:PopulateCompactRecords()
		return auctionItem
	end
end
