-- ------------------------------------------------------------------------------ --
--                           TradeSkillMaster_AuctionDB                           --
--           http://www.curse.com/addons/wow/tradeskillmaster_auctiondb           --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- register this file with Ace Libraries
local TSM = select(2, ...)
TSM = LibStub("AceAddon-3.0"):NewAddon(TSM, "TSM_AuctionDB", "AceEvent-3.0", "AceConsole-3.0")
local AceGUI = LibStub("AceGUI-3.0") -- load the AceGUI libraries

local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster_AuctionDB") -- loads the localization table

TSM.MAX_AVG_DAY = 1
local SECONDS_PER_DAY = 60 * 60 * 24

local savedDBDefaults = {
	factionrealm = {
		appData = {},
		scanData = "",
		time = 0,
		lastCompleteScan = 0,
		appDataUpdate = 0,
	},
	profile = {
		tooltip = true,
		resultsPerPage = 50,
		resultsSortOrder = "ascending",
		resultsSortMethod = "name",
		hidePoorQualityItems = true,
		marketValueTooltip = true,
		minBuyoutTooltip = true,
		showAHTab = true,
	},
}

-- Called once the player has loaded WOW.
function TSM:OnInitialize()
	-- load the savedDB into TSM.db
	TSM.db = LibStub:GetLibrary("AceDB-3.0"):New("TradeSkillMaster_AuctionDBDB", savedDBDefaults, true)

	-- make easier references to all the modules
	for moduleName, module in pairs(TSM.modules) do
		TSM[moduleName] = module
	end

	-- register this module with TSM
	TSM:RegisterModule()
	TSM.db.factionrealm.time = 10 -- because AceDB won't save if we don't do this...
	
	TSM.data = {}
	TSM:Deserialize(TSM.db.factionrealm.scanData, TSM.data)
end

-- registers this module with TSM by first setting all fields and then calling TSMAPI:NewModule().
function TSM:RegisterModule()
	TSM.priceSources = {
		{ key = "DBMarket", label = L["AuctionDB - Market Value"], callback = "GetMarketValue" },
		{ key = "DBMinBuyout", label = L["AuctionDB - Minimum Buyout"], callback = "GetMinBuyout" },
	}
	TSM.icons = {
		{ side = "module", desc = "AuctionDB", slashCommand = "auctiondb", callback = "Config:Load", icon = "Interface\\Icons\\Inv_Misc_Platnumdisks" },
	}
	if TSM.db.profile.showAHTab then
		TSM.auctionTab = { callbackShow = "GUI:Show", callbackHide = "GUI:Hide" }
	end
	TSM.slashCommands = {
		{ key = "adbreset", label = L["Resets AuctionDB's scan data"], callback = "Reset" },
	}
	TSM.moduleAPIs = {
		{ key = "lastCompleteScan", callback = TSM.GetLastCompleteScan },
		{ key = "lastCompleteScanTime", callback = TSM.GetLastCompleteScanTime },
		{ key = "adbScans", callback = TSM.GetScans },
		{ key = "adbOppositeFaction", callback = TSM.GetOppositeFactionData },
	}
	TSM.tooltipOptions = {callback = "Config:LoadTooltipOptions"}
	TSMAPI:NewModule(TSM)
end

function TSM:LoadAuctionData()
	local function LoadDataThread(self, itemIDs)
		-- process new items first
		for itemID in pairs(TSM.db.factionrealm.appData) do
			if not TSM.data[itemID] then
				TSM:DecodeItemData(itemID)
				TSM:ProcessAppData(itemID)
				TSM:EncodeItemData(itemID)
			end
			self:Yield()
		end
		
		local currentDay = TSM.Data:GetDay()
		for _, itemID in ipairs(itemIDs) do
			TSM:DecodeItemData(itemID)
			TSM:ProcessAppData(itemID)
			if type(TSM.data[itemID].scans) == "table" then
				local temp = {}
				for i=0, 14 do
					if i <= TSM.MAX_AVG_DAY then
						temp[currentDay-i] = TSM.Data:ConvertScansToAvg(TSM.data[itemID].scans[currentDay-i])
					else
						local dayScans = TSM.data[itemID].scans[currentDay-i]
						if type(dayScans) == "table" then
							if dayScans.avg then
								temp[currentDay-i] = dayScans.avg
							else
								-- old method
								temp[currentDay-i] = TSM.Data:GetAverage(dayScans)
							end
						elseif type(dayScans) == "number" then
							temp[currentDay-i] = dayScans
						end
					end
				end
				TSM.data[itemID].scans = temp
			end
			TSM:EncodeItemData(itemID)
			self:Yield()
		end
	end
	
	local itemIDs = {}
	for itemID in pairs(TSM.data) do
		tinsert(itemIDs, itemID)
	end
	TSMAPI.Threading:Start(LoadDataThread, 0.1, nil, itemIDs)
