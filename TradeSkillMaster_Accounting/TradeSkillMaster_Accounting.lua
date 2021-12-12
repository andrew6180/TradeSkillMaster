-- ------------------------------------------------------------------------------ --
--                           TradeSkillMaster_Accounting                          --
--           http://www.curse.com/addons/wow/tradeskillmaster_accounting          --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- register this file with Ace Libraries
local TSM = select(2, ...)
TSM = LibStub("AceAddon-3.0"):NewAddon(TSM, "TSM_Accounting", "AceEvent-3.0", "AceConsole-3.0")
TSM.SELL_KEYS = { "itemString", "itemName", "stackSize", "quantity", "price", "buyer", "player", "time", "source" }
TSM.BUY_KEYS = { "itemString", "itemName", "stackSize", "quantity", "price", "seller", "player", "time", "source" }
TSM.INCOME_KEYS = { "type", "amount", "source", "player", "time" }
TSM.EXPENSE_KEYS = { "type", "amount", "destination", "player", "time" }
TSM.EXPIRED_KEYS = { "itemString", "itemName", "stackSize", "quantity", "player", "time" }
TSM.CANCELLED_KEYS = { "itemString", "itemName", "stackSize", "quantity", "player", "time" }
TSM.GOLD_LOG_KEYS = { "startMinute", "endMinute", "copper" }
local MAX_CSV_RECORDS = 55000
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster_Accounting") -- loads the localization table
local LibParse = LibStub("LibParse")

local savedDBDefaults = {
	global = {
		itemStrings = {},
		infoID = 0,
	},
	factionrealm = {
		csvSales = "",
		csvBuys = "",
		csvIncome = "",
		csvExpense = "",
		csvExpired = "",
		csvCancelled = "",
		timeFormat = "ago",
		mvSource = "adbmarket",
		priceFormat = "avg",
		tooltip = { sale = false, purchase = false },
		smartBuyPrice = false,
		expiredAuctions = false,
		cancelledAuctions = false,
		saleRate = false,
		trackTrades = true,
		autoTrackTrades = false,
		displayGreys = true,
		goldLog = {},
		displayTransfers = true,
		saveTimeSales = "",
		saveTimeBuys = "",
		trimmed = {},
	},
}

