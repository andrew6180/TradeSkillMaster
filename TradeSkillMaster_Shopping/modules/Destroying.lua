local TSM = select(2, ...)
local Destroying = TSM:NewModule("Destroying")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster_Shopping") -- loads the localization table

local private = {sources={}}


function Destroying:OnEnable()
	TSMAPI:CreateTimeDelay("shoppingDestroyingUpdateTargets", 0, private.UpdateTargetItems, 60) --1)
	TSM.db.global.destroyingTargetItems = TSM.db.global.destroyingTargetItems or {}
end

function private:UpdateTargetItems()
	local update
	for itemString in pairs(TSMAPI.InkConversions) do
		private.sources[itemString] = "mill"
		if not TSM.db.global.destroyingTargetItems[itemString] then
			update = true
			local name = TSMAPI:GetSafeItemInfo(itemString)
			if name then
				TSM.db.global.destroyingTargetItems[itemString] = name
			end
		end
	end
	for _, itemString in ipairs(TSMAPI:GetConversionTargetItems("mill")) do
		private.sources[itemString] = "mill"
		if not TSM.db.global.destroyingTargetItems[itemString] then
			update = true
			local name = TSMAPI:GetSafeItemInfo(itemString)
			if name then
				TSM.db.global.destroyingTargetItems[itemString] = name
			end
		end
	end
	for _, itemString in ipairs(TSMAPI:GetConversionTargetItems("prospect")) do
		private.sources[itemString] = "prospect"
		if not TSM.db.global.destroyingTargetItems[itemString] then
			update = true
			local name = TSMAPI:GetSafeItemInfo(itemString)
			if name then
				TSM.db.global.destroyingTargetItems[itemString] = name
			end
		end
	end
	for _, itemString in ipairs(TSMAPI:GetEnchantingTargetItems()) do
		private.sources[itemString] = "disenchant"
		if not TSM.db.global.destroyingTargetItems[itemString] then
			update = true
			local name = TSMAPI:GetSafeItemInfo(itemString)
			if name then
				TSM.db.global.destroyingTargetItems[itemString] = name
			end
		end
	end
	
	if not update then
		TSMAPI:CancelFrame("shoppingDestroyingUpdateTargets")
	end
end

function Destroying:StartDestroyingSearch(target, filter, isCrafting)
	if not private.sources[target] then return TSM:Printf(L["Invalid destroy target: '%s'"], target) end
	
	TSM.isCrafting = isCrafting
	Destroying.maxQuantity = filter.maxQuantity
	filter.maxPrice = nil
	if private.sources[target] == "mill" then
		private:TryStarting(private.StartMillingSearch, target, filter)
	elseif private.sources[target] == "prospect" then
		private:TryStarting(private.StartProspectingSearch, target, filter)
	elseif private.sources[target] == "disenchant" then
		private:TryStarting(private.StartDisenchantingSearch, target, filter)
	end
	TSMAPI:FireEvent("SHOPPING:SEARCH:STARTDESTROYSCAN", {target=target, filter=filter})
end

function private:TryStarting(func, target, filter, attempt)
	attempt = attempt or 0
	if attempt <= 10 and not func(target, filter, attempt == 10) then
		TSMAPI:CreateTimeDelay("destroySearchTryStart", 0.1, function() private:TryStarting(func, target, filter, attempt+1) end)
	end
end

function private:AddItemQuery(itemList, filter, itemString)
	local name = TSMAPI:GetSafeItemInfo(itemString)
	if name then
		local query = CopyTable(filter)
		query.name = name
		tinsert(itemList, query)
		return true
	end
end

function private.StartMillingSearch(target, filter, lastAttempt)
	local matItemString = target
	local inkItemString, pigmentItemString
	if TSMAPI.InkConversions[target] then
		inkItemString = target
		pigmentItemString = TSMAPI.InkConversions[target].pigment
	else
		for itemString, data in pairs(TSMAPI.InkConversions) do
			if target == data.pigment then
				inkItemString = itemString
				pigmentItemString = target
				break
			end
		end
		if not inkItemString then return TSM:Printf(L["Unknown milling search target: '%s'"], target) end
	end
	
	private.evenFilter = {}
	private.conversions = {}
	private.conversions[inkItemString] = 1
	private.conversions[pigmentItemString] = 1 / TSMAPI.InkConversions[inkItemString].pigmentPerInk
	local itemList = {}
	
	-- add ink and pigment
	if not private:AddItemQuery(itemList, filter, inkItemString) and not lastAttempt then return end
	if not private:AddItemQuery(itemList, filter, pigmentItemString) and not lastAttempt then return end
	
	-- add primary herbs
	for itemString, data in pairs(TSMAPI:GetItemConversions(pigmentItemString)) do
		if not private:AddItemQuery(itemList, filter, itemString) and not lastAttempt then return end
		private.evenFilter[itemString] = filter.evenOnly
		private.conversions[itemString] = data.rate / TSMAPI.InkConversions[inkItemString].pigmentPerInk
	end
	
	-- deal with vendor trades
	local otherInks = TSMAPI.Conversions[inkItemString]
	for otherInk, otherInkData in pairs(otherInks or {}) do
		if not TSMAPI.Conversions[otherInk] and otherInkData.source == "vendortrade" and TSMAPI.InkConversions[otherInk] then
			local vendorTradeRate = otherInkData.rate
			for itemString, millData in pairs(TSMAPI:GetItemConversions(TSMAPI.InkConversions[otherInk].pigment)) do
				if not private:AddItemQuery(itemList, filter, itemString) and not lastAttempt then return end
				private.evenFilter[itemString] = filter.evenOnly
				private.conversions[itemString] = vendorTradeRate * millData.rate / TSMAPI.InkConversions[inkItemString].pigmentPerInk
			end
			if not private:AddItemQuery(itemList, filter, otherInk) and not lastAttempt then return end
			if not private:AddItemQuery(itemList, filter, TSMAPI.InkConversions[otherInk].pigment) and not lastAttempt then return end
			private.conversions[otherInk] = vendorTradeRate
			private.conversions[TSMAPI.InkConversions[otherInk].pigment] = vendorTradeRate / TSMAPI.InkConversions[otherInk].pigmentPerInk
		end
	end
	
	private.mode = "mill"
	private.target = inkItemString
	if TSM.isCrafting then
		local func = TSMAPI:ParseCustomPrice("matprice")
		local price = func and func(matItemString) or nil
		private.targetMarketValue = price
		TSM.Util:ShowSearchFrame(true, L["% Mat Price"])
	else
		private.targetMarketValue = TSM:GetMaxPrice(TSM.db.global.marketValueSource, inkItemString)
		TSM.Util:ShowSearchFrame(true, L["% Target Value"])
	end
	TSM.Search:SetSearchBarDisabled(true)
	TSM.Util:StartFilterScan(itemList, private.ScanCallback)
	return true
