-- ------------------------------------------------------------------------------ --
--                                TradeSkillMaster                                --
--                http://www.curse.com/addons/wow/tradeskill-master               --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- Much of this code is copied from .../AceGUI-3.0/widgets/AceGUIWidget-EditBox.lua
-- This EditBox widget is modified to fit TSM's theme / needs
local TSM = select(2, ...)
local Type, Version = "TSMEditBox", 2
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)
if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end

-- Lua APIs
local tostring, pairs = tostring, pairs

-- WoW APIs
local PlaySound = PlaySound
local GetCursorInfo, ClearCursor, GetSpellInfo = GetCursorInfo, ClearCursor, GetSpellInfo
local CreateFrame, UIParent = CreateFrame, UIParent
local _G = _G


--[[-----------------------------------------------------------------------------
Support functions
-------------------------------------------------------------------------------]]

if not TSMEditBoxInsertLink then
	-- upgradeable hook
	hooksecurefunc("ChatEdit_InsertLink", function(...) return _G.TSMEditBoxInsertLink(...) end)
end

function _G.TSMEditBoxInsertLink(text)
	for i = 1, AceGUI:GetWidgetCount(Type) do
		local editbox = _G["TSMEditBox"..i]
		if editbox and editbox:IsVisible() and editbox:HasFocus() then
			editbox:Insert(text)
			return true
		end
	end
end

local function ShowButton(self)
	if not self.disablebutton then
		self.button:Show()
		self.editbox:SetTextInsets(0, 20, 3, 3)
	end
end

local function HideButton(self)
	self.button:Hide()
	self.editbox:SetTextInsets(0, 0, 3, 3)
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

local function Frame_OnShowFocus(frame)
	frame.obj.editbox:SetFocus()
	frame:SetScript("OnShow", nil)
end

local function EditBox_OnEscapePressed(frame)
	AceGUI:ClearFocus()
end

local function EditBox_OnEnterPressed(frame)
	local self = frame.obj
	local value = frame:GetText()
	self:ClearFocus()
	local cancel = self:Fire("OnEnterPressed", value)
	if not cancel then
		PlaySound("igMainMenuOptionCheckBoxOn")
		HideButton(self)
	end
end

local function EditBox_OnReceiveDrag(frame)
	local self = frame.obj
	local type, id, info = GetCursorInfo()
	if type == "item" then
		self:SetText(info)
		self:Fire("OnEnterPressed", info)
		ClearCursor()
	elseif type == "spell" then
		local name = GetSpellInfo(id, info)
		self:SetText(name)
		self:Fire("OnEnterPressed", name)
		ClearCursor()
	end
	HideButton(self)
	AceGUI:ClearFocus()
end

local function EditBox_OnTextChanged(frame)
	local self = frame.obj
	local value = frame:GetText()
	if tostring(value) ~= tostring(self.lasttext) then
		self:Fire("OnTextChanged", value)
		self.lasttext = value
		ShowButton(self)
	end
end

local function EditBox_OnFocusGained(frame)
	AceGUI:SetFocus(frame.obj)
	frame.obj:Fire("OnEditFocusGained")
end

local function EditBox_OnFocusLost(frame)
	frame.obj:Fire("OnEditFocusLost")
end

local function Button_OnClick(frame)
	local editbox = frame.obj.editbox
	editbox:ClearFocus()
	EditBox_OnEnterPressed(editbox)
end


--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]

