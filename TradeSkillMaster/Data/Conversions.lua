-- ------------------------------------------------------------------------------ --
--                                TradeSkillMaster                                --
--                http://www.curse.com/addons/wow/tradeskill-master               --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

local TSM = select(2, ...)
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster") -- loads the localization table


local conversions = {
	-- Epic WotLK gems
	["item:36919:0:0:0:0:0:0"] = { -- Cardinal Ruby
		["item:36910:0:0:0:0:0:0"] = {rate=.03, source="prospect"},
	},
	["item:36922:0:0:0:0:0:0"] = { -- King's Amber
		["item:36910:0:0:0:0:0:0"] = {rate=.03, source="prospect"},
	},
	["item:36925:0:0:0:0:0:0"] = { -- Majestic Zircon
		["item:36910:0:0:0:0:0:0"] = {rate=.03, source="prospect"},
	},
	["item:36928:0:0:0:0:0:0"] = { -- Dreadstone
		["item:36910:0:0:0:0:0:0"] = {rate=.03, source="prospect"},
	},
	["item:36931:0:0:0:0:0:0"] = { -- Ametrine
		["item:36910:0:0:0:0:0:0"] = {rate=.03, source="prospect"},
	},
	["item:36934:0:0:0:0:0:0"] = { -- Eye of Zul
		["item:36910:0:0:0:0:0:0"] = {rate=.03, source="prospect"},
	},
	-- common pigments (inks)
	["item:39151:0:0:0:0:0:0"] = { -- Alabaster Pigment (Ivory / Moonglow Ink)
		["item:765:0:0:0:0:0:0"] = {rate=.5, source="mill"},
		["item:2447:0:0:0:0:0:0"] = {rate=.6, source="mill"},
		["item:2449:0:0:0:0:0:0"] = {rate=.6, source="mill"},
	},
	["item:39343:0:0:0:0:0:0"] = { -- Azure Pigment (Ink of the Sea)
		["item:39969:0:0:0:0:0:0"] = {rate=.5, source="mill"},
		["item:36904:0:0:0:0:0:0"] = {rate=.5, source="mill"},
		["item:36907:0:0:0:0:0:0"] = {rate=.5, source="mill"},
		["item:36901:0:0:0:0:0:0"] = {rate=.5, source="mill"},
		["item:39970:0:0:0:0:0:0"] = {rate=.5, source="mill"},
		["item:37921:0:0:0:0:0:0"] = {rate=.5, source="mill"},
		["item:36905:0:0:0:0:0:0"] = {rate=.6, source="mill"},
		["item:36906:0:0:0:0:0:0"] = {rate=.6, source="mill"},
		["item:36903:0:0:0:0:0:0"] = {rate=.6, source="mill"},
	},
	["item:61979:0:0:0:0:0:0"] = { -- Ashen Pigment (Blackfallow Ink)
		["item:52983:0:0:0:0:0:0"] = {rate=.5, source="mill"},
		["item:52984:0:0:0:0:0:0"] = {rate=.5, source="mill"},
		["item:52985:0:0:0:0:0:0"] = {rate=.5, source="mill"},
		["item:52986:0:0:0:0:0:0"] = {rate=.5, source="mill"},
		["item:52987:0:0:0:0:0:0"] = {rate=.6, source="mill"},
		["item:52988:0:0:0:0:0:0"] = {rate=.6, source="mill"},
	},
	["item:39334:0:0:0:0:0:0"] = { -- Dusky Pigment (Midnight Ink)
		["item:785:0:0:0:0:0:0"] = {rate=.5, source="mill"},
		["item:2450:0:0:0:0:0:0"] = {rate=.5, source="mill"},
		["item:2452:0:0:0:0:0:0"] = {rate=.5, source="mill"},
		["item:2453:0:0:0:0:0:0"] = {rate=.6, source="mill"},
		["item:3820:0:0:0:0:0:0"] = {rate=.6, source="mill"},
	},
	["item:39339:0:0:0:0:0:0"] = { -- Emerald Pigment (Jadefire Ink)
		["item:3818:0:0:0:0:0:0"] = {rate=.5, source="mill"},
		["item:3821:0:0:0:0:0:0"] = {rate=.5, source="mill"},
		["item:3358:0:0:0:0:0:0"] = {rate=.6, source="mill"},
		["item:3819:0:0:0:0:0:0"] = {rate=.6, source="mill"},
	},
	["item:39338:0:0:0:0:0:0"] = { -- Golden Pigment (Lion's Ink)
		["item:3355:0:0:0:0:0:0"] = {rate=.5, source="mill"},
		["item:3369:0:0:0:0:0:0"] = {rate=.5, source="mill"},
		["item:3356:0:0:0:0:0:0"] = {rate=.6, source="mill"},
		["item:3357:0:0:0:0:0:0"] = {rate=.6, source="mill"},
	},
	["item:39342:0:0:0:0:0:0"] = { -- Nether Pigment (Ethereal Ink)
		["item:22786:0:0:0:0:0:0"] = {rate=.5, source="mill"},
		["item:22785:0:0:0:0:0:0"] = {rate=.5, source="mill"},
		["item:22789:0:0:0:0:0:0"] = {rate=.5, source="mill"},
		["item:22787:0:0:0:0:0:0"] = {rate=.5, source="mill"},
		["item:22790:0:0:0:0:0:0"] = {rate=.6, source="mill"},
		["item:22793:0:0:0:0:0:0"] = {rate=.6, source="mill"},
		["item:22791:0:0:0:0:0:0"] = {rate=.6, source="mill"},
		["item:22792:0:0:0:0:0:0"] = {rate=.6, source="mill"},
	},
	["item:79251:0:0:0:0:0:0"] = { -- Shadow Pigment (Ink of Dreams)
		["item:72237:0:0:0:0:0:0"] = {rate=.5, source="mill"},
		["item:72234:0:0:0:0:0:0"] = {rate=.5, source="mill"},
		["item:79010:0:0:0:0:0:0"] = {rate=.5, source="mill"},
		["item:72235:0:0:0:0:0:0"] = {rate=.5, source="mill"},
		["item:79011:0:0:0:0:0:0"] = {rate=.6, source="mill"},
		["item:89639:0:0:0:0:0:0"] = {rate=.5, source="mill"},
	},
	["item:39341:0:0:0:0:0:0"] = { -- Silvery Pigment (Shimmering Ink)
		["item:13464:0:0:0:0:0:0"] = {rate=.5, source="mill"},
		["item:13463:0:0:0:0:0:0"] = {rate=.5, source="mill"},
		["item:13465:0:0:0:0:0:0"] = {rate=.6, source="mill"},
		["item:13466:0:0:0:0:0:0"] = {rate=.6, source="mill"},
		["item:13467:0:0:0:0:0:0"] = {rate=.6, source="mill"},
	},
	["item:39340:0:0:0:0:0:0"] = { -- Violet Pigment (Celestial Ink)
		["item:4625:0:0:0:0:0:0"] = {rate=.5, source="mill"},
		["item:8831:0:0:0:0:0:0"] = {rate=.5, source="mill"},
		["item:8838:0:0:0:0:0:0"] = {rate=.5, source="mill"},
		["item:8839:0:0:0:0:0:0"] = {rate=.6, source="mill"},
		["item:8845:0:0:0:0:0:0"] = {rate=.6, source="mill"},
		["item:8846:0:0:0:0:0:0"] = {rate=.6, source="mill"},
	},
	
	-- rare pigments (inks)
	["item:43109:0:0:0:0:0:0"] = { -- Icy Pigment (Snowfall Ink)
		["item:39969:0:0:0:0:0:0"] = {rate=.05, source="mill"},
		["item:36904:0:0:0:0:0:0"] = {rate=.05, source="mill"},
		["item:36907:0:0:0:0:0:0"] = {rate=.05, source="mill"},
		["item:36901:0:0:0:0:0:0"] = {rate=.05, source="mill"},
		["item:39970:0:0:0:0:0:0"] = {rate=.05, source="mill"},
		["item:37921:0:0:0:0:0:0"] = {rate=.05, source="mill"},
		["item:36905:0:0:0:0:0:0"] = {rate=.1, source="mill"},
		["item:36906:0:0:0:0:0:0"] = {rate=.1, source="mill"},
		["item:36903:0:0:0:0:0:0"] = {rate=.1, source="mill"},
	},
	["item:61980:0:0:0:0:0:0"] = { -- Burning Embers (Inferno Ink)
		["item:52983:0:0:0:0:0:0"] = {rate=.05, source="mill"},
		["item:52984:0:0:0:0:0:0"] = {rate=.05, source="mill"},
		["item:52985:0:0:0:0:0:0"] = {rate=.05, source="mill"},
		["item:52986:0:0:0:0:0:0"] = {rate=.05, source="mill"},
		["item:52987:0:0:0:0:0:0"] = {rate=.1, source="mill"},
		["item:52988:0:0:0:0:0:0"] = {rate=.1, source="mill"},
	},
	["item:43104:0:0:0:0:0:0"] = { -- Burnt Pigment (Dawnstar Ink)
		["item:3356:0:0:0:0:0:0"] = {rate=.1, source="mill"},
		["item:3357:0:0:0:0:0:0"] = {rate=.1, source="mill"},
		["item:3369:0:0:0:0:0:0"] = {rate=.05, source="mill"},
		["item:3355:0:0:0:0:0:0"] = {rate=.05, source="mill"},
	},
	["item:43108:0:0:0:0:0:0"] = { -- Ebon Pigment (Darkflame Ink)
		["item:22792:0:0:0:0:0:0"] = {rate=.1, source="mill"},
		["item:22790:0:0:0:0:0:0"] = {rate=.1, source="mill"},
		["item:22791:0:0:0:0:0:0"] = {rate=.1, source="mill"},
		["item:22793:0:0:0:0:0:0"] = {rate=.1, source="mill"},
		["item:22786:0:0:0:0:0:0"] = {rate=.05, source="mill"},
		["item:22785:0:0:0:0:0:0"] = {rate=.05, source="mill"},
		["item:22787:0:0:0:0:0:0"] = {rate=.05, source="mill"},
		["item:22789:0:0:0:0:0:0"] = {rate=.05, source="mill"},
	},
	["item:43105:0:0:0:0:0:0"] = { -- Indigo Pigment (Royal Ink)
		["item:3358:0:0:0:0:0:0"] = {rate=.1, source="mill"},
		["item:3819:0:0:0:0:0:0"] = {rate=.1, source="mill"},
		["item:3821:0:0:0:0:0:0"] = {rate=.05, source="mill"},
		["item:3818:0:0:0:0:0:0"] = {rate=.05, source="mill"},
	},
	["item:79253:0:0:0:0:0:0"] = { -- Misty Pigment (Starlight Ink)
		["item:72237:0:0:0:0:0:0"] = {rate=.05, source="mill"},
		["item:72234:0:0:0:0:0:0"] = {rate=.05, source="mill"},
		["item:79010:0:0:0:0:0:0"] = {rate=.05, source="mill"},
		["item:72235:0:0:0:0:0:0"] = {rate=.05, source="mill"},
		["item:79011:0:0:0:0:0:0"] = {rate=.1, source="mill"},
		["item:89639:0:0:0:0:0:0"] = {rate=.05, source="mill"},
	},
	["item:43106:0:0:0:0:0:0"] = { -- Ruby Pigment (Fiery Ink)
		["item:4625:0:0:0:0:0:0"] = {rate=.05, source="mill"},
		["item:8838:0:0:0:0:0:0"] = {rate=.05, source="mill"},
		["item:8831:0:0:0:0:0:0"] = {rate=.05, source="mill"},
		["item:8845:0:0:0:0:0:0"] = {rate=.1, source="mill"},
		["item:8846:0:0:0:0:0:0"] = {rate=.1, source="mill"},
		["item:8839:0:0:0:0:0:0"] = {rate=.1, source="mill"},
	},
	["item:43107:0:0:0:0:0:0"] = { -- Sapphire Pigment (Ink of the Sky)
		["item:13463:0:0:0:0:0:0"] = {rate=.05, source="mill"},
		["item:13464:0:0:0:0:0:0"] = {rate=.05, source="mill"},
		["item:13465:0:0:0:0:0:0"] = {rate=.1, source="mill"},
		["item:13466:0:0:0:0:0:0"] = {rate=.1, source="mill"},
		["item:13467:0:0:0:0:0:0"] = {rate=.1, source="mill"},
	},
	["item:43103:0:0:0:0:0:0"] = { -- Verdant Pigment (Hunter's Ink)
		["item:2453:0:0:0:0:0:0"] = {rate=.1, source="mill"},
		["item:3820:0:0:0:0:0:0"] = {rate=.1, source="mill"},
		["item:2450:0:0:0:0:0:0"] = {rate=.05, source="mill"},
		["item:785:0:0:0:0:0:0"] = {rate=.05, source="mill"},
		["item:2452:0:0:0:0:0:0"] = {rate=.05, source="mill"},
	},

	--Vanilla Gems
	["item:774:0:0:0:0:0:0"] = { -- malachite
		["item:2770:0:0:0:0:0:0"] = {rate=.5, source="prospect"},
	},
	["item:818:0:0:0:0:0:0"] = { -- Tigerseye
		["item:2770:0:0:0:0:0:0"] = {rate=.5, source="prospect"},
	},
	["item:1210:0:0:0:0:0:0"] = { -- Shadowgem
		["item:2771:0:0:0:0:0:0"] = {rate=.4, source="prospect"},
		["item:2770:0:0:0:0:0:0"] = {rate=.1, source="prospect"},
	},
	["item:1206:0:0:0:0:0:0"] = { -- Moss Agate
		["item:2771:0:0:0:0:0:0"] = {rate=.3, source="prospect"},
	},
	["item:1705:0:0:0:0:0:0"] = { -- Lesser moonstone
		["item:2771:0:0:0:0:0:0"] = {rate=.4, source="prospect"},
		["item:2772:0:0:0:0:0:0"] = { rate=.3, source="prospect"},
	},
	["item:1529:0:0:0:0:0:0"] = { -- Jade
		["item:2772:0:0:0:0:0:0"] = {rate=.4, source="prospect"},
		["item:2771:0:0:0:0:0:0"] = {rate=.03, source="prospect"},
	},
	["item:3864:0:0:0:0:0:0"] = { -- Citrine
		["item:2772:0:0:0:0:0:0"] = {rate=.4, source="prospect"}, --	iron
		["item:3858:0:0:0:0:0:0"] = {rate=.3, source="prospect"}, -- mith
		["item:2771:0:0:0:0:0:0"] = {rate=.03, source="prospect"}, -- tin
	},
	["item:7909:0:0:0:0:0:0"] = { -- Aquamarine
		["item:3858:0:0:0:0:0:0"] = {rate=.3, source="prospect"},
		["item:2772:0:0:0:0:0:0"] = {rate=.05, source="prospect"},
		["item:2771:0:0:0:0:0:0"] = {rate=.03, source="prospect"},
	},
	["item:7910:0:0:0:0:0:0"] = { -- Star Ruby
		["item:3858:0:0:0:0:0:0"] = {rate=.4, source="prospect"},
		["item:10620:0:0:0:0:0:0"] = {rate=.1, source="prospect"},
		["item:2772:0:0:0:0:0:0"] = {rate=.05, source="prospect"},
	},
	["item:12361:0:0:0:0:0:0"] = { -- Blue Sapphire
		["item:10620:0:0:0:0:0:0"] = {rate=.3, source="prospect"},
		["item:3858:0:0:0:0:0:0"] = {rate=.03, source="prospect"},
	},
	["item:12799:0:0:0:0:0:0"] = { -- Large Opal
		["item:10620:0:0:0:0:0:0"] = {rate =.3, source="prospect"}, -- thorium
		["item:3858:0:0:0:0:0:0"] = {rate=.03, source="prospect"}, -- Mith
	},
	["item:12800:0:0:0:0:0:0"] = { -- Azerothian Diamond
		["item:10620:0:0:0:0:0:0"] = {rate=.3, source="prospect"},
		["item:3858:0:0:0:0:0:0"] = {rate=.02, source="prospect"},
	},
	["item:12364:0:0:0:0:0:0"] = { -- Huge Emerald
		["item:10620:0:0:0:0:0:0"] = {rate=.3, source="prospect"},
		["item:3858:0:0:0:0:0:0"] = {rate=.02, source="prospect"},
	},

	-- uncommon gems
	["item:23117:0:0:0:0:0:0"] = { -- Azure Moonstone
		["item:23424:0:0:0:0:0:0"] = {rate=.2, source="prospect"},
		["item:23425:0:0:0:0:0:0"] = {rate=.2, source="prospect"},
	},
	["item:23077:0:0:0:0:0:0"] = { -- Blood Garnet
		["item:23424:0:0:0:0:0:0"] = {rate=.2, source="prospect"},
		["item:23425:0:0:0:0:0:0"] = {rate=.2, source="prospect"},
	},
	["item:23079:0:0:0:0:0:0"] = { -- Deep Peridot
		["item:23424:0:0:0:0:0:0"] = {rate=.2, source="prospect"},
		["item:23425:0:0:0:0:0:0"] = {rate=.2, source="prospect"},
	},
	["item:21929:0:0:0:0:0:0"] = { -- Flame Spessarite
		["item:23424:0:0:0:0:0:0"] = {rate=.2, source="prospect"},
		["item:23425:0:0:0:0:0:0"] = {rate=.2, source="prospect"},
	},
	["item:23112:0:0:0:0:0:0"] = { -- Golden Draenite
		["item:23424:0:0:0:0:0:0"] = {rate=.2, source="prospect"},
		["item:23425:0:0:0:0:0:0"] = {rate=.2, source="prospect"},
	},
	["item:23107:0:0:0:0:0:0"] = { -- Shadow Draenite
		["item:23424:0:0:0:0:0:0"] = {rate=.2, source="prospect"},
		["item:23425:0:0:0:0:0:0"] = {rate=.2, source="prospect"},
	},
	["item:36917:0:0:0:0:0:0"] = { -- Bloodstone
		["item:36909:0:0:0:0:0:0"] = {rate=.25, source="prospect"},
		["item:36912:0:0:0:0:0:0"] = {rate=.2, source="prospect"},
		["item:36910:0:0:0:0:0:0"] = {rate=.25, source="prospect"},
	},
	["item:36923:0:0:0:0:0:0"] = { -- Chalcedony
		["item:36909:0:0:0:0:0:0"] = {rate=.25, source="prospect"},
		["item:36912:0:0:0:0:0:0"] = {rate=.2, source="prospect"},
		["item:36910:0:0:0:0:0:0"] = {rate=.25, source="prospect"},
	},
	["item:36932:0:0:0:0:0:0"] = { -- Dark Jade
		["item:36909:0:0:0:0:0:0"] = {rate=.25, source="prospect"},
		["item:36912:0:0:0:0:0:0"] = {rate=.2, source="prospect"},
		["item:36910:0:0:0:0:0:0"] = {rate=.25, source="prospect"},
	},
	["item:36929:0:0:0:0:0:0"] = { -- Huge Citrine
		["item:36909:0:0:0:0:0:0"] = {rate=.25, source="prospect"},
		["item:36912:0:0:0:0:0:0"] = {rate=.2, source="prospect"},
		["item:36910:0:0:0:0:0:0"] = {rate=.25, source="prospect"},
	},
	["item:36926:0:0:0:0:0:0"] = { -- Shadow Crystal
		["item:36909:0:0:0:0:0:0"] = {rate=.25, source="prospect"},
		["item:36912:0:0:0:0:0:0"] = {rate=.2, source="prospect"},
		["item:36910:0:0:0:0:0:0"] = {rate=.25, source="prospect"},
	},
	["item:36920:0:0:0:0:0:0"] = { -- Sun Crystal
		["item:36909:0:0:0:0:0:0"] = {rate=.25, source="prospect"},
		["item:36912:0:0:0:0:0:0"] = {rate=.2, source="prospect"},
		["item:36910:0:0:0:0:0:0"] = {rate=.25, source="prospect"},
	},
	-- ["item:52182:0:0:0:0:0:0"] = { -- Jasper
		-- ["item:53038:0:0:0:0:0:0"] = {rate=.25, source="prospect"},
		-- ["item:52185:0:0:0:0:0:0"] = {rate=.2, source="prospect"},
		-- ["item:52183:0:0:0:0:0:0"] = {rate=.2, source="prospect"},
	-- },
	-- ["item:52180:0:0:0:0:0:0"] = { -- Nightstone
		-- ["item:53038:0:0:0:0:0:0"] = {rate=.25, source="prospect"},
		-- ["item:52185:0:0:0:0:0:0"] = {rate=.2, source="prospect"},
		-- ["item:52183:0:0:0:0:0:0"] = {rate=.2, source="prospect"},
	-- },
	-- ["item:52178:0:0:0:0:0:0"] = { -- Zephyrite
		-- ["item:53038:0:0:0:0:0:0"] = {rate=.25, source="prospect"},
		-- ["item:52185:0:0:0:0:0:0"] = {rate=.2, source="prospect"},
		-- ["item:52183:0:0:0:0:0:0"] = {rate=.2, source="prospect"},
	-- },
	-- ["item:52179:0:0:0:0:0:0"] = { -- Alicite
		-- ["item:53038:0:0:0:0:0:0"] = {rate=.25, source="prospect"},
		-- ["item:52185:0:0:0:0:0:0"] = {rate=.2, source="prospect"},
		-- ["item:52183:0:0:0:0:0:0"] = {rate=.2, source="prospect"},
	-- },
	-- ["item:52177:0:0:0:0:0:0"] = { -- Carnelian
		-- ["item:53038:0:0:0:0:0:0"] = {rate=.25, source="prospect"},
		-- ["item:52185:0:0:0:0:0:0"] = {rate=.2, source="prospect"},
		-- ["item:52183:0:0:0:0:0:0"] = {rate=.2, source="prospect"},
	-- },
	-- ["item:52181:0:0:0:0:0:0"] = { -- Hessonite
		-- ["item:53038:0:0:0:0:0:0"] = {rate=.25, source="prospect"},
		-- ["item:52185:0:0:0:0:0:0"] = {rate=.2, source="prospect"},
		-- ["item:52183:0:0:0:0:0:0"] = {rate=.2, source="prospect"},
	-- },
	-- ["item:76130:0:0:0:0:0:0"] = { -- Tiger Opal
		-- ["item:72092:0:0:0:0:0:0"] = {rate=.25, source="prospect"},
		-- ["item:72093:0:0:0:0:0:0"] = {rate=.25, source="prospect"},
		-- ["item:72103:0:0:0:0:0:0"] = {rate=.2, source="prospect"},
		-- ["item:72094:0:0:0:0:0:0"] = {rate=.2, source="prospect"},
	-- },
	-- ["item:76133:0:0:0:0:0:0"] = { -- Lapis Lazuli
		-- ["item:72092:0:0:0:0:0:0"] = {rate=.25, source="prospect"},
		-- ["item:72093:0:0:0:0:0:0"] = {rate=.25, source="prospect"},
		-- ["item:72103:0:0:0:0:0:0"] = {rate=.2, source="prospect"},
		-- ["item:72094:0:0:0:0:0:0"] = {rate=.2, source="prospect"},
	-- },
	-- ["item:76134:0:0:0:0:0:0"] = { -- Sunstone
		-- ["item:72092:0:0:0:0:0:0"] = {rate=.25, source="prospect"},
		-- ["item:72093:0:0:0:0:0:0"] = {rate=.25, source="prospect"},
		-- ["item:72103:0:0:0:0:0:0"] = {rate=.2, source="prospect"},
		-- ["item:72094:0:0:0:0:0:0"] = {rate=.2, source="prospect"},
	-- },
	-- ["item:76135:0:0:0:0:0:0"] = { -- Roguestone
		-- ["item:72092:0:0:0:0:0:0"] = {rate=.25, source="prospect"},
		-- ["item:72093:0:0:0:0:0:0"] = {rate=.25, source="prospect"},
		-- ["item:72103:0:0:0:0:0:0"] = {rate=.2, source="prospect"},
		-- ["item:72094:0:0:0:0:0:0"] = {rate=.2, source="prospect"},
	-- },
	-- ["item:76136:0:0:0:0:0:0"] = { -- Pandarian Garnet
		-- ["item:72092:0:0:0:0:0:0"] = {rate=.25, source="prospect"},
		-- ["item:72093:0:0:0:0:0:0"] = {rate=.25, source="prospect"},
		-- ["item:72103:0:0:0:0:0:0"] = {rate=.2, source="prospect"},
		-- ["item:72094:0:0:0:0:0:0"] = {rate=.2, source="prospect"},
	-- },
	-- ["item:76137:0:0:0:0:0:0"] = { -- Alexandrite
		-- ["item:72092:0:0:0:0:0:0"] = {rate=.25, source="prospect"},
		-- ["item:72093:0:0:0:0:0:0"] = {rate=.25, source="prospect"},
		-- ["item:72103:0:0:0:0:0:0"] = {rate=.2, source="prospect"},
		-- ["item:72094:0:0:0:0:0:0"] = {rate=.2, source="prospect"},
	-- },

	--Rare Gems
	["item:23440:0:0:0:0:0:0"] = { -- Dawnstone
		["item:23424:0:0:0:0:0:0"] = {rate=.01, source="prospect"},
		["item:23425:0:0:0:0:0:0"] = {rate=.04, source="prospect"},
	},
	["item:23436:0:0:0:0:0:0"] = { -- Living Ruby
		["item:23424:0:0:0:0:0:0"] = {rate=.01, source="prospect"},
		["item:23425:0:0:0:0:0:0"] = {rate=.04, source="prospect"},
	},
	["item:23441:0:0:0:0:0:0"] = { -- Nightseye
		["item:23424:0:0:0:0:0:0"] = {rate=.01, source="prospect"},
		["item:23425:0:0:0:0:0:0"] = {rate=.04, source="prospect"},
	},
	["item:23439:0:0:0:0:0:0"] = { -- Noble Topaz
		["item:23424:0:0:0:0:0:0"] = {rate=.01, source="prospect"},
		["item:23425:0:0:0:0:0:0"] = {rate=.04, source="prospect"},
	},
	["item:23438:0:0:0:0:0:0"] = { -- Star of Elune
		["item:23424:0:0:0:0:0:0"] = {rate=.01, source="prospect"},
		["item:23425:0:0:0:0:0:0"] = {rate=.04, source="prospect"},
	},
	["item:23437:0:0:0:0:0:0"] = { -- Talasite
		["item:23424:0:0:0:0:0:0"] = {rate=.01, source="prospect"},
		["item:23425:0:0:0:0:0:0"] = {rate=.04, source="prospect"},
	},
	["item:36921:0:0:0:0:0:0"] = { -- Autumn's Glow
		["item:36909:0:0:0:0:0:0"] = {rate=.01, source="prospect"},
		["item:36912:0:0:0:0:0:0"] = {rate=.04, source="prospect"},
		["item:36910:0:0:0:0:0:0"] = {rate=.04, source="prospect"},
	},
	["item:36933:0:0:0:0:0:0"] = { -- Forest Emerald
		["item:36909:0:0:0:0:0:0"] = {rate=.01, source="prospect"},
		["item:36912:0:0:0:0:0:0"] = {rate=.04, source="prospect"},
		["item:36910:0:0:0:0:0:0"] = {rate=.04, source="prospect"},
	},
	["item:36930:0:0:0:0:0:0"] = { -- Monarch Topaz
		["item:36909:0:0:0:0:0:0"] = {rate=.01, source="prospect"},
		["item:36912:0:0:0:0:0:0"] = {rate=.04, source="prospect"},
		["item:36910:0:0:0:0:0:0"] = {rate=.04, source="prospect"},
	},
	["item:36918:0:0:0:0:0:0"] = { -- Scarlet Ruby
		["item:36909:0:0:0:0:0:0"] = {rate=.01, source="prospect"},
		["item:36912:0:0:0:0:0:0"] = {rate=.04, source="prospect"},
		["item:36910:0:0:0:0:0:0"] = {rate=.04, source="prospect"},
	},
	["item:36924:0:0:0:0:0:0"] = { -- Sky Sapphire
		["item:36909:0:0:0:0:0:0"] = {rate=.01, source="prospect"},
		["item:36912:0:0:0:0:0:0"] = {rate=.04, source="prospect"},
		["item:36910:0:0:0:0:0:0"] = {rate=.04, source="prospect"},
	},
	["item:36927:0:0:0:0:0:0"] = { -- Twilight Opal
		["item:36909:0:0:0:0:0:0"] = {rate=.01, source="prospect"},
		["item:36912:0:0:0:0:0:0"] = {rate=.04, source="prospect"},
		["item:36910:0:0:0:0:0:0"] = {rate=.04, source="prospect"},
	},
	-- ["item:52192:0:0:0:0:0:0"] = { -- Dream Emerald
		-- ["item:53038:0:0:0:0:0:0"] = {rate=.08, source="prospect"},
		-- ["item:52185:0:0:0:0:0:0"] = {rate=.05, source="prospect"},
		-- ["item:52183:0:0:0:0:0:0"] = {rate=.04, source="prospect"},
	-- },
	-- ["item:52193:0:0:0:0:0:0"] = { -- Ember Topaz
		-- ["item:53038:0:0:0:0:0:0"] = {rate=.08, source="prospect"},
		-- ["item:52185:0:0:0:0:0:0"] = {rate=.05, source="prospect"},
		-- ["item:52183:0:0:0:0:0:0"] = {rate=.04, source="prospect"},
	-- },
	-- ["item:52190:0:0:0:0:0:0"] = { -- Inferno Ruby
		-- ["item:53038:0:0:0:0:0:0"] = {rate=.08, source="prospect"},
		-- ["item:52185:0:0:0:0:0:0"] = {rate=.05, source="prospect"},
		-- ["item:52183:0:0:0:0:0:0"] = {rate=.04, source="prospect"},
	-- },
	-- ["item:52195:0:0:0:0:0:0"] = { -- Amberjewel
		-- ["item:53038:0:0:0:0:0:0"] = {rate=.08, source="prospect"},
		-- ["item:52185:0:0:0:0:0:0"] = {rate=.05, source="prospect"},
		-- ["item:52183:0:0:0:0:0:0"] = {rate=.04, source="prospect"},
	-- },
	-- ["item:52194:0:0:0:0:0:0"] = { -- Demonseye
		-- ["item:53038:0:0:0:0:0:0"] = {rate=.08, source="prospect"},
		-- ["item:52185:0:0:0:0:0:0"] = {rate=.05, source="prospect"},
		-- ["item:52183:0:0:0:0:0:0"] = {rate=.04, source="prospect"},
	-- },
	-- ["item:52191:0:0:0:0:0:0"] = { -- Ocean Sapphire
		-- ["item:53038:0:0:0:0:0:0"] = {rate=.08, source="prospect"},
		-- ["item:52185:0:0:0:0:0:0"] = {rate=.05, source="prospect"},
		-- ["item:52183:0:0:0:0:0:0"] = {rate=.04, source="prospect"},
	-- },
	-- ["item:76131:0:0:0:0:0:0"] = { -- Primordial Ruby
		-- ["item:72092:0:0:0:0:0:0"] = {rate=.04, source="prospect"},
		-- ["item:72093:0:0:0:0:0:0"] = {rate=.04, source="prospect"},
		-- ["item:72103:0:0:0:0:0:0"] = {rate=.15, source="prospect"},
		-- ["item:72094:0:0:0:0:0:0"] = {rate=.15, source="prospect"},
	-- },
	-- ["item:76138:0:0:0:0:0:0"] = { -- River's Heart
		-- ["item:72092:0:0:0:0:0:0"] = {rate=.04, source="prospect"},
		-- ["item:72093:0:0:0:0:0:0"] = {rate=.04, source="prospect"},
		-- ["item:72103:0:0:0:0:0:0"] = {rate=.15, source="prospect"},
		-- ["item:72094:0:0:0:0:0:0"] = {rate=.15, source="prospect"},
	-- },
	-- ["item:76139:0:0:0:0:0:0"] = { -- Wild Jade
		-- ["item:72092:0:0:0:0:0:0"] = {rate=.04, source="prospect"},
		-- ["item:72093:0:0:0:0:0:0"] = {rate=.04, source="prospect"},
		-- ["item:72103:0:0:0:0:0:0"] = {rate=.15, source="prospect"},
		-- ["item:72094:0:0:0:0:0:0"] = {rate=.15, source="prospect"},
	-- },
	-- ["item:76140:0:0:0:0:0:0"] = { -- Vermillion Onyx
		-- ["item:72092:0:0:0:0:0:0"] = {rate=.04, source="prospect"},
		-- ["item:72093:0:0:0:0:0:0"] = {rate=.04, source="prospect"},
		-- ["item:72103:0:0:0:0:0:0"] = {rate=.15, source="prospect"},
		-- ["item:72094:0:0:0:0:0:0"] = {rate=.15, source="prospect"},
	-- },
	-- ["item:76141:0:0:0:0:0:0"] = { -- Imperial Amethyst
		-- ["item:72092:0:0:0:0:0:0"] = {rate=.04, source="prospect"},
		-- ["item:72093:0:0:0:0:0:0"] = {rate=.04, source="prospect"},
		-- ["item:72103:0:0:0:0:0:0"] = {rate=.15, source="prospect"},
		-- ["item:72094:0:0:0:0:0:0"] = {rate=.15, source="prospect"},
	-- },
	-- ["item:76142:0:0:0:0:0:0"] = { -- Sun's Radiance
		-- ["item:72092:0:0:0:0:0:0"] = {rate=.04, source="prospect"},
		-- ["item:72093:0:0:0:0:0:0"] = {rate=.04, source="prospect"},
		-- ["item:72103:0:0:0:0:0:0"] = {rate=.15, source="prospect"},
		-- ["item:72094:0:0:0:0:0:0"] = {rate=.15, source="prospect"},
	-- },

	--transformations
	-- ["item:52719:0:0:0:0:0:0"] = { -- Greater Celestial Essence
		-- ["item:52718:0:0:0:0:0:0"] = {rate=1/3, source="transform"},
	-- },
	["item:52718:0:0:0:0:0:0"] = { -- Lesser Celestial Essence
		["item:52719:0:0:0:0:0:0"] = {rate=3, source="transform"},
	},
	["item:34055:0:0:0:0:0:0"] = { -- Greater Cosmic Essence
		["item:34056:0:0:0:0:0:0"] = {rate=1/3, source="transform"},
	},
	["item:34056:0:0:0:0:0:0"] = { -- Lesser Cosmic Essence
		["item:34055:0:0:0:0:0:0"] = {rate=3, source="transform"},
	},
	["item:22446:0:0:0:0:0:0"] = { -- Greater Planar Essence
		["item:22447:0:0:0:0:0:0"] = {rate=1/3, source="transform"},
	},
	["item:22447:0:0:0:0:0:0"] = { -- Lesser Planar Essence
		["item:22446:0:0:0:0:0:0"] = {rate=3, source="transform"},
	},
	["item:16203:0:0:0:0:0:0"] = { -- Greater Eternal Essence
		["item:16202:0:0:0:0:0:0"] = {rate=1/3, source="transform"},
	},
	["item:16202:0:0:0:0:0:0"] = { -- Lesser Eternal Essence
		["item:16203:0:0:0:0:0:0"] = {rate=3, source="transform"},
	},
	["item:11175:0:0:0:0:0:0"] = { -- Greater Nether Essence
		["item:11174:0:0:0:0:0:0"] = {rate=1/3, source="transform"},
	},
	["item:11174:0:0:0:0:0:0"] = { -- Lesser Nether Essence
		["item:11175:0:0:0:0:0:0"] = {rate=3, source="transform"},
	},
	["item:11135:0:0:0:0:0:0"] = { -- Greater Mystic Essence
		["item:11134:0:0:0:0:0:0"] = {rate=1/3, source="transform"},
	},
	["item:11134:0:0:0:0:0:0"] = { -- Lesser Mystic Essence
		["item:11135:0:0:0:0:0:0"] = {rate=3, source="transform"},
	},
	["item:11082:0:0:0:0:0:0"] = { -- Greater Astral Essence
		["item:10998:0:0:0:0:0:0"] = {rate=1/3, source="transform"},
	},
	["item:10998:0:0:0:0:0:0"] = { -- Lesser Astral Essence
		["item:11082:0:0:0:0:0:0"] = {rate=3, source="transform"},
	},
	["item:10939:0:0:0:0:0:0"] = { -- Greater Magic Essence
		["item:10938:0:0:0:0:0:0"] = {rate=3, source="transform"},
	},
	["item:10938:0:0:0:0:0:0"] = { -- Lesser Magic Essence
		["item:10939:0:0:0:0:0:0"] = {rate=1/3, source="transform"},
	},
	["item:52721:0:0:0:0:0:0"] = { -- Heavenly Shard
		["item:52720:0:0:0:0:0:0"] = {rate=1/3, source="transform"},
	},
	["item:34052:0:0:0:0:0:0"] = { -- Dream Shard
		["item:34053:0:0:0:0:0:0"] = {rate=1/3, source="transform"},
	},
	-- ["item:74247:0:0:0:0:0:0"] = { -- Ethereal Shard
		-- ["item:74252:0:0:0:0:0:0"] = {rate=1/3, source="transform"},
	-- },
	["item:22578:0:0:0:0:0:0"] = { -- Mote of Water
		["item:21885:0:0:0:0:0:0"] = {rate=10, source="transform"},
	},
	["item:21885:0:0:0:0:0:0"] = { -- Primal Water
		["item:22578:0:0:0:0:0:0"] = {rate=1/10, source="transform"},
	},
	["item:22577:0:0:0:0:0:0"] = { -- Mote of Shadow
		["item:22456:0:0:0:0:0:0"] = {rate=10, source="transform"},
	},
	["item:22456:0:0:0:0:0:0"] = { -- Primal Shadow
		["item:22577:0:0:0:0:0:0"] = {rate=1/10, source="transform"},
	},
	["item:22576:0:0:0:0:0:0"] = { -- Mote of Mana
		["item:22457:0:0:0:0:0:0"] = {rate=10, source="transform"},
	},
	["item:22457:0:0:0:0:0:0"] = { -- Primal Mana
		["item:22576:0:0:0:0:0:0"] = {rate=1/10, source="transform"},
	},
	["item:22575:0:0:0:0:0:0"] = { -- Mote of Life
		["item:21886:0:0:0:0:0:0"] = {rate=10, source="transform"},
	},
	["item:21886:0:0:0:0:0:0"] = { -- Primal Life
		["item:22575:0:0:0:0:0:0"] = {rate=1/10, source="transform"},
	},
	["item:22573:0:0:0:0:0:0"] = { -- Mote of Earth
		["item:22452:0:0:0:0:0:0"] = {rate=10, source="transform"},
	},
	["item:22452:0:0:0:0:0:0"] = { -- Primal Earth
		["item:22573:0:0:0:0:0:0"] = {rate=1/10, source="transform"},
	},
	["item:22574:0:0:0:0:0:0"] = { -- Mote of Air
		["item:21884:0:0:0:0:0:0"] = {rate=10, source="transform"},
	},
	["item:21884:0:0:0:0:0:0"] = { -- Primal Air
		["item:22574:0:0:0:0:0:0"] = {rate=1/10, source="transform"},
	},
	["item:37700:0:0:0:0:0:0"] = { -- Crystallized Air
		["item:35623:0:0:0:0:0:0"] = {rate=10, source="transform"},
	},
	["item:35623:0:0:0:0:0:0"] = { -- Eternal Air
		["item:37700:0:0:0:0:0:0"] = {rate=1/10, source="transform"},
	},
	["item:37701:0:0:0:0:0:0"] = { -- Crystallized Earth
		["item:35624:0:0:0:0:0:0"] = {rate=10, source="transform"},
	},
	["item:35624:0:0:0:0:0:0"] = { -- Eternal Earth
		["item:37701:0:0:0:0:0:0"] = {rate=1/10, source="transform"},
	},
	["item:37702:0:0:0:0:0:0"] = { -- Crystallized Fire
		["item:36860:0:0:0:0:0:0"] = {rate=10, source="transform"},
	},
	["item:36860:0:0:0:0:0:0"] = { -- Eternal Fire
		["item:37702:0:0:0:0:0:0"] = {rate=1/10, source="transform"},
	},
	["item:37703:0:0:0:0:0:0"] = { -- Crystallized Shadow
		["item:35627:0:0:0:0:0:0"] = {rate=10, source="transform"},
	},
	["item:35627:0:0:0:0:0:0"] = { -- Eternal Shadow
		["item:37703:0:0:0:0:0:0"] = {rate=1/10, source="transform"},
	},
	["item:37704:0:0:0:0:0:0"] = { -- Crystallized Life
		["item:35625:0:0:0:0:0:0"] = {rate=10, source="transform"},
	},
	["item:35625:0:0:0:0:0:0"] = { -- Eternal Life
		["item:37704:0:0:0:0:0:0"] = {rate=1/10, source="transform"},
	},
	["item:37705:0:0:0:0:0:0"] = { -- Crystallized Water
		["item:35622:0:0:0:0:0:0"] = {rate=10, source="transform"},
	},
	["item:35622:0:0:0:0:0:0"] = { -- Eternal Water
		["item:37705:0:0:0:0:0:0"] = {rate=1/10, source="transform"},
	},

	--vendor trades
	["item:37101:0:0:0:0:0:0"] = { -- Ivory Ink
		["item:79254:0:0:0:0:0:0"] = {rate=1, source="vendortrade"},
	},
	["item:39469:0:0:0:0:0:0"] = { -- Moonglow Ink
		["item:79254:0:0:0:0:0:0"] = {rate=1, source="vendortrade"},
	},
	["item:39774:0:0:0:0:0:0"] = { -- Midnight Ink
		["item:79254:0:0:0:0:0:0"] = {rate=1, source="vendortrade"},
	},
	["item:43116:0:0:0:0:0:0"] = { -- Lion's Ink
		["item:79254:0:0:0:0:0:0"] = {rate=1, source="vendortrade"},
	},
	["item:43118:0:0:0:0:0:0"] = { -- Jadefire Ink
		["item:79254:0:0:0:0:0:0"] = {rate=1, source="vendortrade"},
	},
	["item:43120:0:0:0:0:0:0"] = { -- Celestial Ink
		["item:79254:0:0:0:0:0:0"] = {rate=1, source="vendortrade"},
	},
	["item:43122:0:0:0:0:0:0"] = { -- Shimmering Ink
		["item:79254:0:0:0:0:0:0"] = {rate=1, source="vendortrade"},
	},
	["item:43124:0:0:0:0:0:0"] = { -- Ethereal Ink
		["item:79254:0:0:0:0:0:0"] = {rate=1, source="vendortrade"},
	},
	["item:43126:0:0:0:0:0:0"] = { -- Ink of the Sea
		["item:79254:0:0:0:0:0:0"] = {rate=1, source="vendortrade"},
	},
	["item:43127:0:0:0:0:0:0"] = { -- Snowfall Ink
		["item:79254:0:0:0:0:0:0"] = {rate=1/10, source="vendortrade"},
	},
	-- ["item:61978:0:0:0:0:0:0"] = { -- Blackfallow Ink
		-- ["item:79254:0:0:0:0:0:0"] = {rate=1, source="vendortrade"},
	-- },
	-- ["item:61981:0:0:0:0:0:0"] = { -- Inferno Ink
		-- ["item:79254:0:0:0:0:0:0"] = {rate=1/10, source="vendortrade"},
	-- },
	-- ["item:79255:0:0:0:0:0:0"] = { -- Starlight Ink
		-- ["item:79254:0:0:0:0:0:0"] = {rate=1/10, source="vendortrade"},
	-- },
}
TSMAPI.Conversions = conversions


local inks = {
	-- uncommon inks
	["item:37101:0:0:0:0:0:0"] = {pigment="item:39151:0:0:0:0:0:0", pigmentPerInk=1}, -- Ivory Ink
	["item:39469:0:0:0:0:0:0"] = {pigment="item:39151:0:0:0:0:0:0", pigmentPerInk=2}, -- Moonglow Ink
	["item:39774:0:0:0:0:0:0"] = {pigment="item:39334:0:0:0:0:0:0", pigmentPerInk=2}, -- Midnight Ink
	["item:43116:0:0:0:0:0:0"] = {pigment="item:39338:0:0:0:0:0:0", pigmentPerInk=2}, -- Lion's Ink
	["item:43118:0:0:0:0:0:0"] = {pigment="item:39339:0:0:0:0:0:0", pigmentPerInk=2}, -- Jadefire Ink
	["item:43120:0:0:0:0:0:0"] = {pigment="item:39340:0:0:0:0:0:0", pigmentPerInk=2}, -- Celestial Ink
	["item:43122:0:0:0:0:0:0"] = {pigment="item:39341:0:0:0:0:0:0", pigmentPerInk=2}, -- Shimmering Ink
	["item:43124:0:0:0:0:0:0"] = {pigment="item:39342:0:0:0:0:0:0", pigmentPerInk=2}, -- Ethereal Ink
	["item:43126:0:0:0:0:0:0"] = {pigment="item:39343:0:0:0:0:0:0", pigmentPerInk=2}, -- Ink of the Sea
	-- ["item:61978:0:0:0:0:0:0"] = {pigment="item:61979:0:0:0:0:0:0", pigmentPerInk=2}, -- Blackfallow Ink
	-- ["item:79254:0:0:0:0:0:0"] = {pigment="item:79251:0:0:0:0:0:0", pigmentPerInk=2}, -- Ink of Dreams
	
	-- rare inks
	["item:43115:0:0:0:0:0:0"] = {pigment="item:43103:0:0:0:0:0:0", pigmentPerInk=1}, -- Hunter's Ink
	["item:43117:0:0:0:0:0:0"] = {pigment="item:43104:0:0:0:0:0:0", pigmentPerInk=1}, -- Dawnstar Ink
	["item:43119:0:0:0:0:0:0"] = {pigment="item:43105:0:0:0:0:0:0", pigmentPerInk=1}, -- Royal Ink
	["item:43121:0:0:0:0:0:0"] = {pigment="item:43106:0:0:0:0:0:0", pigmentPerInk=1}, -- Fiery Ink
	["item:43123:0:0:0:0:0:0"] = {pigment="item:43107:0:0:0:0:0:0", pigmentPerInk=1}, -- Ink of the Sky
	["item:43125:0:0:0:0:0:0"] = {pigment="item:43108:0:0:0:0:0:0", pigmentPerInk=1}, -- Darkflame Ink
	["item:43127:0:0:0:0:0:0"] = {pigment="item:43109:0:0:0:0:0:0", pigmentPerInk=2}, -- Snowfall Ink
	-- ["item:61981:0:0:0:0:0:0"] = {pigment="item:61980:0:0:0:0:0:0", pigmentPerInk=2}, -- Inferno Ink
	-- ["item:79255:0:0:0:0:0:0"] = {pigment="item:79253:0:0:0:0:0:0", pigmentPerInk=2}, -- Starlight Ink
}
TSMAPI.InkConversions = inks


-- returns the conversion info for a given target item
function TSMAPI:GetItemConversions(itemString)
	if not itemString or not conversions[itemString] then return end
	return CopyTable(conversions[itemString])
end

function TSMAPI:GetConvertCost(targetItem, priceSource)
	local conversions = TSMAPI:GetItemConversions(targetItem)
	if not conversions then return end
	
	local prices = {}
	for itemString, info in pairs(conversions) do
		local price = TSMAPI:GetItemValue(itemString, priceSource)
		if price then
			tinsert(prices, price/info.rate)
		end
	end
	if #prices == 0 then return end
	return min(unpack(prices))
end

function TSMAPI:GetConversionTargetItems(source)
	local result = {}
	for itemString, items in pairs(conversions) do
		for _, info in pairs(items) do
			if info.source == source then
				tinsert(result, itemString)
				break
			end
		end
	end
	return result
end