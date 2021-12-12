-- ------------------------------------------------------------------------------ --
--                                TradeSkillMaster                                --
--                http://www.curse.com/addons/wow/tradeskill-master               --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- Much of this code is copied from .../AceGUI-3.0/widgets/AceGUIContainer-ScrollFrame.lua
-- This ScrollFrame container is modified to fit TSM's theme / needs
local TSM = select(2, ...)
local Type, Version = "TSMScrollFrame", 2
local AceGUI = LibStub("AceGUI-3.0")
if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end

-- Lua APIs
local pairs, assert, type = pairs, assert, type
local min, max, floor, abs = math.min, math.max, math.floor, math.abs

-- WoW APIs
local CreateFrame, UIParent = CreateFrame, UIParent

--[[-----------------------------------------------------------------------------
Support functions
-------------------------------------------------------------------------------]]
local function FixScrollOnUpdate(frame)
	frame:SetScript("OnUpdate", nil)
	frame.obj:FixScroll()
end

--[[-----------------------------------------------------------------------------
Scripts
-------------------------------------------------------------------------------]]
local function ScrollFrame_OnMouseWheel(frame, value)
	frame.obj:MoveScroll(value)
end

local function ScrollFrame_OnSizeChanged(frame)
	frame:SetScript("OnUpdate", FixScrollOnUpdate)
end

