-- ------------------------------------------------------------------------------ --
--                                TradeSkillMaster                                --
--          http://www.curse.com/addons/wow/tradeskillmaster_warehousing          --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- This file contains various utility related to connected realms

local TSM = select(2, ...)
local lib = TSMAPI

local CONNECTED_REALMS = {
	US = {
		{"Aegwynn", "Bonechewer", "Daggerspine", "Gurubashi", "Hakkar"},
		{"Agamaggan", "Archimode", "Jaedenar", "The Underbog"},
		{"Akama", "Dragonmaw ", "Mug'thol"},
		{"Aggramar", "Fizzcrank"},
		{"Alexstrasza", "Terokkar"},
		{"Alleria", "Khadgar"},
		{"Altar of Storms", "Anetheron", "Magtheridon", "Ysondre"},
		{"Andorhal", "Scilla", "Ursin"},
		{"Antonidas", "Uldum"},
		{"Anub'arak", "Chromaggus", "Crushridge", "Garithos", "Nathrezim", "Smolderthorn"},
		{"Anvilmar", "Undermine"},
		{"Arygos", "Llane"},
		{"Auchindoun", "Cho'gall", "Laughing Skull"},
		{"Azgalor", "Azshara", "Destromath", "Thunderlord"},
		{"Azjol-Nerub", "Khaz Modan"},
		{"Balnazzar", "Gorgonnash", "The Forgotten Coast", "Warsong"},
		{"Black Dragonflight", "Gul'dan", "Skullcrusher"},
		{"Blackhand", "Galakrond"},
		{"Blackwing Lair", "Dethecus", "Detheroc", "Haomarush", "Lethon"},
		{"Bladefist", "Kul Tiras"},
		{"Blade's Edge", "Thunderhorn"},
		{"Blood Furnace", "Mannoroth", "Nazjatar"},
		{"Bloodscalp", "Boulderfist", "Dunemaul", "Maiev", "Stonemaul"},
		{"Borean Tundra", "Shadowsong"},
		{"Burning Blade", "Lightning's Blade", "Onyxia"},
		{"Bronzebeard", "Shandris"},
		{"Cairne", "Perenolde"},
		{"Coilfang", "Dalvengyr", "Dark Iron", "Demon Soul"},
		{"Darrowmere", "Windrunner"},
		{"Dath'Remar", "Khaz'goroth"},
		{"Dentarg", "Whisperwind"},
		{"Draenor", "Echo Isles"},
		{"Dragonblight", "Fenris"},
		{"Drak'Tharon", "Firetree", "Malorne", "Rivendare", "Spirestone", "Stormscale"},
		{"Drak'thul", "Skywall"},
		{"Draka", "Suramar"},
		{"Dreadmaul", "Thaurissan"},
		{"Eitrigg", "Shu'halo"},
		{"Eldre'Thalas", "Korialstrasz"},
		{"Eonar", "Velen"},
		{"Eredar", "Gorefiend", "Spinebreaker", "Wildhammer"},
		{"Executus", "Kalecgos", "Shattered Halls"},
		{"Exodar", "Medivh"},
		{"Farstriders", "Silver Hand", "Thorium Brotherhood"},
		{"Feathermoon", "Scarlet Crusade"},
		{"Frostmane", "Ner'zhul", "Tortheldrin"},
		{"Frostwolf", "Varshj"},
		{"Ghostlands", "Kael'thas"},
		{"Gundrak", "Jubei'Thos"},
		{"Hellscream", "Zangarmarsh"},
		{"Hydraxis", "Terenas"},
		{"Icecrown", "Malygos"},
		{"Kargath", "Norgannon"},
		{"Kilrogg", "Winterhoof"},
		{"Kirin Tor", "Sentinels", "Steamwheedle Cartel"},
		{"Misha", "Rexxar"},
		{"Mok'Nathal", "Silvermoon"},
		{"Muradin", "Nordrassil"},
		{"Nazgrel", "Nesingwary", "Vek'nilash"},
		{"Quel'dorei", "Sen'jin"},
		{"Runetotem", "Uther"},
		{"Ravencrest", "Uldaman"},
	},
	EU = {
		{"Aggra (Português)", "Grim Batol"},
		{"Agamaggan", "Bloodscalp", "Crushridge", "Emeriss", "Hakkar"},
		{"Ahn'Qiraj", "Balnazzar", "Boulderfist", "Chromaggus", "Daggerspine", "Laughing Skull", "Shattered Halls", "Sunstrider", "Talnivarr", "Trollbane"},
		{"Alexstrasza", "Nethersturm"},
		{"Anetheron", "Festung der Stürme", "Gul'dan", "Rajaxx"},
		{"Arak-arahm", "Rashgarroth", "Throk'Feroth"},
		{"Arathi", "Illidan", "Naxxramas", "Temple noir"},
		{"Arthas", "Blutkessel", "Vek'lor"},
		{"Auchindoun", "Dunemaul", "Jaedenar"},
		{"Area 52", "Un'Goro"},
		{"Bladefist", "Zenedar"},
		{"Bloodfeathre", "Burning Steppes", "Executus", "Kor'gall", "Shattered Hand"},
		{"Burning Blade", "Drak'thul"},
		{"Cho'gall", "Eldre'Thalas", "Sinstralis"},
		{"Colinas Pardas", "Los Errantes", "Tyrande"},
		{"Conseil des Ombres", "Culte de la Rive noire", "La Croisade écarlate"},
		{"Dalaran", "Marécage de Zangar"},
		{"Dalvengyr", "Nazjatar"},
		{"Darksorrow", "Genjuros", "Neptulon"},
		{"Das Syndikat", "Der abyssiche Rat", "Die Arguswacht", "Die Todeskrallen"},
		{"Deepholm", "Razuvious"},
		{"Deathwing", "Karazhan", "Lightning's Blade"},
		{"Dethecus", "Mug'thol", "Terrordar", "Theradras"},
		{"Dragonmaw", "Haomarush", "Spinebreaker", "Stormreaver", "Vashj"},
		{"Echsenkessel", "Mal'Ganis", "Taerar"},
		{"Eitrigg", "Krasus"},
		{"Elune", "Varimathras"},
		{"Exodar", "Minahonda"},
		{"Garona", "Ner'zhul"},
		{"Garrosh", "Nozdormu", "Shattrath"},
		{"Gilneas", "Ulduar"},
		{"Kilrogg", "Nagrand", "Runetotem"},
		{"Moonglade", "The Sha'tar"},
		{"Ravenholdt", "Scarshield Legion", "Sporeggar", "The Venture Co"},
		{"Sanguino", "Shen'dralar", "Uldum", "Zul'jin"},
		{"Skullcrusher", "Xavius"},
		{"Thunderhorn", "Wildhammer"},
	},
}

function TSMAPI:GetConnectedRealms()
	local region = strupper(strsub(GetCVar("realmList"), 1, 2))
	if not CONNECTED_REALMS[region] then return end
	local currentRealm = GetRealmName()
	
	for _, realms in ipairs(CONNECTED_REALMS[region]) do
		for i, realm in ipairs(realms) do
			if realm == currentRealm then
				local result = CopyTable(realms)
				tremove(result, i)
				return result
			end
		end
	end
end