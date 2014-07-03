-- ------------------------------------------------------------------------------ --
--                          TradeSkillMaster_ItemTracker                          --
--          http://www.curse.com/addons/wow/tradeskillmaster_itemtracker          --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- register this file with Ace Libraries
local TSM = select(2, ...)
TSM = LibStub("AceAddon-3.0"):NewAddon(TSM, "TSM_ItemTracker", "AceEvent-3.0", "AceConsole-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster_ItemTracker")

-- default values for the savedDB
local savedDBDefaults = {
	-- any global 
	global = {
		tooltip = "simple",
	},

	-- data that is stored per realm/faction combination
	factionrealm = {
		characters = {},
		guilds = {},
		ignoreGuilds = {},
	},

	-- data that is stored per user profile
	profile = {
		marketValue = "DBMarket",
	},
}

local characterDefaults = {
	-- anything added to the characters table will have these defaults
	bags = {},
	bank = {},
	auctions = {},
	guild = nil,
	mail = {},
	mailInbox = {},
	lastUpdate = { bags = 0, bank = 0, auctions = 0, mail = 0, guild = 0 },
	account = nil,
}
TSM.characterDefaults = characterDefaults
local guildDefaults = {
	items = {},
	lastUpdate = 0,
}

-- Called once the player has loaded into the game
-- Anything that needs to be done in order to initialize the addon should go here
function TSM:OnInitialize()
	-- create shortcuts to all the modules
	for moduleName, module in pairs(TSM.modules) do
		TSM[moduleName] = module
	end

	-- load the saved variables table into TSM.db
	TSM.db = LibStub:GetLibrary("AceDB-3.0"):New("TradeSkillMaster_ItemTrackerDB", savedDBDefaults, true)
	TSM.characters = TSM.db.factionrealm.characters
	TSM.guilds = TSM.db.factionrealm.guilds
	
	-- handle connected realms for characters
	local connectedRealms = TSMAPI.GetConnectedRealms and TSMAPI:GetConnectedRealms() or {}
	for _, realm in ipairs(connectedRealms) do
		local connectedRealmData = TSM.db.sv.factionrealm[TSM.db.keys.faction.." - "..realm]
		if connectedRealmData and connectedRealmData.characters then
			for player, data in pairs(connectedRealmData.characters) do
				TSM.characters[player.."-"..realm] = data
			end
		end
	end

	-- register this module with TSM
	TSM:RegisterModule()

	-- conversion stuff
	for player, data in pairs(TSM.characters) do
		if type(data.lastUpdate) ~= "table" then
			data.lastUpdate = CopyTable(characterDefaults.lastUpdate)
		end
		data.mail = data.mail or {}
	end
	for guild, data in pairs(TSM.guilds) do
		data.lastUpdate = data.lastUpdate or guildDefaults.lastUpdate
		data.characters = nil
	end

	-- other init stuff
	local playerName, guildName = UnitName("player"), GetGuildInfo("player")
	if not TSM.characters[playerName] then
		TSM.characters[playerName] = characterDefaults
	end
	TSM.characters[playerName].account = TSMAPI.Sync:GetAccountKey()
	if guildName and not TSM.guilds[guildName] then
		TSM.guilds[guildName] = guildDefaults
	end

	-- get rid of old itemIDs
	local function ClearItemIDs(tbl)
		if not tbl then return end
		for item in pairs(tbl) do
			if tonumber(item) then
				tbl[item] = nil
			end
		end
	end

	for _, playerData in pairs(TSM.characters) do
		ClearItemIDs(playerData.bags)
		ClearItemIDs(playerData.bank)
		ClearItemIDs(playerData.auctions)
		ClearItemIDs(playerData.mail)
	end
	for _, guildData in pairs(TSM.guilds) do
		ClearItemIDs(guildData.items)
	end

	TSM.Data:Initialize()
	TSM:UpdatePlayerLookup()

	local function RemoveOldAuctions()
		for player, data in pairs(TSM.characters) do
			local lastAuctionUpdate = data.auctions and data.auctions.time
			if lastAuctionUpdate and (time() - lastAuctionUpdate) > 48 * 60 * 60 then
				wipe(TSM.characters[player].auctions)
			end
		end
	end

	TSMAPI:CreateTimeDelay("itemTrackerDeleteOldAuctions", 0, RemoveOldAuctions, 60)