end

function TSM:ProcessAppData(itemID)
	if not TSM.db.factionrealm.appData[itemID] then return end
	
	TSM.data[itemID] = TSM.data[itemID] or {scans = {}, lastScan = 0}
	local dbData = TSM.data[itemID]
	local day = TSM.Data:GetDay()
	for _, appData in ipairs(TSM.db.factionrealm.appData[itemID]) do
		local marketValue, minBuyout, scanTime = appData.m, appData.b, appData.t
		if abs(day - TSM.Data:GetDay(scanTime)) <= TSM.MAX_AVG_DAY then
			local dayScans = dbData.scans
			dayScans[day] = dayScans[day] or {avg=0, count=0}
			if type(dayScans[day]) == "number" then
				-- this should never happen...
				dayScans[day] = {dayScans[day]}
			end
			dayScans[day].avg = dayScans[day].avg or 0
			dayScans[day].count = dayScans[day].count or 0
			if #dayScans[day] > 0 then
				dayScans[day] = TSM.Data:ConvertScansToAvg(dayScans[day])
			end
			dayScans[day].avg = floor((dayScans[day].avg * dayScans[day].count + marketValue) / (dayScans[day].count + 1) + 0.5)
			dayScans[day].count = dayScans[day].count + 1
			if not dbData.lastScan or dbData.lastScan < scanTime then
				dbData.lastScan = scanTime
				dbData.minBuyout = minBuyout > 0 and minBuyout or nil
			end
		end
	end
	TSM.Data:UpdateMarketValue(dbData)
	TSM.db.factionrealm.appData[itemID] = nil
end

function TSM:OnEnable()
	local function DecodeJSON(data)
		data = gsub(data, ":", "=")
		data = gsub(data, "\"horde\"", "horde")
		data = gsub(data, "\"alliance\"", "alliance")
		data = gsub(data, "\"m\"", "m")
		data = gsub(data, "\"n\"", "n")
		data = gsub(data, "\"b\"", "b")
		data = gsub(data, "\"([0-9]+)\"", "[%1]")
		loadstring("TSM_APP_DATA_TMP = " .. data .. "")()
		local val = TSM_APP_DATA_TMP
		TSM_APP_DATA_TMP = nil
		return val
	end

	if TSM.AppData then
		local realm = strlower(GetRealmName() or "")
		local faction = strlower(UnitFactionGroup("player") or "")
		if faction == "" or faction == "Neutral" then return end
		local numNewScans = 0
		local maxScanTime = 0
		for realmInfo, appScanData in pairs(TSM.AppData) do
			local r, f, t, extra = ("-"):split(realmInfo)
			if extra then
				r = r .. "-" .. f
				f = t
				t = extra
			end
			r = strlower(r)
			f = strlower(f)
			local scanTime = tonumber(t)
			if realm == r and (faction == f or f == "both") and scanTime > TSM.db.factionrealm.appDataUpdate and abs(TSM.Data:GetDay() - TSM.Data:GetDay(scanTime)) <= TSM.MAX_AVG_DAY then
				local importData = DecodeJSON(appScanData)[faction]
				if importData then
					for itemID, data in pairs(importData) do
						itemID = tonumber(itemID)
						data.m = tonumber(data.m)
						data.b = tonumber(data.b)
						data.t = scanTime
						if itemID and data.m and data.b then
							TSM.db.factionrealm.appData[itemID] = TSM.db.factionrealm.appData[itemID] or {}
							tinsert(TSM.db.factionrealm.appData[itemID], data)
						end
					end
					maxScanTime = max(maxScanTime, scanTime)
					numNewScans = numNewScans + 1
				end
			end
		end

		if numNewScans > 0 then
			TSM.db.factionrealm.appDataUpdate = maxScanTime
			TSM.db.factionrealm.lastCompleteScan = TSM.db.factionrealm.appDataUpdate
			TSM:Printf(L["Imported %s scans worth of new auction data!"], numNewScans)
		end

		TSM.AppData = nil
	end

	TSM:LoadAuctionData()
