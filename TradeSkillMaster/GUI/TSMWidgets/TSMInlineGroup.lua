-- ------------------------------------------------------------------------------ --
--                                TradeSkillMaster                                --
--                http://www.curse.com/addons/wow/tradeskill-master               --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- Much of this code is copied from .../AceGUI-3.0/widgets/AceGUIContainer-InlineGroup.lua
-- This InlineGroup container is modified to fit TSM's theme / needs
local TSM = select(2, ...)
local AceGUI = LibStub("AceGUI-3.0")
local Type, Version = "TSMInlineGroup", 2
if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end

local function Constructor()
	local container = AceGUI:Create("InlineGroup")
	container.type = Type
	container.Add = TSMAPI.AddGUIElement
	
	container.bgFrame = container.content:GetParent()
	container.border = container.content:GetParent()
	container.content:SetParent(container.frame)
	
	local title = container.frame:CreateFontString(nil, "BACKGROUND")
	title:SetPoint("TOPLEFT", 10, 0)
	title:SetPoint("TOPRIGHT", -14, 0)
	title:SetJustifyH("LEFT")
	title:SetJustifyV("BOTTOM")
	title:SetFont(TSMAPI.Design:GetBoldFont(), 18)
	TSMAPI.Design:SetTitleTextColor(title)
	container.titletext = title
	
	container.HideTitle = function(self, hideTitle)
		local frame = self.content:GetParent()
		frame:ClearAllPoints()
		if hideTitle then
			self:SetTitle()
			frame:SetPoint("TOPLEFT", 0, 0)
			frame:SetPoint("BOTTOMRIGHT", -1, 3)
		else
			frame:SetPoint("TOPLEFT", 0, -17)
			frame:SetPoint("BOTTOMRIGHT", -1, 3)
		end
	end
	
	container.HideBorder = function(self, hideBorder)
		if hideBorder then
			self.border:Hide()
		else
			self.border:Show()
		end
	end
	
	container.SetBackdrop = function(self, backdrop)
		if backdrop then
			TSMAPI.Design:SetContentColor(self.bgFrame)
		else
			TSMAPI.Design:SetFrameColor(self.bgFrame)
			self.bgFrame:SetBackdropColor(0, 0, 0, 0)
		end
	end
	
	AceGUI:RegisterAsContainer(container)
	return container
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)