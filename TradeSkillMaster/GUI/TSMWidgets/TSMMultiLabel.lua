-- ------------------------------------------------------------------------------ --
--                                TradeSkillMaster                                --
--                http://www.curse.com/addons/wow/tradeskill-master               --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- Much of this code is copied from .../AceGUI-3.0/widgets/AceGUIWidget-MultiLabel.lua
-- This MultiLabel widget is modified to fit TSM's theme / needs
local TSM = select(2, ...)
local Type, Version = "TSMMultiLabel", 2
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)
if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end


--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]

local methods = {
	["OnAcquire"] = function(self)
		-- height is set dynamically by the text size
		self:SetWidth(200)
		for i=1, #self.labels do
			self.labels[i]:SetText()
		end
	end,
	
	["OnWidthSet"] = function(self, width)
		self:SetLabels(self.info)
	end,

	["SetLabels"] = function(self, info)
		self.info = info
		local totalWidth = self.frame:GetWidth() or 0
		local usedWidth = 0
		local maxHeight = 0
		for i=1, #info do
			if not self.labels[i] then
				self.labels[i] = self.frame:CreateFontString(nil, "BACKGROUND")
				self.labels[i]:SetFont(TSMAPI.Design:GetContentFont("normal"))
				TSMAPI.Design:SetWidgetLabelColor(self.labels[i])
				self.labels[i]:SetJustifyH("LEFT")
				self.labels[i]:SetJustifyV("TOP")
			end
			self.labels[i]:SetText(info[i].text)
			self.labels[i]:SetPoint("TOPLEFT", self.frame, "TOPLEFT", usedWidth, 0)
			
			local labelWidth = totalWidth*(info[i].relativeWidth or 0)
			labelWidth = min(labelWidth, totalWidth-usedWidth)
			self.labels[i]:SetWidth(labelWidth)
			usedWidth = usedWidth + labelWidth
			
			if self.labels[i]:GetHeight() > maxHeight then
				maxHeight = self.labels[i]:GetHeight()
			end
		end
		self.frame:SetHeight(maxHeight)
	end,
}


--[[-----------------------------------------------------------------------------
Constructor
-------------------------------------------------------------------------------]]

local function Constructor()
	local frame = CreateFrame("Frame", nil, UIParent)
	frame:Hide()

	local widget = {
		labels = {},
		info = {},
		frame = frame,
		type  = Type,
	}
	for method, func in pairs(methods) do
		widget[method] = func
	end

	return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)