end

-- registers this module with TSM by first setting all fields and then calling TSMAPI:NewModule().
function TSM:RegisterModule()
	TSM.icons = {
		{ side = "module", desc = "ItemTracker", slashCommand = "itemtracker", callback = "Config:Load", icon = "Interface\\Icons\\INV_Misc_Gem_Variety_01" },
	}
	TSM.moduleAPIs = {
		{ key = "playerlist", callback = "GetPlayers" },
		{ key = "guildlist", callback = "GetGuilds" },
		{ key = "playerbags", callback = "GetPlayerBags" },
		{ key = "playerbank", callback = "GetPlayerBank" },
		{ key = "playermail", callback = "GetPlayerMail" },
		{ key = "guildbank", callback = "GetGuildBank" },
		{ key = "playerauctions", callback = "GetPlayerAuctions" },
		{ key = "auctionstotal", callback = "GetAuctionsTotal" },
		{ key = "playertotal", callback = "GetPlayerTotal" },
		{ key = "guildtotal", callback = "GetGuildTotal" },
		{ key = "playerguildtotal", callback = "GetPlayerGuildTotal" },
		{ key = "playerguild", callback = "GetPlayerGuild" },
	}
	TSM.sync = { callback = "Sync:Callback" }
	TSM.tooltipOptions = { callback = "Config:LoadTooltipOptions" }

	TSMAPI:NewModule(TSM)
end

function TSM:GetTooltip(itemString)
	if TSM.db.global.tooltip == "hide" then return end

	local itemString = TSMAPI:GetBaseItemString(itemString, true)
	local text = {}
	local grandTotal = 0

	if TSM.db.global.tooltip == "simple" then
		local player, alts = TSM:GetPlayerTotal(itemString)
		local guild = TSM:GetGuildTotal(itemString)
		local auctions = TSM:GetAuctionsTotal(itemString)
		grandTotal = grandTotal + player + alts + guild + auctions
		if grandTotal > 0 then
			tinsert(text, { left = "  " .. "ItemTracker:", right = format(L["(%s player, %s alts, %s guild banks, %s AH)"], "|cffffffff" .. player .. "|r", "|cffffffff" .. alts .. "|r", "|cffffffff" .. guild .. "|r", "|cffffffff" .. auctions .. "|r") })
		end
	elseif TSM.db.global.tooltip == "full" then
		for name, data in pairs(TSM.characters) do
			local bags = data.bags[itemString] or 0
			local bank = data.bank[itemString] or 0
			local auctions = data.auctions[itemString] or 0
			local mail = data.mail[itemString] or 0
			local total = bags + bank + auctions + mail
			grandTotal = grandTotal + total

			local bagText = "|cffffffff" .. bags .. "|r"
			local bankText = "|cffffffff" .. bank .. "|r"
			local auctionText = "|cffffffff" .. auctions .. "|r"
			local mailText = "|cffffffff" .. mail .. "|r"
			local totalText = "|cffffffff" .. total .. "|r"

			if total > 0 then
				tinsert(text, { left = format("  %s:", name), right = format(L["%s (%s bags, %s bank, %s AH, %s mail)"], "|cffffffff" .. totalText, "|cffffffff" .. bagText, "|cffffffff" .. bankText, "|cffffffff" .. auctionText, "|cffffffff" .. mailText) })
			end
		end

		for name, data in pairs(TSM.guilds) do
			if not TSM.db.factionrealm.ignoreGuilds[name] then
				local gbank = data.items[itemString] or 0
				grandTotal = grandTotal + gbank

				local gbankText = "|cffffffff" .. (gbank) .. "|r"

				if gbank > 0 then
					tinsert(text, { left = format("  %s:", name), right = format(L["%s in guild bank"], gbankText) })
				end
			end
		end
	end

	if #text > 0 then
		tinsert(text, 1, { left = "|cffffff00" .. "TSM ItemTracker:", right = format(L["%s item(s) total"], "|cffffffff" .. grandTotal .. "|r") })
	end

	return text
