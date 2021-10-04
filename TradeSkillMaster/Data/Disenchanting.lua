-- ------------------------------------------------------------------------------ --
--                                TradeSkillMaster                                --
--                http://www.curse.com/addons/wow/tradeskill-master               --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster")
TSMAPI.DisenchantingData = {}
local data = TSMAPI.DisenchantingData
local WEAPON, ARMOR = GetAuctionItemClasses()

data.disenchant = {
	{
		desc = L["Dust"],
		["item:10940:0:0:0:0:0:0"] = {
			-- Strange Dust
			name = GetItemInfo("item:10940:0:0:0:0:0:0"),
			minLevel = 0,
			maxLevel = 24,
			itemTypes = {
				[ARMOR] = {
					[2] = {
						{
							minItemLevel = 5,
							maxItemLevel = 15,
							amountOfMats = 1.2
						},
						{
							minItemLevel = 16,
							maxItemLevel = 20,
							amountOfMats = 1.875
						},
						{
							minItemLevel = 21,
							maxItemLevel = 25,
							amountOfMats = 3.75
						},
					},
				},
				[WEAPON] = {
					[2] = {
						{
							minItemLevel = 5,
							maxItemLevel = 15,
							amountOfMats = 0.3
						},
						{
							minItemLevel = 16,
							maxItemLevel = 20,
							amountOfMats = 0.5
						},
						{
							minItemLevel = 21,
							maxItemLevel = 25,
							amountOfMats = 0.75
						},
					},
				},
			},
		},
		["item:11083:0:0:0:0:0:0"] = {
			-- Soul Dust
			name = GetItemInfo("item:11083:0:0:0:0:0:0"),
			minLevel = 20,
			maxLevel = 30,
			itemTypes = {
				[ARMOR] = {
					[2] = {
						{
							minItemLevel = 26,
							maxItemLevel = 30,
							amountOfMats = 1.125
						},
						{
							minItemLevel = 31,
							maxItemLevel = 35,
							amountOfMats = 2.625
						},
					},
				},
				[WEAPON] = {
					[2] = {
						{
							minItemLevel = 26,
							maxItemLevel = 30,
							amountOfMats = 0.3
						},
						{
							minItemLevel = 31,
							maxItemLevel = 35,
							amountOfMats = 0.7
						},
					},
				},
			},
		},
		["item:11137:0:0:0:0:0:0"] = {
			-- Vision Dust
			name = GetItemInfo("item:11137:0:0:0:0:0:0"),
			minLevel = 30,
			maxLevel = 40,
			itemTypes = {
				[ARMOR] = {
					[2] = {
						{
							minItemLevel = 36,
							maxItemLevel = 40,
							amountOfMats = 1.125
						},
						{
							minItemLevel = 41,
							maxItemLevel = 45,
							amountOfMats = 2.625
						},
					},
				},
				[WEAPON] = {
					[2] = {
						{
							minItemLevel = 36,
							maxItemLevel = 40,
							amountOfMats = 0.3
						},
						{
							minItemLevel = 41,
							maxItemLevel = 45,
							amountOfMats = 0.7
						},
					},
				},
			},
		},
		["item:11176:0:0:0:0:0:0"] = {
			-- Dream Dust
			name = GetItemInfo("item:11176:0:0:0:0:0:0"),
			minLevel = 41,
			maxLevel = 50,
			itemTypes = {
				[ARMOR] = {
					[2] = {
						{
							minItemLevel = 46,
							maxItemLevel = 50,
							amountOfMats = 1.125
						},
						{
							minItemLevel = 51,
							maxItemLevel = 55,
							amountOfMats = 2.625
						},
					},
				},
				[WEAPON] = {
					[2] = {
						{
							minItemLevel = 46,
							maxItemLevel = 50,
							amountOfMats = 0.3
						},
						{
							minItemLevel = 51,
							maxItemLevel = 55,
							amountOfMats = 0.77
						},
					},
				},
			},
		},
		["item:16204:0:0:0:0:0:0"] = {
			-- Illusion Dust
			name = GetItemInfo("item:16204:0:0:0:0:0:0"),
			minLevel = 51,
			maxLevel = 60,
			itemTypes = {
				[ARMOR] = {
					[2] = {
						{
							minItemLevel = 56,
							maxItemLevel = 60,
							amountOfMats = 1.125
						},
						{
							minItemLevel = 61,
							maxItemLevel = 65,
							amountOfMats = 2.625
						},
					},
				},
				[WEAPON] = {
					[2] = {
						{
							minItemLevel = 56,
							maxItemLevel = 60,
							amountOfMats = 0.33
						},
						{
							minItemLevel = 61,
							maxItemLevel = 65,
							amountOfMats = 0.77
						},
					},
				},
			},
		},
		["item:22445:0:0:0:0:0:0"] = {
			-- Arcane Dust
			name = GetItemInfo("item:22445:0:0:0:0:0:0"),
			minLevel = 57,
			maxLevel = 70,
			itemTypes = {
				[ARMOR] = {
					[2] = {
						{
							minItemLevel = 79,
							maxItemLevel = 79,
							amountOfMats = 1.5
						},
						{
							minItemLevel = 80,
							maxItemLevel = 99,
							amountOfMats = 1.875
						},
						{
							minItemLevel = 100,
							maxItemLevel = 120,
							amountOfMats = 2.625
						},
					},
				},
				[WEAPON] = {
					[2] = {
						{
							minItemLevel = 80,
							maxItemLevel = 99,
							amountOfMats = 0.55
						},
						{
							minItemLevel = 100,
							maxItemLevel = 120,
							amountOfMats = 0.77
						},
					},
				},
			},
		},
		["item:34054:0:0:0:0:0:0"] = {
			-- Infinite Dust
			name = GetItemInfo("item:34054:0:0:0:0:0:0"),
			minLevel = 67,
			maxLevel = 80,
			itemTypes = {
				[ARMOR] = {
					[2] = {
						{
							minItemLevel = 130,
							maxItemLevel = 151,
							-- amountOfMats = 1.5 
							amountOfMats = 1.875 -- 2-3, 75% chance = 2.5*0.75
						},
						{
							minItemLevel = 152,
							maxItemLevel = 200,
							-- amountOfMats = 3.375
							amountOfMats = 4.125 -- 4-7, 75% chance = 5.5*0.75	
						},
					},
				},
				[WEAPON] = {
					[2] = {
						{
							minItemLevel = 130,
							maxItemLevel = 151,
							-- amountOfMats = 0.55
							amountOfMats = 0.55 -- 2-3, 22% chance = 2.5*0.22
						},
						{
							minItemLevel = 152,
							maxItemLevel = 200,
							-- amountOfMats = 1.1
							amountOfMats = 1.21 -- 4-7, 22% chance = 5.5*0.22
						},
					},
				},
			},
		},
		-- ["item:52555:0:0:0:0:0:0"] = {
			-- -- Hypnotic Dust
			-- name = GetItemInfo("item:52555:0:0:0:0:0:0"),
			-- minLevel = 77,
			-- maxLevel = 85,
			-- itemTypes = {
				-- [ARMOR] = {
					-- [2] = {
						-- {
							-- minItemLevel = 272,
							-- maxItemLevel = 275,
							-- amountOfMats = 1.125
						-- },
						-- {
							-- minItemLevel = 276,
							-- maxItemLevel = 290,
							-- amountOfMats = 1.5
						-- },
						-- {
							-- minItemLevel = 291,
							-- maxItemLevel = 305,
							-- amountOfMats = 1.875
						-- },
						-- {
							-- minItemLevel = 306,
							-- maxItemLevel = 315,
							-- amountOfMats = 2.25
						-- },
						-- {
							-- minItemLevel = 316,
							-- maxItemLevel = 325,
							-- amountOfMats = 2.625
						-- },
						-- {
							-- minItemLevel = 326,
							-- maxItemLevel = 350,
							-- amountOfMats = 3
						-- },
					-- },
				-- },
				-- [WEAPON] = {
					-- [2] = {
						-- {
							-- minItemLevel = 272,
							-- maxItemLevel = 275,
							-- amountOfMats = 0.375
						-- },
						-- {
							-- minItemLevel = 276,
							-- maxItemLevel = 290,
							-- amountOfMats = 0.5
						-- },
						-- {
							-- minItemLevel = 291,
							-- maxItemLevel = 305,
							-- amountOfMats = 0.625
						-- },
						-- {
							-- minItemLevel = 306,
							-- maxItemLevel = 315,
							-- amountOfMats = 0.75
						-- },
						-- {
							-- minItemLevel = 316,
							-- maxItemLevel = 325,
							-- amountOfMats = 0.875
						-- },
						-- {
							-- minItemLevel = 326,
							-- maxItemLevel = 350,
							-- amountOfMats = 1
						-- },
					-- },
				-- },
			-- },
		-- },
		-- ["item:74249:0:0:0:0:0:0"] = {
			-- -- Spirit Dust
			-- name = GetItemInfo("item:74249:0:0:0:0:0:0"),
			-- minLevel = 83,
			-- maxLevel = 88,
			-- itemTypes = {
				-- [ARMOR] = {
					-- [2] = {
						-- {
							-- minItemLevel = 364,
							-- maxItemLevel = 390,
							-- amountOfMats = 2.125
						-- },
						-- {
							-- minItemLevel = 391,
							-- maxItemLevel = 410,
							-- amountOfMats = 2.55
						-- },
						-- {
							-- minItemLevel = 411,
							-- maxItemLevel = 450,
							-- amountOfMats = 3.4
						-- },
					-- },
				-- },
				-- [WEAPON] = {
					-- [2] = {
						-- {
							-- minItemLevel = 377,
							-- maxItemLevel = 390,
							-- amountOfMats = 2.125
						-- },
						-- {
							-- minItemLevel = 391,
							-- maxItemLevel = 410,
							-- amountOfMats = 2.55
						-- },
						-- {
							-- minItemLevel = 411,
							-- maxItemLevel = 450,
							-- amountOfMats = 3.4
						-- },
					-- },
				-- },
			-- },
		-- },
	},
	{
		desc = L["Essences"],
		["item:10939:0:0:0:0:0:0"] = {
			-- Greater Magic Essence
			name = GetItemInfo("item:10939:0:0:0:0:0:0"),
			minLevel = 1,
			maxLevel = 15,
			itemTypes = {
				[ARMOR] = {
					[2] = {
						{
							minItemLevel = 5,
							maxItemLevel = 15,
							amountOfMats = 0.1
						},
						{
							minItemLevel = 16,
							maxItemLevel = 20,
							amountOfMats = 0.3
						},
					},
				},
				[WEAPON] = {
					[2] = {
						{
							minItemLevel = 5,
							maxItemLevel = 15,
							amountOfMats = 0.4
						},
						{
							minItemLevel = 16,
							maxItemLevel = 20,
							amountOfMats = 1.125
						},
					},
				},
			},
		},
		["item:11082:0:0:0:0:0:0"] = {
			-- Greater Astral Essence
			name = GetItemInfo("item:11082:0:0:0:0:0:0"),
			minLevel = 16,
			maxLevel = 25,
			itemTypes = {
				[ARMOR] = {
					[2] = {
						{
							minItemLevel = 21,
							maxItemLevel = 25,
							amountOfMats = .075
						},
						{
							minItemLevel = 26,
							maxItemLevel = 30,
							amountOfMats = 0.3
						},
					},
				},
				[WEAPON] = {
					[2] = {
						{
							minItemLevel = 21,
							maxItemLevel = 25,
							amountOfMats = 0.375
						},
						{
							minItemLevel = 26,
							maxItemLevel = 30,
							amountOfMats = 1.125
						},
					},
				},
			},
		},
		["item:11135:0:0:0:0:0:0"] = {
			-- Greater Mystic Essence
			name = GetItemInfo("item:11135:0:0:0:0:0:0"),
			minLevel = 26,
			maxLevel = 35,
			itemTypes = {
				[ARMOR] = {
					[2] = {
						{
							minItemLevel = 31,
							maxItemLevel = 35,
							amountOfMats = 0.1
						},
						{
							minItemLevel = 36,
							maxItemLevel = 40,
							amountOfMats = 0.3
						},
					},
				},
				[WEAPON] = {
					[2] = {
						{
							minItemLevel = 31,
							maxItemLevel = 35,
							amountOfMats = 0.375
						},
						{
							minItemLevel = 36,
							maxItemLevel = 40,
							amountOfMats = 1.125
						},
					},
				},
			},
		},
		["item:11175:0:0:0:0:0:0"] = {
			-- Greater Nether Essence
			name = GetItemInfo("item:11175:0:0:0:0:0:0"),
			minLevel = 36,
			maxLevel = 45,
			itemTypes = {
				[ARMOR] = {
					[2] = {
						{
							minItemLevel = 41,
							maxItemLevel = 45,
							amountOfMats = 0.1
						},
						{
							minItemLevel = 46,
							maxItemLevel = 50,
							amountOfMats = 0.3
						},
					},
				},
				[WEAPON] = {
					[2] = {
						{
							minItemLevel = 41,
							maxItemLevel = 45,
							amountOfMats = 0.375
						},
						{
							minItemLevel = 46,
							maxItemLevel = 50,
							amountOfMats = 1.125
						},
					},
				},
			},
		},
		["item:16203:0:0:0:0:0:0"] = {
			-- Greater Eternal Essence
			name = GetItemInfo("item:16203:0:0:0:0:0:0"),
			minLevel = 46,
			maxLevel = 60,
			itemTypes = {
				[ARMOR] = {
					[2] = {
						{
							minItemLevel = 51,
							maxItemLevel = 55,
							amountOfMats = 0.1
						},
						{
							minItemLevel = 56,
							maxItemLevel = 60,
							amountOfMats = 0.3
						},
						{
							minItemLevel = 61,
							maxItemLevel = 65,
							amountOfMats = 0.5
						},
					},
				},
				[WEAPON] = {
					[2] = {
						{
							minItemLevel = 51,
							maxItemLevel = 55,
							amountOfMats = 0.375
						},
						{
							minItemLevel = 56,
							maxItemLevel = 60,
							amountOfMats = 0.125
						},
						{
							minItemLevel = 61,
							maxItemLevel = 65,
							amountOfMats = 1.875
						},
					},
				},
			},
		},
		["item:22446:0:0:0:0:0:0"] = {
			-- Greater Planar Essence
			name = GetItemInfo("item:22446:0:0:0:0:0:0"),
			minLevel = 58,
			maxLevel = 70,
			itemTypes = {
				[ARMOR] = {
					[2] = {
						{
							minItemLevel = 66,
							maxItemLevel = 99,
							amountOfMats = 0.167
						},
						{
							minItemLevel = 100,
							maxItemLevel = 120,
							amountOfMats = 0.3
						},
					},
				},
				[WEAPON] = {
					[2] = {
						{
							minItemLevel = 79,
							maxItemLevel = 79,
							amountOfMats = 0.625
						},
						{
							minItemLevel = 80,
							maxItemLevel = 99,
							amountOfMats = 0.625
						},
						{
							minItemLevel = 100,
							maxItemLevel = 120,
							amountOfMats = 1.125
						},
					},
				},
			},
		},
		["item:34055:0:0:0:0:0:0"] = {
			-- Greater Cosmic Essence
			name = GetItemInfo("item:34055:0:0:0:0:0:0"),
			minLevel = 67,
			maxLevel = 80,
			itemTypes = {
				[ARMOR] = {
					[2] = {
						{
							minItemLevel = 130,
							maxItemLevel = 151,
							-- amountOfMats = 0.1
							amountOfMats = 0.11 -- 1-2 Lesser, 22% Chance = 1.5*0.22/3
						},
						{
							minItemLevel = 152,
							maxItemLevel = 200,
							-- amountOfMats = 0.3
							amountOfMats = 0.33 -- 1-2 Greater, 22% Chance = 1.5*0.22
						},
					},
				},
				[WEAPON] = {
					[2] = {
						{
							minItemLevel = 130,
							maxItemLevel = 151,
							-- amountOfMats = 0.375
							amountOfMats = 0.375 -- 1-2 Lesser, 75% chance = 1.5*0.75/3
						},
						{
							minItemLevel = 152,
							maxItemLevel = 200,
							-- amountOfMats = 1.125
							amountOfMats = 1.125 -- 1-2 Greater, 75% chance = 1.5*0.75
						},
					},
				},
			},
		},
		-- ["item:52719:0:0:0:0:0:0"] = {
			-- -- Greater Celestial Essence
			-- name = GetItemInfo("item:52719:0:0:0:0:0:0"),
			-- minLevel = 77,
			-- maxLevel = 85,
			-- itemTypes = {
				-- [ARMOR] = {
					-- [2] = {
						-- {
							-- minItemLevel = 201,
							-- maxItemLevel = 275,
							-- amountOfMats = 0.125
						-- },
						-- {
							-- minItemLevel = 276,
							-- maxItemLevel = 290,
							-- amountOfMats = 0.167
						-- },
						-- {
							-- minItemLevel = 291,
							-- maxItemLevel = 305,
							-- amountOfMats = 0.208
						-- },
						-- {
							-- minItemLevel = 306,
							-- maxItemLevel = 315,
							-- amountOfMats = 0.375
						-- },
						-- {
							-- minItemLevel = 316,
							-- maxItemLevel = 325,
							-- amountOfMats = 0.625
						-- },
						-- {
							-- minItemLevel = 326,
							-- maxItemLevel = 350,
							-- amountOfMats = 0.75
						-- },
					-- },
				-- },
				-- [WEAPON] = {
					-- [2] = {
						-- {
							-- minItemLevel = 201,
							-- maxItemLevel = 275,
							-- amountOfMats = 0.375
						-- },
						-- {
							-- minItemLevel = 276,
							-- maxItemLevel = 290,
							-- amountOfMats = 0.5
						-- },
						-- {
							-- minItemLevel = 291,
							-- maxItemLevel = 305,
							-- amountOfMats = 0.625
						-- },
						-- {
							-- minItemLevel = 306,
							-- maxItemLevel = 315,
							-- amountOfMats = 1.125
						-- },
						-- {
							-- minItemLevel = 316,
							-- maxItemLevel = 325,
							-- amountOfMats = 1.875
						-- },
						-- {
							-- minItemLevel = 326,
							-- maxItemLevel = 350,
							-- amountOfMats = 2.25
						-- },
					-- },
				-- },
			-- },
		-- },
		-- ["item:74250:0:0:0:0:0:0"] = {
			-- -- Mysterious Essence
			-- name = GetItemInfo("item:74250:0:0:0:0:0:0"),
			-- minLevel = 83,
			-- maxLevel = 88,
			-- itemTypes = {
				-- [ARMOR] = {
					-- [2] = {
						-- {
							-- minItemLevel = 364,
							-- maxItemLevel = 390,
							-- amountOfMats = 0.15
						-- },
						-- {
							-- minItemLevel = 391,
							-- maxItemLevel = 410,
							-- amountOfMats = 0.225
						-- },
						-- {
							-- minItemLevel = 411,
							-- maxItemLevel = 450,
							-- amountOfMats = 0.3
						-- },
					-- },
				-- },
				-- [WEAPON] = {
					-- [2] = {
						-- {
							-- minItemLevel = 377,
							-- maxItemLevel = 390,
							-- amountOfMats = 0.15
						-- },
						-- {
							-- minItemLevel = 391,
							-- maxItemLevel = 410,
							-- amountOfMats = 0.225
						-- },
						-- {
							-- minItemLevel = 411,
							-- maxItemLevel = 450,
							-- amountOfMats = 0.3
						-- },
					-- },
				-- },
			-- },
		-- },
	},
	{
		desc = L["Shards"],
		["item:10978:0:0:0:0:0:0"] = {
			-- Small Glimmering Shard
			name = GetItemInfo("item:10978:0:0:0:0:0:0"),
			minLevel = 1,
			maxLevel = 20,
			itemTypes = {
				[ARMOR] = {
					[2] = {
						{
							minItemLevel = 1,
							maxItemLevel = 20,
							amountOfMats = 0.05
						},
						{
							minItemLevel = 21,
							maxItemLevel = 25,
							amountOfMats = 0.1
						},
					},
					[3] = {
						{
							minItemLevel = 1,
							maxItemLevel = 25,
							amountOfMats = 1.000
						},
					},
				},
				[WEAPON] = {
					[3] = {
						{
							minItemLevel = 1,
							maxItemLevel = 25,
							amountOfMats = 1.000
						},
					},
				},
			},
		},
		["item:11084:0:0:0:0:0:0"] = {
			-- Large Glimmering Shard
			name = GetItemInfo("item:11084:0:0:0:0:0:0"),
			minLevel = 16,
			maxLevel = 25,
			itemTypes = {
				[ARMOR] = {
					[2] = {
						{
							minItemLevel = 26,
							maxItemLevel = 30,
							amountOfMats = 0.05
						},
					},
					[3] = {
						{
							minItemLevel = 26,
							maxItemLevel = 30,
							amountOfMats = 1.000
						},
					},
				},
				[WEAPON] = {
					[3] = {
						{
							minItemLevel = 26,
							maxItemLevel = 30,
							amountOfMats = 1.000
						},
					},
				},
			},
		},
		["item:11138:0:0:0:0:0:0"] = {
			-- Small Glowing Shard
			name = GetItemInfo("item:11138:0:0:0:0:0:0"),
			minLevel = 26,
			maxLevel = 30,
			itemTypes = {
				[ARMOR] = {
					[2] = {
						{
							minItemLevel = 31,
							maxItemLevel = 35,
							amountOfMats = 0.05
						},
					},
					[3] = {
						{
							minItemLevel = 31,
							maxItemLevel = 35,
							amountOfMats = 1.000
						},
					},
				},
				[WEAPON] = {
					[2] = {
						{
							minItemLevel = 31,
							maxItemLevel = 35,
							amountOfMats = 0.05
						},
					},
					[3] = {
						{
							minItemLevel = 31,
							maxItemLevel = 35,
							amountOfMats = 1.000
						},
					},
				},
			},
		},
		["item:11139:0:0:0:0:0:0"] = {
			-- Large Glowing Shard
			name = GetItemInfo("item:11139:0:0:0:0:0:0"),
			minLevel = 31,
			maxLevel = 35,
			itemTypes = {
				[ARMOR] = {
					[2] = {
						{
							minItemLevel = 36,
							maxItemLevel = 40,
							amountOfMats = 0.05
						},
					},
					[3] = {
						{
							minItemLevel = 36,
							maxItemLevel = 40,
							amountOfMats = 1.000
						},
					},
				},
				[WEAPON] = {
					[2] = {
						{
							minItemLevel = 36,
							maxItemLevel = 40,
							amountOfMats = 0.05
						},
					},
					[3] = {
						{
							minItemLevel = 36,
							maxItemLevel = 40,
							amountOfMats = 1.000
						},
					},
				},
			},
		},
		["item:11177:0:0:0:0:0:0"] = {
			-- Small Radiant Shard
			name = GetItemInfo("item:11177:0:0:0:0:0:0"),
			minLevel = 36,
			maxLevel = 40,
			itemTypes = {
				[ARMOR] = {
					[2] = {
						{
							minItemLevel = 41,
							maxItemLevel = 45,
							amountOfMats = 0.05
						},
					},
					[3] = {
						{
							minItemLevel = 41,
							maxItemLevel = 45,
							amountOfMats = 1.000
						},
					},
					[4] = {
						{
							minItemLevel = 36,
							maxItemLevel = 40,
							amountOfMats = 3
						},
						{
							minItemLevel = 41,
							maxItemLevel = 45,
							amountOfMats = 3.5
						},
					},
				},
				[WEAPON] = {
					[2] = {
						{
							minItemLevel = 41,
							maxItemLevel = 45,
							amountOfMats = 0.05
						},
					},
					[3] = {
						{
							minItemLevel = 41,
							maxItemLevel = 45,
							amountOfMats = 1.000
						},
					},
					[4] = {
						{
							minItemLevel = 36,
							maxItemLevel = 40,
							amountOfMats = 3
						},
						{
							minItemLevel = 41,
							maxItemLevel = 45,
							amountOfMats = 3.5
						},
					},
				},
			},
		},
		["item:11178:0:0:0:0:0:0"] = {
			-- Large Radiant Shard
			name = GetItemInfo("item:11178:0:0:0:0:0:0"),
			minLevel = 41,
			maxLevel = 45,
			itemTypes = {
				[ARMOR] = {
					[2] = {
						{
							minItemLevel = 46,
							maxItemLevel = 50,
							amountOfMats = 0.05
						},
					},
					[3] = {
						{
							minItemLevel = 46,
							maxItemLevel = 50,
							amountOfMats = 1.000
						},
					},
					[4] = {
						{
							minItemLevel = 46,
							maxItemLevel = 50,
							amountOfMats = 3.5
						},
					},
				},
				[WEAPON] = {
					[2] = {
						{
							minItemLevel = 46,
							maxItemLevel = 50,
							amountOfMats = 0.05
						},
					},
					[3] = {
						{
							minItemLevel = 46,
							maxItemLevel = 50,
							amountOfMats = 1.000
						},
					},
					[4] = {
						{
							minItemLevel = 46,
							maxItemLevel = 50,
							amountOfMats = 3.5
						},
					},
				},
			},
		},
		["item:14343:0:0:0:0:0:0"] = {
			-- Small Brilliant Shard
			name = GetItemInfo("item:14343:0:0:0:0:0:0"),
			minLevel = 46,
			maxLevel = 50,
			itemTypes = {
				[ARMOR] = {
					[2] = {
						{
							minItemLevel = 51,
							maxItemLevel = 55,
							amountOfMats = 0.05
						},
					},
					[3] = {
						{
							minItemLevel = 51,
							maxItemLevel = 55,
							amountOfMats = 1.000
						},
					},
					[4] = {
						{
							minItemLevel = 51,
							maxItemLevel = 55,
							amountOfMats = 3.5
						},
					},
				},
				[WEAPON] = {
					[2] = {
						{
							minItemLevel = 51,
							maxItemLevel = 55,
							amountOfMats = 0.05
						},
					},
					[3] = {
						{
							minItemLevel = 51,
							maxItemLevel = 55,
							amountOfMats = 1.000
						},
					},
					[4] = {
						{
							minItemLevel = 51,
							maxItemLevel = 55,
							amountOfMats = 3.5
						},
					},
				},
			},
		},
		["item:14344:0:0:0:0:0:0"] = {
			-- Large Brilliant Shard
			name = GetItemInfo("item:14344:0:0:0:0:0:0"),
			minLevel = 56,
			maxLevel = 75,
			itemTypes = {
				[ARMOR] = {
					[2] = {
						{
							minItemLevel = 56,
							maxItemLevel = 65,
							amountOfMats = 0.05
						},
					},
					[3] = {
						{
							minItemLevel = 56,
							maxItemLevel = 65,
							amountOfMats = 0.995
						},
					},
				},
				[WEAPON] = {
					[2] = {
						{
							minItemLevel = 56,
							maxItemLevel = 65,
							amountOfMats = 0.05
						},
					},
					[3] = {
						{
							minItemLevel = 56,
							maxItemLevel = 65,
							amountOfMats = 0.995
						},
					},
				},
			},
		},
		["item:22449:0:0:0:0:0:0"] = {
			-- Large Prismatic Shard
			name = GetItemInfo("item:22449:0:0:0:0:0:0"),
			minLevel = 56,
			maxLevel = 70,
			itemTypes = {
				[ARMOR] = {
					[2] = {
						{
							minItemLevel = 66,
							maxItemLevel = 99,
							amountOfMats = 0.0167
						},
						{
							minItemLevel = 100,
							maxItemLevel = 120,
							amountOfMats = 0.05
						},
					},
					[3] = {
						{
							minItemLevel = 66,
							maxItemLevel = 99,
							amountOfMats = 0.33
						},
						{
							minItemLevel = 100,
							maxItemLevel = 120,
							amountOfMats = 1
						},
					},
				},
				[WEAPON] = {
					[2] = {
						{
							minItemLevel = 66,
							maxItemLevel = 99,
							amountOfMats = 0.0167
						},
						{
							minItemLevel = 100,
							maxItemLevel = 120,
							amountOfMats = 0.05
						},
					},
					[3] = {
						{
							minItemLevel = 66,
							maxItemLevel = 99,
							amountOfMats = 0.33
						},
						{
							minItemLevel = 100,
							maxItemLevel = 120,
							amountOfMats = 1
						},
					},
				},
			},
		},
		["item:34052:0:0:0:0:0:0"] = {
			-- Dream Shard
			-- 2 is uncommon, 3 is rare, 4 is epic
			name = GetItemInfo("item:34052:0:0:0:0:0:0"),
			minLevel = 68,
			maxLevel = 80,
			itemTypes = {
				[ARMOR] = {
					[2] = {
						{
							minItemLevel = 121,
							maxItemLevel = 151,
							-- amountOfMats = 0.0167
							amountOfMats = 0.01 -- 1 Small, 3% Chance = 1/3*0.03
						},
						{
							minItemLevel = 152,
							maxItemLevel = 200,
							-- amountOfMats = 0.05
							amountOfMats = 0.03 -- 1 Large, 3% Chance = 1*0.03
						},
					},
					[3] = {
						{
							minItemLevel = 121,
							maxItemLevel = 164,
							amountOfMats = 0.333 -- 1 Small, 100% Chance = 1/3*1
						},
						{
							minItemLevel = 165,
							maxItemLevel = 200,
							amountOfMats = 1 -- 1 Large, 100% Chance = 1*1
						},
					},
				},
				[WEAPON] = {
					[2] = {
						{
							minItemLevel = 121,
							maxItemLevel = 151,
							-- amountOfMats = 0.0167
							amountOfMats = 0.01 -- 1 Small, 3% Chance = 1/3*0.03
						},
						{
							minItemLevel = 152,
							maxItemLevel = 200,
							-- amountOfMats = 0.05
							amountOfMats = 0.03 -- 1 Large, 3% Chance = 1*0.03
						},
					},
					[3] = {
						{
							minItemLevel = 121,
							maxItemLevel = 164,
							amountOfMats = 0.333 -- 1 Small, 100% Chance = 1/3*1
						},
						{
							minItemLevel = 165,
							maxItemLevel = 200,
							amountOfMats = 1 -- 1 Large, 100% Chance = 1*1
						},
					},
				},
			},
		},
		-- ["item:52720:0:0:0:0:0:0"] = {
			-- -- Small Heavenly Shard
			-- name = GetItemInfo("item:52720:0:0:0:0:0:0"),
			-- minLevel = 78,
			-- maxLevel = 85,
			-- itemTypes = {
				-- [ARMOR] = {
					-- [3] = {
						-- {
							-- minItemLevel = 282,
							-- maxItemLevel = 316,
							-- amountOfMats = 1
						-- },
					-- },
				-- },
				-- [WEAPON] = {
					-- [3] = {
						-- {
							-- minItemLevel = 282,
							-- maxItemLevel = 316,
							-- amountOfMats = 1
						-- },
					-- },
				-- },
			-- },
		-- },
		-- ["item:52721:0:0:0:0:0:0"] = {
			-- -- Heavenly Shard
			-- name = GetItemInfo("item:52721:0:0:0:0:0:0"),
			-- minLevel = 78,
			-- maxLevel = 85,
			-- itemTypes = {
				-- [ARMOR] = {
					-- [3] = {
						-- {
							-- minItemLevel = 282,
							-- maxItemLevel = 316,
							-- amountOfMats = 0.33
						-- },
						-- {
							-- minItemLevel = 317,
							-- maxItemLevel = 377,
							-- amountOfMats = 1
						-- },
					-- },
				-- },
				-- [WEAPON] = {
					-- [3] = {
						-- {
							-- minItemLevel = 282,
							-- maxItemLevel = 316,
							-- amountOfMats = 0.33
						-- },
						-- {
							-- minItemLevel = 317,
							-- maxItemLevel = 377,
							-- amountOfMats = 1
						-- },
					-- },
				-- },
			-- },
		-- },
		-- ["item:74252:0:0:0:0:0:0"] = {
			-- --Small Ethereal Shard
			-- name = GetItemInfo("item:74252:0:0:0:0:0:0"),
			-- minLevel = 85,
			-- maxLevel = 90,
			-- itemTypes = {
				-- [ARMOR] = {
					-- [3] = {
						-- {
							-- minItemLevel = 384,
							-- maxItemLevel = 429,
							-- amountOfMats = 1
						-- },
					-- },
				-- },
				-- [WEAPON] = {
					-- [3] = {
						-- {
							-- minItemLevel = 384,
							-- maxItemLevel = 429,
							-- amountOfMats = 1
						-- },
					-- },
				-- },
			-- },
		-- },
		-- ["item:74247:0:0:0:0:0:0"] = {
			-- --Ethereal Shard
			-- name = GetItemInfo("item:74247:0:0:0:0:0:0"),
			-- minLevel = 85,
			-- maxLevel = 90,
			-- itemTypes = {
				-- [ARMOR] = {
					-- [3] = {
						-- {
							-- minItemLevel = 384,
							-- maxItemLevel = 429,
							-- amountOfMats = 0.33
						-- },
						-- {
							-- minItemLevel = 430,
							-- maxItemLevel = 500,
							-- amountOfMats = 1
						-- },
					-- },
				-- },
				-- [WEAPON] = {
					-- [3] = {
						-- {
							-- minItemLevel = 384,
							-- maxItemLevel = 429,
							-- amountOfMats = 0.33
						-- },
						-- {
							-- minItemLevel = 430,
							-- maxItemLevel = 500,
							-- amountOfMats = 1
						-- },
					-- },
				-- },
			-- },
		-- },
	},
	{
		desc = L["Crystals"],
		["item:20725:0:0:0:0:0:0"] = {
			-- Nexus Crystal
			name = GetItemInfo("item:20725:0:0:0:0:0:0"),
			minLevel = 56,
			maxLevel = 60,
			itemTypes = {
				[ARMOR] = {
					[4] = {
						{
							minItemLevel = 56,
							maxItemLevel = 60,
							amountOfMats = 1.000
						},
						{
							minItemLevel = 61,
							maxItemLevel = 94,
							amountOfMats = 1.5
						},
					},
				},
				[WEAPON] = {
					[4] = {
						{
							minItemLevel = 56,
							maxItemLevel = 60,
							amountOfMats = 1.000
						},
						{
							minItemLevel = 61,
							maxItemLevel = 94,
							amountOfMats = 1.5
						},
					},
				},
			},
		},
		["item:22450:0:0:0:0:0:0"] = {
			-- Void Crystal
			name = GetItemInfo("item:22450:0:0:0:0:0:0"),
			minLevel = 70,
			maxLevel = 70,
			itemTypes = {
				[ARMOR] = {
					[4] = {
						{
							minItemLevel = 95,
							maxItemLevel = 99,
							amountOfMats = 1
						},
						{
							minItemLevel = 100,
							maxItemLevel = 164,
							amountOfMats = 1.5
						},
					},
				},
				[WEAPON] = {
					[4] = {
						{
							minItemLevel = 95,
							maxItemLevel = 99,
							amountOfMats = 1
						},
						{
							minItemLevel = 100,
							maxItemLevel = 164,
							amountOfMats = 1.5
						},
					},
				},
			},
		},
		["item:34057:0:0:0:0:0:0"] = {
			-- Abyss Crystal
			name = GetItemInfo("item:34057:0:0:0:0:0:0"),
			minLevel = 80,
			maxLevel = 80,
			itemTypes = {
				[ARMOR] = {
					[4] = {
						{
							minItemLevel = 165,
							maxItemLevel = 299,
							amountOfMats = 1.000
						},
					},
				},
				[WEAPON] = {
					[4] = {
						{
							minItemLevel = 165,
							maxItemLevel = 299,
							amountOfMats = 1.000
						},
					},
				},
			},
		},
		-- ["item:52722:0:0:0:0:0:0"] = {
			-- -- Maelstrom Crystal
			-- name = GetItemInfo("item:52722:0:0:0:0:0:0"),
			-- minLevel = 85,
			-- maxLevel = 85,
			-- itemTypes = {
				-- [ARMOR] = {
					-- [4] = {
						-- {
							-- minItemLevel = 300,
							-- maxItemLevel = 419,
							-- amountOfMats = 1.000
						-- },
					-- },
				-- },
				-- [WEAPON] = {
					-- [4] = {
						-- {
							-- minItemLevel = 285,
							-- maxItemLevel = 419,
							-- amountOfMats = 1.000
						-- },
					-- },
				-- },
			-- },
		-- },
		-- ["item:74248:0:0:0:0:0:0"] = {
			-- -- Sha Crystal
			-- name = GetItemInfo("item:74248:0:0:0:0:0:0"),
			-- minLevel = 85,
			-- maxLevel = 90,
			-- itemTypes = {
				-- [ARMOR] = {
					-- [4] = {
						-- {
							-- minItemLevel = 420,
							-- maxItemLevel = 600,
							-- amountOfMats = 1.000
						-- },
					-- },
				-- },
				-- [WEAPON] = {
					-- [4] = {
						-- {
							-- minItemLevel = 420,
							-- maxItemLevel = 600,
							-- amountOfMats = 1.000
						-- },
					-- },
				-- },
			-- },
		-- },
	},
}

