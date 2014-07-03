-- ------------------------------------------------------------------------------ --
--                           TradeSkillMaster_Destroying                          --
--           http://www.curse.com/addons/wow/tradeskillmaster_destroying          --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- register this file with Ace Libraries
local TSM = select(2, ...)
TSM = LibStub("AceAddon-3.0"):NewAddon(TSM, "TSM_Destroying", "AceConsole-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster_Destroying") -- loads the localization table

--Professions--
TSM.spells = {
	milling = 51005,
	prospect = 31252,
	disenchant = 13262,
}

local savedDBDefaults = {
	global = {
		history = {},
		ignore = {},
		autoStack = true,
		autoShow = true,
		timeFormat = "ago",
		deMaxQuality = 3,
		logDays = 3,
		includeSoulbound = false,
	},
}

-- Called once the player has loaded WOW.
function TSM:OnInitialize()
	-- create shortcuts to all the modules
	for moduleName, module in pairs(TSM.modules) do
		TSM[moduleName] = module
	end
	
	-- load the savedDB into TSM.db
	TSM.db = LibStub:GetLibrary("AceDB-3.0"):New("TradeSkillMaster_DestroyingDB", savedDBDefaults, true)

	-- register this module with TSM
	TSM:RegisterModule()
end

-- registers this module with TSM by first setting all fields and then calling TSMAPI:NewModule().
function TSM:RegisterModule()
	TSM.icons = {
		{side="module", desc="Destroying", slashCommand = "destroying", callback="Options:Load", icon="Interface\\Icons\\INV_Gizmo_RocketBoot_Destroyed_02"},
	}
	TSM.slashCommands = {
		{key="destroy", label=L["Opens the Destroying frame if there's stuff in your bags to be destroyed."], callback="GUI:ShowFrame"},
	}

	TSMAPI:NewModule(TSM)
end

-- determines if an item is millable or prospectable
local scanTooltip
local destroyCache = {}
function TSM:IsDestroyable(bag, slot, itemString)
	if destroyCache[itemString] then
		return unpack(destroyCache[itemString])
	end

	local _, link, quality, _, _, iType = TSMAPI:GetSafeItemInfo(itemString)
	local WEAPON, ARMOR = GetAuctionItemClasses()
	if itemString and not TSMAPI.DisenchantingData.notDisenchantable[itemString] and (iType == ARMOR or iType == WEAPON) and (quality >= 2 and quality <= TSM.db.global.deMaxQuality) then
		destroyCache[itemString] = {IsSpellKnown(TSM.spells.disenchant) and GetSpellInfo(TSM.spells.disenchant), 1}
		return unpack(destroyCache[itemString])
	end
	
	if not scanTooltip then
		scanTooltip = CreateFrame("GameTooltip", "TSMDestroyScanTooltip", UIParent, "GameTooltipTemplate")
		scanTooltip:SetOwner(UIParent, "ANCHOR_NONE")
	end
	scanTooltip:ClearLines()
	scanTooltip:SetBagItem(bag, slot)

	for i=1, scanTooltip:NumLines() do
		local text = _G["TSMDestroyScanTooltipTextLeft"..i] and _G["TSMDestroyScanTooltipTextLeft"..i]:GetText()
		if text == ITEM_MILLABLE then
			destroyCache[itemString] = {IsSpellKnown(TSM.spells.milling) and GetSpellInfo(TSM.spells.milling), 5}
			break
		elseif text == ITEM_PROSPECTABLE then
			destroyCache[itemString] = {IsSpellKnown(TSM.spells.prospect) and GetSpellInfo(TSM.spells.prospect), 5}
			break
		end
	end
	return unpack(destroyCache[itemString] or {})
end