-- Called once the player has loaded WOW.
function TSM:OnInitialize()
	-- load the savedDB into TSM.db
	TSM.db = LibStub:GetLibrary("AceDB-3.0"):New("TradeSkillMaster_AccountingDB", savedDBDefaults, true)

	for module in pairs(TSM.modules) do
		TSM[module] = TSM.modules[module]
	end

	-- register with TSM
	TSM:RegisterModule()

	-- clear out 1.x data
	if TSM.db.factionrealm.itemData then
		TSM.db.factionrealm.itemData = nil
	end

	if TSM.db.factionrealm.data then
		TSM.db.factionrealm.csvSales = TSM.db.factionrealm.data.sales
		TSM.db.factionrealm.csvBuys = TSM.db.factionrealm.data.buys
		TSM.db.factionrealm.data = nil
	end
	
	for key, timestamp in pairs(TSM.db.factionrealm.trimmed) do
		TSM:Printf(L["|cffff0000IMPORTANT:|r When TSM_Accounting last saved data for this realm, it was too big for WoW to handle, so old data was automatically trimmed in order to avoid corruption of the saved variables. The last %s of %s data has been preserved."], SecondsToTime(time()-timestamp), key)
	end
	TSM.db.factionrealm.trimmed = {}

	TSM.Data:Load()

	-- fix issues in gold log
	for player, playerData in pairs(TSM.db.factionrealm.goldLog) do
		for i=#playerData, 1, -1 do
			local data = playerData[i]
			data.startMinute = floor(data.startMinute)
			data.endMinute = floor(data.endMinute)
			if data.startMinute == data.endMinute and data.copper == 0 then
				tremove(playerData, i)
			else
				-- round to nearest 1k gold
				data.copper = TSM:Round(data.copper, COPPER_PER_GOLD*1000)
			end
		end
		if #playerData >= 2 then
			for i=2, #playerData do
				playerData[i].startMinute = playerData[i-1].endMinute + 1
			end
			for i=#playerData-1, 1, -1 do
				if playerData[i].copper == playerData[i+1].copper then
					playerData[i].endTime = playerData[i+1].endTime
					tremove(playerData, i+1)
				end
			end
			for i=#playerData-2, 1, -1 do
				i = min(i, #playerData-2)
				if i < 1 then break end
				if playerData[i].copper == playerData[i+2].copper and playerData[i+1].copper == 0 then
					playerData[i].endTime = playerData[i+2].endTime
					tremove(playerData, i+2)
					tremove(playerData, i+1)
				end
			end
		end
	end
end

-- registers this module with TSM by first setting all fields and then calling TSMAPI:NewModule().
function TSM:RegisterModule()
	TSM.icons = {
		{ side = "module", desc = "Accounting", slashCommand = "accounting", callback = "GUI:Load", icon = "Interface\\Icons\\Inv_Misc_Coin_02" },
	}
	TSM.priceSources = {
		{ key = "avgSell", label = L["Avg Sell Price"], callback = "GetAvgSellPrice" },
		{ key = "avgBuy", label = L["Avg Buy Price"], callback = "GetAvgBuyPrice" },
		{ key = "maxSell", label = L["Max Sell Price"], callback = "GetMaxSellPrice" },
		{ key = "maxBuy", label = L["Max Buy Price"], callback = "GetMaxBuyPrice" },
	}
	TSM.tooltipOptions = { callback = "GUI:LoadTooltipOptions" }

	TSMAPI:NewModule(TSM)
end

local tooltipCache = {buys={}, sales={}}
function TSM:GetTooltip(itemString)
	if not (TSM.db.factionrealm.tooltip.sale or TSM.db.factionrealm.tooltip.purchase) then return end
	if not TSM.items[itemString] then return end
	TSM.cache[itemString] = TSM.cache[itemString] or {}
	local text = {}

	local avgSalePrice, totalSaleNum = TSM:GetAvgSellPrice(itemString)
	totalSaleNum = totalSaleNum or 0
	local numSaleRecords = #TSM.items[itemString].sales
	local lastSold = numSaleRecords > 0 and TSM.items[itemString].sales[numSaleRecords].time or 0
	local moneyCoinsTooltip = TSMAPI:GetMoneyCoinsTooltip()
	if TSM.db.factionrealm.tooltip.sale and numSaleRecords > 0 then
		local totalSalePrice = avgSalePrice * totalSaleNum

		if IsShiftKeyDown() then
			if moneyCoinsTooltip then
				tinsert(text, { left = "  " .. L["Sold (Total Price):"], right = format("%s (%s)", "|cffffffff" .. totalSaleNum .. "|r", (TSMAPI:FormatTextMoneyIcon(totalSalePrice, "|cffffffff", true) or ("|cffffffff" .. "?"))) })
			else
				tinsert(text, { left = "  " .. L["Sold (Total Price):"], right = format("%s (%s)", "|cffffffff" .. totalSaleNum .. "|r", (TSMAPI:FormatTextMoney(totalSalePrice, "|cffffffff", true) or ("|cffffffff" .. "?"))) })
			end
		else
			local maxPrice = TSM:GetMaxSellPrice(itemString)
			if moneyCoinsTooltip then
				tinsert(text, { left = "  " .. L["Sold (Avg/Max Price):"], right = format("%s (%s / %s)", "|cffffffff" .. totalSaleNum .. "|r", (TSMAPI:FormatTextMoneyIcon(avgSalePrice, "|cffffffff", true) or ("|cffffffff" .. "?")), (TSMAPI:FormatTextMoneyIcon(maxPrice, "|cffffffff", true) or ("|cffffffff" .. "?"))) })
			else
				tinsert(text, { left = "  " .. L["Sold (Avg/Max Price):"], right = format("%s (%s / %s)", "|cffffffff" .. totalSaleNum .. "|r", (TSMAPI:FormatTextMoney(avgSalePrice, "|cffffffff", true) or ("|cffffffff" .. "?")), (TSMAPI:FormatTextMoney(maxPrice, "|cffffffff", true) or ("|cffffffff" .. "?"))) })
			end
		end
		if lastSold > 0 then
			local timeDiff = SecondsToTime(time() - lastSold)
			tinsert(text, { left = "  " .. L["Last Sold:"], right = "|cffffffff" .. format(L["%s ago"], timeDiff) })
		end
	end

	local cancelledNum, expiredNum, totalFailed = TSM:GetAuctionStats(itemString, (lastSold > 0 and lastSold))

	if expiredNum > 0 and cancelledNum > 0 then
		tinsert(text, { left = "  " .. L["Failed Since Last Sale (Expired/Cancelled):"], right = format("%s (%s/%s)", "|cffffffff" .. (expiredNum + cancelledNum) .. "|r", "|cffffffff" .. expiredNum .. "|r", "|cffffffff" .. cancelledNum .. "|r") })
	elseif expiredNum > 0 then
		tinsert(text, { left = "  " .. L["Expired Since Last Sale:"], right = "|cffffffff" .. expiredNum })
	elseif cancelledNum > 0 then
		tinsert(text, { left = "  " .. L["Cancelled Since Last Sale:"], right = "|cffffffff" .. cancelledNum })
	end

	if totalSaleNum > 0 and totalFailed > 0 then
		local saleRate = TSM:Round(totalSaleNum / (totalSaleNum + (totalFailed or 0)), 0.01)
		tinsert(text, { left = "  " .. L["Sale Rate:"], right = "|cffffffff" .. saleRate })
	end

	if TSM.db.factionrealm.tooltip.purchase and TSM.items[itemString] and #TSM.items[itemString].buys > 0 then
		local lastPurchased = TSM.items[itemString].buys[#TSM.items[itemString].buys].time
		local totalPrice, totalNum = 0, 0
		for _, record in ipairs(TSM.items[itemString].buys) do
			totalNum = totalNum + record.quantity
			totalPrice = totalPrice + record.copper * record.quantity
		end

		if IsShiftKeyDown() then
			if moneyCoinsTooltip then
				tinsert(text, { left = "  " .. L["Purchased (Total Price):"], right = format("%s (%s)", "|cffffffff" .. totalNum .. "|r", (TSMAPI:FormatTextMoneyIcon(totalPrice, "|cffffffff", true) or ("|cffffffff" .. "?"))) })
			else
				tinsert(text, { left = "  " .. L["Purchased (Total Price):"], right = format("%s (%s)", "|cffffffff" .. totalNum .. "|r", (TSMAPI:FormatTextMoney(totalPrice, "|cffffffff", true) or ("|cffffffff" .. "?"))) })
			end
		else
			local avgPrice = TSM:GetAvgBuyPrice(itemString)
			local maxPrice = TSM:GetMaxBuyPrice(itemString)
			if moneyCoinsTooltip then
				tinsert(text, { left = "  " .. L["Purchased (Avg/Max Price):"], right = format("%s (%s / %s)", "|cffffffff" .. totalNum .. "|r", (TSMAPI:FormatTextMoneyIcon(avgPrice, "|cffffffff", true) or ("|cffffffff" .. "?")), (TSMAPI:FormatTextMoneyIcon(maxPrice, "|cffffffff", true) or ("|cffffffff" .. "?"))) })
			else
				tinsert(text, { left = "  " .. L["Purchased (Avg/Max Price):"], right = format("%s (%s / %s)", "|cffffffff" .. totalNum .. "|r", (TSMAPI:FormatTextMoney(avgPrice, "|cffffffff", true) or ("|cffffffff" .. "?")), (TSMAPI:FormatTextMoney(maxPrice, "|cffffffff", true) or ("|cffffffff" .. "?"))) })
			end
		end
		if lastPurchased then
			local timeDiff = SecondsToTime(time() - lastPurchased)
			tinsert(text, { left = "  " .. L["Last Purchased:"], right = "|cffffffff" .. format(L["%s ago"], timeDiff) })
		end
	end

	-- add heading
	if #text > 0 then
		tinsert(text, 1, "|cffffff00TSM Accounting:")
		return text
	end
end

function TSM:OnTSMDBShutdown()
	-- process items
	local appDBSales = {}
	local sales, buys, cancels, expires = {}, {}, {}, {}
	local saveTimeSales, saveTimeBuys = {}, {}
	for itemString, data in pairs(TSM.items) do
		local name = data.itemName or TSMAPI:GetSafeItemInfo(itemString) or TSM:GetItemName(itemString) or "?"
		name = gsub(name, ",", "") -- can't have commas in the itemNames in the CSV
		local itemAppData = {}
		
		-- process sales
		for _, record in ipairs(data.sales) do
			record.itemString = itemString
			record.itemName = name
			record.buyer = record.otherPlayer
			record.source = record.key
			record.price = record.copper
			if record.key == "Auction" then
				record.saveTime = record.saveTime or time()
				tinsert(saveTimeSales, record.saveTime)
				tinsert(itemAppData, {record.copper, record.quantity, record.time, record.saveTime})
			end
			tinsert(sales, record)
		end
		
		-- process buys
		for _, record in ipairs(data.buys) do
			record.itemString = itemString
			record.itemName = name
			record.seller = record.otherPlayer
			record.source = record.key
			record.price = record.copper
			if record.key == "Auction" then
				record.saveTime = record.saveTime or time()
				tinsert(saveTimeBuys, record.saveTime)
				tinsert(itemAppData, {record.copper, record.quantity, record.time, record.saveTime})
			end
			tinsert(buys, record)
		end
		if #itemAppData > 0 and strfind(itemString, "item:") then
			local item = gsub(itemString, "item:", "")
			item = gsub(item, ":0:0:0:0:0:", ":")
			local itemID, rand = (":"):split(item)
			if rand == "0" then
				appDBSales[itemID] = itemAppData
			else
				appDBSales[item] = itemAppData
			end
		end
		
		-- process auctions
		for _, record in ipairs(data.auctions) do
			record.itemString = itemString
			record.itemName = name
			if record.key == "Cancel" then
				tinsert(cancels, record)
			elseif record.key == "Expire" then
				tinsert(expires, record)
			end
		end
	end
	
	-- trim anything that'll be too long
	for key, data in pairs({["sales"]=sales, ["buys"]=buys}) do
		if #data > MAX_CSV_RECORDS then
			sort(data, function(a, b) return a.time > b.time end)
			while (#data > floor(MAX_CSV_RECORDS*0.9)) do
				tremove(data)
			end
			TSM.db.factionrealm.trimmed[key] = data[#data].time
		end
	end
	
	TSM.db.factionrealm.saveTimeSales = table.concat(saveTimeSales, ",")
	TSM.db.factionrealm.saveTimeBuys = table.concat(saveTimeBuys, ",")
	TSM.db.factionrealm.csvSales = LibParse:CSVEncode(TSM.SELL_KEYS, sales)
	TSM.db.factionrealm.csvBuys = LibParse:CSVEncode(TSM.BUY_KEYS, buys)
	TSM.db.factionrealm.csvCancelled = LibParse:CSVEncode(TSM.CANCELLED_KEYS, cancels)
	TSM.db.factionrealm.csvExpired = LibParse:CSVEncode(TSM.EXPIRED_KEYS, expires)
	
	-- process income
	local income = {}
	for _, record in ipairs(TSM.money.income) do
		if record.key == "Transfer" then
			record.type = "Money Transfer"
			record.source = record.otherPlayer
			record.amount = record.copper
			tinsert(income, record)
		end
	end
	TSM.db.factionrealm.csvIncome = LibParse:CSVEncode(TSM.INCOME_KEYS, income)
	
	-- process expense
	local expense = {}
	for _, record in ipairs(TSM.money.expense) do
		record.amount = record.copper
		record.destination = record.otherPlayer
		if record.key == "Transfer" then
			record.type = "Money Transfer"
			tinsert(expense, record)
		elseif record.key == "Postage" then
			record.type = "Postage"
			tinsert(expense, record)
		elseif record.key == "Repair" then
			record.type = "Repair Bill"
			tinsert(expense, record)
		end
	end
	TSM.db.factionrealm.csvExpense = LibParse:CSVEncode(TSM.EXPENSE_KEYS, expense)
	
	-- process gold log
	TSM.Data:LogGold()
	for player, data in pairs(TSM.db.factionrealm.goldLog) do
		if type(data) == "table" then
			TSM.db.factionrealm.goldLog[player] = LibParse:CSVEncode(TSM.GOLD_LOG_KEYS, data)
		end
	end
end

function TSM:GetItemName(item)
	for itemName, itemString in pairs(TSM.db.global.itemStrings) do
		if itemString == item then
			return itemName
		end
	end
end

local baseItemLookup = { update = 0 }
function TSM:UpdateBaseItemLookup()
	if time() - baseItemLookup.update < 30 then return end
	baseItemLookup = { update = time() }
	for itemString in pairs(TSM.items) do
		local baseItemString = TSMAPI:GetBaseItemString(itemString)
		if baseItemString ~= itemString then
			baseItemLookup[baseItemString] = baseItemLookup[baseItemString] or {}
			tinsert(baseItemLookup[baseItemString], itemString)
		end
	end
end

local function GetAuctionStats(itemString, minTime)
	local cancel, expire, total = 0, 0, 0
	for _, record in ipairs(TSM.items[itemString].auctions) do
		if record.key == "Cancel" and TSM.db.factionrealm.cancelledAuctions and record.time > minTime then
			cancel = cancel + record.quantity
		elseif record.key == "Expire" and TSM.db.factionrealm.expiredAuctions and record.time > minTime then
			expire = expire + record.quantity
		end
		total = total + record.quantity
	end
	return cancel, expire, total
end

function TSM:GetAuctionStats(itemString, minTime)
	minTime = minTime or 0
	if not itemString then return end
	if not TSM.cache[itemString].totalFailed then
		local cancel, expire, total = GetAuctionStats(itemString, minTime)
		TSM.cache[itemString].totalCancel = cancel
		TSM.cache[itemString].totalExpire = expire
		TSM.cache[itemString].totalFailed = total
	end
	return TSM.cache[itemString].totalCancel, TSM.cache[itemString].totalExpire, TSM.cache[itemString].totalFailed
end

local function GetAverageSellPrice(itemString, noBaseItem)
	if not noBaseItem and itemString and baseItemLookup[itemString] then
		local totalPrice, totalNum = 0, 0
		for _, item in ipairs(baseItemLookup[itemString]) do
			local price, num = GetAverageSellPrice(item, true)
			if price and num and num > 0 then
				totalPrice = totalPrice + price
				totalNum = totalNum + num
			end
		end
		if totalNum > 0 then
			return TSM:Round(totalPrice / totalNum)
		end
	end
	if not (TSM.items[itemString] and #TSM.items[itemString].sales > 0) then return end

	local totalPrice, totalSaleNum = 0, 0
	for _, record in ipairs(TSM.items[itemString].sales) do
		totalSaleNum = totalSaleNum + record.quantity
		totalPrice = totalPrice + record.copper * record.quantity
	end

	return TSM:Round(totalPrice / totalSaleNum), totalSaleNum
end

function TSM:GetAvgSellPrice(itemString)
	itemString = TSMAPI:GetItemString(select(2, TSMAPI:GetSafeItemInfo(itemString)))
	if not itemString then return end
	TSM:UpdateBaseItemLookup()
	TSM.cache[itemString] = TSM.cache[itemString] or {}
	if not TSM.cache[itemString].avgSellPrice then
		local price, num = GetAverageSellPrice(itemString)
		TSM.cache[itemString].avgSellPrice = price
		TSM.cache[itemString].avgSellNum = num
	end
	return TSM.cache[itemString].avgSellPrice, TSM.cache[itemString].avgSellNum
end

local function GetAvgerageBuyPrice(itemString, noBaseItem)
	if not noBaseItem and itemString and baseItemLookup[itemString] then
		local totalPrice, totalNum = 0, 0
		for _, item in ipairs(baseItemLookup[itemString]) do
			if not baseItemLookup[item] then
				local price, num = GetAvgerageBuyPrice(item, true)
				if price and num and num > 0 then
					totalPrice = totalPrice + price
					totalNum = totalNum + num
				end
			end
		end
		if totalNum > 0 then
			return TSM:Round(totalPrice / totalNum)
		end
	end
	if not (TSM.items[itemString] and #TSM.items[itemString].buys > 0) then return end

	local itemCount = 0
	if TSM.db.factionrealm.smartBuyPrice then
		local player, alts = TSMAPI:ModuleAPI("ItemTracker", "playertotal", itemString)
		if not player then
			alts = nil
		end
		player = player or 0
		alts = alts or 0
		local guild = TSMAPI:ModuleAPI("ItemTracker", "guildtotal", itemString) or 0
		local auctions = TSMAPI:ModuleAPI("ItemTracker", "auctionstotal", itemString) or 0
		itemCount = player + alts + guild + auctions
	end

	local num, totalPrice = 0, 0
	for i = #TSM.items[itemString].buys, 1, -1 do
		local record = TSM.items[itemString].buys[i]
		for j = 1, record.quantity do
			num = num + 1
			totalPrice = totalPrice + record.copper
			if itemCount > 0 and num >= itemCount then break end
		end
		if itemCount > 0 and num >= itemCount then break end
	end

	return TSM:Round(totalPrice / num), num
end

function TSM:GetAvgBuyPrice(itemString)
	itemString = TSMAPI:GetItemString(select(2, TSMAPI:GetSafeItemInfo(itemString)))
	if not itemString then return end
	TSM.cache[itemString] = TSM.cache[itemString] or {}
	TSM:UpdateBaseItemLookup()
	if not TSM.cache[itemString].avgBuyPrice then
		local price, num = GetAvgerageBuyPrice(itemString)
		TSM.cache[itemString].avgBuyPrice = price
		TSM.cache[itemString].avgBuyNum = num
	end
	return TSM.cache[itemString].avgBuyPrice, TSM.cache[itemString].avgBuyNum
end

function TSM:GetMaxSellPrice(itemString)
	itemString = TSMAPI:GetItemString(select(2, TSMAPI:GetSafeItemInfo(itemString)))
	if not (itemString and TSM.items[itemString] and #TSM.items[itemString].sales > 0) then return end
	TSM.cache[itemString] = TSM.cache[itemString] or {}

	if not TSM.cache[itemString].maxSellPrice then
		local maxPrice = 0
		for _, record in ipairs(TSM.items[itemString].sales) do
			maxPrice = max(maxPrice, record.copper)
		end
		TSM.cache[itemString].maxSellPrice = maxPrice
	end
	
	return TSM.cache[itemString].maxSellPrice
end

function TSM:GetMaxBuyPrice(itemString)
	itemString = TSMAPI:GetItemString(select(2, TSMAPI:GetSafeItemInfo(itemString)))
	if not (itemString and TSM.items[itemString] and #TSM.items[itemString].buys > 0) then return end
	TSM.cache[itemString] = TSM.cache[itemString] or {}

	if not TSM.cache[itemString].maxBuyPrice then
		local maxPrice = 0
		for _, record in ipairs(TSM.items[itemString].buys) do
			maxPrice = max(maxPrice, record.copper)
		end
		TSM.cache[itemString].maxBuyPrice = maxPrice
	end
	
	return TSM.cache[itemString].maxBuyPrice
end

function TSM:Round(value, sig)
	sig = sig or 1
	local gold = value / sig
	gold = floor(gold + 0.5)
	return gold * sig
end