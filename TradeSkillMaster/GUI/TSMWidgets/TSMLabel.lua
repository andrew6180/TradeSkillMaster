-- ------------------------------------------------------------------------------ --
--                                TradeSkillMaster                                --
--                http://www.curse.com/addons/wow/tradeskill-master               --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- Much of this code is copied from .../AceGUI-3.0/widgets/AceGUIWidget-Label.lua
-- This Label widget is modified to fit TSM's theme / needs
local TSM = select(2, ...)
local Type, Version = "TSMLabel", 2
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)
if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end

-- Lua APIs
local max, select, pairs = math.max, select, pairs

-- WoW APIs
local CreateFrame, UIParent = CreateFrame, UIParent


--[[-----------------------------------------------------------------------------
Support functions
-------------------------------------------------------------------------------]]

local function UpdateLabelAnchor(self)
	if self.resizing then return end
	local frame = self.frame
	local width = frame.width or frame:GetWidth() or 0
	local label = self.label
	local height

	label:ClearAllPoints()
	label:SetPoint("TOPLEFT")
	label:SetWidth(min(label:GetStringWidth(), width))
	height = label:GetHeight()
	
	self.resizing = true
	frame:SetHeight(height)
	frame.height = height
	self.resizing = nil
end


--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
local methods = {
	["OnAcquire"] = function(self)
		-- set the flag to stop constant size updates
		self.resizing = true
		-- height is set dynamically by the text and image size
		self:SetWidth(200)
		self:SetText()
		self:SetColor()

		-- reset the flag
		self.resizing = nil
		-- run the update explicitly
		UpdateLabelAnchor(self)
	end,

	["OnWidthSet"] = function(self, width)
		UpdateLabelAnchor(self)
	end,

	["SetText"] = function(self, text)
		self.label:SetText(text)
		UpdateLabelAnchor(self)
	end,

	["SetColor"] = function(self, r, g, b)
		if not (r and b and g) then
			TSMAPI.Design:SetWidgetLabelColor(self.label)
		else
			self.label:SetTextColor(r, g, b)
		end
	end,
}

--[[-----------------------------------------------------------------------------
Constructor
-------------------------------------------------------------------------------]]
local function Constructor()
	local frame = CreateFrame("Frame", nil, UIParent)
	frame:Hide()

	local label = frame:CreateFontString(nil, "BACKGROUND")
	label:SetJustifyH("LEFT")
	label:SetJustifyV("TOP")
	label:SetFont(TSMAPI.Design:GetContentFont("normal"))

	-- create widget
	local widget = {
		label = label,
		frame = frame,
		type  = Type,
	}
	for method, func in pairs(methods) do
		widget[method] = func
	end

	return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)
