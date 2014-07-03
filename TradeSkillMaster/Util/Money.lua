-- ------------------------------------------------------------------------------ --
--                                TradeSkillMaster                                --
--          http://www.curse.com/addons/wow/tradeskillmaster_warehousing          --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- This file contains various money APIs

local TSM = select(2, ...)
TSM.GOLD_TEXT = "|cffffd700g|r"
TSM.SILVER_TEXT = "|cffc7c7cfs|r"
TSM.COPPER_TEXT = "|cffeda55fc|r"

local private = {}
TSMAPI:RegisterForTracing(private, "TradeSkillMaster.Money_private")
local GOLD_ICON = "|TInterface\\MoneyFrame\\UI-GoldIcon:0|t"
local SILVER_ICON = "|TInterface\\MoneyFrame\\UI-SilverIcon:0|t"
local COPPER_ICON = "|TInterface\\MoneyFrame\\UI-CopperIcon:0|t"


function private:PadNumber(num, pad)
	if num < 10 and pad then
		return format("%02d", num)
	end
	
	return tostring(num)
end

--- Creates a formatted money string from a copper value.
-- @param money The money value in copper.
-- @param color The color to make the money text (minus the 'g'/'s'/'c'). If nil, will not add any extra color formatting.
-- @param pad If true, the formatted string will be left padded.
-- @param trim If true, will remove any 0 valued tokens. For example, "1g" instead of "1g0s0c". If money is zero, will return "0c".
-- @param disabled If true, the g/s/c text will not be colored.
-- @return Returns the formatted money text according to the parameters.
function TSMAPI:FormatTextMoney(money, color, pad, trim, disabled)
	local money = tonumber(money)
	if not money then return end
	
	local isNegative = money < 0
	money = abs(money)
	local gold = floor(money / COPPER_PER_GOLD)
	local silver = floor((money - (gold * COPPER_PER_GOLD)) / COPPER_PER_SILVER)
	local copper = floor(money%COPPER_PER_SILVER)
	local text = ""
	local isFirst = true
	
	-- Trims 0 silver and/or 0 copper from the text
	if trim then
	    if gold > 0 then
			if color then
				text = format("%s%s ", color..private:PadNumber(gold, pad and not isFirst).."|r", disabled and "g" or TSM.GOLD_TEXT)
			else
				text = format("%s%s ", private:PadNumber(gold, pad and not isFirst), disabled and "g" or TSM.GOLD_TEXT)
			end
			isFirst = false
		end
		if silver > 0 then
			if color then
				text = format("%s%s%s ", text, color..private:PadNumber(silver, pad and not isFirst).."|r", disabled and "s" or TSM.SILVER_TEXT)
			else
				text = format("%s%s%s ", text, private:PadNumber(silver, pad and not isFirst), disabled and "s" or TSM.SILVER_TEXT)
			end
			isFirst = false
		end
		if copper > 0 then
			if color then
				text = format("%s%s%s ", text, color..private:PadNumber(copper, pad and not isFirst).."|r", disabled and "c" or TSM.COPPER_TEXT)
			else
				text = format("%s%s%s ", text, private:PadNumber(copper, pad and not isFirst), disabled and "c" or TSM.COPPER_TEXT)
			end
			isFirst = false
		end
		if money == 0 then
			if color then
				text = format("%s%s%s ", text, color..private:PadNumber(copper, pad and not isFirst).."|r", disabled and "c" or TSM.COPPER_TEXT)
			else
				text = format("%s%s%s ", text, private:PadNumber(copper, pad  and not isFirst), disabled and "c" or TSM.COPPER_TEXT)
			end
			isFirst = false
		end
	else
		-- Add gold
		if gold > 0 then
			if color then
				text = format("%s%s ", color..private:PadNumber(gold, pad  and not isFirst).."|r", disabled and "g" or TSM.GOLD_TEXT)
			else
				text = format("%s%s ", private:PadNumber(gold, pad  and not isFirst), disabled and "g" or TSM.GOLD_TEXT)
			end
			isFirst = false
		end
	
		-- Add silver
		if gold > 0 or silver > 0 then
			if color then
				text = format("%s%s%s ", text, color..private:PadNumber(silver, pad  and not isFirst).."|r", disabled and "s" or TSM.SILVER_TEXT)
			else
				text = format("%s%s%s ", text, private:PadNumber(silver, pad  and not isFirst), disabled and "s" or TSM.SILVER_TEXT)
			end
			isFirst = false
		end
	
		-- Add copper
		if color then
			text = format("%s%s%s ", text, color..private:PadNumber(copper, pad  and not isFirst).."|r", disabled and "c" or TSM.COPPER_TEXT)
		else
			text = format("%s%s%s ", text, private:PadNumber(copper, pad  and not isFirst), disabled and "c" or TSM.COPPER_TEXT)
		end
	end
	
	if isNegative then
		if color then
			return color .. "-|r" .. text:trim()
		else
			return "-" .. text:trim()
		end
	else
		return text:trim()
	end
