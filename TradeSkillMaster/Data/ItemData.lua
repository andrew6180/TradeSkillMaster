-- ------------------------------------------------------------------------------ --
--                                TradeSkillMaster                                --
--                http://www.curse.com/addons/wow/tradeskill-master               --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- random lookup tables and other functions that don't have a home go in here

local TSM = select(2, ...)
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster")

TSMAPI.EquipLocLookup = {
	[INVTYPE_HEAD]=1, [INVTYPE_NECK]=2, [INVTYPE_SHOULDER]=3, [INVTYPE_BODY]=4, [INVTYPE_CHEST]=5,
	[INVTYPE_WAIST]=6, [INVTYPE_LEGS]=7, [INVTYPE_FEET]=8, [INVTYPE_WRIST]=9, [INVTYPE_HAND]=10,
	[INVTYPE_FINGER]=11, [INVTYPE_TRINKET]=12, [INVTYPE_CLOAK]=13, [INVTYPE_HOLDABLE]=14,
	[INVTYPE_WEAPONMAINHAND]=15, [INVTYPE_ROBE]=16, [INVTYPE_TABARD]=17, [INVTYPE_BAG]=18,
	[INVTYPE_2HWEAPON]=19, [INVTYPE_RANGED]=20, [INVTYPE_SHIELD]=21, [INVTYPE_WEAPON]=22
}

TSMAPI.SOULBOUND_MATS = {
	-- ["item:79731:0:0:0:0:0:0"] = true, -- Scroll of Wisdom
	-- ["item:76061:0:0:0:0:0:0"] = true, -- Spirit of Harmony
	-- ["item:82447:0:0:0:0:0:0"] = true, -- Imperial Silk
	-- ["item:54440:0:0:0:0:0:0"] = true, -- Dreamcloth
	-- ["item:94111:0:0:0:0:0:0"] = true, -- Lightning Steel Ingot
	-- ["item:94113:0:0:0:0:0:0"] = true, -- Jard's Peculiar Energy Source
	-- ["item:98717:0:0:0:0:0:0"] = true, -- Balanced Trillium Ingot
	-- ["item:98619:0:0:0:0:0:0"] = true, -- Celestial Cloth
	-- ["item:98617:0:0:0:0:0:0"] = true, -- Hardened Magnificent Hide
}