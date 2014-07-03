-- ------------------------------------------------------------------------------ --
--                                TradeSkillMaster                                --
--                http://www.curse.com/addons/wow/tradeskill-master               --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- This SimpleGroup container is modified to fit TSM's theme / needs
local Type, Version = "TSMSimpleGroup", 2
local AceGUI = LibStub("AceGUI-3.0")
if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end

local function Constructor()
	local container = AceGUI:Create("SimpleGroup")
	container.type = Type
	container.Add = TSMAPI.AddGUIElement
	return AceGUI:RegisterAsContainer(container)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)