--[[

This library is intended to fix the shortfalls of using debugprofilestop() for
getting accurate sub-second timing in addons. Specifically, this library aims
to prevent any conflicts that may arrise with multiple addons using
debugprofilestart and debugprofilestop. While perfect accuracy is not
guarenteed due to the potential for an addon to load before this library and
use the original debugprofilestart/debugprofilestop functions, this library
provides a best-effort means of correcting any issues if this is the case.
The best solution is for addons to NOT use debugprofilestart() and to NOT store
a local reference to debugprofilestop(), even if they aren't using this library
directly.

-------------------------------------------------------------------------------
 
AccurateTime is hereby placed in the Public Domain
See the wowace page for usage and documentation.
Author: Sapu94 (sapu94@gmail.com)
Website: http://www.wowace.com/addons/accuratetime/
--]]

local _G = _G
local AT_VERSION = 4


-- Check if we're already loaded
-- If this is a newer version, remove the old hooks and we'll re-hook
if _G.AccurateTime then
	if _G.AccurateTime.version > AT_VERSION then
		-- newer (or same) version already loaded - abort
		return
	end
	
	-- undo hook so we can re-hook
	debugprofilestart = _G.AccurateTime._debugprofilestart
	debugprofilestop = _G.AccurateTime._debugprofilestop
else
	-- reset timer in the back-end so we avoid potential (unlikely) overflows
	-- only do this the first time we're loaded
	debugprofilestart()
end


-- setup global library reference
_G.AccurateTime = {}
AccurateTime = _G.AccurateTime
AccurateTime.version = AT_VERSION

-- Store original functions.
-- debugprofilestart should never be called, but we'll store it just in case.
AccurateTime._debugprofilestop = debugprofilestop
AccurateTime._debugprofilestart = debugprofilestart

-- key to use for direct, non-library calls to
-- debugprofilestart/debugprofilestop
AccurateTime.DEFAULT_KEY = AccurateTime.DEFAULT_KEY or {}

-- other internal variables
AccurateTime._errorTime = AccurateTime._errorTime or 0
AccurateTime._timers = AccurateTime._timers or {}


-- Gets the current time in milliseconds. Will be directly from the original
-- debugprofilestop() with any error we've detected added in. This error would
-- come solely from an addon calling the unhooked debugprofilestart().
function AccurateTime:GetAbsTime()
	return AccurateTime._debugprofilestop() + AccurateTime._errorTime
end

-- It is up to the caller to ensure the key they are using is unique.
-- Using table reference or description strings is preferable.
-- If no key is specified, a unique key will be created and returned.
-- If the timer is already running, restart it.
-- Usage: local key = AccurateTime:GetTimer([key])
function AccurateTime:StartTimer(key)
	key = key or {}
	AccurateTime._timers[key] = AccurateTime._timers[key] or AccurateTime:GetAbsTime()
	return key
end

-- gets the current value of a timer
-- Usage: local value = AccurateTime:GetTimer(key[, silent])
function AccurateTime:GetTimer(key, silent)
	assert(key, "No key specified.")
	if silent and not AccurateTime._timers[key] then return end
	assert(AccurateTime._timers[key], "No timer currently running for the given key.")
	return AccurateTime:GetAbsTime() - AccurateTime._timers[key]
end

-- Removes a timer and returns its current value.
-- Usage: local value = AccurateTime:StopTimer(key)
function AccurateTime:StopTimer(key)
	if key == AccurateTime.DEFAULT_KEY and not AccurateTime._timers[key] then
		-- Don't assert if somebody calls debugprofilestop() without starting
		-- This is a best-effort attempt to give them an accurate time
		return AccurateTime:GetAbsTime()
	end
	assert(key, "No key specified.")
	assert(AccurateTime._timers[key], "No timer currently running for the given key.")
	
	local value = AccurateTime:GetTimer(key)
	AccurateTime._timers[key] = nil
	return value
end


-- apply hooks
debugprofilestart = function() AccurateTime:StartTimer(AccurateTime.DEFAULT_KEY) end
debugprofilestop = function() return AccurateTime:StopTimer(AccurateTime.DEFAULT_KEY) end


-- Create an OnUpdate script to detect and attempt to correct other addons
-- which use the original (non-hooked) debugprofilestart(). This should in
-- theory never happen, but we'll do a best-effort correction if it does.
local function OnUpdate(self)
	local absTime = AccurateTime:GetAbsTime()
	if absTime < self.lastUpdateTime then
		-- debugprofilestart() was called and the back-end timer was reset
		-- Estimate what the absolute time should be using GetTime() (converted
		-- to ms) and add it to AccurateTime._errorTime.
		local realAbsTime = self.lastUpdateAbsTime + (GetTime() - self.lastUpdateTime) * 1000
		AccurateTime._errorTime = AccurateTime._errorTime + (realAbsTime - absTime)
	end
	self.lastUpdateAbsTime = absTime
	self.lastUpdateTime = GetTime()
end
if not AccurateTime._frame then
	-- create frame just once
	AccurateTime._frame = CreateFrame("Frame")
	AccurateTime._frame.lastUpdateTime = GetTime()
	AccurateTime._frame.lastUpdateAbsTime = 0
end
-- upgrade the frame
AccurateTime._frame:SetScript("OnUpdate", OnUpdate)

--[===[@debug@
function AccurateTimeTest()
	local start = debugprofilestop()
	for i=1, 10000000 do
	end
	print("loop", debugprofilestop()-start)
	start = debugprofilestop()
	for i=1, 10000000 do
		debugprofilestop()
	end
	print("overriden", debugprofilestop()-start)
	start = debugprofilestop()
	for i=1, 10000000 do
		AccurateTime._debugprofilestop()
	end
	print("raw", debugprofilestop()-start)
end
--@end-debug@]===]