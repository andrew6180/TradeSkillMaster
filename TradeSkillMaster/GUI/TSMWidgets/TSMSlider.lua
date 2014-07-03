-- ------------------------------------------------------------------------------ --
--                                TradeSkillMaster                                --
--                http://www.curse.com/addons/wow/tradeskill-master               --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- Much of this code is copied from .../AceGUI-3.0/widgets/AceGUIWidget-Slider.lua
-- This Slider widget is modified to fit TSM's theme / needs
local TSM = select(2, ...)
local Type, Version = "TSMSlider", 2
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)
if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end

-- Lua APIs
local min, max, floor = math.min, math.max, math.floor
local tonumber, pairs = tonumber, pairs

-- WoW APIs
local PlaySound = PlaySound
local CreateFrame, UIParent = CreateFrame, UIParent


--[[-----------------------------------------------------------------------------
Support functions
-------------------------------------------------------------------------------]]

local function UpdateText(self)
	local value = self.value or 0
	if self.ispercent then
		self.editbox:SetText(("%s%%"):format(floor(value * 1000 + 0.5) / 10))
	else
		self.editbox:SetText(floor(value * 100 + 0.5) / 100)
	end
end

local function UpdateLabels(self)
	local min, max = (self.min or 0), (self.max or 100)
	if self.ispercent then
		self.lowtext:SetFormattedText("%s%%", (min * 100))
		self.hightext:SetFormattedText("%s%%", (max * 100))
	else
		self.lowtext:SetText(min)
		self.hightext:SetText(max)
	end
end


--[[-----------------------------------------------------------------------------
Scripts
-------------------------------------------------------------------------------]]

local function Control_OnEnter(frame)
	frame.obj:Fire("OnEnter")
end

local function Control_OnLeave(frame)
	frame.obj:Fire("OnLeave")
end

local function Frame_OnMouseDown(frame)
	frame.obj.slider:EnableMouseWheel(true)
	AceGUI:ClearFocus()
end

local function Slider_OnValueChanged(frame)
	local self = frame.obj
	if not frame.setup then
		local newvalue = frame:GetValue()
		-- workaround for 5.4 issues
		if self.step and self.step > 0 then
			local min_value = self.min or 0
			newvalue = floor((newvalue - min_value) / self.step + 0.5) * self.step + min_value
		end
		if newvalue ~= self.value and not self.disabled then
			self.value = newvalue
			self:Fire("OnValueChanged", newvalue)
		end
		if self.value then
			UpdateText(self)
		end
	end
end

local function Slider_OnMouseUp(frame, button)
	local self = frame.obj
	self.slider:EnableMouseWheel(true)
	self:Fire("OnMouseUp", self.value)
end

local function Slider_OnMouseWheel(frame, v)
	local self = frame.obj
	if not self.disabled then
		local value = self.value
		if v > 0 then
			value = min(value + (self.step or 1), self.max)
		else
			value = max(value - (self.step or 1), self.min)
		end
		self.slider:SetValue(value)
	end
end

local function EditBox_OnMouseUp(frame)
	local self = frame.obj
end

local function EditBox_OnEscapePressed(frame)
	frame:ClearFocus()
end

local function EditBox_OnEnterPressed(frame)
	local self = frame.obj
	local value = frame:GetText()
	if self.ispercent then
		value = value:gsub('%%', '')
		value = tonumber(value) / 100
	else
		value = tonumber(value)
	end
	
	if value then
		PlaySound("igMainMenuOptionCheckBoxOn")
		self.slider:SetValue(value)
		self:Fire("OnMouseUp", value)
		frame:ClearFocus()
	end
end


--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]

local methods = {
	["OnAcquire"] = function(self)
		self:SetWidth(200)
		self:SetHeight(44)
		self:SetDisabled(false)
		self:SetIsPercent(nil)
		self:SetSliderValues(0,100,1)
		self:SetValue(0)
		self.slider:EnableMouseWheel(false)
	end,

	["SetDisabled"] = function(self, disabled)
		self.disabled = disabled
		TSMAPI.Design:SetWidgetTextColor(self.editbox, disabled)
		self.slider:EnableMouse(not disabled)
		self.editbox:EnableMouse(not disabled)
		TSMAPI.Design:SetWidgetLabelColor(self.label, disabled)
		TSMAPI.Design:SetWidgetLabelColor(self.hightext, disabled)
		TSMAPI.Design:SetWidgetLabelColor(self.lowtext, disabled)
		if disabled then
			self.editbox:ClearFocus()
		end
	end,

	["SetValue"] = function(self, value)
		self.slider.setup = true
		self.slider:SetValue(value)
		self.value = value
		UpdateText(self)
		self.slider.setup = nil
	end,

	["GetValue"] = function(self)
		return self.value
	end,

	["SetLabel"] = function(self, text)
		self.label:SetText(text)
	end,

	["SetSliderValues"] = function(self, min, max, step)
		local frame = self.slider
		frame.setup = true
		self.min = min
		self.max = max
		self.step = step
		frame:SetMinMaxValues(min or 0,max or 100)
		UpdateLabels(self)
		frame:SetValueStep(step or 1)
		if self.value then
			frame:SetValue(self.value)
		end
		frame.setup = nil
	end,

	["SetIsPercent"] = function(self, value)
		self.ispercent = value
		UpdateLabels(self)
		UpdateText(self)
	end,
}