end

function TSM:OnTSMDBShutdown()
	TSM.db.factionrealm.time = 0
	TSM:Serialize(TSM.data)
end

function TSM:GetTooltip(itemString, quantity)
	if not TSM.db.profile.tooltip then return end
	if not strfind(itemString, "item:") then return end
	local itemID = TSMAPI:GetItemID(itemString)
	if not itemID or not TSM.data[itemID] then return end
	local text = {}
	local moneyCoinsTooltip = TSMAPI:GetMoneyCoinsTooltip()
	quantity = quantity or 1

	-- add market value info
	if TSM.db.profile.marketValueTooltip then
		local marketValue = TSM:GetMarketValue(itemID)
		if marketValue then
				if moneyCoinsTooltip then
					if IsShiftKeyDown() then
						tinsert(text, { left = "  " .. format(L["Market Value x%s:"], quantity), right = TSMAPI:FormatTextMoneyIcon(marketValue * quantity, "|cffffffff", true) })
					else
						tinsert(text, { left = "  " .. L["Market Value:"], right = TSMAPI:FormatTextMoneyIcon(marketValue, "|cffffffff", true) })
					end
				else
					if IsShiftKeyDown() then
						tinsert(text, { left = "  " .. format(L["Market Value x%s:"], quantity), right = TSMAPI:FormatTextMoney(marketValue * quantity, "|cffffffff", true) })
					else
						tinsert(text, { left = "  " .. L["Market Value:"], right = TSMAPI:FormatTextMoney(marketValue, "|cffffffff", true) })
					end
				end
			end
	end

	-- add min buyout info
	if TSM.db.profile.minBuyoutTooltip then
		local minBuyout = TSM:GetMinBuyout(itemID)
		if minBuyout then
			if quantity then
				if moneyCoinsTooltip then
					if IsShiftKeyDown() then
						tinsert(text, { left = "  " .. format(L["Min Buyout x%s:"], quantity), right = TSMAPI:FormatTextMoneyIcon(minBuyout * quantity, "|cffffffff", true) })
					else
						tinsert(text, { left = "  " .. L["Min Buyout:"], right = TSMAPI:FormatTextMoneyIcon(minBuyout, "|cffffffff", true) })
					end
				else
					if IsShiftKeyDown() then
						tinsert(text, { left = "  " .. format(L["Min Buyout x%s:"], quantity), right = TSMAPI:FormatTextMoney(minBuyout * quantity, "|cffffffff", true) })
					else
						tinsert(text, { left = "  " .. L["Min Buyout:"], right = TSMAPI:FormatTextMoney(minBuyout, "|cffffffff", true) })
					end
				end
			end
		end
	end

	-- add heading and last scan time info
	if #text > 0 then
		local lastScan = TSM:GetLastScanTime(itemID)
		if lastScan then
			local timeColor = "|cffff0000"
			if (time() - lastScan) < 60 * 60 * 3 then
				timeColor = "|cff00ff00"
			elseif (time() - lastScan) < 60 * 60 * 12 then
				timeColor = "|cffffff00"
			end
			local timeDiff = SecondsToTime(time() - lastScan)		
			--tinsert(text, 1, { left = "|cffffff00" .. "TSM AuctionDB:", right = "|cffffffff" .. format(L["%s ago"], timeDiff) })
			tinsert(text, 1, { left = "|cffffff00" .. "TSM AuctionDB:", right = format("%s (%s)", format("|cffffffff".."%d auctions".."|r", TSM.data[itemID].quantity), format(timeColor..L["%s ago"].."|r", timeDiff)) })
		else
			tinsert(text, 1, { left = "|cffffff00" .. "TSM AuctionDB:", right = "|cffffffff" .. L["Not Scanned"] })
		end
		return text
	end
