-- ------------------------------------------------------------------------------ --
--                            TradeSkillMaster_Mailing                            --
--            http://www.curse.com/addons/wow/tradeskillmaster_mailing            --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- register this file with Ace Libraries
local TSM = select(2, ...)
TSM = LibStub("AceAddon-3.0"):NewAddon(TSM, "TSM_Mailing", "AceEvent-3.0", "AceConsole-3.0")
local AceGUI = LibStub("AceGUI-3.0") -- load the AceGUI libraries
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster_Mailing") -- loads the localization table

TSM.SPELLING_WARNING = "|cffff0000"..L["BE SURE TO SPELL THE NAME CORRECTLY!"].."|r"
local private = {lootIndex=1, recheckTime=1, allowTimerStart=true}

local savedDBDefaults = {
	global = {
		defaultMailTab = true,
		autoCheck = true,
		displayMoneyCollected = true,
		sendItemsIndividually = false,
		resendDelay = 1,
		sendDelay = 0.5,
		optionsTreeStatus = {},
		openAllLeaveGold = false,
		inboxMessages = true,
		sendMessages = true,
		defaultPage = 1,
		showReloadBtn = true,
		keepMailSpace = 0,
	},
	factionrealm = {
		deMailTarget = "",
		mailTargets = {},
		mailItems = {},
	},
	char = {
		goldMailTarget = "",
		goldKeepAmount = 1000000,
	},
}

function TSM:OnEnable()
	-- load the savedDB into TSM.db
	TSM.db = LibStub:GetLibrary("AceDB-3.0"):New("TradeSkillMaster_MailingDB", savedDBDefaults, true)
	
	for moduleName, module in pairs(TSM.modules) do
		TSM[moduleName] = module
	end
	
	-- register this module with TSM
	TSM:RegisterModule()
	
	-- temporary check
	TSMAPI:Verify(TSMAPI.IsPlayer, "You need to update your TradeSkillMaster addon. Otherwise, you may see lua errors!")
end

-- registers this module with TSM by first setting all fields and then calling TSMAPI:NewModule().
function TSM:RegisterModule()
	TSM.operations = {maxOperations=12, callbackOptions="Options:Load", callbackInfo="GetOperationInfo"}
	TSM.moduleAPIs = {
		{key="mailItems", callback="AutoMail:SendItems"},
	}
	
	TSMAPI:NewModule(TSM)
end

TSM.operationDefaults = {
	maxQtyEnabled = nil,
	maxQty = 10,
	target = "",
	restock = nil, -- take into account how many the target already has
	restockGBank = nil,
	keepQty = 0,
	ignorePlayer = {},
	ignoreFactionrealm = {},
	relationships = {},
}

function TSM:GetOperationInfo(operationName)
	local operation = TSM.operations[operationName]
	if not operation then return end
	if operation.target == "" then return end
	
	if operation.maxQtyEnabled then
		return format(L["Mailing up to %d to %s."], operation.maxQty, operation.target)
	else
		return format(L["Mailing all to %s."], operation.target)
	end
end