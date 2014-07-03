-- ------------------------------------------------------------------------------ --
--                                TradeSkillMaster                                --
--                http://www.curse.com/addons/wow/tradeskill-master               --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- Much of this code is copied from .../AceGUI-3.0/widgets/AceGUIWidget-Window.lua
-- This Window container is modified to fit TSM's theme / needs
local TSM = select(2, ...)
local Type, Version = "TSMWindow", 2
local AceGUI = LibStub("AceGUI-3.0")
if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end

-- Lua APIs
local pairs, assert, type = pairs, assert, type

-- WoW APIs
local PlaySound = PlaySound
local CreateFrame, UIParent = CreateFrame, UIParent


--[[----------------------------------------------------------------------------
Support functions
-------------------------------------------------------------------------------]]

local function frameOnClose(this)
	this.obj:Fire("OnClose")
end

local function closeOnClick(this)
	PlaySound("gsTitleOptionExit")
	this.obj:Hide()
end

local function frameOnMouseDown(this)
	this:StartMoving()
	AceGUI:ClearFocus()
end

local function frameOnMouseUp(this)
	this:StopMovingOrSizing()
end


--[[----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]

local methods = {
	["OnAcquire"] = function(self)
		self.frame:SetParent(UIParent)
		self.frame:SetFrameStrata("FULLSCREEN_DIALOG")
		self:ApplyStatus()
		self:Show()
	end,
	
	["OnRelease"] = function(self)
		self.status = nil
		for k in pairs(self.localstatus) do
			self.localstatus[k] = nil
		end
	end,
	
	["Show"] = function(self)
		self.frame:Show()
	end,
	
	["Hide"] = function(self)
		self.frame:Hide()
	end,
	
	["SetTitle"] = function(self,title)
		self.titletext:SetText(title)
	end,
	
	["ApplyStatus"] = function(self)
		local status = self.status or self.localstatus
		local frame = self.frame
		self:SetWidth(status.width or 700)
		self:SetHeight(status.height or 500)
		if status.top and status.left then
			frame:SetPoint("TOP",UIParent,"BOTTOM",0,status.top)
			frame:SetPoint("LEFT",UIParent,"LEFT",status.left,0)
		else
			frame:SetPoint("CENTER",UIParent,"CENTER")
		end
	end,
	
	["OnWidthSet"] = function(self, width)
		local content = self.content
		local contentwidth = width - 34
		if contentwidth < 0 then
			contentwidth = 0
		end
		content:SetWidth(contentwidth)
		content.width = contentwidth
	end,
	
	["OnHeightSet"] = function(self, height)
		local content = self.content
		local contentheight = height - 57
		if contentheight < 0 then
			contentheight = 0
		end
		content:SetHeight(contentheight)
		content.height = contentheight
	end,
}

--[[-----------------------------------------------------------------------------
Constructor
-------------------------------------------------------------------------------]]

local function Constructor()
	local frame = CreateFrame("Frame")
	frame:SetWidth(700)
	frame:SetHeight(500)
	frame:SetPoint("CENTER")
	frame:EnableMouse(true)
	frame:SetMovable(true)
	frame:SetResizable(true)
	frame:SetFrameStrata("FULLSCREEN_DIALOG")
	frame:SetScript("OnMouseDown", frameOnMouseDown)
	frame:SetScript("OnMouseUp", frameOnMouseUp)
	frame:SetScript("OnHide", frameOnClose)
	TSMAPI.Design:SetFrameBackdropColor(frame)
	
	local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
	close:SetPoint("TOPRIGHT", 2, 1)
	close:SetScript("OnClick", closeOnClick)
	
	local titletext = frame:CreateFontString(nil, "ARTWORK")
	titletext:SetFont(TSMAPI.Design:GetBoldFont(), 18)
	TSMAPI.Design:SetTitleTextColor(titletext)
	titletext:SetPoint("TOP", 0, -4)
	
	local line = frame:CreateTexture()
	line:SetPoint("TOPLEFT", 2, -28)
	line:SetPoint("TOPRIGHT", -2, -28)
	line:SetHeight(2)
	TSMAPI.Design:SetIconRegionColor(line)

	--Container Support
	local content = CreateFrame("Frame", nil, frame)
	content:SetPoint("TOPLEFT", frame, "TOPLEFT", 12, -32)
	content:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -12, 13)
	
	local widget = {
		frame = frame,
		type = Type,
		localstatus = {},
		content = content,
		title = title,
		titletext = titletext,
		closebutton = close,
	}
	for method, func in pairs(methods) do
		widget[method] = func
	end
	frame.obj, content.obj, close.obj = widget, widget, widget
	
	widget.Add = TSMAPI.AddGUIElement
	
	return AceGUI:RegisterAsContainer(widget)
end

AceGUI:RegisterWidgetType(Type,Constructor,Version)