end

function private.StartProspectingSearch(target, filter, lastAttempt)
	local itemList = {}
	private.evenFilter = {}
	if not private:AddItemQuery(itemList, filter, target) and not lastAttempt then return end
	for itemString in pairs(TSMAPI:GetItemConversions(target)) do
		if not private:AddItemQuery(itemList, filter, itemString) and not lastAttempt then return end
		private.evenFilter[itemString] = filter.evenOnly
	end

	private.mode = "prospect"
	private.target = target
	if TSM.isCrafting then
		local func = TSMAPI:ParseCustomPrice("matprice")
		local price = func and func(target) or nil
		private.targetMarketValue = price
		TSM.Util:ShowSearchFrame(true, L["% Max Price"])
	else
		private.targetMarketValue = TSM:GetMaxPrice(TSM.db.global.marketValueSource, target)
		TSM.Util:ShowSearchFrame(true, L["% Target Value"])
	end
	TSM.Search:SetSearchBarDisabled(true)
	TSM.Util:StartFilterScan(itemList, private.ScanCallback)
	return true
end

function private.StartDisenchantingSearch(target, filter, lastAttempt)
	local disenchantData = TSMAPI:GetDisenchantData(target)
	if not disenchantData then return end
	
	local queries = {}
	local query = TSMAPI:GetAuctionQueryInfo(target)
	if not query and not lastAttempt then return end
	if query then
		tinsert(queries, query)
	end
	for itemType, rarityData in pairs(disenchantData.itemTypes) do
		local class = 0
		if itemType == "Weapon" then
			class = 1
		elseif itemType == "Armor" then
			class = 2
		end
		for rarity, data in pairs(rarityData) do
			local minILevel = data[1].minItemLevel or 0
			local maxILevel = data[#data].maxItemLevel or 0
			local query = {name="", class=class, subClass=0, minLevel=disenchantData.minLevel, maxLevel=disenchantData.maxLevel, minILevel=minILevel, maxILevel=maxILevel, quality=rarity}
			tinsert(queries, query)
		end
	end
	
	for itemString, data in pairs(TSMAPI.Conversions[target] or {}) do
		local query = TSMAPI:GetAuctionQueryInfo(itemString)
		if not query and not lastAttempt then return end
		if query then
			tinsert(queries, query)
		end
	end
	
	private.mode = "disenchant"
	private.target = target
	if TSM.isCrafting then
		local func = TSMAPI:ParseCustomPrice("matprice")
		local price = func and func(target) or nil
		private.targetMarketValue = price
		TSM.Util:ShowSearchFrame(true, L["% Max Price"])
	else
		private.targetMarketValue = TSM:GetMaxPrice(TSM.db.global.marketValueSource, target)
		TSM.Util:ShowSearchFrame(true, L["% Target Value"])
	end
	TSM.Search:SetSearchBarDisabled(true)
	TSM.Util:StartFilterScan(queries, private.ScanCallback)
	return true
end


function private.ScanCallback(event, ...)
	if event == "filter" then
		return
	elseif event == "process" then
		local itemString, auctionItem = ...
		local rate, shouldEvenFilter
		if private.mode == "mill" then
			rate = private.conversions[itemString]
			shouldEvenFilter = private.evenFilter[itemString]
		elseif private.mode == "disenchant" then
			if TSMAPI.Conversions[private.target] and TSMAPI.Conversions[private.target][itemString] then
				rate = TSMAPI.Conversions[private.target][itemString].rate
			else
				rate = TSMAPI:GetEnchantingConversionNum(private.target, itemString)
			end
		elseif private.mode == "prospect" then
			shouldEvenFilter = private.evenFilter[itemString]
			local conversions = TSMAPI:GetItemConversions(private.target)
			rate = conversions and conversions[itemString] and conversions[itemString].rate
			rate = rate and (rate / 5)
		end
		if itemString == private.target then
			auctionItem.destroyingNum = 1
			auctionItem:SetMarketValue(private.targetMarketValue)
		else
			if not rate then return end
			if shouldEvenFilter then
				auctionItem:FilterRecords(function(record) return record.count%5 ~= 0 end)
			end
			auctionItem.destroyingNum = 1/rate
			if private.targetMarketValue then
				auctionItem:SetMarketValue(private.targetMarketValue*rate)
			end
		end
		return auctionItem
	elseif event == "done" then
		TSM.Search:SetSearchBarDisabled(false)
	end
end