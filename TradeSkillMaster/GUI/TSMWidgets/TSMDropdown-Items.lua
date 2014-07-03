-- ------------------------------------------------------------------------------ --
--                                TradeSkillMaster                                --
--                http://www.curse.com/addons/wow/tradeskill-master               --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- Much of this code is copied from .../AceGUI-3.0/widgets/AceGUIWidget-Dropdown-Items.lua
-- This Dropdown-Items widget is modified to fit TSM's theme / needs
local TSM = select(2, ...)
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)

-- Lua APIs
local select, assert = select, assert

-- WoW APIs
local PlaySound = PlaySound
local CreateFrame = CreateFrame


local ItemBase = {}
do
	--[[-----------------------------------------------------------------------------
	Support functions
	-------------------------------------------------------------------------------]]

	local function fixlevels(parent,...)
		local i = 1
		local child = select(i, ...)
		while child do
			child:SetFrameLevel(parent:GetFrameLevel()+1)
			fixlevels(child, child:GetChildren())
			i = i + 1
			child = select(i, ...)
		end
	end


	--[[-----------------------------------------------------------------------------
	Scripts
	-------------------------------------------------------------------------------]]

	local function Frame_OnEnter(this)
		local self = this.obj

		if self.useHighlight then
			self.highlight:Show()
		end
		self:Fire("OnEnter")
		
		if self.specialOnEnter then
			self.specialOnEnter(self)
		end
	end

	local function Frame_OnLeave(this)
		local self = this.obj
		
		self.highlight:Hide()
		self:Fire("OnLeave")
		
		if self.specialOnLeave then
			self.specialOnLeave(self)
		end
	end


	--[[-----------------------------------------------------------------------------
	Methods
	-------------------------------------------------------------------------------]]

	local methods = {
		["OnAcquire"] = function(self)
			self:SetDisabled()
			self.frame:SetToplevel(true)
			self.frame:SetFrameStrata("FULLSCREEN_DIALOG")
		end,

		["OnRelease"] = function(self)
			self:SetDisabled()
			self.pullout = nil
			self.frame:SetParent(nil)
			self.frame:ClearAllPoints()
			self.frame:Hide()
		end,

		["SetPullout"] = function(self, pullout)
			self.pullout = pullout
			
			self.frame:SetParent(nil)
			self.frame:SetParent(pullout.itemFrame)
			self.parent = pullout.itemFrame
			fixlevels(pullout.itemFrame, pullout.itemFrame:GetChildren())
		end,

		["SetText"] = function(self, text)
			self.text:SetText(text or "")
		end,

		["GetText"] = function(self)
			return self.text:GetText()
		end,

		["SetPoint"] = function(self, ...)
			self.frame:SetPoint(...)
		end,

		["Show"] = function(self)
			self.frame:Show()
		end,

		["Hide"] = function(self)
			self.frame:Hide()
		end,

		["SetDisabled"] = function(self, disabled)
			self.disabled = disabled
			TSMAPI.Design:SetWidgetTextColor(self.text, disabled)
			self.useHighlight = not disabled
		end,

		["SetOnLeave"] = function(self, func)
			self.specialOnLeave = func
		end,

		["SetOnEnter"] = function(self, func)
			self.specialOnEnter = func
		end,
	}

	function ItemBase.Create(type)
		local count = AceGUI:GetNextWidgetNum(type)
		local frame = CreateFrame("Button", "TSMDropDownItem"..count)
		
		frame:SetHeight(17)
		frame:SetFrameStrata("FULLSCREEN_DIALOG")
		
		local text = frame:CreateFontString(nil,"OVERLAY")
		text:SetFont(TSMAPI.Design:GetContentFont("normal"))
		text:SetJustifyH("LEFT")
		text:SetPoint("TOPLEFT",frame,"TOPLEFT",18,0)
		text:SetPoint("BOTTOMRIGHT",frame,"BOTTOMRIGHT",-8,0)

		local highlight = frame:CreateTexture(nil, "OVERLAY")
		highlight:SetTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
		highlight:SetBlendMode("ADD")
		highlight:SetHeight(14)
		highlight:ClearAllPoints()
		highlight:SetPoint("RIGHT",frame,"RIGHT",-3,0)
		highlight:SetPoint("LEFT",frame,"LEFT",5,0)
		highlight:Hide()

		local check = frame:CreateTexture("OVERLAY")	
		check:SetWidth(16)
		check:SetHeight(16)
		check:SetPoint("LEFT",frame,"LEFT",3,-1)
		check:SetTexture("Interface\\Buttons\\UI-CheckBox-Check")
		check:Hide()

		local sub = frame:CreateTexture("OVERLAY")
		sub:SetWidth(16)
		sub:SetHeight(16)
		sub:SetPoint("RIGHT",frame,"RIGHT",-3,-1)
		sub:SetTexture("Interface\\ChatFrame\\ChatFrameExpandArrow")
		sub:Hide()
		
		frame:SetScript("OnEnter", Frame_OnEnter)
		frame:SetScript("OnLeave", Frame_OnLeave)
		
		local widget = {
			frame = frame,
			text = text,
			highlight = highlight,
			check = check,
			sub = sub,
			useHighlight = true,
			origMethods = methods,
			type = type,
		}
		for method, func in pairs(methods) do
			widget[method] = func
		end
		frame.obj = widget
		
		return widget
	end
end


do
	local Type, Version = "TSMDropdown-Item-Execute", 2
	
	local function Frame_OnClick(this)
		local self = this.obj
		if self.disabled then return end
		self:Fire("OnClick")
		if self.pullout then
			self.pullout:Close()
		end
	end
	
	local function Constructor()
		local item = ItemBase.Create(Type)
		item.frame:SetScript("OnClick", Frame_OnClick)
		return AceGUI:RegisterAsWidget(item)
	end
	
	AceGUI:RegisterWidgetType(Type, Constructor, Version)
end


do
	local Type, Version = "TSMDropdown-Item-Toggle", 2
	
	local function Frame_OnClick(this, button)
		local self = this.obj
		if self.disabled then return end
		self.value = not self.value
		if self.value then
			PlaySound("igMainMenuOptionCheckBoxOn")
		else
			PlaySound("igMainMenuOptionCheckBoxOff")
		end
		self:UpdateToggle()
		self:Fire("OnValueChanged", self.value)
	end
	
	local methods = {
		["UpdateToggle"] = function(self)
			if self.value then
				self.check:Show()
			else
				self.check:Hide()
			end
		end,
		
		["SetValue"] = function(self, value)
			self.value = value
			self:UpdateToggle()
		end,
		
		["GetValue"] = function(self)
			return self.value
		end,
	}
	
	local function Constructor()
		local item = ItemBase.Create(Type)
		item.frame:SetScript("OnClick", Frame_OnClick)
		for method, func in pairs(methods) do
			item[method] = func
		end
		return AceGUI:RegisterAsWidget(item)
	end
	
	AceGUI:RegisterWidgetType(Type, Constructor, Version)
end