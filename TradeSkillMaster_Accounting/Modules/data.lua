-- ------------------------------------------------------------------------------ --
--                           TradeSkillMaster_Accounting                          --
--           http://www.curse.com/addons/wow/tradeskillmaster_accounting          --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- create a local reference to the TradeSkillMaster_Accounting table and register a new module
local TSM = select(2, ...)
local Data = TSM:NewModule("Data", "AceEvent-3.0", "AceHook-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster_Accounting") -- loads the localization table
local LibParse = LibStub("LibParse")
local private = {}
TSMAPI:RegisterForTracing(private, "TSM_Accounting.Data_private")

local SECONDS_PER_DAY = 24 * 60 * 60
local TIME_BUCKET = 300 -- group sales/buys within 5 minutes together
local REPAIR_COST, REPAIR_MONEY, COULD_REPAIR, CAN_REPAIR = 0, 0, false, ""
local expired = AUCTION_EXPIRED_MAIL_SUBJECT:gsub("%%s", "")
local cancelled = AUCTION_REMOVED_MAIL_SUBJECT:gsub("%%s", "")
local outbid = AUCTION_OUTBID_MAIL_SUBJECT:gsub("%%s", "(.+)")

--[[
****************************** In-Memory Data Layout ***************************
TSM = {
	items = {
		[itemString] = {
			sales = {
				-- Possible keys: Auction, COD, Trade, Vendor
				{key="...", stackSize=#, quantity=#, time=#, copper=#, player="...", otherPlayer="..."},
				...
			},
			buys = {
				-- Possible keys: Auction, COD, Trade, Vendor
				{key="...", stackSize=#, quantity=#, time=#, copper=#, player="...", otherPlayer="..."},
				...
			},
			auctions = {
				-- Possible keys: Cancel, Expire
				{key="...", stackSize=#, quantity=#, time=#, player="..."},
				...
			},
		},
	},
	money = {
		income = {
			-- Possible keys: Transfer
			{key="...", copper=#, time=#, player="...", otherPlayer="..."},
		},
		expense = {
			-- Possible keys: Postage, Repair, Transfer
			{key="...", copper=#, time=#, player="...", otherPlayer="..."},
		},
	},
}
]]

function private:CleanRecord(record)
	record.itemName = nil
	record.itemString = nil
	record.time = floor(record.time)
	record.type = nil
	record.otherPlayer = record.buyer or record.seller or record.destination or record.source or "?"
	record.copper = record.price or record.amount
	record.price = nil
	record.amount = nil
	record.buyer = nil
	record.seller = nil
	record.destination = nil
	record.source = nil
end
function private:LoadItemRecords(csvData, recordType, key)
	local saveTimeIndex = 1
	local saveTimes
	if recordType == "sales" then
		saveTimes = TSMAPI:SafeStrSplit(TSM.db.factionrealm.saveTimeSales, ",")
	elseif recordType == "buys" then
		saveTimes = TSMAPI:SafeStrSplit(TSM.db.factionrealm.saveTimeBuys, ",")
	end
	for _, record in ipairs(select(2, LibParse:CSVDecode(csvData)) or {}) do
		local itemString = record.itemString
		if itemString and type(record.time) == "number" then
			local itemName = (record.itemName ~= "?") and record.itemName or nil
			itemName = itemName or TSMAPI:GetSafeItemInfo(itemString) or TSM:GetItemName(itemString)
			record.key = key or record.source or "Auction"
			private:CleanRecord(record)
			if saveTimes and record.key == "Auction" then
				record.saveTime = tonumber(saveTimes[saveTimeIndex])
				saveTimeIndex = saveTimeIndex + 1
			end
			TSM.items[itemString] = TSM.items[itemString] or {sales={}, buys={}, auctions={}}
			TSM.items[itemString].name = TSM.items[itemString].name or itemName
			tinsert(TSM.items[itemString][recordType], record)
			TSM.cache[itemString] = {}
		end
	end
	for itemString in ipairs(TSM.items) do
		sort(TSM.items[itemString][recordType], function(a, b) return (a.time or 0) < (b.time or 0) end)
	end
end
function private:LoadMoneyRecords(csvData, recordType)
	TSM.money[recordType] = {}
	local typeTranslation = {}
	if recordType == "income" then
		typeTranslation = {["Money Transfer"]="Transfer"}
	elseif recordType == "expense" then
		typeTranslation = {["Money Transfer"]="Transfer", ["Postage"]="Postage", ["Repair Bill"]="Repair"}
	end
	for _, record in ipairs(select(2, LibParse:CSVDecode(csvData)) or {}) do
		record.key = typeTranslation[record.type] or "Transfer"
		if record.key and type(record.time) == "number" then
			private:CleanRecord(record)
			tinsert(TSM.money[recordType], record)
		end
	end
end
function Data:Load()
	-- Decode item records
	TSM.items = {}
	TSM.cache = {}
	private:LoadItemRecords(TSM.db.factionrealm.csvSales, "sales")
	private:LoadItemRecords(TSM.db.factionrealm.csvBuys, "buys")
	private:LoadItemRecords(TSM.db.factionrealm.csvCancelled, "auctions", "Cancel")
	private:LoadItemRecords(TSM.db.factionrealm.csvExpired, "auctions", "Expire")
	
	-- Decode money records
	TSM.money = {}
	private:LoadMoneyRecords(TSM.db.factionrealm.csvIncome, "income")
	private:LoadMoneyRecords(TSM.db.factionrealm.csvExpense, "expense")
	
	-- Decode the gold log
	for player, data in pairs(TSM.db.factionrealm.goldLog) do
		if type(data) == "string" then
			TSM.db.factionrealm.goldLog[player] = select(2, LibParse:CSVDecode(data))
		end
	end
	Data:SetupDataTracking()
	Data:PopulateDataCaches()
end

function Data:SetupDataTracking()
	Data:RawHook("TakeInboxItem", function(...) Data:ScanCollectedMail("TakeInboxItem", 1, ...) end, true)
	Data:RawHook("TakeInboxMoney", function(...) Data:ScanCollectedMail("TakeInboxMoney", 1, ...) end, true)
	Data:RawHook("AutoLootMailItem", function(...) Data:ScanCollectedMail("AutoLootMailItem", 1, ...) end, true)
	Data:RawHook("SendMail", function(...) Data:CheckSendMail("SendMail", ...) end, true)
	Data:SecureHook("UseContainerItem", function(...) Data:CheckMerchantSale(...) end)
	Data:SecureHook("BuyMerchantItem", function(...) Data:BuyMerchantItem(...) end)
	Data:SecureHook("BuybackItem", function(...) Data:BuybackMerchantItem(...) end)
	Data:RegisterEvent("AUCTION_OWNED_LIST_UPDATE", "ScanAuctionItems")
	Data:RegisterEvent("MERCHANT_SHOW", "SetupRepairCost")
	Data:RegisterEvent("MERCHANT_UPDATE", "ResetRepairMoney")
	Data:RegisterEvent("UPDATE_INVENTORY_DURABILITY", "AddRepairCosts")
	Data:RegisterEvent("MAIL_SHOW")
	Data:RegisterEvent("MAIL_CLOSED")
	TSMAPI:RegisterForBagChange(function(...) Data:ScanBagItems(...) end)
	TSMAPI:CreateFunctionRepeat("accountingGoldTracking", Data.LogGold)
end

function private:RequestSellerInfo()
	local isDone = true
	for i=1, GetInboxNumItems() do
		local invoiceType, _, seller = GetInboxInvoiceInfo(i)
		if invoiceType and seller == "" then
			isDone = false
		end
	end
	if isDone and GetInboxNumItems() > 0 then
		TSMAPI:CancelFrame("accountingGetSellers")
	end
end
function Data:MAIL_SHOW()
	TSMAPI:CreateTimeDelay("accountingGetSellers", 0.1, private.RequestSellerInfo, 0.1)
end
function Data:MAIL_CLOSED()
	TSMAPI:CancelFrame("accountingGetSellers")
end


function private:CanCombineRecords(recordA, recordB)
	local keys = {"key", "copper", "stackSize", "player", "otherPlayer"}
	for _, key in ipairs(keys) do
		if recordA[key] ~= recordB[key] then
			return false
		end
	end
	return abs(recordA.time-recordB.time) < TIME_BUCKET
end

function private:InsertItemRecord(itemString, dataType, newRecord)
	newRecord.time = floor(newRecord.time or time())
	newRecord.player = UnitName("player")
	TSM.items[itemString] = TSM.items[itemString] or {sales={}, buys={}, auctions={}}
	for _, record in ipairs(TSM.items[itemString][dataType]) do
		if private:CanCombineRecords(record, newRecord) then
			-- combine with existing record
			record.quantity = record.quantity + newRecord.stackSize -- this is total quantity, not number of stacks
			return
		end
	end
	tinsert(TSM.items[itemString][dataType], newRecord)
	TSM.cache[itemString] = {}
	-- keep the records sorted by time
	sort(TSM.items[itemString][dataType], function(a, b) return (a.time or 0) < (b.time or 0) end)
end
function Data:InsertItemSaleRecord(itemString, key, stackSize, copper, buyer, timeStamp)
	if not (itemString and key and stackSize and copper and buyer and copper > 0) then return end
	if key ~= "Auction" and key ~= "COD" and key ~= "Trade" and key ~= "Vendor" then return end
	private:InsertItemRecord(itemString, "sales", {key=key, stackSize=stackSize, quantity=stackSize, copper=copper, otherPlayer=buyer, time=timeStamp})
end
function Data:InsertItemBuyRecord(itemString, key, stackSize, copper, seller, timeStamp)
	if not (itemString and key and stackSize and copper and seller and copper > 0) then return end
	if key ~= "Auction" and key ~= "COD" and key ~= "Trade" and key ~= "Vendor" then return end
	private:InsertItemRecord(itemString, "buys", {key=key, stackSize=stackSize, quantity=stackSize, copper=copper, otherPlayer=seller, time=timeStamp})
end
function Data:InsertItemAuctionRecord(itemString, key, stackSize, timeStamp)
	if not (itemString and key and stackSize) then return end
	if key ~= "Cancel" and key ~= "Expire" then return end
	private:InsertItemRecord(itemString, "auctions", {key=key, stackSize=stackSize, quantity=stackSize, time=timeStamp})
end

function private:InsertMoneyRecord(dataType, newRecord)
	newRecord.time = floor(time())
	newRecord.player = UnitName("player")
	for _, record in ipairs(TSM.money[dataType]) do
		if private:CanCombineRecords(record, newRecord) then
			-- combine with existing record
			record.copper = record.copper + newRecord.copper
			return
		end
	end
	tinsert(TSM.money[dataType], newRecord)
end
function Data:InsertMoneyIncomeRecord(key, copper, destination, timeStamp)
	if not (key and copper and destination and copper > 0) then return end
	if key ~= "Transfer" then return end
	private:InsertMoneyRecord("income", {key=key, copper=copper, otherPlayer=destination, time=timeStamp})
end
function Data:InsertMoneyExpenseRecord(key, copper, destination, timeStamp)
	if not (key and copper and destination and copper > 0) then return end
	if key ~= "Postage" and key ~= "Repair" and key ~= "Transfer" then return end
	private:InsertMoneyRecord("expense", {key=key, copper=copper, otherPlayer=destination, time=timeStamp})
end


function Data:CheckMerchantSale(bag, slot, onSelf)
	if MerchantFrame:IsShown() and not onSelf then
		local itemString = TSMAPI:GetItemString(GetContainerItemLink(bag, slot))
		local quantity = select(2, GetContainerItemInfo(bag, slot))
		local copper = select(11, TSMAPI:GetSafeItemInfo(itemString))
		Data:InsertItemSaleRecord(itemString, "Vendor", quantity, copper, "Merchant")
	end
end

function Data:BuyMerchantItem(index, quantity)
	local itemName, _, price, batchQuantity = GetMerchantItemInfo(index)
	if not price or price <= 0 then return end
	if not quantity then
		quantity = batchQuantity
	end
	local link = GetMerchantItemLink(index);
	local itemString = TSM.db.global.itemStrings[itemName] or TSMAPI:GetItemString(link)
	local copper = floor(price / batchQuantity + 0.5)
	Data:InsertItemBuyRecord(itemString, "Vendor", quantity, copper, "Merchant")
end

function Data:BuybackMerchantItem(index)
	local itemName, _, price, quantity = GetBuybackItemInfo(index)
	local link = GetMerchantItemLink(index)
	local itemString = TSM.db.global.itemStrings[itemName] or TSMAPI:GetItemString(link)
	local copper = floor(price / quantity + 0.5)
	Data:InsertItemBuyRecord(itemString, "Vendor", quantity, copper, "Merchant")
end

function Data:AddRepairCosts()
	if (COULD_REPAIR and REPAIR_COST > 0) then
		local cash = GetMoney()
		if (REPAIR_MONEY > cash) then
			-- this is probably a repair bill
			local cost = REPAIR_MONEY - cash
			Data:InsertMoneyExpenseRecord("Repair", cost, "Merchant")
			-- reset money as this might have been a single item repair
			REPAIR_MONEY = cash
			-- reset the repair cost for the next repair
			REPAIR_COST, CAN_REPAIR = GetRepairAllCost()
		end
	end
end

-- scans the mail that the player just attempted to send (Pre-Hook) to see if COD
function Data:CheckSendMail(oFunc, destination, currentSubject, bodyText)
	local codAmount = GetSendMailCOD()
	local moneyAmount = GetSendMailMoney()
	local mailCost = GetSendMailPrice()
	local subject
	local total = 0
	local ignore = false

	if codAmount ~= 0 then
		for i = 1, 12 do
			local itemName, _, count, _ = GetSendMailItem(i)
			if itemName and count then
				if not subject then
					subject = itemName
				end

				if subject == itemName then
					total = total + count
				else
					ignore = true
				end
			end
		end
	else
		ignore = true
	end

	if moneyAmount > 0 then -- add a record for the money transfer
		Data:InsertMoneyExpenseRecord("Transfer", moneyAmount, destination)
		Data:InsertMoneyExpenseRecord("Postage", mailCost - moneyAmount, destination)
	else
		-- add a record for the mail cost
		Data:InsertMoneyExpenseRecord("Postage", mailCost, destination)
	end

	if not ignore then
		Data.hooks[oFunc](destination, subject .. " (" .. total .. ") TSM", bodyText)
	else
		Data.hooks[oFunc](destination, currentSubject, bodyText)
	end
end

function private:CanLootMailIndex(index)
	local hasItem = select(8, GetInboxHeaderInfo(index))
	if not hasItem or hasItem == 0 then return true end
	for j = 1, ATTACHMENTS_MAX_RECEIVE do
		local itemString = TSMAPI:GetItemString(GetInboxItemLink(index, j))
		local quantity = select(3, GetInboxItem(index, j))
		local space = 0
		if itemString then
			for bag = 0, NUM_BAG_SLOTS do
				if TSMAPI:ItemWillGoInBag(itemString, bag) then
					for slot = 1, GetContainerNumSlots(bag) do
						local iString = TSMAPI:GetItemString(GetContainerItemLink(bag, slot))
						if iString == itemString then
							local stackSize = select(2, GetContainerItemInfo(bag, slot))
							local maxStackSize = select(8, TSMAPI:GetSafeItemInfo(itemString))
							if (maxStackSize - stackSize) >= quantity then
								return true
							end
						elseif not iString then
							return true
						end
					end
				end
			end
		end
	end
end

-- scans the mail that the player just attempted to collected (Pre-Hook)
function Data:ScanCollectedMail(oFunc, attempt, index, subIndex)
	local invoiceType, itemName, buyer, bid, buyout, deposit, ahcut = GetInboxInvoiceInfo(index)
	--local invoiceType, itemName, buyer, bid, _, _, ahcut, _, _, _, quantity = GetInboxInvoiceInfo(index)
	local sender, subject, money, codAmount, _, itemCount = select(3, GetInboxHeaderInfo(index))
	if not subject then return end
	local success = true
	if attempt > 2 then
		if buyer == "" then
			buyer = "?"
		elseif sender == "" then
			sender = "?"
		end
	end

	local quantity = 0
	for j = 1, ATTACHMENTS_MAX_RECEIVE do
		quantity = select(3, GetInboxItem(index, j))
	end
	if quantity == 0 then
		quantity = 1
	end

	if invoiceType == "seller" and buyer and buyer ~= "" then -- AH Sales
		local daysLeft = select(7, GetInboxHeaderInfo(index))
		local saleTime = (time() + (daysLeft - 30) * SECONDS_PER_DAY)
		local link = select(2, TSMAPI:GetSafeItemInfo(itemName))
		local itemString = TSM.db.global.itemStrings[itemName] or TSMAPI:GetItemString(link)
		if itemString and private:CanLootMailIndex(index) then
			local copper = floor((bid - ahcut) / quantity + 0.5)
			Data:InsertItemSaleRecord(itemString, "Auction", quantity, copper, buyer, saleTime)
		end
	elseif invoiceType == "buyer" and buyer and buyer ~= "" then -- AH Buys
		local link = GetInboxItemLink(index, subIndex or 1)
		local itemString = TSMAPI:GetItemString(link)
		if itemString and private:CanLootMailIndex(index) then
			--might as well grab the name for future lookups
			local name = TSMAPI:GetSafeItemInfo(link)
			TSM.db.global.itemStrings[name] = itemString

			local copper = floor(bid / quantity + 0.5)
			local daysLeft = select(7, GetInboxHeaderInfo(index))
			local buyTime = (time() + (daysLeft - 30) * SECONDS_PER_DAY)
			Data:InsertItemBuyRecord(itemString, "Auction", quantity, copper, buyer, buyTime)
		end
	elseif codAmount > 0 then -- COD Buys (only if all attachments are same item)
		local link = GetInboxItemLink(index, subIndex or 1)
		local itemString = TSMAPI:GetItemString(link)
		if itemString then
			--might as well grab the name for future lookups
			local name = TSMAPI:GetSafeItemInfo(link)
			TSM.db.global.itemStrings[name] = itemString

			local total = 0
			local stacks = 0
			local ignore = false
			for i = 1, ATTACHMENTS_MAX_RECEIVE do
				local nameCheck, _, count, _, _ = GetInboxItem(index, i)

				if nameCheck and count then
					if nameCheck == name then
						total = total + count
						stacks = stacks + 1
					else
						ignore = true
					end
				end
			end

			if total ~= 0 and not ignore and private:CanLootMailIndex(index) then
				local copper = floor(codAmount / total + 0.5)
				local daysLeft = select(7, GetInboxHeaderInfo(index))
				local buyTime = (time() + (daysLeft - 3) * SECONDS_PER_DAY)
				local maxStack = select(8, TSMAPI:GetSafeItemInfo(link))
				for i = 1, stacks do
					local stackSize = (total >= maxStack) and maxStack or total
					Data:InsertItemBuyRecord(itemString, "COD", stackSize, copper, sender, buyTime)
					total = total - stackSize
					if total <= 0 then break end
				end
			end
		end
	elseif money > 0 and invoiceType ~= "seller" and not strfind(subject, outbid) then
		local str
		if GetLocale() == "deDE" then
			str = gsub(subject, gsub(COD_PAYMENT, TSMAPI:StrEscape("%1$s"), ""), "")
		else
			str = gsub(subject, gsub(COD_PAYMENT, TSMAPI:StrEscape("%s"), ""), "")
		end
		local daysLeft = select(7, GetInboxHeaderInfo(index))
		local saleTime = (time() + (daysLeft - 31) * SECONDS_PER_DAY)
		if private:CanLootMailIndex(index) then
			if str and strfind(str, "TSM$") then -- payment for a COD the player sent
				local codName = strmatch(str, "([^%(]+)"):trim()
				local qty = strmatch(str, "%(([0-9]+)%)")
				qty = tonumber(qty)
				local itemString = TSM.db.global.itemStrings[codName]
				if itemString then
					local copper = floor(money / qty + 0.5)
					local maxStack = select(8, TSMAPI:GetSafeItemInfo(itemString)) or 1
					local stacks = ceil(qty / maxStack)

					for i = 1, stacks do
						local stackSize = (qty >= maxStack) and maxStack or qty
						Data:InsertItemSaleRecord(itemString, "COD", stackSize, copper, sender, saleTime)
						qty = qty - stackSize
						if qty <= 0 then break end
					end
				end
			else -- record a money transfer
				Data:InsertMoneyIncomeRecord("Transfer", money, sender, saleTime)
			end
		end
	elseif strfind(subject, expired) then -- expired auction
		local daysLeft = select(7, GetInboxHeaderInfo(index))
		local expiredTime = (time() + (daysLeft - 30) * SECONDS_PER_DAY)
		local link = GetInboxItemLink(index, subIndex or 1)
		local qty = select(3, GetInboxItem(index, subIndex or 1))
		local itemString = TSMAPI:GetItemString(link)
		if private:CanLootMailIndex(index) then
			Data:InsertItemAuctionRecord(itemString, "Expire", qty, expiredTime)
		end
	elseif strfind(subject, cancelled) then -- cancelled auction
		local daysLeft = select(7, GetInboxHeaderInfo(index))
		local cancelledTime = (time() + (daysLeft - 30) * SECONDS_PER_DAY)
		local link = GetInboxItemLink(index, subIndex or 1)
		local qty = select(3, GetInboxItem(index, subIndex or 1))
		local itemString = TSMAPI:GetItemString(link)
		if private:CanLootMailIndex(index) then
			Data:InsertItemAuctionRecord(itemString, "Cancel", qty, cancelledTime)
		end
	else
		success = false
	end

	if success then
		Data.hooks[oFunc](index, subIndex)
	elseif (not select(2, GetInboxHeaderInfo(index)) or (invoiceType and (not buyer or buyer == ""))) and attempt <= 5 then
		TSMAPI:CreateTimeDelay("accountingHookDelay", 0.2, function() Data:ScanCollectedMail(oFunc, attempt + 1, index, subIndex) end)
	elseif attempt > 5 then
		Data.hooks[oFunc](index, subIndex)
	else
		Data.hooks[oFunc](index, subIndex)
	end
end

-- scan the auctions the user has on the AH for name -> itemString lookup table
function Data:ScanAuctionItems()
	for i = 1, GetNumAuctionItems("owner") do
		local name = GetAuctionItemInfo("owner", i)
		if name then
			local itemString = TSMAPI:GetItemString(GetAuctionItemLink("owner", i))
			TSM.db.global.itemStrings[name] = itemString
		end
	end
end

-- scans the bags to help build the name -> itemString lookup table
function Data:ScanBagItems(state)
	for itemString in pairs(state) do
		local name = TSMAPI:GetSafeItemInfo(itemString)
		if name then
			TSM.db.global.itemStrings[name] = itemString
		end
	end
end




-- ************************************************ --
--				GUI Helper Functions							 --
-- ************************************************ --

-- returns a formatted time in the format that the user has selected
function private:GetFormattedTime(rTime)
	if TSM.db.factionrealm.timeFormat == "ago" then
		return format(L["%s ago"], SecondsToTime(time() - rTime) or "?")
	elseif TSM.db.factionrealm.timeFormat == "usdate" then
		return date("%m/%d/%y %H:%M", rTime)
	elseif TSM.db.factionrealm.timeFormat == "eudate" then
		return date("%d/%m/%y %H:%M", rTime)
	elseif TSM.db.factionrealm.timeFormat == "aidate" then
		return date("%y/%m/%d %H:%M", rTime)
	end
end

function private:IsItemFiltered(itemString, filters)
	local name, _, rarity = TSMAPI:GetSafeItemInfo(itemString)
	name = name or TSM.items[itemString].name
	rarity = rarity or 0
	if not name then return true end
	
	if filters.name and not strfind(strlower(name), strlower(filters.name)) then
		return true
	end
	
	if filters.rarity and rarity ~= filters.rarity then
		return true
	end
	
	if not TSM.db.factionrealm.displayGreys and rarity == 0 then
		return true
	end
	
	if filters.group then
		local groupPath = TSMAPI:GetGroupPath(itemString)
		if not groupPath or not strfind(groupPath, "^"..TSMAPI:StrEscape(filters.group)) then
			return true
		end
	end
end

function private:IsRecordFiltered(record, filters)
	if filters.player and record.player ~= filters.player then
		return true
	end
	if filters.otherPlayer and record.otherPlayer ~= filters.otherPlayer then
		return true
	end
	if not TSM.db.factionrealm.displayTransfers and record.key == "Transfer" then
		return true
	end
	if filters.time and floor(record.time/SECONDS_PER_DAY) < (floor(time()/SECONDS_PER_DAY) - filters.time) then
		return true
	end
	if not record.key or (filters.key and record.key ~= filters.key) then
		return true
	end
end

function private:GetItemSTData(dataType, filters)
	local stData = {}
	for itemString, data in pairs(TSM.items) do
		if #data[dataType] > 0 and not private:IsItemFiltered(itemString, filters) then
			for _, record in ipairs(data[dataType]) do
				if not private:IsRecordFiltered(record, filters) then
					local row = {
						cols = {
							{
								value = select(2, TSMAPI:GetSafeItemInfo(itemString)) or TSM.items[itemString].name,
								sortArg = TSM.items[itemString].name or itemString,
							},
							{
								value = record.player,
								sortArg = record.player,
							},
							{
								value = record.key,
								sortArg = record.key,
							},
							{
								value = record.stackSize,
								sortArg = record.stackSize,
							},
							{
								value = floor(record.quantity / record.stackSize),
								sortArg = floor(record.quantity / record.stackSize),
							},
							{
								value = TSMAPI:FormatTextMoney(record.copper),
								sortArg = record.copper,
							},
							{
								value = TSMAPI:FormatTextMoney(record.copper*record.quantity),
								sortArg = record.copper*record.quantity,
							},
							{
								value = private:GetFormattedTime(record.time),
								sortArg = record.time,
							},
						},
						itemString = itemString,
						record = record,
					}
					tinsert(stData, row)
				end
			end
		end
	end
	return stData
end
function Data.GetSaleSTData(filters)
	return private:GetItemSTData("sales", filters)
end
function Data.GetBuySTData(filters)
	return private:GetItemSTData("buys", filters)
end

function private:GetItemSummaryData(filters, includeProfit)
	local itemData = {}
	
	for itemString, data in pairs(TSM.items) do
		if not private:IsItemFiltered(itemString, filters) then
			local sellTotal, sellNum = 0, 0
			for _, record in ipairs(data.sales) do
				if not private:IsRecordFiltered(record, filters) then
					sellTotal = sellTotal + record.copper * record.quantity
					sellNum = sellNum + record.quantity
				end
			end
			local avgSell = TSM:Round(sellTotal / sellNum) or 0

			local buyTotal, buyNum = 0, 0
			for _, record in ipairs(data.buys) do
				if not private:IsRecordFiltered(record, filters) then
					buyTotal = buyTotal + record.copper * record.quantity
					buyNum = buyNum + record.quantity
				end
			end
			local avgBuy = TSM:Round(buyTotal / buyNum) or 0

			local isValidItem
			local profit, profitText
			if includeProfit and buyNum > 0 and sellNum > 0 then
				profit = avgSell - avgBuy
				local profitPercent = TSM:Round(100 * profit / avgBuy)
				local color = profit > 0 and "|cff00ff00" or "|cffff0000"
				profitText = TSMAPI:FormatTextMoney(profit, color) .. " (" .. color .. profitPercent .. "%|r)"
				isValidItem = true
			elseif not includeProfit then
				isValidItem = (buyNum > 0 or sellNum > 0)
			end

			if isValidItem then
				itemData[itemString] = {buyNum=buyNum, sellNum=sellNum, profit=profit, profitText=profitText}
				if TSM.db.factionrealm.priceFormat == "total" then
					itemData[itemString].avgSell = sellNum > 0 and sellTotal or 0
					itemData[itemString].avgBuy = buyNum > 0 and buyTotal or 0
				else
					itemData[itemString].avgSell = sellNum > 0 and avgSell or 0
					itemData[itemString].avgBuy = buyNum > 0 and avgBuy or 0
				end
			end
		end
	end
	return itemData
end
function Data.GetResaleSTData(filters)
	local resaleItemData = private:GetItemSummaryData(filters, true)
	local stData = {}
	for itemString, data in pairs(resaleItemData) do
		local name = TSM.items[itemString].name
		local row = {
			cols = {
				{
					value = select(2, TSMAPI:GetSafeItemInfo(itemString)) or TSM.items[itemString].name,
					sortArg = TSM.items[itemString].name or itemString,
				},
				{
					value = data.sellNum,
					sortArg = data.sellNum,
				},
				{
					value = TSMAPI:FormatTextMoney(data.avgSell),
					sortArg = data.avgSell,
				},
				{
					value = data.buyNum,
					sortArg = data.buyNum,
				},
				{
					value = TSMAPI:FormatTextMoney(data.avgBuy),
					sortArg = data.avgBuy,
				},
				{
					value = data.profitText,
					sortArg = data.profit,
				},
			},
			itemString = itemString,
			totalNum = data.sellNum + data.buyNum,
		}
		tinsert(stData, row)
	end

	return stData
end
function Data.GetItemSummarySTData(filters)
	local itemData = private:GetItemSummaryData(filters, false)
	local stData = {}
	for itemString, data in pairs(itemData) do
		local name = TSM.items[itemString].name
		local marketValue = TSMAPI:GetItemValue(itemString, TSM.db.factionrealm.mvSource)
		local row = {
			cols = {
				{
					value = select(2, TSMAPI:GetSafeItemInfo(itemString)) or name,
					sortArg = name or itemString,
				},
				{
					value = TSMAPI:FormatTextMoney(marketValue) or "|cff999999---|r",
					sortArg = marketValue or 0,
				},
				{
					value = data.sellNum,
					sortArg = data.sellNum,
				},
				{
					value = data.avgSell > 0 and TSMAPI:FormatTextMoney(data.avgSell) or "|cff999999---|r",
					sortArg = data.avgSell,
				},
				{
					value = data.buyNum,
					sortArg = data.buyNum,
				},
				{
					value = data.avgSell > 0 and TSMAPI:FormatTextMoney(data.avgBuy) or "|cff999999---|r",
					sortArg = data.avgBuy,
				},
			},
			itemString = itemString,
			totalNum = data.sellNum + data.buyNum,
		}
		tinsert(stData, row)
	end

	return stData
end

function private:GetAuctionSTData(dataType, filters)
	local stData = {}
	for itemString, data in pairs(TSM.items) do
		if #data.auctions > 0 and not private:IsItemFiltered(itemString, filters) then
			for _, record in ipairs(data.auctions) do
				if record.key == dataType and not private:IsRecordFiltered(record, filters) then
					local row = {
						cols = {
							{
								value = select(2, TSMAPI:GetSafeItemInfo(itemString)) or data.name,
								sortArg = data.name or itemString,
							},
							{
								value = record.player,
								sortArg = record.player,
							},
							{
								value = record.stackSize,
								sortArg = record.stackSize,
							},
							{
								value = record.quantity / record.stackSize,
								sortArg = record.quantity / record.stackSize,
							},
							{
								value = private:GetFormattedTime(record.time),
								sortArg = record.time,
							},
						},
						itemString = itemString,
					}
					tinsert(stData, row)
				end
			end
		end
	end
	return stData
end
function Data.GetExpireSTData(filters)
	return private:GetAuctionSTData("Expire", filters)
end
function Data.GetCancelSTData(filters)
	return private:GetAuctionSTData("Cancel", filters)
end

function private:GetMoneySTData(dataType, filters)
	local stData = {}
	for _, record in ipairs(TSM.money[dataType]) do
		if not private:IsRecordFiltered(record, filters) then
			local row = {
				cols = {
					{
						value = record.key,
						sortArg = record.key,
					},
					{
						value = record.player,
						sortArg = record.player,
					},
					{
						value = record.otherPlayer,
						sortArg = record.otherPlayer,
					},
					{
						value = TSMAPI:FormatTextMoney(record.copper),
						sortArg = record.copper,
					},
					{
						value = private:GetFormattedTime(record.time),
						sortArg = record.time,
					},
				},
			}
			tinsert(stData, row)
		end
	end
	return stData
end
function Data.GetIncomeSTData(filters)
	return private:GetMoneySTData("income", filters)
end
function Data.GetExpenseSTData(filters)
	return private:GetMoneySTData("expense", filters)
end

function Data.GetSummaryData(filters)
	local goldData = {
		sales = {total=0, month=0, week=0, topGold={}, topQuantity={}},
		income = {total=0, month=0, week=0, topGold={}, topQuantity={}},
		buys = {total=0, month=0, week=0, topGold={}, topQuantity={}},
		expense = {total=0, month=0, week=0, topGold={}, topQuantity={}},
		profit = {total=0, month=0, week=0},
		totalTime = 0,
		monthTime = 0,
		weekTime = 0,
	}
	
	
	local function ProcessSummaryItemData(itemData, resultTbl, itemString)
		local itemTotal, itemNum = 0, 0
		for _, record in ipairs(itemData) do
			if not private:IsRecordFiltered(record, filters) then
				local timeDiff = time() - record.time
				
				-- update local variables
				itemNum = itemNum + record.quantity
				itemTotal = itemTotal + record.copper * record.quantity
				
				-- update total data
				resultTbl.total = resultTbl.total + record.copper * record.quantity
				goldData.totalTime = max(goldData.totalTime, timeDiff)
				if timeDiff <= (SECONDS_PER_DAY * 30) then
					-- update month data
					resultTbl.month = resultTbl.month + record.copper * record.quantity
					goldData.monthTime = max(goldData.monthTime, timeDiff)
				end
				if timeDiff <= (SECONDS_PER_DAY * 7) then
					-- update week data
					resultTbl.week = resultTbl.week + record.copper * record.quantity
					goldData.weekTime = max(goldData.weekTime, timeDiff)
				end
			end
		end
		
		-- check if this is a top item by gold and/or quantity
		if itemTotal > (resultTbl.topGold.copper or 0) then
			resultTbl.topGold = {itemString=itemString, copper=itemTotal, itemID=TSMAPI:GetItemID(itemString)}
		end
		if itemNum > (resultTbl.topQuantity.num or 0) then
			resultTbl.topQuantity = {itemString=itemString, num=itemNum, itemID=TSMAPI:GetItemID(itemString)}
		end
	end
	for itemString, data in pairs(TSM.items) do
		if not private:IsItemFiltered(itemString, filters) then
			ProcessSummaryItemData(data.sales, goldData.sales, itemString)
			ProcessSummaryItemData(data.buys, goldData.buys, itemString)
		end
	end
	
	
	local function ProcessSummaryMoneyData(moneyData, resultTbl)
		local moneyKeyNum, moneyKeyGold = {}, {}
		for _, record in ipairs(moneyData) do
			if not private:IsRecordFiltered(record, filters) then
				local timeDiff = time() - record.time
				
				-- update local variables
				moneyKeyNum[record.key] = (moneyKeyNum[record.key] or 0) + 1
				moneyKeyGold[record.key] = (moneyKeyGold[record.key] or 0) + record.copper
				
				-- update total data
				resultTbl.total = resultTbl.total + record.copper
				goldData.totalTime = max(goldData.totalTime, timeDiff)
				if timeDiff < (SECONDS_PER_DAY * 30) then
					-- update month data
					resultTbl.month = resultTbl.month + record.copper
					goldData.monthTime = max(goldData.monthTime, timeDiff)
				end
				if timeDiff < (SECONDS_PER_DAY * 7) then
					-- update week data
					resultTbl.week = resultTbl.week + record.copper
					goldData.weekTime = max(goldData.weekTime, timeDiff)
				end
			end
		end
		for key, total in pairs(moneyKeyNum) do
			if total > (resultTbl.topQuantity.num or 0) then
				resultTbl.topQuantity = {key=key, num=total}
			end
		end
		for key, total in pairs(moneyKeyGold) do
			if total > (resultTbl.topGold.copper or 0) then
				resultTbl.topGold = {key=key, copper=total}
			end
		end
	end
	ProcessSummaryMoneyData(TSM.money.income, goldData.income)
	ProcessSummaryMoneyData(TSM.money.expense, goldData.expense)

	
	goldData.sales.topGold.link = goldData.sales.topGold.itemString and (select(2, TSMAPI:GetSafeItemInfo(goldData.sales.topGold.itemString)) or TSM.items[goldData.sales.topGold.itemString].name) or L["none"]
	goldData.sales.topQuantity.link = goldData.sales.topQuantity.itemString and (select(2, TSMAPI:GetSafeItemInfo(goldData.sales.topQuantity.itemString)) or TSM.items[goldData.sales.topQuantity.itemString].name) or L["none"]
	goldData.buys.topGold.link = goldData.buys.topGold.itemString and (select(2, TSMAPI:GetSafeItemInfo(goldData.buys.topGold.itemString)) or TSM.items[goldData.buys.topGold.itemString].name) or L["none"]
	goldData.buys.topQuantity.link = goldData.buys.topQuantity.itemString and (select(2, TSMAPI:GetSafeItemInfo(goldData.buys.topQuantity.itemString)) or TSM.items[goldData.buys.topQuantity.itemString].name) or L["none"]
	
	goldData.profit.total = ((goldData.sales.total + goldData.income.total) - (goldData.buys.total + goldData.expense.total))
	goldData.profit.month = ((goldData.sales.month + goldData.income.month) - (goldData.buys.month + goldData.expense.month))
	goldData.profit.week = ((goldData.sales.week + goldData.income.week) - (goldData.buys.week + goldData.expense.week))
	
	if goldData.totalTime > (SECONDS_PER_DAY * 30) then
		goldData.monthTime = SECONDS_PER_DAY * 30
	end
	if goldData.totalTime > (SECONDS_PER_DAY * 7) then
		goldData.weekTime = SECONDS_PER_DAY * 7
	end
	goldData.totalTime = ceil(goldData.totalTime / SECONDS_PER_DAY)
	goldData.monthTime = ceil(goldData.monthTime / SECONDS_PER_DAY)
	goldData.weekTime = ceil(goldData.weekTime / SECONDS_PER_DAY)

	return goldData
end

function Data.GetItemDetailData(itemString)
	if not TSM.items[itemString] then return end

	local data = {activity={}, buys={players={}, price={}, num={}, avg={}}, sales={players={}, price={}, num={}, avg={}}, stData={}}
	
	local function ProcessItemActivity(itemData, resultTbl, activityType)
		local totalPrice, totalNum = 0, 0
		local monthPrice, monthNum = 0, 0
		local weekPrice, weekNum = 0, 0

		for i, record in ipairs(itemData) do
			resultTbl.players[record.otherPlayer] = (resultTbl.players[record.otherPlayer] or 0) + record.quantity
			tinsert(data.activity, {activityType=activityType, record=record})

			totalPrice = totalPrice + record.copper * record.quantity
			totalNum = totalNum + record.quantity
			local timeDiff = time() - record.time
			if timeDiff < (SECONDS_PER_DAY * 30) then
				monthPrice = monthPrice + record.copper * record.quantity
				monthNum = monthNum + record.quantity
			end
			if timeDiff < (SECONDS_PER_DAY * 7) then
				weekPrice = weekPrice + record.copper * record.quantity
				weekNum = weekNum + record.quantity
			end
		end
		
		resultTbl.price.total = totalPrice
		resultTbl.price.month = monthPrice
		resultTbl.price.week = weekPrice
		
		resultTbl.num.total = totalNum
		resultTbl.num.month = monthNum
		resultTbl.num.week = weekNum
		
		resultTbl.avg.total = totalNum > 0 and TSM:Round(totalPrice / totalNum) or 0
		resultTbl.avg.month = monthNum > 0 and TSM:Round(monthPrice / monthNum) or 0
		resultTbl.avg.week = weekNum > 0 and TSM:Round(weekPrice / weekNum) or 0
		
		if totalNum > 0 then
			resultTbl.hasData = true
		end
	end
	ProcessItemActivity(TSM.items[itemString].buys, data.buys, "Purchase")
	ProcessItemActivity(TSM.items[itemString].sales, data.sales, "Sale")
	
	for _, stRecord in ipairs(data.activity) do
		local activityType = stRecord.activityType
		local record = stRecord.record
		local row = {
			cols = {
				{
					value = activityType,
					sortArg = activityType,
				},
				{
					value = record.key,
					sortArg = record.key or "",
				},
				{
					value = record.otherPlayer,
					sortArg = record.otherPlayer,
				},
				{
					value = record.quantity,
					sortArg = record.quantity,
				},
				{
					value = TSMAPI:FormatTextMoney(record.copper),
					sortArg = record.copper,
				},
				{
					value = TSMAPI:FormatTextMoney(record.copper * record.quantity),
					sortArg = record.copper * record.quantity,
				},
				{
					value = private:GetFormattedTime(record.time),
					sortArg = record.time,
				},
			},
			record = record,
			recordType = activityType,
		}
		tinsert(data.stData, row)
	end

	return data
end


function Data:PopulateDataCaches()
	Data.playerListCache = {}
	
	for itemString, data in pairs(TSM.items) do
		for _, record in ipairs(data.buys) do
			Data.playerListCache[record.player] = record.player
		end
		for _, record in ipairs(data.sales) do
			Data.playerListCache[record.player] = record.player
		end
		for _, record in ipairs(data.auctions) do
			Data.playerListCache[record.player] = record.player
		end
	end
	
	for _, record in pairs(TSM.money.income) do
		Data.playerListCache[record.player] = record.player
	end
	for _, record in pairs(TSM.money.expense) do
		Data.playerListCache[record.player] = record.player
	end
end

function Data:RemoveOldData(daysOld)
	local cutOffTime = time() - daysOld * SECONDS_PER_DAY
	local numRecords, numItems = 0, 0
	
	for itemString, data in pairs(TSM.items) do
		local numLeft = 0
		for _, key in ipairs({"sales", "buys", "auctions"}) do
			for i=#data[key], 1, -1 do
				if data[key][i].time < cutOffTime then
					numRecords = numRecords + 1
					tremove(data[key], i)
				end
			end
			numLeft = numLeft + #data[key]
		end
		if numLeft == 0 then
			TSM.items[itemString] = nil
			numItems = numItems + 1
		end
	end
	for dataType, records in pairs(TSM.money) do
		for i=#records, 1, -1 do
			if records[i].time < cutOffTime then
				numRecords = numRecords + 1
				tremove(records, i)
			end
		end
	end

	TSM:Printf(L["Removed a total of %s old records and %s items with no remaining records."], numRecords, numItems)
end

function Data:SetupRepairCost()
	REPAIR_MONEY = GetMoney();
	COULD_REPAIR = CanMerchantRepair();
	-- if merchant can repair set up variables so we can track repairs
	if (COULD_REPAIR) then
		REPAIR_COST, CAN_REPAIR = GetRepairAllCost();
	end
end

function Data:ResetRepairMoney()
	-- Could have bought something before or after repair
	REPAIR_MONEY = GetMoney()
end

do
	local tradeInfo

	local function onAcceptUpdate(_, player, target)
		if (player == 1 or target == 1) and not (GetTradePlayerItemLink(7) or GetTradeTargetItemLink(7)) then
			-- update tradeInfo
			tradeInfo = { player = {}, target = {} }
			tradeInfo.player.money = tonumber(GetPlayerTradeMoney())
			tradeInfo.target.money = tonumber(GetTargetTradeMoney())
			tradeInfo.target.name = UnitName("NPC")

			for i = 1, 6 do
				local link = GetTradeTargetItemLink(i)
				local count = select(3, GetTradeTargetItemInfo(i))
				if link then
					tinsert(tradeInfo.target, { itemString = TSMAPI:GetItemString(link), count = count })
				end

				local link = GetTradePlayerItemLink(i)
				local count = select(3, GetTradePlayerItemInfo(i))
				if link then
					tinsert(tradeInfo.player, { itemString = TSMAPI:GetItemString(link), count = count })
				end
			end
		else
			tradeInfo = nil
		end
	end

	local function onChatMsg(_, msg)
		if not TSM.db.factionrealm.trackTrades then return
		end
		if msg == ERR_TRADE_COMPLETE and tradeInfo then
			-- trade went through
			local info
			if tradeInfo.player.money > 0 and #tradeInfo.player == 0 and tradeInfo.target.money == 0 and #tradeInfo.target > 0 then
				-- player bought items
				local itemString, count
				for i = 1, #tradeInfo.target do
					local data = tradeInfo.target[i]
					if not itemString then
						itemString = data.itemString
						count = data.count
					elseif itemString == data.itemString then
						count = count + data.count
					else
						return
					end
				end
				if not itemString or not count then return
				end
				info = { type = "buys", itemString = itemString, count = count, price = tradeInfo.player.money / count }
				info.gotText = select(2, TSMAPI:GetSafeItemInfo(itemString)) .. "x" .. count
				info.gaveText = TSMAPI:FormatTextMoney(tradeInfo.player.money)
			elseif tradeInfo.player.money == 0 and #tradeInfo.player > 0 and tradeInfo.target.money > 0 and #tradeInfo.target == 0 then
				-- player sold items
				local itemString, count
				for i = 1, #tradeInfo.player do
					local data = tradeInfo.player[i]
					if not itemString then
						itemString = data.itemString
						count = data.count
					elseif itemString == data.itemString then
						count = count + data.count
					else
						return
					end
				end
				if not itemString or not count then return
				end
				info = { type = "sales", itemString = itemString, count = count, price = tradeInfo.target.money / count }
				info.gaveText = select(2, TSMAPI:GetSafeItemInfo(itemString)) .. "x" .. count
				info.gotText = TSMAPI:FormatTextMoney(tradeInfo.target.money)
			else
				return
			end

			local function InsertTradeRecord()
				if info.type == "sales" then
					Data:InsertItemSaleRecord(info.itemString, "Trade", info.count, info.price, tradeInfo.target.name)
				elseif info.type == "buys" then
					Data:InsertItemBuyRecord(info.itemString, "Trade", info.count, info.price, tradeInfo.target.name)
				end
			end
			if TSM.db.factionrealm.autoTrackTrades then
				InsertTradeRecord()
			else
				StaticPopupDialogs["TSMAccountingOnTrade"] = {
					text = format(L["TSM_Accounting detected that you just traded %s %s in return for %s. Would you like Accounting to store a record of this trade?"], tradeInfo.target.name, info.gaveText, info.gotText),
					button1 = YES,
					button2 = NO,
					timeout = 0,
					whileDead = true,
					hideOnEscape = true,
					OnAccept = InsertTradeRecord,
					OnCancel = function() end,
				}
				TSMAPI:ShowStaticPopupDialog("TSMAccountingOnTrade")
			end
		end
	end

	Data:RegisterEvent("TRADE_ACCEPT_UPDATE", onAcceptUpdate)
	Data:RegisterEvent("UI_INFO_MESSAGE", onChatMsg)
end

local lastTrackMinute = 0
function Data:LogGold()
	local currentTime = time()
	local currentMinute = floor(currentTime / 60)
	if currentMinute <= lastTrackMinute then return end
	local player = UnitName("player")
	if not player then return end
	lastTrackMinute = currentMinute

	TSM.db.factionrealm.goldLog[player] = TSM.db.factionrealm.goldLog[player] or {}
	local goldLog = TSM.db.factionrealm.goldLog[player]
	local currentGold = TSM:Round(GetMoney(), COPPER_PER_GOLD * 1000)
	if #goldLog > 0 and currentGold == goldLog[#goldLog].copper then
		goldLog[#goldLog].endMinute = currentMinute
	else
		if #goldLog > 0 then
			goldLog[#goldLog].endMinute = currentMinute - 1
		end
		tinsert(goldLog, { startMinute = currentMinute, endMinute = currentMinute, copper = currentGold })
	end
end