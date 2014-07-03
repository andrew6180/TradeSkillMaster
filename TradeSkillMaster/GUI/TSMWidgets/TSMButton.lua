-- ------------------------------------------------------------------------------ --
--                                TradeSkillMaster                                --
--                http://www.curse.com/addons/wow/tradeskill-master               --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- Much of this code is copied from .../AceGUI-3.0/widgets/AceGUIWidget-Button.lua
-- This Button widget is modified to fit TSM's theme / needs
local TSM = select(2, ...)
local Type, Version = "TSMButton", 2
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)
if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end


-- Lua APIs
local pairs = pairs

-- WoW APIs
local _G = _G
local PlaySound, CreateFrame, UIParent = PlaySound, CreateFrame, UIParent


--[[-----------------------------------------------------------------------------
Scripts
-------------------------------------------------------------------------------]]

local function Button_OnClick(frame, ...)
	AceGUI:ClearFocus()
	PlaySound("igMainMenuOption")
	frame.obj:Fire("OnClick", ...)
end

local function Control_OnEnter(frame)
	frame.obj:Fire("OnEnter")
end

local function Control_OnLeave(frame)
	frame.obj:Fire("OnLeave")
end


--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]

local methods = {
	["OnAcquire"] = function(self)
		self:SetHeight(24)
		self:SetWidth(200)
		self:SetDisabled(false)
		self:SetText()
		self.btn:GetFontString():SetTextColor(1, 1, 1, 1)
	end,

	["SetText"] = function(self, text)
		self.btn:SetText(text)
	end,

	["SetDisabled"] = function(self, disabled)
		self.disabled = disabled
		if disabled then
			self.btn:Disable()
			self.btn:GetFontString():SetTextColor(1, 1, 1, 0.5)
		else
			self.btn:Enable()
			self.btn:GetFontString():SetTextColor(1, 1, 1, 1)
		end
	end
}


--[[-----------------------------------------------------------------------------
Constructor
-------------------------------------------------------------------------------]]

local function Constructor()
	local name = "TSMButton" .. AceGUI:GetNextWidgetNum(Type)
	
	local frame = CreateFrame("Frame", nil, UIParent)
	local btn = CreateFrame("Button", name, frame)
	btn:Hide()
	btn:EnableMouse(true)
	btn:SetPoint("TOPLEFT", 0, -2)
	btn:SetPoint("BOTTOMRIGHT", 0, 2)
	TSMAPI.Design:SetContentColor(btn)
	local highlight = btn:CreateTexture(nil, "HIGHLIGHT")
	highlight:SetAllPoints()
	highlight:SetTexture(1, 1, 1, .2)
	highlight:SetBlendMode("BLEND")
	btn.highlight = highlight
	btn:SetScript("OnClick", Button_OnClick)
	btn:SetScript("OnEnter", Control_OnEnter)
	btn:SetScript("OnLeave", Control_OnLeave)
	btn:Show()
	
	local label = btn:CreateFontString()
	label:SetPoint("CENTER")
	label:SetHeight(15)
	label:SetJustifyH("CENTER")
	label:SetJustifyV("CENTER")
	label:SetFont(TSMAPI.Design:GetContentFont("normal"))
	TSMAPI.Design:SetWidgetTextColor(label)
	btn:SetFontString(label)

	local widget = {
		frame = frame,
		btn = btn,
		type  = Type
	}
	for method, func in pairs(methods) do
		widget[method] = func
	end
	btn.obj = widget

	return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)