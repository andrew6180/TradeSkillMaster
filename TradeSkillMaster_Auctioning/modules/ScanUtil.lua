-- ------------------------------------------------------------------------------ --
--                           TradeSkillMaster_Auctioning                          --
--           http://www.curse.com/addons/wow/tradeskillmaster_auctioning          --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

local TSM = select(2, ...)
local Scan = TSM:NewModule("Scan", "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster_Auctioning") -- loads the localization table

Scan.auctionData = {}
Scan.skipped = {}


local function CallbackHandler(event, ...)
	if event == "QUERY_COMPLETE" then
		local filterList = ...
		local numItems = 0
		for _, v in ipairs(filterList) do
			numItems = numItems + #v.items
		end
		Scan.filterList = filterList
		Scan.numFilters = #filterList
		Scan:ScanNextFilter()
	elseif event == "QUERY_UPDATE" then
		local current, total, skipped = ...
		TSM.Manage:UpdateStatus("query", current, total)
		for _, itemString in ipairs(skipped) do
			TSM.Manage:ProcessScannedItem(itemString)
			tinsert(Scan.skipped, itemString)
		end
	elseif event == "SCAN_PAGE_UPDATE" then
		TSM.Manage:UpdateStatus("page", ...)
	elseif event == "SCAN_INTERRUPTED" then
		TSM.Manage:ScanComplete(true)
	elseif event == "SCAN_TIMEOUT" then
		tremove(Scan.filterList, 1)
		Scan:ScanNextFilter()
	elseif event == "SCAN_COMPLETE" then
		local data = ...
		for _, itemString in ipairs(Scan.filterList[1].items) do
			-- make sure we haven't already scanned this item (possible with common search terms)
			if not Scan.auctionData[itemString] then
				Scan:ProcessItem(itemString, data[itemString])
				TSM.Manage:ProcessScannedItem(itemString)
			end
		end
		tremove(Scan.filterList, 1)
		Scan:ScanNextFilter()
	end
end

function Scan:StartItemScan(itemList)
	wipe(Scan.auctionData)
	wipe(Scan.skipped)
	TSMAPI:GenerateQueries(itemList, CallbackHandler)
	TSM.Manage:UpdateStatus("query", 0, -1)
end

