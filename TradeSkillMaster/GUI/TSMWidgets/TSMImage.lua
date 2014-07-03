-- ------------------------------------------------------------------------------ --
--                                TradeSkillMaster                                --
--                http://www.curse.com/addons/wow/tradeskill-master               --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

local TSM = select(2, ...)
local Type, Version = "TSMImage", 2
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)
if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end


--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]

local methods = {
	["OnAcquire"] = function(self)
		self:SetSizeRatio(0.5)
		self:SetWidth(100)
		self:SetText()
		self:SetImage()
	end,
	
	["OnWidthSet"] = function(self, w)
		self:SetHeight(w*self.ratio)
	end,
	
	["SetSizeRatio"] = function(self, ratio)
		self.ratio = ratio
	end,
	
	["SetImage"] = function(self, image)
		self.image:SetTexture(image)
	end,
	
	["SetText"] = function(self, text)
		self.text:SetText(text)
	end,
}


--[[-----------------------------------------------------------------------------
Constructor
-------------------------------------------------------------------------------]]

local function Constructor()
	local frame = CreateFrame("Frame", nil, UIParent)
	local image = frame:CreateTexture(nil, "ARTWORK")
	image:SetAllPoints()
	local text = frame:CreateFontString()
	text:SetFont(TSMAPI.Design:GetContentFont("normal"))
	text:SetTextColor(1, 1, 1, 1)
	text:SetPoint("BOTTOMRIGHT", -2, 2)

	local widget = {
		frame = frame,
		image = image,
		text = text,
		type  = Type
	}
	for method, func in pairs(methods) do
		widget[method] = func
	end

	return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)