--[[-----------------------------------------------------------------------------
Constructor
-------------------------------------------------------------------------------]]

local function Constructor()
	local frame = CreateFrame("Frame", nil, UIParent)

	frame:EnableMouse(true)
	frame:SetScript("OnMouseDown", Frame_OnMouseDown)
	frame:SetScript("OnEnter", Control_OnEnter)
	frame:SetScript("OnLeave", Control_OnLeave)

	local label = frame:CreateFontString(nil, "OVERLAY")
	label:SetPoint("TOPLEFT", 0, -2)
	label:SetPoint("TOPRIGHT", 0, -2)
	label:SetJustifyH("CENTER")
	label:SetHeight(15)
	label:SetFont(TSMAPI.Design:GetContentFont("normal"))

	local slider = CreateFrame("Slider", nil, frame)
	slider:SetOrientation("HORIZONTAL")
	slider:SetHeight(6)
	slider:SetHitRectInsets(0, 0, -10, 0)
	slider:SetPoint("TOPLEFT", label, "BOTTOMLEFT", 3, -4)
	slider:SetPoint("TOPRIGHT", label, "BOTTOMRIGHT", -20, -4)
	slider:SetValue(0)
	slider:SetScript("OnValueChanged",Slider_OnValueChanged)
	slider:SetScript("OnEnter", Control_OnEnter)
	slider:SetScript("OnLeave", Control_OnLeave)
	slider:SetScript("OnMouseUp", Slider_OnMouseUp)
	slider:SetScript("OnMouseWheel", Slider_OnMouseWheel)
	TSMAPI.Design:SetFrameColor(slider)
	local thumbTex = slider:CreateTexture(nil, "ARTWORK")
	thumbTex:SetPoint("CENTER")
	TSMAPI.Design:SetContentColor(thumbTex)
	thumbTex:SetHeight(15)
	thumbTex:SetWidth(8)
	slider:SetThumbTexture(thumbTex)

	local lowtext = slider:CreateFontString(nil, "ARTWORK")
	lowtext:SetFont(TSMAPI.Design:GetContentFont("small"))
	lowtext:SetPoint("TOPLEFT", slider, "BOTTOMLEFT", 2, -4)

	local hightext = slider:CreateFontString(nil, "ARTWORK")
	hightext:SetFont(TSMAPI.Design:GetContentFont("small"))
	hightext:SetPoint("TOPRIGHT", slider, "BOTTOMRIGHT", -2, -4)

	local editbox = CreateFrame("EditBox", nil, frame)
	editbox:SetAutoFocus(false)
	editbox:SetPoint("TOP", slider, "BOTTOM", 0, -6)
	editbox:SetHeight(15)
	editbox:SetWidth(70)
	editbox:SetJustifyH("CENTER")
	editbox:EnableMouse(true)
	TSMAPI.Design:SetContentColor(editbox)
	editbox:SetScript("OnEnterPressed", EditBox_OnEnterPressed)
	editbox:SetScript("OnEscapePressed", EditBox_OnEscapePressed)
	editbox:SetScript("OnEnter", Control_OnEnter)
	editbox:SetScript("OnLeave", Control_OnLeave)
	editbox:SetFont(TSMAPI.Design:GetContentFont("normal"))
	editbox:SetShadowColor(0, 0, 0, 0)

	local widget = {
		label       = label,
		slider      = slider,
		lowtext     = lowtext,
		hightext    = hightext,
		editbox     = editbox,
		alignoffset = 25,
		frame       = frame,
		type        = Type
	}
	for method, func in pairs(methods) do
		widget[method] = func
	end
	slider.obj, editbox.obj, frame.obj = widget, widget, widget

	return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)