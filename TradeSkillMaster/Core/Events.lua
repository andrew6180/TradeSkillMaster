-- ------------------------------------------------------------------------------ --
--                                TradeSkillMaster                                --
--                http://www.curse.com/addons/wow/tradeskill-master               --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- TSM's event handler.

local TSM = select(2, ...)
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster")
local private = {}
TSMAPI:RegisterForTracing(private, "TradeSkillMaster.Events_private")
private.objects = {}


private.eventObjectCallbacks = {
	SetCallbackAnyEvent = function(self, callback)
		self._anyEventCallback = callback
	end,
	SetCallback = function(self, event, callback, matchAll)
		self._callbacks[event] = {func = callback, matchAll = (matchAll and true or false)} -- need to convert matchAll to a boolean
	end,
	ClearAllCallbacks = function(self)
		wipe(self._callbacks)
	end
}

function TSMAPI:GetEventObject()
	local obj = {}
	obj._callbacks = {}
	obj._anyEventCallback = nil
	for name, func in pairs(private.eventObjectCallbacks) do
		obj[name] = func
	end
	tinsert(private.objects, obj)
	return obj
end

function private:OnEventFired(event, arg, fullEvent)
	local isPartial = event ~= fullEvent and true or false
	for _, obj in ipairs(private.objects) do
		if not isPartial and obj._anyEventCallback then
			obj._anyEventCallback(fullEvent, arg)
		end
		local callback = obj._callbacks[event]
		if callback then
			if isPartial == callback.matchAll then
				callback.func(fullEvent, arg)
			end
		end
	end
end

function TSMAPI:FireEvent(event, arg)
	local parts = {(":"):split(event)}
	for i=1, #parts do
		local partialEvent = table.concat(parts, ":", 1, i)
		private:OnEventFired(partialEvent, arg, event)
	end
end
