-- ------------------------------------------------------------------------------ --
--                                TradeSkillMaster                                --
--                http://www.curse.com/addons/wow/tradeskill-master               --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- Much of this code is copied from .../AceGUI-3.0/widgets/AceGUIWidget-TSMMultiLineEditBox.lua
-- This TSMMultiLineEditBox widget is modified to fit TSM's theme / needs
local TSM = select(2, ...)
local Type, Version = "TSMMultiLineEditBox", 2
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)
if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end

local function Constructor()
	local widget = AceGUI:Create("MultiLineEditBox")
	return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)