end

function TSM:OnTSMDBShutdown()
	TSM.db.factionrealm.characters = {}
	local faction = TSM.db.keys.faction
	for name, playerData in pairs(TSM.characters) do
		local player, realm = ("-"):split(name)
		if realm and realm ~= "" then
			local factionrealm = faction.." - "..realm
			for key, data in pairs(TSM.db.sv.factionrealm) do
				if key == factionrealm then
					data[player] = playerData
					break
				end
			end
		else
			TSM.db.factionrealm.characters[player] = playerData
		end
	end
	
	-- not yet handling guilds for connected realms
	TSM.db.factionrealm.guilds = TSM.guilds
end

function TSM:UpdatePlayerLookup()
	TSM.playerLookup = {}
	for name in pairs(TSM.characters) do
		TSM.playerLookup[strlower(name)] = name
	end
end

function TSM:GetPlayers()
	local temp = {}
	for name in pairs(TSM.characters) do
		tinsert(temp, name)
	end
	return temp
end

function TSM:GetGuilds()
	local temp = {}
	for name in pairs(TSM.guilds) do
		tinsert(temp, name)
	end
	return temp
end

function TSM:GetPlayerBags(player)
	player = player or TSM.CURRENT_PLAYER
	player = TSM.playerLookup[player] or player
	if not player or not TSM.characters[player] then return end
	return TSM.characters[player].bags
end

function TSM:GetPlayerBank(player)
	player = player or TSM.CURRENT_PLAYER
	player = TSM.playerLookup[player] or player
	if not player or not TSM.characters[player] then return end
	return TSM.characters[player].bank
end

function TSM:GetPlayerMail(player)
	player = player or TSM.CURRENT_PLAYER
	player = TSM.playerLookup[player] or player
	if not player or not TSM.characters[player] then return end
	return TSM.characters[player].mail
end

function TSM:GetGuildBank(guild)
	guild = guild or TSM.CURRENT_GUILD
	if not guild or not TSM.guilds[guild] or TSM.db.factionrealm.ignoreGuilds[guild] then return end
	return TSM.guilds[guild].items
end

function TSM:GetPlayerAuctions(player)
	player = player or TSM.CURRENT_PLAYER
	player = TSM.playerLookup[player] or player
	if not TSM.characters[player] then return end
	return TSM.characters[player].auctions
end

function TSM:GetPlayerTotal(itemString)
	local playerTotal, altTotal = 0, 0

	for name, data in pairs(TSM.characters) do
		if name == TSM.CURRENT_PLAYER then
			playerTotal = playerTotal + (data.bags[itemString] or 0)
			playerTotal = playerTotal + (data.bank[itemString] or 0)
			playerTotal = playerTotal + (data.mail[itemString] or 0)
		else
			altTotal = altTotal + (data.bags[itemString] or 0)
			altTotal = altTotal + (data.bank[itemString] or 0)
			altTotal = altTotal + (data.mail[itemString] or 0)
		end
	end

	return playerTotal, altTotal
end

function TSM:GetGuildTotal(itemString)
	local guildTotal = 0
	for guild, data in pairs(TSM.guilds) do
		if not TSM.db.factionrealm.ignoreGuilds[guild] then
			guildTotal = guildTotal + (data.items[itemString] or 0)
		end
	end
	return guildTotal
end

function TSM:GetAuctionsTotal(itemString)
	local auctionsTotal = 0
	for _, data in pairs(TSM.characters) do
		auctionsTotal = auctionsTotal + (data.auctions[itemString] or 0)
	end
	return auctionsTotal
end

function TSM:GetPlayerGuildTotal(itemString, player)
	player = player or TSM.CURRENT_PLAYER
	player = TSM.playerLookup[player] or player
	if not player or not TSM.characters[player] then return end
	local guild = TSM.characters[player].guild
	if not guild or not TSM.guilds[guild] or TSM.db.factionrealm.ignoreGuilds[guild] then return end

	return TSM.guilds[guild].items[itemString]
end

function TSM:GetPlayerGuild(player)
	player = TSM.playerLookup[player] or player
	if not player or not TSM.characters[player] then return end
	return TSM.characters[player].guild
end