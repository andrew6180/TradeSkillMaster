-- ------------------------------------------------------------------------------ --
--                                TradeSkillMaster                                --
--          http://www.curse.com/addons/wow/tradeskillmaster_warehousing          --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- This file contains APIs related to items (itemLinks/itemStrings/etc)

local TSM = select(2, ...)

function TSMAPI:SafeTooltipLink(link)
	GameTooltip:SetHyperlink(link)
end

function TSMAPI:GetItemString(item)
	if type(item) == "string" then
		item = item:trim()
	end
	
	if type(item) ~= "string" and type(item) ~= "number" then
		return nil, "invalid arg type"
	end
	item = select(2, TSMAPI:GetSafeItemInfo(item)) or item
	if tonumber(item) then
		return "item:"..item..":0:0:0:0:0:0"
	end
	
	local itemInfo = {strfind(item, "|?c?f?f?(%x*)|?H?([^:]*):?(%d+):?(%d*):?(%d*):?(%d*):?(%d*):?(%d*):?(%-?%d*):?(%-?%d*):?(%-?%d*):?(%d*)|?h?%[?([^%[%]]*)%]?|?h?|?r?")}

	if not itemInfo[11] then return nil, "invalid link" end
	itemInfo[11] = tonumber(itemInfo[11]) or 0
	
	local it = nil
	if itemInfo[4] == "item" then
		for i=6, 10 do itemInfo[i] = 0 end
		it = table.concat(itemInfo, ":", 4, 11)
	else
		it = table.concat(itemInfo, ":", 4, 7)
	end
	return it
end

function TSMAPI:GetBaseItemString(itemString, doGroupLookup)
	if type(itemString) ~= "string" then return end
	if strsub(itemString, 1, 2) == "|c" then
		-- this is an itemLink so get the itemString first
		itemString = TSMAPI:GetItemString(itemString)
		if not itemString then return end
	end
	
	local parts = {(":"):split(itemString)}
	for i=3, #parts do
		parts[i] = 0
	end
	local baseItemString = table.concat(parts, ":")
	if not doGroupLookup then
		return baseItemString
	end
	
	if TSM.db.profile.items[itemString] and TSM.db.profile.items[baseItemString] then
		return itemString
	elseif TSM.db.profile.items[baseItemString] then
		return baseItemString
	else
		return itemString
	end
end

local itemInfoCache = {}
function TSMAPI:GetSafeItemInfo(link)
	if type(link) ~= "string" then return end
	
	if not itemInfoCache[link] then
		if strmatch(link, "item:") then
			itemInfoCache[link] = {GetItemInfo(link)}
		end
		if itemInfoCache[link] and #itemInfoCache[link] == 0 then itemInfoCache[link] = nil end
	end
	if not itemInfoCache[link] then return end
	return unpack(itemInfoCache[link])
end

--- Attempts to get the itemID from a given itemLink/itemString.
-- @param itemLink The link or itemString for the item.
-- @param ignoreGemID If true, will not attempt to get the equivalent id for the item (ie for old gems where there are multiple ids for a single item).
-- @return Returns the itemID as the first parameter. On error, will return nil as the first parameter and an error message as the second.
function TSMAPI:GetItemID(itemLink)
	if not itemLink or type(itemLink) ~= "string" then return nil, "invalid args" end
	
	-- Remove any random enchant information
	--local parts = {("/"):split(itemLink)}
	--itemLink = parts[1]

	local test = select(2, strsplit(":", itemLink))
	if not test then return nil, "invalid link" end
	
	local s, e = strfind(test, "[0-9]+")
	if not (s and e) then return nil, "not an itemLink" end
	
	local itemID = tonumber(strsub(test, s, e))
	if not itemID then return nil, "invalid number" end
	
	return itemID
end


-- check if an item is soulbound or not
local function GetTooltipCharges(tooltip)
	for id=1, tooltip:NumLines() do
		local text = _G["TSMSoulboundScanTooltipTextLeft" .. id]
		if text and text:GetText() then
			local maxCharges = strmatch(text:GetText(), "^([0-9]+) Charges?$")
			if maxCharges then
				return maxCharges
			end
		end
	end
end
local scanTooltip
local resultsCache = {lastClear=GetTime()}
function TSMAPI:IsSoulbound(bag, slot)
	if GetTime() - resultsCache.lastClear > 0.5 then
		resultsCache = {lastClear=GetTime()}
	end
	
	if not scanTooltip then
		scanTooltip = CreateFrame("GameTooltip", "TSMSoulboundScanTooltip", UIParent, "GameTooltipTemplate")
		scanTooltip:SetOwner(UIParent, "ANCHOR_NONE")
	end
	scanTooltip:ClearLines()
	
	local slotID
	if type(bag) == "string" then
		slotID = bag
		scanTooltip:SetHyperlink(slotID)
	elseif bag and slot then
		slotID = bag.."@"..slot
		local itemID = GetContainerItemID(bag, slot)
		local maxCharges
		if itemID then
			scanTooltip:SetHyperlink("item:"..itemID)
			maxCharges = GetTooltipCharges(scanTooltip)
		end
		scanTooltip:SetBagItem(bag, slot)
		if maxCharges then
			if GetTooltipCharges(scanTooltip) ~= maxCharges then
				resultsCache[slotID] = true
				return resultsCache[slotID]
			end
		end
	else
		return
	end
	
	if resultsCache[slotID] ~= nil then return resultsCache[slotID] end
	resultsCache[slotID] = false
	for id=1, scanTooltip:NumLines() do
		local text = _G["TSMSoulboundScanTooltipTextLeft" .. id]
		if text and ((text:GetText() == ITEM_BIND_ON_PICKUP and id < 4) or text:GetText() == ITEM_SOULBOUND or text:GetText() == ITEM_BIND_QUEST) then
			resultsCache[slotID] = true
			break
		end
	end
	return resultsCache[slotID]
end