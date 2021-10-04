-- ------------------------------------------------------------------------------ --
--                                TradeSkillMaster                                --
--                http://www.curse.com/addons/wow/tradeskill-master               --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- This file contains price related TSMAPI functions.

local TSM = select(2, ...)
local moduleObjects = TSM.moduleObjects
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster") -- loads the localization table

TSM_PRICE_TEMP = {loopError=function(str) TSM:Printf(L["Loop detected in the following custom price:"].." "..TSMAPI.Design:GetInlineColor("link")..str.."|r") end}
local MONEY_PATTERNS = {
	"([0-9]+g[ ]*[0-9]+s[ ]*[0-9]+c)", 	-- g/s/c
	"([0-9]+g[ ]*[0-9]+s)", 				-- g/s
	"([0-9]+g[ ]*[0-9]+c)", 				-- g/c
	"([0-9]+s[ ]*[0-9]+c)", 				-- s/c
	"([0-9]+g)", 								-- g
	"([0-9]+s)", 								-- s
	"([0-9]+c)",								-- c
}
local MATH_FUNCTIONS = {
	["avg"] = "_avg",
	["min"] = "_min",
	["max"] = "_max",
	["first"] = "_first",
	["check"] = "_check",
}

function TSMAPI:GetPriceSources()
	local sources = {}
	for _, obj in pairs(moduleObjects) do
		if obj.priceSources then
			for _, info in ipairs(obj.priceSources) do
				sources[info.key] = info.label
			end
		end
	end
	return sources
end

local itemValueKeyCache = {}
function TSMAPI:GetItemValue(link, key)
	local itemLink = select(2, TSMAPI:GetSafeItemInfo(link)) or link
	if not itemLink then return end

	-- look in module objects for this key
	if itemValueKeyCache[key] then
		local info = itemValueKeyCache[key]
		return info.callback(itemLink, info.arg)
	end
	for _, obj in pairs(moduleObjects) do
		if obj.priceSources then
			for _, info in ipairs(obj.priceSources) do
				if info.key == key then
					itemValueKeyCache[key] = info
					local value = info.callback(itemLink, info.arg)
					return (type(value) == "number" and value > 0) and value or nil
				end
			end
		end
	end
end



