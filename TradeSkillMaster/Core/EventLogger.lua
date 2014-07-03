-- ------------------------------------------------------------------------------ --
--                                TradeSkillMaster                                --
--                http://www.curse.com/addons/wow/tradeskill-master               --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- TSM's error handler.

local TSM = select(2, ...)
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster")

local eventObj = TSMAPI:GetEventObject()
local currentIndex = 1
local NUM_LOG_ENTRIES = 20
local debugLog = {}

local alpha = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_="
local base = #alpha
local alphaTable = {}
local alphaTableLookup = {}
for i = 1, base do
	local char = strsub(alpha, i, i)
	tinsert(alphaTable, char)
	alphaTableLookup[char] = i
end

local function EventCallback(event, arg)
	debugLog[currentIndex] = {event=event, arg=arg}
	currentIndex = currentIndex + 1
	if currentIndex > NUM_LOG_ENTRIES then
		currentIndex = 1
	end
end
eventObj:SetCallbackAnyEvent(EventCallback)


function TSM:GetEventLog()
	local temp = {}
	for i=1, #debugLog do
		local index = currentIndex - i
		if index <= 0 then
			index = index + NUM_LOG_ENTRIES
		end
		tinsert(temp, debugLog[index])
	end
	return temp
end