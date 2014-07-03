-- ------------------------------------------------------------------------------ --
--                                TradeSkillMaster                                --
--          http://www.curse.com/addons/wow/tradeskillmaster_warehousing          --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- This file contains various delay APIs

local TSM = select(2, ...)

local delays = {}
local events = {}
local private = {} -- registers for tracing at the end

-- OnUpdate script handler for delay frames
local function DelayFrameOnUpdate(self, elapsed)
	if self.inUse == "repeat" then
		self.callback()
	elseif self.inUse == "delay" then
		self.timeLeft = self.timeLeft - elapsed
		if self.timeLeft <= 0 then
			if self.repeatDelay then
				self.timeLeft = self.repeatDelay
			else
				TSMAPI:CancelFrame(self)
			end
			if self.callback then
				self.callback()
			end
		end
	end
end

-- Helper function for creating delay frames
local function CreateDelayFrame()
	local delay = CreateFrame("Frame")
	delay:Hide()
	delay:SetScript("OnUpdate", DelayFrameOnUpdate)
	return delay
end

--- Creates a time-based delay. The callback function will be called after the specified duration.
-- Use TSMAPI:CancelFrame(label) to cancel delays (usually just used for repetitive delays).
-- @param label An arbitrary label for this delay. If a delay with this label has already been started, the request will be ignored.
-- @param duration How long before the callback should be called. This is generally accuate within 50ms (depending on frame rate).
-- @param callback The function to be called after the duration expires.
-- @param repeatDelay If you want this delay to repeat until canceled, after the initial duration expires, will restart the callback with this duration. Passing nil means no repeating.
-- @return Returns an error message as the second return value on error.
function TSMAPI:CreateTimeDelay(...)
	local label, duration, callback, repeatDelay
	if type(select(1, ...)) == "number" then
		-- use unique string as placeholder label if none specified
		label = tostring({})
		duration, callback, repeatDelay = ...
	else
		label, duration, callback, repeatDelay = ...
	end
	if not label or type(duration) ~= "number" or type(callback) ~= "function" then return nil, "invalid args", label, duration, callback, repeatDelay end

	local frameNum
	for i, frame in ipairs(delays) do
		if frame.label == label then return end
		if not frame.inUse then
			frameNum = i
		end
	end
	
	if not frameNum then
		-- all the frames are in use, create a new one
		tinsert(delays, CreateDelayFrame())
		frameNum = #delays
	end
	
	local frame = delays[frameNum]
	frame.inUse = "delay"
	frame.repeatDelay = repeatDelay
	frame.label = label
	frame.timeLeft = duration
	frame.callback = callback
	frame:Show()
end

--- The passed callback function will be called once every OnUpdate until canceled via TSMAPI:CancelFrame(label).
-- @param label An arbitrary label for this delay. If a delay with this label has already been started, the request will be ignored.
-- @param callback The function to be called every OnUpdate.
-- @return Returns an error message as the second return value on error.
function TSMAPI:CreateFunctionRepeat(label, callback)
	if not label or label == "" or type(callback) ~= "function" then return nil, "invalid args", label, callback end

	local frameNum
	for i, frame in ipairs(delays) do
		if frame.label == label then return end
		if not frame.inUse then
			frameNum = i
		end
	end
	
	if not frameNum then
		-- all the frames are in use, create a new one
		tinsert(delays, CreateDelayFrame())
		frameNum = #delays
	end
	
	local frame = delays[frameNum]
	frame.inUse = "repeat"
	frame.label = label
	frame.callback = callback
	frame:Show()
end

--- Cancels a frame created through TSMAPI:CreateTimeDelay() or TSMAPI:CreateFunctionRepeat().
-- Frames are automatically recycled to avoid memory leaks.
-- @param label The label of the frame you want to cancel.
function TSMAPI:CancelFrame(label)
	if label == "" then return end
	local delayFrame
	if type(label) == "table" then
		delayFrame = label
	else
		for i, frame in ipairs(delays) do
			if frame.label == label then
				delayFrame = frame
			end
		end
	end
	
	if delayFrame then
		delayFrame:Hide()
		delayFrame.label = nil
		delayFrame.inUse = nil
		delayFrame.validate = nil
		delayFrame.timeLeft = nil
	end
end


local function EventFrameOnUpdate(self)
	for event, data in pairs(self.events) do
		if data.eventPending and GetTime() > (data.lastCallback + data.bucketTime) then
			data.eventPending = nil
			data.lastCallback = GetTime()
			data.callback()
		end
	end
end

local function EventFrameOnEvent(self, event)
	self.events[event].eventPending = true
end

local function CreateEventFrame()
	local event = CreateFrame("Frame")
	event:Show()
	event:SetScript("OnEvent", EventFrameOnEvent)
	event:SetScript("OnUpdate", EventFrameOnUpdate)
	event.events = {}
	return event
end

function TSMAPI:CreateEventBucket(event, callback, bucketTime)
	local eventFrame
	for _, frame in ipairs(events) do
		if not frame.events[event] then
			eventFrame = frame
			break
		end
	end
	if not eventFrame then
		eventFrame = CreateEventFrame()
		tinsert(events, eventFrame)
	end
	
	eventFrame:RegisterEvent(event)
	eventFrame.events[event] = {callback=callback, bucketTime=bucketTime, lastCallback=0}
end


TSMAPI:CreateTimeDelay(0.1, function()
		-- This MUST be at the end for this file since RegisterForTracing uses TSMAPI:CreateTimeDelay() which is defined in this file.
		TSMAPI:RegisterForTracing(private, "TradeSkillMaster.Delay_private")
	end)