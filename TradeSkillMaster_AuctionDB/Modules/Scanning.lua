-- ------------------------------------------------------------------------------ --
--                           TradeSkillMaster_AuctionDB                           --
--           http://www.curse.com/addons/wow/tradeskillmaster_auctiondb           --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- load the parent file (TSM) into a local variable and register this file as a module
local TSM = select(2, ...)
local Scan = TSM:NewModule("Scan", "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster_AuctionDB") -- loads the localization table

Scan.groupScanData = {}
Scan.filterList = {}
Scan.numFilters = 0


local function ScanCallback(event, ...)
	if event == "SCAN_PAGE_UPDATE" then
		local page, total = ...
		TSM.GUI:UpdateStatus(format(L["Scanning page %s/%s"], page, total), page*100/total)
	elseif event == "SCAN_COMPLETE" then
		local data = ...
		Scan:ProcessScanData(data)
		Scan:DoneScanning()
	elseif event == "INTERRUPTED" then
		Scan:DoneScanning()
	end
end

function Scan.ProcessGetAllScan(self)
	local temp = 0
	while true do
		temp = min(temp + 1, 100)
		self:Sleep(0.2)
		if not Scan.isScanning then return end
		if Scan.getAllLoaded then
			break
		end
		TSM.GUI:UpdateStatus(L["Running query..."], nil, temp)
	end

	local data = {}
	for i=1, Scan.getAllLoaded do
		TSM.GUI:UpdateStatus(format(L["Scanning page %s/%s"], 1, 1), i*100/Scan.getAllLoaded)
		if i % 100 == 0 then
			self:Yield()
			if GetNumAuctionItems("list") ~= Scan.getAllLoaded then
				--TSM:Print(L["GetAll scan did not run successfully due to issues on Blizzard's end. Using the TSM application for your scans is recommended."])
				TSM:Print("GetAll scan did not run successfully.")
				Scan:DoneScanning()
				return
			end
		end
		
		local itemID = TSMAPI:GetItemID(GetAuctionItemLink("list", i))
		--local _, _, count, _, _, _, _, _, _, buyout = GetAuctionItemInfo("list", i)
		local _, _, count, _, _, _, _, _, buyout = GetAuctionItemInfo("list", i)
		if itemID and buyout and buyout > 0 then
			data[itemID] = data[itemID] or {records={}, minBuyout=math.huge, quantity=0}
			data[itemID].minBuyout = min(data[itemID].minBuyout, buyout)
			data[itemID].quantity = data[itemID].quantity + count
			for j=1, count do
				tinsert(data[itemID].records, floor(buyout/count))
			end
		end
	end
	
	TSM.db.factionrealm.lastCompleteScan = time()
	TSM.Data:ProcessData(data)
	
	TSM.GUI:UpdateStatus(L["Processing data..."])
	while TSM.processingData do
		self:Sleep(0.2)
	end
	
	TSM:Print(L["It is strongly recommended that you reload your ui (type '/reload') after running a GetAll scan. Otherwise, any other scans (Post/Cancel/Search/etc) will be much slower than normal."])
end

function Scan:AUCTION_ITEM_LIST_UPDATE()
	Scan:UnregisterEvent("AUCTION_ITEM_LIST_UPDATE")
	local num, total = GetNumAuctionItems("list")
	
	--if num ~= total or num == 0 then
	if num == 0 then
		--TSM:Print(L["GetAll scan did not run successfully due to issues on Blizzard's end. Using the TSM application for your scans is recommended."])
		TSM:Print("GetAll scan did not run successfully.")
		Scan:DoneScanning()
		return
	end
	Scan.getAllLoaded = num
end

function Scan:GetAllScanQuery()
	local canScan, canGetAll = CanSendAuctionQuery()
	if not canGetAll then return TSM:Print(L["Can't run a GetAll scan right now."]) end
	if not canScan then return TSMAPI:CreateTimeDelay(0.5, Scan.GetAllScanQuery) end
	QueryAuctionItems("", nil, nil, nil, nil, nil, nil, nil, nil, true)
	Scan:RegisterEvent("AUCTION_ITEM_LIST_UPDATE")
	TSMAPI.Threading:Start(Scan.ProcessGetAllScan, 1, function() Scan:DoneScanning() end)
end