end

--- Creates a formatted money string from a copper value and uses coin icon.
-- @param money The money value in copper.
-- @param color The color to make the money text (minus the coin icons). If nil, will not add any extra color formatting.
-- @param pad If true, the formatted string will be left padded.
-- @param trim If true, will not remove any 0 valued tokens. For example, "1g" instead of "1g0s0c". If money is zero, will return "0c".
-- @return Returns the formatted money text according to the parameters.
function TSMAPI:FormatTextMoneyIcon(money, color, pad, trim)
	local money = tonumber(money)
	if not money then return end
	local isNegative = money < 0
	money = abs(money)
	local gold = floor(money / COPPER_PER_GOLD)
	local silver = floor((money - (gold * COPPER_PER_GOLD)) / COPPER_PER_SILVER)
	local copper = floor(money%COPPER_PER_SILVER)
	local text = ""
	local isFirst = true
	
	-- Trims 0 silver and/or 0 copper from the text
	if trim then
	    if gold > 0 then
			if color then
				text = format("%s%s ", color..private:PadNumber(gold, pad  and not isFirst).."|r", GOLD_ICON)
			else
				text = format("%s%s ", private:PadNumber(gold, pad  and not isFirst), GOLD_ICON)
			end
			isFirst = false
		end
		if silver > 0 then
			if color then
				text = format("%s%s%s ", text, color..private:PadNumber(silver, pad  and not isFirst).."|r", SILVER_ICON)
			else
				text = format("%s%s%s ", text, private:PadNumber(silver, pad  and not isFirst), SILVER_ICON)
			end
			isFirst = false
		end
		if copper > 0 then
			if color then
				text = format("%s%s%s ", text, color..private:PadNumber(copper, pad  and not isFirst).."|r", COPPER_ICON)
			else
				text = format("%s%s%s ", text, private:PadNumber(copper, pad  and not isFirst), COPPER_ICON)
			end
			isFirst = false
		end
		if money == 0 then
			if color then
				text = format("%s%s%s ", text, color..private:PadNumber(copper, pad  and not isFirst).."|r", COPPER_ICON)
			else
				text = format("%s%s%s ", text, private:PadNumber(copper, pad  and not isFirst), COPPER_ICON)
			end
			isFirst = false
		end
	else
		-- Add gold
		if gold > 0 then
			if color then
				text = format("%s%s ", color..private:PadNumber(gold, pad  and not isFirst).."|r", GOLD_ICON)
			else
				text = format("%s%s ", private:PadNumber(gold, pad  and not isFirst), GOLD_ICON)
			end
			isFirst = false
		end
	
		-- Add silver
		if gold > 0 or silver > 0 then
			if color then
				text = format("%s%s%s ", text, color..private:PadNumber(silver, pad  and not isFirst).."|r", SILVER_ICON)
			else
				text = format("%s%s%s ", text, private:PadNumber(silver, pad  and not isFirst), SILVER_ICON)
			end
			isFirst = false
		end
	
		-- Add copper
		if color then
			text = format("%s%s%s ", text, color..private:PadNumber(copper, pad  and not isFirst).."|r", COPPER_ICON)
		else
			text = format("%s%s%s ", text, private:PadNumber(copper, pad  and not isFirst), COPPER_ICON)
		end
	end
	
	if isNegative then
		if color then
			return color .. "-|r" .. text:trim()
		else
			return "-" .. text:trim()
		end
	else
		return text:trim()
	end
end

-- Converts a formated money string back to the copper value
function TSMAPI:UnformatTextMoney(value)
	-- remove any colors
	value = gsub(value, "|cff([0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F])", "")
	value = gsub(value, "|r", "")
	
	-- extract gold/silver/copper values
	local gold = tonumber(string.match(value, "([0-9]+)g"))
	local silver = tonumber(string.match(value, "([0-9]+)s"))
	local copper = tonumber(string.match(value, "([0-9]+)c"))
		
	if gold or silver or copper then
		-- Convert it all into copper
		copper = (copper or 0) + ((gold or 0) * COPPER_PER_GOLD) + ((silver or 0) * COPPER_PER_SILVER)
	end

	return copper
end