end

function TSM:Reset()
	-- Popup Confirmation Window used in this module
	StaticPopupDialogs["TSMAuctionDBClearDataConfirm"] = StaticPopupDialogs["TSMAuctionDBClearDataConfirm"] or {
		text = L["Are you sure you want to clear your AuctionDB data?"],
		button1 = YES,
		button2 = CANCEL,
		timeout = 0,
		whileDead = true,
		hideOnEscape = true,
		OnAccept = function()
			TSM.db.factionrealm.lastCompleteScan = 0
			TSM.db.factionrealm.appDataUpdate = 0
			for i in pairs(TSM.data) do
				TSM.data[i] = nil
			end
			TSM:Print(L["Reset Data"])
		end,
		OnCancel = false,
	}

	StaticPopup_Show("TSMAuctionDBClearDataConfirm")
	for i = 1, 10 do
		local popup = _G["StaticPopup" .. i]
		if popup and popup.which == "TSMAuctionDBClearDataConfirm" then
			popup:SetFrameStrata("TOOLTIP")
			break
		end
	end
end

local alpha = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_="
local base = #alpha
local alphaTable = {}
local alphaTableLookup = {}
for i = 1, base do
	local char = strsub(alpha, i, i)
	tinsert(alphaTable, char)
	alphaTableLookup[char] = i
end

local function decode(h)
	if not h then return end
	if strfind(h, "~") then return end
	local result = 0

	local len = #h
	for j=len-1, 0, -1 do
		if not alphaTableLookup[strsub(h, len-j, len-j)] then error(h.." at index "..len-j) end
		result = result + (alphaTableLookup[strsub(h, len-j, len-j)] - 1) * (base ^ j)
		j = j - 1
	end

	return result
end

local function encode(d)
	d = tonumber(d)
	if not d or not (d < math.huge and d > 0) then -- this cannot be simplified since 0/0 is neither less than nor greater than any number
		return "~"
	end

	local r = d % base
	local diff = d - r
	if diff == 0 then
		return alphaTable[r + 1]
	else
		return encode(diff / base) .. alphaTable[r + 1]
	end
end