local function ScrollBar_OnScrollValueChanged(frame, value)
	frame.obj:SetScroll(value)
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
local methods = {
	["OnAcquire"] = function(self) 
		self:SetScroll(0)
		self:FixScroll()
	end,

	["OnRelease"] = function(self)
		self.status = nil
		for k in pairs(self.localstatus) do
			self.localstatus[k] = nil
		end
		self.scrollframe:SetPoint("BOTTOMRIGHT")
		self.scrollbar:Hide()
		self.scrollBarShown = nil
		self.content.height, self.content.width = nil, nil
	end,

	["SetScroll"] = function(self, value)
		local status = self.status or self.localstatus
		local viewheight = self.scrollframe:GetHeight()
		local height = self.content:GetHeight()
		local offset

		if viewheight > height then
			offset = 0
		else
			offset = floor((height - viewheight) / 1000.0 * value)
		end
		self.content:ClearAllPoints()
		self.content:SetPoint("TOPLEFT", 0, offset)
		self.content:SetPoint("TOPRIGHT", 0, offset)
		status.offset = offset
		status.scrollvalue = value
	end,

	["MoveScroll"] = function(self, value)
		local status = self.status or self.localstatus
		local height, viewheight = self.scrollframe:GetHeight(), self.content:GetHeight()
		
		if self.scrollBarShown then
			local diff = height - viewheight
			local delta = 1
			if value < 0 then
				delta = -1
			end
			self.scrollbar:SetValue(min(max(status.scrollvalue + delta*(1000/(diff/45)),0), 1000))
		end
	end,

	["FixScroll"] = function(self)
		if self.updateLock then return end
		self.updateLock = true
		local status = self.status or self.localstatus
		local height, viewheight = self.scrollframe:GetHeight(), self.content:GetHeight()
		local offset = status.offset or 0
		local curvalue = self.scrollbar:GetValue()
		-- Give us a margin of error of 2 pixels to stop some conditions that i would blame on floating point inaccuracys
		-- No-one is going to miss 2 pixels at the bottom of the frame, anyhow!
		if viewheight < height + 2 then
			if self.scrollBarShown then
				self.scrollBarShown = nil
				self.scrollbar:Hide()
				self.scrollbar:SetValue(0)
				self.scrollframe:SetPoint("BOTTOMRIGHT")
				self:DoLayout()
			end
		else
			if not self.scrollBarShown then
				self.scrollBarShown = true
				self.scrollbar:Show()
				self.scrollframe:SetPoint("BOTTOMRIGHT", -20, 0)
				self:DoLayout()
			end
			local value = (offset / (viewheight - height) * 1000)
			if value > 1000 then value = 1000 end
			self.scrollbar:SetValue(value)
			self:SetScroll(value)
			if value < 1000 then
				self.content:ClearAllPoints()
				self.content:SetPoint("TOPLEFT", 0, offset)
				self.content:SetPoint("TOPRIGHT", 0, offset)
				status.offset = offset
			end
		end
		self.updateLock = nil
	end,

	["LayoutFinished"] = function(self, width, height)
		self.content:SetHeight(height or (0 + 20))
		self.scrollframe:SetScript("OnUpdate", FixScrollOnUpdate)
		
		-- no idea why, but this MUST be here to avoid glitches with the scrollbar not showing up when it should
		self.content:GetHeight()
	end,

	["SetStatusTable"] = function(self, status)
		assert(type(status) == "table")
		self.status = status
		if not status.scrollvalue then
			status.scrollvalue = 0
		end
	end,

	["OnWidthSet"] = function(self, width)
		local content = self.content
		content.width = width
	end,

	["OnHeightSet"] = function(self, height)
		local content = self.content
		content.height = height
	end
}
--[[-----------------------------------------------------------------------------
Constructor
-------------------------------------------------------------------------------]]
local function Constructor()
	local frame = CreateFrame("Frame", nil, UIParent)
	local num = AceGUI:GetNextWidgetNum(Type)

	local scrollframe = CreateFrame("ScrollFrame", nil, frame)
	scrollframe:SetPoint("TOPLEFT")
	scrollframe:SetPoint("BOTTOMRIGHT")
	scrollframe:EnableMouseWheel(true)
	scrollframe:SetScript("OnMouseWheel", ScrollFrame_OnMouseWheel)
	scrollframe:SetScript("OnSizeChanged", ScrollFrame_OnSizeChanged)

	local scrollbar = CreateFrame("Slider", ("TSMScrollFrame%dScrollBar"):format(num), scrollframe, "UIPanelScrollBarTemplate")
	scrollbar:SetPoint("TOPLEFT", scrollframe, "TOPRIGHT", 6, -4)
	scrollbar:SetPoint("BOTTOMLEFT", scrollframe, "BOTTOMRIGHT", 6, 4)
	scrollbar:SetMinMaxValues(0, 1000)
	scrollbar:SetValueStep(1)
	scrollbar:SetValue(0)
	scrollbar:SetWidth(12)
	scrollbar:Hide()
	scrollbar:SetScript("OnValueChanged", ScrollBar_OnScrollValueChanged)
	
	local thumbTex = scrollbar:GetThumbTexture()
	thumbTex:SetPoint("CENTER")
	TSMAPI.Design:SetContentColor(thumbTex)
	thumbTex:SetHeight(150)
	thumbTex:SetWidth(scrollbar:GetWidth())
	
	local scrollbg = scrollbar:CreateTexture(nil, "BACKGROUND")
	scrollbg:SetAllPoints(scrollbar)
	TSMAPI.Design:SetFrameColor(scrollbg)
	
	_G[scrollbar:GetName().."ScrollUpButton"]:Hide()
	_G[scrollbar:GetName().."ScrollDownButton"]:Hide()

	--Container Support
	local content = CreateFrame("Frame", nil, scrollframe)
	content:SetPoint("TOPLEFT")
	content:SetPoint("TOPRIGHT")
	content:SetHeight(400)
	scrollframe:SetScrollChild(content)

	local widget = {
		localstatus = { scrollvalue = 0 },
		scrollframe = scrollframe,
		scrollbar   = scrollbar,
		content     = content,
		frame       = frame,
		type        = Type
	}
	for method, func in pairs(methods) do
		widget[method] = func
	end
	scrollframe.obj, scrollbar.obj = widget, widget
	widget.Add = TSMAPI.AddGUIElement

	return AceGUI:RegisterAsContainer(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)