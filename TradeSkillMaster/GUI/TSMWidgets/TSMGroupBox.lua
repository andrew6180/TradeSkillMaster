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
local Type, Version = "TSMGroupBox", 2
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster") -- loads the localization table
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)
if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end

-- Lua APIs
local tostring, pairs = tostring, pairs

-- WoW APIs
local PlaySound = PlaySound
local GetCursorInfo, ClearCursor, GetSpellInfo = GetCursorInfo, ClearCursor, GetSpellInfo
local CreateFrame, UIParent = CreateFrame, UIParent
local _G = _G

-- local variables
local groupSelectionFrame



--[[-----------------------------------------------------------------------------
Support functions
-------------------------------------------------------------------------------]]

local function CreateGroupSelectionFrame()
	if groupSelectionFrame then return end
	groupSelectionFrame = CreateFrame("Frame", nil, TSMMainFrame1)
	TSMAPI.Design:SetFrameBackdropColor(groupSelectionFrame)
	groupSelectionFrame:SetWidth(300)
	groupSelectionFrame:SetHeight(400)
	groupSelectionFrame:SetPoint("CENTER")
	
	local label = TSMAPI.GUI:CreateLabel(groupSelectionFrame)
	label:SetPoint("TOPLEFT", 5, -2)
	label:SetPoint("TOPRIGHT", -5, -2)
	label:SetHeight(40)
	label:SetJustifyV("CENTER")
	label:SetJustifyH("CENTER")
	label:SetText(L["Select a group from the list below and click 'OK' at the bottom."])
	
	local container = CreateFrame("Frame", nil, groupSelectionFrame)
	container:SetPoint("TOPLEFT", 5, -45)
	container:SetPoint("BOTTOMRIGHT", -5, 45)
	TSMAPI.Design:SetFrameColor(container)
	groupSelectionFrame.groupTree = TSMAPI:CreateGroupTree(container, nil, nil, true)
	
	local function OnBtnClick(btn)
		if btn.which == "clear" then
			groupSelectionFrame.groupTree:ClearSelection()
		elseif btn.which == "cancel" then
			groupSelectionFrame:Hide()
		elseif btn.which == "okay" then
			local groupBox = groupSelectionFrame.obj
			local groupPath = groupSelectionFrame.groupTree:GetGroupBoxSelection()
			groupBox:SetText(TSMAPI:FormatGroupPath(groupPath))
			groupBox:Fire("OnValueChanged", groupPath)
			groupSelectionFrame:Hide()
		end
	end
	
	local btn = TSMAPI.GUI:CreateButton(groupSelectionFrame, 14)
	btn:SetPoint("BOTTOMLEFT", 5, 5)
	btn:SetWidth(90)
	btn:SetHeight(24)
	btn:SetText(L["Clear"])
	btn:SetScript("OnClick", OnBtnClick)
	btn.which = "clear"
	groupSelectionFrame.clearBtn = btn
	
	local btn = TSMAPI.GUI:CreateButton(groupSelectionFrame, 14)
	btn:SetPoint("BOTTOMLEFT", groupSelectionFrame.clearBtn, "BOTTOMRIGHT", 5, 0)
	btn:SetWidth(90)
	btn:SetHeight(24)
	btn:SetText(CANCEL)
	btn:SetScript("OnClick", OnBtnClick)
	btn.which = "cancel"
	groupSelectionFrame.cancelBtn = btn
	
	local btn = TSMAPI.GUI:CreateButton(groupSelectionFrame, 14)
	btn:SetPoint("BOTTOMLEFT", groupSelectionFrame.cancelBtn, "BOTTOMRIGHT", 5, 0)
	btn:SetPoint("BOTTOMRIGHT", -5, 5)
	btn:SetWidth(90)
	btn:SetHeight(24)
	btn:SetText(OKAY)
	btn:SetScript("OnClick", OnBtnClick)
	btn.which = "okay"
	groupSelectionFrame.okBtn = btn
	
	groupSelectionFrame:Hide()
end

local function ShowGroupSelectionFrame(parent, obj)
	groupSelectionFrame:SetFrameStrata("FULLSCREEN_DIALOG")
	groupSelectionFrame:Show()
	groupSelectionFrame:SetPoint("CENTER", parent)
	groupSelectionFrame.obj = obj
	groupSelectionFrame.groupTree:SetGropBoxSelection(obj:GetText())
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

local function Control_OnClick(frame)
	frame.obj.editbox:ClearFocus()
	ShowGroupSelectionFrame(frame, frame.obj)
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
		self:SetMaxLetters(0)
		CreateGroupSelectionFrame()
	end,

	["OnRelease"] = function(self)
	end,

	["SetDisabled"] = function(self, disabled)
		self.disabled = disabled
		TSMAPI.Design:SetWidgetTextColor(self.editbox, disabled)
		self.editbox:EnableMouse(not disabled)
		TSMAPI.Design:SetWidgetLabelColor(self.label, disabled)
	end,

	["SetText"] = function(self, text)
		self.editbox:SetText(text or "")
		self.editbox:SetCursorPosition(0)
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

	["SetMaxLetters"] = function (self, num)
		self.editbox:SetMaxLetters(num or 0)
	end,
}

--[[-----------------------------------------------------------------------------
Constructor
-------------------------------------------------------------------------------]]

local function Constructor()
	local num = AceGUI:GetNextWidgetNum(Type)
	local frame = CreateFrame("Frame", nil, UIParent)
	frame:Hide()

	local editbox = CreateFrame("EditBox", "TSMGroupBox"..num, frame)
	editbox:SetAutoFocus(false)
	editbox:SetScript("OnEnter", Control_OnEnter)
	editbox:SetScript("OnLeave", Control_OnLeave)
	editbox:SetScript("OnEditFocusGained", Control_OnClick)
	editbox:SetTextInsets(0, 0, 3, 3)
	editbox:SetMaxLetters(256)
	editbox:SetPoint("BOTTOMRIGHT", -6, 0)
	editbox:SetHeight(19)
	editbox:SetFont(TSMAPI.Design:GetContentFont("small"))
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

	local widget = {
		frame				= frame,
		alignoffset		= 30,
		editbox			= editbox,
		label				= label,
		type				= Type
	}
	for method, func in pairs(methods) do
		widget[method] = func
	end
	frame.obj = widget
	editbox.obj = widget

	return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)