-- validates a price string that was passed into TSMAPI:ParseCustomPrice
local supportedOperators = { "+", "-", "*", "/" }
local function ParsePriceString(str, badPriceSource)
	if tonumber(str) then
		return function() return tonumber(str) end
	end

	local origStr = str
	
	-- make everything lower case
	str = strlower(str)
	
	
	-- remove any colors around gold/silver/copper
	str = gsub(str, "|cff([0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F])g|r", "g")
	str = gsub(str, "|cff([0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F])s|r", "s")
	str = gsub(str, "|cff([0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F])c|r", "c")

	-- replace all formatted gold amount with their copper value
	local start = 1
	local goldAmountContinue = true
	while goldAmountContinue do
		goldAmountContinue = false
		local minFind = {}
		for _, pattern in ipairs(MONEY_PATTERNS) do
			local s, e, sub = strfind(str, pattern, start)
			if s and (not minFind.s or minFind.s > s) then
				minFind.s = s
				minFind.e = e
				minFind.sub = sub
			end
		end
		if minFind.s then
			local value = TSMAPI:UnformatTextMoney(minFind.sub)
			if not value then return end -- sanity check
			local preStr = strsub(str, 1, minFind.s-1)
			local postStr = strsub(str, minFind.e+1)
			str = preStr .. value .. postStr
			start = #str - #postStr + 1
			goldAmountContinue = true
		end
	end

	-- remove up to 1 occurance of convert(priceSource[, item])
	local convertPriceSource, convertItem
	local _, _, convertParams = strfind(str, "convert%(([^%)]+)%)")
	if convertParams then
		local source
		local s = strfind(convertParams, "|c")
		if s then
			local _, e = strfind(convertParams, "|r")
			local itemString = e and TSMAPI:GetItemString(strsub(convertParams, s, e))
			if not itemString then return nil, L["Invalid item link."] end -- there's an invalid item link in the convertParams
			convertItem = itemString
			source = strsub(convertParams, 1, s - 1)
		elseif strfind(convertParams, "item:") then
			local s, e = strfind(convertParams, "item:([0-9]+):?([0-9]*):?([0-9]*):?([0-9]*):?([0-9]*):?([0-9]*):?([0-9]*)")
			convertItem = strsub(convertParams, s, e)
			source = strsub(convertParams, 1, s - 1)
		elseif strfind(convertParams, "battlepet:") then
			local s, e = strfind(convertParams, "item:([0-9]+):?([0-9]*):?([0-9]*):?([0-9]*):?([0-9]*):?([0-9]*):?([0-9]*)")
			convertItem = strsub(convertParams, s, e)
			source = strsub(convertParams, 1, s - 1)
		else
			source = convertParams
		end
		source = gsub(source:trim(), ",$", ""):trim()
		for key in pairs(TSMAPI:GetPriceSources()) do
			if strlower(key) == source then
				convertPriceSource = key
				break
			end
		end
		if not convertPriceSource then
			return nil, L["Invalid price source in convert."]
		end
		local num = 0
		str, num = gsub(str, "convert%(([^%)]+)%)", "~convert~")
		if num > 1 then
			return nil, L["A maximum of 1 convert() function is allowed."]
		end
	end

	-- replace all item links with "~item~"
	local items = {}
	while true do
		local s = strfind(str, "|c")
		if not s then break end -- no more item links
		local _, e = strfind(str, "|r")
		local itemString = e and TSMAPI:GetItemString(strsub(str, s, e))
		if not itemString then return nil, L["Invalid item link."] end -- there's an invalid item link in the str
		tinsert(items, itemString)
		str = strsub(str, 1, s - 1) .. "~item~" .. strsub(str, e + 1)
	end

	-- replace all itemStrings with "~item~"
	while true do
		local s, e
		if strfind(str, "item:") then
			s, e = strfind(str, "item:([0-9]+):?([0-9]*):?([0-9]*):?([0-9]*):?([0-9]*):?([0-9]*):?([0-9]*)")
		elseif strfind(str, "battlepet:") then
			s, e = strfind(str, "battlepet:([0-9]+):?([0-9]*):?([0-9]*):?([0-9]*):?([0-9]*):?([0-9]*):?([0-9]*)")
		else
			break
		end
		local itemString = strsub(str, s, e)
		tinsert(items, itemString)
		str = strsub(str, 1, s - 1) .. "~item~" .. strsub(str, e + 1)
	end

	-- make sure there's spaces on either side of operators
	for _, operator in ipairs(supportedOperators) do
		str = gsub(str, TSMAPI:StrEscape(operator), " " .. operator .. " ")
	end

	-- add space to start of string for percentage matching
	str = " "..str
	-- fix any whitespace issues around item links and remove parenthesis
	str = gsub(str, "%(([ ]*)~item~([ ]*)%)", " ~item~")
	-- ensure a space on either side of parenthesis and commas
	str = gsub(str, "%(", " ( ")
	str = gsub(str, "%)", " ) ")
	str = gsub(str, ",", " , ")
	-- remove any occurances of more than one consecutive space
	str = gsub(str, "([ ]+)", " ")

	-- ensure equal number of left/right parenthesis
	if select(2, gsub(str, "%(", "")) ~= select(2, gsub(str, "%)", "")) then return nil, L["Unbalanced parentheses."] end

	-- convert percentages to decimal numbers
	for leading, pctValue in gmatch(str, "([^0-9%.])([0-9%.]+)%%") do
		if tonumber(pctValue) then
			local number = tonumber(pctValue) / 100
			str = gsub(str, leading..pctValue.."%%", leading .. number .. " *")
		end
	end
	
	-- create array of valid price sources
	local priceSourceKeys = {}
	for key in pairs(TSMAPI:GetPriceSources()) do
		tinsert(priceSourceKeys, strlower(key))
	end
	for key in pairs(TSM.db.global.customPriceSources) do
		tinsert(priceSourceKeys, strlower(key))
	end

	-- validate all words in the string
	local parts = TSMAPI:SafeStrSplit(str:trim(), " ")
	for i, word in ipairs(parts) do
		if tContains(supportedOperators, word) then
			if i == #parts then
				return nil, L["Invalid operator at end of custom price."]
			end
			-- valid operand
		elseif badPriceSource == word then
			-- price source that's explicitly invalid
			return nil, format(L["You cannot use %s as part of this custom price."], word)
		elseif tContains(priceSourceKeys, word) then
			-- valid price source
		elseif tonumber(word) then
			-- make sure it's not an itemID (incorrect)
			if i > 2 and parts[i-1] == "(" and tContains(priceSourceKeys, parts[i-2]) then
				return nil, L["Invalid parameter to price source."]
			end
			-- valid number
		elseif word == "~item~" then
			-- make sure previous word was a price source
			if i > 1 and tContains(priceSourceKeys, parts[i-1]) then
				-- valid item parameter
			else
				return nil, L["Item links may only be used as parameters to price sources."]
			end
		elseif word == "(" or word == ")" then
			-- valid parenthesis
		elseif word == "," then
			if not parts[i+1] or parts[i+1] == ")" then
				return nil, L["Misplaced comma"]
			else
				-- we're hoping this is a valid comma within a function, will be caught by loadstring otherwise
			end
		elseif MATH_FUNCTIONS[word] then
			if not parts[i+1] or parts[i+1] ~= "(" then
				return nil, format(L["Invalid word: '%s'"], word)
			end
			-- valid math function
		elseif word == "~convert~" then
			-- valid convert statement
		elseif word:trim() == "" then
			-- harmless extra spaces
		else
			return nil, format(L["Invalid word: '%s'"], word)
		end
	end

	for key in pairs(TSMAPI:GetPriceSources()) do
		-- replace all "<priceSource> ~item~" occurances with the parameters to TSMAPI:GetItemValue (with "~item~" left in for the item)
		for match in gmatch(" "..str.." ", " "..strlower(key).." ~item~") do
			match = match:trim()
			str = gsub(str, match, "(\"~item~\",\"" .. key .. "\",\"reg\")")
		end
		-- replace all "<priceSource>" occurances with the parameters to TSMAPI:GetItemValue (with _item for the item)
		for match in gmatch(" "..str.." ", " "..strlower(key).." ") do
			match = match:trim()
			str = gsub(str, match, "(\"_item\",\"" .. key .. "\",\"reg\")")
		end
	end
	
	for key in pairs(TSM.db.global.customPriceSources) do
		-- price sources need to have at least 1 capital letter for this algorithm to work, so temporarily give it one
		key = strupper(strsub(key, 1, 1))..strsub(key, 2)
		-- replace all "<customPriceSource> ~item~" occurances with the parameters to TSMAPI:GetCustomPriceSourceValue (with "~item~" left in for the item)
		for match in gmatch(" "..str.." ", " " .. strlower(key) .. " ~item~") do
			match = match:trim()
			str = gsub(str, match, "(\"~item~\",\"" .. key .. "\",\"custom\")")
		end
		-- replace all "<customPriceSource>" occurances with the parameters to TSMAPI:GetCustomPriceSourceValue (with _item for the item)
		for match in gmatch(" "..str.." ", " " .. strlower(key) .. " ") do
			match = match:trim()
			str = gsub(str, match, "(\"_item\",\"" .. key .. "\",\"custom\")")
		end
		
		-- change custom price sources back to lower case
		str = gsub(str, TSMAPI:StrEscape("(\"~item~\",\"" .. key .. "\",\"custom\")"), strlower("(\"~item~\",\"" .. key .. "\",\"custom\")"))
		str = gsub(str, TSMAPI:StrEscape("(\"_item\",\"" .. key .. "\",\"custom\")"), strlower("(\"_item\",\"" .. key .. "\",\"custom\")"))
	end

	-- replace all occurances of "~item~" with the item link
	for match in gmatch(str, "~item~") do
		local itemString = tremove(items, 1)
		if not itemString then return nil, L["Wrong number of item links."] end
		str = gsub(str, match, itemString, 1)
	end

	-- replace any itemValue API calls with a lookup in the 'values' array
	local itemValues = {}
	for match in gmatch(str, "%(\"([^%)]+)%)") do
		local index = #itemValues + 1
		itemValues[index] = "{\"" .. match .. "}"
		str = gsub(str, TSMAPI:StrEscape("(\"" .. match .. ")"), "values[" .. index .. "]")
	end

	-- replace "~convert~" appropriately
	if convertPriceSource then
		tinsert(itemValues, "{\"" .. (convertItem or "_item") .. "\",\"convert\",\"" .. convertPriceSource .. "\"}")
		str = gsub(str, "~convert~", "values[" .. #itemValues .. "]")
	end

	-- replace math functions special custom function names
	for word, funcName in pairs(MATH_FUNCTIONS) do
		str = gsub(str, word, funcName)
	end
	
	-- remove any unused values
	for i in ipairs(itemValues) do
		if not strfind(" "..str.." ", " values%["..i.."%] ") then
			itemValues[i] = "{}"
		end
	end

	-- finally, create and return the function
	local funcTemplate = [[
		return function(_item)
				local NAN = math.huge*0
				local origStr = %s
				local isTop
				if not TSM_PRICE_TEMP.num then
					TSM_PRICE_TEMP.num = 0
					isTop = true
				end
				TSM_PRICE_TEMP.num = TSM_PRICE_TEMP.num + 1
				if TSM_PRICE_TEMP.num > 100 then
					if (TSM_PRICE_TEMP.lastPrint or 0) + 1 < time() then
						TSM_PRICE_TEMP.lastPrint = time()
						TSM_PRICE_TEMP.loopError(origStr)
					end
					return
				end
				local function isNAN(num)
					return tostring(num) == tostring(NAN)
				end
				local function _min(...)
					local nums = {...}
					for i=#nums, 1, -1 do
						if isNAN(nums[i]) then
							tremove(nums, i)
						end
					end
					if #nums == 0 then return NAN end
					return min(unpack(nums))
				end
				local function _max(...)
					local nums = {...}
					for i=#nums, 1, -1 do
						if isNAN(nums[i]) then
							tremove(nums, i)
						end
					end
					if #nums == 0 then return NAN end
					return max(unpack(nums))
				end
				local function _first(...)
					local nums = {...}
					for i=1, #nums do
						if type(nums[i]) == "number" and not isNAN(nums[i]) then
							return nums[i]
						end
					end
					return NAN
				end
				local function _avg(...)
					local nums = {...}
					local total, count = 0, 0
					for i=#nums, 1, -1 do
						if type(nums[i]) == "number" and not isNAN(nums[i]) then
							total = total + nums[i]
							count = count + 1
						end
					end
					if count == 0 then return NAN end
					return floor(total / count + 0.5)
				end
				local function _check(...)
					if select('#', ...) > 3 then return end
					local check, ifValue, elseValue = ...
					check = check or NAN
					ifValue = ifValue or NAN
					elseValue = elseValue or NAN
					return check > 0 and ifValue or elseValue
				end
				local values = {}
				for i, params in ipairs({%s}) do
					local itemString, key, extraParam = unpack(params)
					if itemString then
						itemString = (itemString == "_item") and _item or itemString
						if key == "convert" then
							values[i] = TSMAPI:GetConvertCost(itemString, extraParam)
						elseif extraParam == "custom" then
							values[i] = TSMAPI:GetCustomPriceSourceValue(itemString, key)
						else
							values[i] = TSMAPI:GetItemValue(itemString, key)
						end
						values[i] = values[i] or NAN
					end
				end
				local result = floor((%s) + 0.5)
				if TSM_PRICE_TEMP.num then
					TSM_PRICE_TEMP.num = TSM_PRICE_TEMP.num - 1
				end
				if isTop then
					TSM_PRICE_TEMP.num = nil
				end
				return not isNAN(result) and result or nil
			end
	]]
	local func, loadErr = loadstring(format(funcTemplate, "\""..origStr.."\"", table.concat(itemValues, ","), str))
	if loadErr then
		loadErr = gsub(loadErr:trim(), "([^:]+):.", "")
		return nil, L["Invalid function."].." Details: "..loadErr
	end
	local success, func = pcall(func)
	if not success then return nil, L["Invalid function."] end
	return func
end

local customPriceCache = {}
local badCustomPriceCache = {}
function TSMAPI:ParseCustomPrice(priceString, badPriceSource)
	priceString = strlower(tostring(priceString):trim())
	if priceString == "" then return nil, L["Empty price string."] end
	if badCustomPriceCache[priceString] then return nil, badCustomPriceCache[priceString] end
	if customPriceCache[priceString] then return customPriceCache[priceString] end

	local func, err = ParsePriceString(priceString, badPriceSource)
	if err then
		badCustomPriceCache[priceString] = err
		return nil, err
	end

	customPriceCache[priceString] = func
	return func
end

function TSMAPI:GetCustomPriceSourceValue(itemString, key)
	local source = TSM.db.global.customPriceSources[key]
	if not source then return end
	local func = TSMAPI:ParseCustomPrice(source)
	if not func then return end
	return func(itemString)
end