data.notDisenchantable = {
	["item:11290:0:0:0:0:0:0"] = true,
	["item:11289:0:0:0:0:0:0"] = true,
	["item:11288:0:0:0:0:0:0"] = true,
	["item:11287:0:0:0:0:0:0"] = true,
	-- ["item:60223:0:0:0:0:0:0"] = true,
	-- ["item:52252:0:0:0:0:0:0"] = true,
	["item:20406:0:0:0:0:0:0"] = true,
	["item:20407:0:0:0:0:0:0"] = true,
	["item:20408:0:0:0:0:0:0"] = true,
	["item:21766:0:0:0:0:0:0"] = true,
	-- ["item:52485:0:0:0:0:0:0"] = true,
	-- ["item:52486:0:0:0:0:0:0"] = true,
	-- ["item:52487:0:0:0:0:0:0"] = true,
	-- ["item:52488:0:0:0:0:0:0"] = true,
	-- ["item:97826:0:0:0:0:0:0"] = true,
	-- ["item:97827:0:0:0:0:0:0"] = true,
	-- ["item:97828:0:0:0:0:0:0"] = true,
	-- ["item:97829:0:0:0:0:0:0"] = true,
	-- ["item:97830:0:0:0:0:0:0"] = true,
	-- ["item:97831:0:0:0:0:0:0"] = true,
	-- ["item:97832:0:0:0:0:0:0"] = true,
}

function TSMAPI:GetEnchantingConversionNum(targetID, matID)
	if targetID == matID then return 1 end

	if data.notDisenchantable[matID] then return end
	local rarity, ilvl, _, class = select(3, GetItemInfo(matID))
	for i = 1, #data.disenchant do
		local mat = data.disenchant[i][targetID]
		if mat and mat.itemTypes and mat.itemTypes[class] and mat.itemTypes[class][rarity] then
			for _, iData in ipairs(mat.itemTypes[class][rarity]) do
				if ilvl >= iData.minItemLevel and ilvl <= iData.maxItemLevel then
					return iData.amountOfMats
				end
			end
		end
	end
end

function TSMAPI:GetEnchantingTargetItems()
	local items = {}
	for _, data in pairs(data.disenchant) do
		for itemString in pairs(data) do
			if itemString ~= "desc" then
				tinsert(items, itemString)
			end
		end
	end
	return items
end

function TSMAPI:GetDisenchantData(targetItem)
	for i = 1, #data.disenchant do
		if data.disenchant[i][targetItem] then
			return data.disenchant[i][targetItem]
		end
	end
end