local function GroupScanCallback(event, ...)
	if event == "QUERY_COMPLETE" then
		local filterList = ...
		local numItems = 0
		for _, v in ipairs(filterList) do
			numItems = numItems + #v.items
		end
		Scan.filterList = filterList
		Scan.numFilters = #filterList
		Scan:ScanNextGroupFilter()
	elseif event == "QUERY_UPDATE" then
		local current, total = ...
		TSM.GUI:UpdateStatus(format(L["Preparing Filter %d / %d"], current, total))
	elseif event == "SCAN_INTERRUPTED" then
		Scan:DoneScanning()
	elseif event == "SCAN_TIMEOUT" then
		tremove(Scan.filterList, 1)
		Scan:ScanNextGroupFilter()
	elseif event == "SCAN_PAGE_UPDATE" then
		local page, total = ...
		TSM.GUI:UpdateStatus(format(L["Scanning %d / %d (Page %d / %d)"], Scan.numFilters-#Scan.filterList, Scan.numFilters, page+1, total), nil, page*100/total)
	elseif event == "SCAN_COMPLETE" then
		local data = ...
		for _, itemString in ipairs(Scan.filterList[1].items) do
			if not Scan.groupScanData[itemString] then
				Scan.groupScanData[itemString] = data[itemString]
			end
		end
		tremove(Scan.filterList, 1)
		Scan:ScanNextGroupFilter()
	end
end

function Scan:ScanNextGroupFilter(data)
	if #Scan.filterList == 0 then
		Scan:ProcessScanData(Scan.groupScanData)
		Scan:DoneScanning()
		return
	end
	TSM.GUI:UpdateStatus(format(L["Scanning %d / %d (Page %d / %d)"], Scan.numFilters-#Scan.filterList, Scan.numFilters, 1, 1), (Scan.numFilters-#Scan.filterList)*100/Scan.numFilters)
	TSMAPI.AuctionScan:RunQuery(Scan.filterList[1], GroupScanCallback)
end

function Scan:StartGroupScan(items)
	Scan.isScanning = "Group"
	Scan.isBuggedGetAll = nil
	Scan.groupItems = items
	wipe(Scan.filterList)
	wipe(Scan.groupScanData)
	Scan.numFilters = 0
	TSMAPI.AuctionScan:StopScan()
	TSMAPI:GenerateQueries(items, GroupScanCallback)
	TSM.GUI:UpdateStatus(L["Preparing Filters..."])
end

function Scan:StartFullScan()
	Scan.isScanning = "Full"
	TSM.GUI:UpdateStatus(L["Running query..."])
	Scan.isBuggedGetAll = nil
	Scan.groupItems = nil
	TSMAPI.AuctionScan:StopScan()
	TSMAPI.AuctionScan:RunQuery({name=""}, ScanCallback)
end

function Scan:StartGetAllScan()
	TSM.db.profile.lastGetAll = time()
	Scan.isScanning = "GetAll"
	Scan.isBuggedGetAll = nil
	Scan.groupItems = nil
	TSMAPI.AuctionScan:StopScan()
	Scan:GetAllScanQuery()
end

function Scan:DoneScanning()
	TSM.GUI:UpdateStatus(L["Done Scanning"], 100)
	Scan.isScanning = nil
	Scan.getAllLoaded = nil
end

function Scan:ProcessScanData(scanData)
	local data = {}
	
	for itemString, obj in pairs(scanData) do
		if TSMAPI:GetBaseItemString(itemString) == itemString then
			local itemID = obj:GetItemID()
			local quantity, minBuyout = 0, 0
			local records = {}
			for _, record in ipairs(obj.records) do
				local itemBuyout = record:GetItemBuyout()
				if itemBuyout and (itemBuyout < minBuyout or minBuyout == 0) then
					minBuyout = itemBuyout
				end
				quantity = quantity + record.count
				for i=1, record.count do
					tinsert(records, itemBuyout)
				end
			end
			data[itemID] = {records=records, minBuyout=minBuyout, quantity=quantity}
		end
	end
	
	if Scan.isScanning ~= "group" then
		TSM.db.factionrealm.lastCompleteScan = time()
	end
	TSM.Data:ProcessData(data, Scan.groupItems)
end

function Scan:ProcessImportedData(auctionData)
	local data = {}
	for itemID, auctions in pairs(auctionData) do
		local quantity, minBuyout, records = 0, 0, {}
		for _, auction in ipairs(auctions) do
			local itemBuyout, count = unpack(auction)
			if itemBuyout and (itemBuyout < minBuyout or minBuyout == 0) then
				minBuyout = itemBuyout
			end
			quantity = quantity + count
			for i=1, count do
				tinsert(records, itemBuyout)
			end
		end
		data[itemID] = {records=records, minBuyout=minBuyout, quantity=quantity}
	end
	TSM.db.factionrealm.lastCompleteScan = time()
	TSM.Data:ProcessData(data)
end