local function encodeScans(scans)
	local tbl, tbl2 = {}, {}
	for day, data in pairs(scans) do
		if type(data) == "table" and data.count and data.avg then
			data = encode(data.avg).."@"..encode(data.count)
		elseif type(data) == "table" then
			-- Old method of encoding scans
			for i = 1, #data do
				tbl2[i] = encode(data[i])
			end
			data = table.concat(tbl2, ";", 1, #data)
		else
			data = encode(data)
		end
		tinsert(tbl, encode(day) .. ":" .. data)
	end
	return table.concat(tbl, "!")
end

local function decodeScans(rope)
	if rope == "A" then return	end
	local scans = {}
	local days = {("!"):split(rope)}
	local currentDay = TSM.Data:GetDay()
	for _, data in ipairs(days) do
		local day, marketValueData = (":"):split(data)
		day = decode(day)
		scans[day] = {}
		
		--bug fix? ...SkillMaster_AuctionDB\TradeSkillMaster_AuctionDB.lua:398: bad argument #1 to 'strfind' (string expected, got nil)
		if marketValueData ~= nil then
		
			if strfind(marketValueData, "@") then
				local avg, count = ("@"):split(marketValueData)
				avg = decode(avg)
				count = decode(count)
				if avg ~= "~" and count ~= "~" then
					if abs(currentDay - day) <= TSM.MAX_AVG_DAY then
						scans[day].avg = avg
						scans[day].count = count
					else
						scans[day] = avg
					end
				end
			else
				-- Old method of decoding scans
				for _, value in ipairs({(";"):split(marketValueData)}) do
					local decodedValue = decode(value)
					if decodedValue ~= "~" then
						tinsert(scans[day], tonumber(decodedValue))
					end
				end
				if day ~= currentDay then
					scans[day] = TSM.Data:GetAverage(scans[day])
				end
			end
			
		end
	end

	return scans
end

function TSM:Serialize()
	local results = {}
	for itemID, data in pairs(TSM.data) do
		if not data.encoded then
			-- should never get here, but just in-case
			TSM:EncodeItemData(itemID)
		end
		if data.encoded then
			tinsert(results, "?" .. encode(itemID) .. "," .. data.encoded)
		end
	end
	TSM.db.factionrealm.scanData = table.concat(results)
end

function TSM:Deserialize(data, resultTbl, fullyDecode)
	if strsub(data, 1, 1) ~= "?" then return end

	for k, a, b, c, d, e, f in gmatch(data, "?([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^?]+)") do
		local itemID = decode(k)
		resultTbl[itemID] = {encoded=strjoin(",", a, b, c, d, e, f)}
		if fullyDecode then
			TSM:DecodeItemData(itemID, resultTbl)
		end
	end
end

function TSM:EncodeItemData(itemID, tbl)
	tbl = tbl or TSM.data
	local data = tbl[itemID]
	if data and data.marketValue then
		data.encoded = strjoin(",", encode(0), encode(data.marketValue), encode(data.lastScan), encode(0), encode(data.minBuyout), encodeScans(data.scans), encode(data.quantity))
	end
end

function TSM:DecodeItemData(itemID, tbl)
	tbl = tbl or TSM.data
	local data = tbl[itemID]
	if data and data.encoded and not data.marketValue then
		local a, b, c, d, e, f, g = (","):split(data.encoded)
		data.marketValue = decode(b)
		data.lastScan = decode(c)
		data.minBuyout = decode(e)
		data.scans = decodeScans(f)	
		data.quantity = decode(g)	
	end
end

function TSM:GetLastCompleteScan()
	local lastScan = {}
	for itemID, data in pairs(TSM.data) do
		TSM:DecodeItemData(itemID)
		if data.lastScan == TSM.db.factionrealm.lastCompleteScan then
			lastScan[itemID] = { marketValue = data.marketValue, minBuyout = data.minBuyout }
		end
	end

	return lastScan
end

function TSM:GetLastCompleteScanTime()
	return TSM.db.factionrealm.lastCompleteScan
end

function TSM:GetScans(link)
	if not link then return	end
	link = select(2, GetItemInfo(link))
	if not link then return	end
	local itemID = TSMAPI:GetItemID(link)
	if not TSM.data[itemID] then return	end
	TSM:DecodeItemData(itemID)

	return CopyTable(TSM.data[itemID].scans)
end

function TSM:GetOppositeFactionData()
	local realm = GetRealmName()
	local faction = UnitFactionGroup("player")
	if faction == "Horde" then
		faction = "Alliance"
	elseif faction == "Alliance" then
		faction = "Horde"
	else
		return
	end

	local data = TSM.db.sv.factionrealm[faction .. " - " .. realm]
	if not data or type(data.scanData) ~= "string" then return end

	local result = {}
	TSM:Deserialize(data.scanData, result, true)
	return result
end

function TSM:GetMarketValue(itemID)
	if itemID and not tonumber(itemID) then
		itemID = TSMAPI:GetItemID(itemID)
	end
	if not itemID or not TSM.data[itemID] then return end
	TSM:DecodeItemData(itemID)
	if not TSM.data[itemID].marketValue or TSM.data[itemID].marketValue == 0 then
		TSM.data[itemID].marketValue = TSM.Data:GetMarketValue(TSM.data[itemID].scans)
	end
	return TSM.data[itemID].marketValue ~= 0 and TSM.data[itemID].marketValue or nil
end

function TSM:GetLastScanTime(itemID)
	TSM:DecodeItemData(itemID)
	return itemID and TSM.data[itemID].lastScan
end

function TSM:GetMinBuyout(itemID)
	if itemID and not tonumber(itemID) then
		itemID = TSMAPI:GetItemID(itemID)
	end
	if not itemID or not TSM.data[itemID] then return end
	TSM:DecodeItemData(itemID)
	return TSM.data[itemID].minBuyout
end