function Scan:ScanNextFilter()
	if #Scan.filterList == 0 then
		TSM.Manage:UpdateStatus("scan", Scan.numFilters, Scan.numFilters)
		return TSM.Manage:ScanComplete()
	end
	TSM.Manage:UpdateStatus("scan", Scan.numFilters-#Scan.filterList, Scan.numFilters)
	TSMAPI.AuctionScan:RunQuery(Scan.filterList[1], CallbackHandler, true)
end

function Scan:ProcessItem(itemString, auctionItem)
	if not itemString or not auctionItem then return end
	auctionItem:SetRecordParams({"GetItemBuyout", "GetItemDisplayedBid", "seller", "count"})
	auctionItem:PopulateCompactRecords()
	auctionItem:SetAlts(TSM.db.factionrealm.player)
	if #auctionItem.records > 0 then
		auctionItem:SetMarketValue(TSMAPI:GetItemValue(itemString, "DBMarket"))
		Scan.auctionData[itemString] = auctionItem
	end
end

function Scan:ShouldIgnoreAuction(record, operation)
	if type(operation) ~= "table" then return end
	if record.timeLeft <= operation.ignoreLowDuration then
		-- ignoring low duration
		return true
	elseif operation.matchStackSize and record.count ~= operation.stackSize then	
		-- matching stack size
		return true
	else
		local minPrice = TSM.Util:GetItemPrices(operation, record.parent:GetItemString()).minPrice
		if operation.priceReset == "ignore" and minPrice and record:GetItemBuyout() and record:GetItemBuyout() <= minPrice then	
			-- ignoring auctions below threshold
			return true
		end
	end
end

-- This gets how many auctions are posted specifically on this tier, it does not get how many of the items they up at this tier
-- but purely the number of auctions
function Scan:GetPlayerAuctionCount(itemString, findBuyout, findBid, findQuantity, operation)
	findBuyout = floor(findBuyout)
	findBid = floor(findBid)
	
	local quantity = 0
	for _, record in ipairs(Scan.auctionData[itemString].compactRecords) do
		if not Scan:ShouldIgnoreAuction(record, operation) and record:IsPlayer() then
			if record:GetItemBuyout() == findBuyout and record:GetItemDisplayedBid() == findBid and record.count == findQuantity then
				quantity = quantity + record.numAuctions
			end
		end
	end
	
	return quantity
end

-- gets the buyout / bid of the second lowest auction for this item
function Scan:GetSecondLowest(itemString, lowestBuyout, operation)
	local auctionItem = Scan.auctionData[itemString]
	if not auctionItem then return end
	
	local buyout, bid
	for _, record in ipairs(auctionItem.compactRecords) do
		if not Scan:ShouldIgnoreAuction(record, operation) then
			local recordBuyout = record:GetItemBuyout()
			if recordBuyout and (not buyout or recordBuyout < buyout) and recordBuyout > lowestBuyout then
				buyout, bid = recordBuyout, record:GetItemDisplayedBid()
			end
		end
	end
	
	return buyout, bid
end

-- Find out the lowest price for this item
function Scan:GetLowestAuction(auctionItem, operation)
	if type(auctionItem) == "string" or type(auctionItem) == "number" then -- it's an itemString
		auctionItem = Scan.auctionData[auctionItem]
	end
	if not auctionItem then return end
	
	-- Find lowest
	local buyout, bid, owner, invalidSellerEntry
	for _, record in ipairs(auctionItem.compactRecords) do
		if not Scan:ShouldIgnoreAuction(record, operation) then
			local recordBuyout = record:GetItemBuyout()
			if recordBuyout then
				local recordBid = record:GetItemDisplayedBid()
				if not buyout or recordBuyout < buyout or (recordBuyout == buyout and recordBid < bid) then
					buyout, bid, owner = recordBuyout, recordBid, record.seller
				end
			end
		end
	end
	if owner == "?" and next(TSM.db.factionrealm.whitelist) then
		invalidSellerEntry = true
	end

	-- Now that we know the lowest, find out if this price "level" is a friendly person
	-- the reason we do it like this, is so if Apple posts an item at 50g, Orange posts one at 50g
	-- but you only have Apple on your white list, it'll undercut it because Orange posted it as well
	local isWhitelist, isPlayer = true, true
	for _, record in ipairs(auctionItem.compactRecords) do
		if not Scan:ShouldIgnoreAuction(record, operation) then
			local recordBuyout = record:GetItemBuyout()
			if not record:IsPlayer() and recordBuyout and recordBuyout == buyout then
				isPlayer = nil
				if not TSM.db.factionrealm.whitelist[strlower(record.seller)] then
					isWhitelist = nil
				end
				
				-- If the lowest we found was from the player, but someone else is matching it (and they aren't on our white list)
				-- then we swap the owner to that person
				buyout, bid, owner = recordBuyout, record:GetItemDisplayedBid(), record.seller
			end
		end
	end
	if owner == "?" and next(TSM.db.factionrealm.whitelist) then
		invalidSellerEntry = true
	end

	return buyout, bid, owner, isWhitelist, isPlayer, invalidSellerEntry
end

function Scan:GetPlayerLowestBuyout(auctionItem, operation)
	if not auctionItem then return end
	
	-- Find lowest
	local buyout
	for _, record in ipairs(auctionItem.compactRecords) do
		if not Scan:ShouldIgnoreAuction(record, operation) then
			local recordBuyout = record:GetItemBuyout()
			if record:IsPlayer() and recordBuyout and (not buyout or recordBuyout < buyout) then
				buyout = recordBuyout
			end
		end
	end

	return buyout
end