local methods = {
	["OnAcquire"] = function(self)
		-- height is controlled by SetLabel
		self:SetWidth(200)
		self:SetDisabled()
		self:SetLabel()
		self:SetText()
		self:DisableButton()
		self:SetMaxLetters(0)
		TSMAPI.GUI:SetAutoComplete(self.editbox, nil)
	end,

	["OnRelease"] = function(self)
		self:ClearFocus()
	end,

	["SetDisabled"] = function(self, disabled)
		self.disabled = disabled
		TSMAPI.Design:SetWidgetTextColor(self.editbox, disabled)
		self.editbox:EnableMouse(not disabled)
		TSMAPI.Design:SetWidgetLabelColor(self.label, disabled)
		if disabled then
			self.editbox:ClearFocus()
		end
	end,

	["SetText"] = function(self, text)
		if self.disabled and text then
			text = gsub(text, "|cff([0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F])", "")
			text = gsub(text, "|r", "")
		end
		self.lasttext = text or ""
		self.editbox:SetText(text or "")
		self.editbox:SetCursorPosition(0)
		HideButton(self)
	end,

	["GetText"] = function(self, text)
		return self.editbox:GetText()
	end,

	["SetLabel"] = function(self, text)
		if text and text ~= "" then
			self.label:SetText(text)
			self.label:Show()
			self.editbox:SetPoint("TOPLEFT", 2, -18)
			self:SetHeight(44)
			self.alignoffset = 30
		else
			self.label:SetText("")
			self.label:Hide()
			self.editbox:SetPoint("TOPLEFT", 2, 0)
			self:SetHeight(26)
			self.alignoffset = 12
		end
	end,

	["DisableButton"] = function(self, disabled)
		self.disablebutton = disabled
		if disabled then
			HideButton(self)
		end
	end,

	["SetMaxLetters"] = function (self, num)
		self.editbox:SetMaxLetters(num or 0)
	end,

	["ClearFocus"] = function(self)
		self.editbox:ClearFocus()
		self.frame:SetScript("OnShow", nil)
	end,

	["SetFocus"] = function(self)
		self.editbox:SetFocus()
		if not self.frame:IsShown() then
			self.frame:SetScript("OnShow", Frame_OnShowFocus)
		end
	end,
	
	["SetAutoComplete"] = function(self, params)
		TSMAPI.GUI:SetAutoComplete(self.editbox, params)
	end,
}

--[[-----------------------------------------------------------------------------
Constructor
-------------------------------------------------------------------------------]]

local function Constructor()
	local num = AceGUI:GetNextWidgetNum(Type)
	local frame = CreateFrame("Frame", nil, UIParent)
	frame:Hide()

	local editbox = CreateFrame("EditBox", "TSMEditBox"..num, frame)
	editbox:SetAutoFocus(false)
	editbox:SetScript("OnEnter", Control_OnEnter)
	editbox:SetScript("OnLeave", Control_OnLeave)
	editbox:SetScript("OnEscapePressed", EditBox_OnEscapePressed)
	editbox:SetScript("OnEnterPressed", EditBox_OnEnterPressed)
	editbox:SetScript("OnTextChanged", EditBox_OnTextChanged)
	editbox:SetScript("OnReceiveDrag", EditBox_OnReceiveDrag)
	editbox:SetScript("OnMouseDown", EditBox_OnReceiveDrag)
	editbox:SetScript("OnEditFocusGained", EditBox_OnFocusGained)
	editbox:SetScript("OnEditFocusLost", EditBox_OnFocusLost)
	editbox:SetTextInsets(0, 0, 3, 3)
	editbox:SetMaxLetters(256)
	editbox:SetPoint("BOTTOMRIGHT", -6, 0)
	editbox:SetHeight(19)
	editbox:SetFont(TSMAPI.Design:GetContentFont("normal"))
	editbox:SetShadowColor(0, 0, 0, 0)
	TSMAPI.Design:SetContentColor(editbox)

	local label = frame:CreateFontString(nil, "OVERLAY")
	label:SetPoint("TOPLEFT", 0, -2)
	label:SetPoint("TOPRIGHT", 0, -2)
	label:SetJustifyH("LEFT")
	label:SetJustifyV("CENTER")
	label:SetHeight(18)
	label:SetFont(TSMAPI.Design:GetContentFont("normal"))
	label:SetShadowColor(0, 0, 0, 0)

	local button = CreateFrame("Button", nil, editbox, "UIPanelButtonTemplate")
	button:SetWidth(40)
	button:SetHeight(20)
	button:SetPoint("RIGHT", -2, 0)
	button:SetText(OKAY)
	button:SetScript("OnClick", Button_OnClick)
	button:Hide()

	local widget = {
		frame				= frame,
		alignoffset		= 30,
		editbox			= editbox,
		label				= label,
		button			= button,
		type				= Type
	}
	for method, func in pairs(methods) do
		widget[method] = func
	end
	editbox.obj, button.obj = widget, widget

	return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)