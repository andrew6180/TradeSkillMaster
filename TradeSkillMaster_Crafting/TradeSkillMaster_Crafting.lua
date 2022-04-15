-- ------------------------------------------------------------------------------ --
--                            TradeSkillMaster_Crafting                           --
--            http://www.curse.com/addons/wow/tradeskillmaster_crafting           --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- register this file with Ace Libraries
local TSM = select(2, ...)
TSM = LibStub("AceAddon-3.0"):NewAddon(TSM, "TSM_Crafting", "AceEvent-3.0", "AceConsole-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster_Crafting") -- loads the localization table


-- default values for the savedDB
local savedDBDefaults = {
	global = {
		optionsTreeStatus = {},
		tooltip = true,
		materialTooltip = true,
		ignoreCharacters = {},
		ignoreGuilds = {},
		profitPercent = 0,
		defaultMatCostMethod = "min(dbmarket, crafting, vendorbuy, convert(dbmarket))",
		defaultCraftPriceMethod = "dbminbuyout",
		priceColumn = 1,
		ignoreCDCraftCost = true,
		neverCraftInks = true,
		frameQueueOpen = nil,
		showingDefaultFrame = nil,
		matsInTooltip = true,
	},
	factionrealm = {
		tradeSkills = {},
		crafts = {},
		mats = {},
		queueStatus = { collapsed = {} },
		sourceStatus = { collapsed = {} },
		gathering = { crafter = nil, professions = {}, neededMats = {}, availableMats = {}, gatheredMats = false, gatherAll = false, destroyingMats = {}, destroyDisable = false, evenStacks = true },
		craftingCostCache = {}
	},
}

-- Called once the player has loaded WOW.
function TSM:OnEnable()
	-- create shortcuts to TradeSkillMaster_Crafting's modules
	for moduleName, module in pairs(TSM.modules) do
		TSM[moduleName] = module
	end

	-- load the savedDB into TSM.db
	TSM.db = LibStub:GetLibrary("AceDB-3.0"):New("TradeSkillMaster_CraftingDB", savedDBDefaults, true)
	TSM:UpdateCraftReverseLookup()
	
	-- register this module with TSM
	TSM:RegisterModule()
		
	-- fix vellum issue
	for spellid, data in pairs(TSM.db.factionrealm.crafts) do
		for itemString in pairs(data.mats) do
			-- if itemString == "item:38682" then
				-- TSM.db.factionrealm.crafts[spellid].mats["item:38682:0:0:0:0:0:0"] = 1
			if itemString == "item:43146" then
				TSM.db.factionrealm.crafts[spellid].mats["item:43146:0:0:0:0:0:0"] = 1
				TSM.db.factionrealm.crafts[spellid].mats[itemString] = nil
			elseif itemString == "item:43145" then
				TSM.db.factionrealm.crafts[spellid].mats["item:43145:0:0:0:0:0:0"] = 1
				TSM.db.factionrealm.crafts[spellid].mats[itemString] = nil
			elseif itemString == "item:39350" then
				TSM.db.factionrealm.crafts[spellid].mats["item:39350:0:0:0:0:0:0"] = 1
				TSM.db.factionrealm.crafts[spellid].mats[itemString] = nil	
			elseif itemString == "item:37602" then
				TSM.db.factionrealm.crafts[spellid].mats["item:37602:0:0:0:0:0:0"] = 1
				TSM.db.factionrealm.crafts[spellid].mats[itemString] = nil		
			elseif itemString == "item:39349" then
				TSM.db.factionrealm.crafts[spellid].mats["item:39349:0:0:0:0:0:0"] = 1
				TSM.db.factionrealm.crafts[spellid].mats[itemString] = nil			
			elseif itemString == "item:38682" then
				TSM.db.factionrealm.crafts[spellid].mats["item:38682:0:0:0:0:0:0"] = 1
				TSM.db.factionrealm.crafts[spellid].mats[itemString] = nil
			elseif itemString == "item:52510" then
				TSM.db.factionrealm.crafts[spellid].mats["item:52510:0:0:0:0:0:0"] = 1
				TSM.db.factionrealm.crafts[spellid].mats[itemString] = nil
			elseif itemString == "item:52511" then
				TSM.db.factionrealm.crafts[spellid].mats["item:52511:0:0:0:0:0:0"] = 1
				TSM.db.factionrealm.crafts[spellid].mats[itemString] = nil
			end
		end
	end
	-- if TSM.db.factionrealm.mats["item:38682"] then
		-- local name = TSMAPI:GetSafeItemInfo("item:38682:0:0:0:0:0:0") or (GetLocale() == "enUS" and "Enchanting Vellum") or nil
		-- TSM.db.factionrealm.mats["item:38682:0:0:0:0:0:0"] = {}
		-- TSM.db.factionrealm.mats["item:38682:0:0:0:0:0:0"].name = name
		-- TSM.db.factionrealm.mats["item:38682"] = nil
	-- end
	if TSM.db.factionrealm.mats["item:43146"] then
		local name = TSMAPI:GetSafeItemInfo("item:43146:0:0:0:0:0:0") or nil
		TSM.db.factionrealm.mats["item:43146:0:0:0:0:0:0"] = {}
		TSM.db.factionrealm.mats["item:43146:0:0:0:0:0:0"].name = name
		TSM.db.factionrealm.mats["item:43146"] = nil
	end
	if TSM.db.factionrealm.mats["item:43145"] then
		local name = TSMAPI:GetSafeItemInfo("item:43145:0:0:0:0:0:0") or nil
		TSM.db.factionrealm.mats["item:43145:0:0:0:0:0:0"] = {}
		TSM.db.factionrealm.mats["item:43145:0:0:0:0:0:0"].name = name
		TSM.db.factionrealm.mats["item:43145"] = nil
	end
	if TSM.db.factionrealm.mats["item:39350"] then
		local name = TSMAPI:GetSafeItemInfo("item:39350:0:0:0:0:0:0") or nil
		TSM.db.factionrealm.mats["item:39350:0:0:0:0:0:0"] = {}
		TSM.db.factionrealm.mats["item:39350:0:0:0:0:0:0"].name = name
		TSM.db.factionrealm.mats["item:39350"] = nil
	end
	if TSM.db.factionrealm.mats["item:39350"] then
		local name = TSMAPI:GetSafeItemInfo("item:39350:0:0:0:0:0:0") or nil
		TSM.db.factionrealm.mats["item:39350:0:0:0:0:0:0"] = {}
		TSM.db.factionrealm.mats["item:39350:0:0:0:0:0:0"].name = name
		TSM.db.factionrealm.mats["item:39350"] = nil
	end
	if TSM.db.factionrealm.mats["item:37602"] then
		local name = TSMAPI:GetSafeItemInfo("item:37602:0:0:0:0:0:0") or nil
		TSM.db.factionrealm.mats["item:37602:0:0:0:0:0:0"] = {}
		TSM.db.factionrealm.mats["item:37602:0:0:0:0:0:0"].name = name
		TSM.db.factionrealm.mats["item:37602"] = nil
	end
	if TSM.db.factionrealm.mats["item:39349"] then
		local name = TSMAPI:GetSafeItemInfo("item:39349:0:0:0:0:0:0") or nil
		TSM.db.factionrealm.mats["item:39349:0:0:0:0:0:0"] = {}
		TSM.db.factionrealm.mats["item:39349:0:0:0:0:0:0"].name = name
		TSM.db.factionrealm.mats["item:39349"] = nil
	end
	if TSM.db.factionrealm.mats["item:38682"] then
		local name = TSMAPI:GetSafeItemInfo("item:38682:0:0:0:0:0:0") or nil
		TSM.db.factionrealm.mats["item:38682:0:0:0:0:0:0"] = {}
		TSM.db.factionrealm.mats["item:38682:0:0:0:0:0:0"].name = name
		TSM.db.factionrealm.mats["item:38682"] = nil
	end
	if TSM.db.factionrealm.mats["item:52510"] then
		local name = TSMAPI:GetSafeItemInfo("item:52510:0:0:0:0:0:0") or nil
		TSM.db.factionrealm.mats["item:52510:0:0:0:0:0:0"] = {}
		TSM.db.factionrealm.mats["item:52510:0:0:0:0:0:0"].name = name
		TSM.db.factionrealm.mats["item:52510"] = nil
	end
	if TSM.db.factionrealm.mats["item:52511"] then
		local name = TSMAPI:GetSafeItemInfo("item:52511:0:0:0:0:0:0") or nil
		TSM.db.factionrealm.mats["item:52511:0:0:0:0:0:0"] = {}
		TSM.db.factionrealm.mats["item:52511:0:0:0:0:0:0"].name = name
		TSM.db.factionrealm.mats["item:52511"] = nil
	end
	
	local func, err = TSMAPI:ParseCustomPrice(TSM.db.global.defaultCraftPriceMethod, "crafting")
	if not func then
		TSM:Printf(L["Your default craft value method was invalid so it has been returned to the default. Details: %s"], err)
		TSM.db.global.defaultCraftPriceMethod = savedDBDefaults.defaultCraftPriceMethod
	end
	for name, operation in pairs(TSM.operations) do
		if operation.craftPriceMethod then
			local func, err = TSMAPI:ParseCustomPrice(TSM.db.global.defaultCraftPriceMethod, "crafting")
			if not func then
				TSM:Printf(L["Your craft value method for '%s' was invalid so it has been returned to the default. Details: %s"], name, err)
				operation.craftPriceMethod = TSM.operationDefaults.craftPriceMethod
			end
		end
	end
end

-- registers this module with TSM by first setting all fields and then calling TSMAPI:NewModule().
function TSM:RegisterModule()
	TSM.icons = { { side = "module", desc = "Crafting", slashCommand = "crafting", callback = "Options:LoadCrafting", icon = "Interface\\Icons\\INV_Misc_Gear_08" } }
	TSM.operations = { maxOperations = 1, callbackOptions = "Options:Load", callbackInfo = "GetOperationInfo" }
	TSM.priceSources = {
		{ key = "Crafting", label = L["Crafting Cost"], callback = "GetCraftingCost" },
		{ key = "matPrice", label = L["Crafting Material Cost"], callback = "GetCraftingMatCost" },
	}
	TSM.moduleAPIs = {
		{ key = "addQueue", callback = "Queue:addQueue" },
		{ key = "removeQueue", callback = "Queue:removeQueue" },
		{ key = "getQueue", callback = "Queue:getQueue" },
		{ key = "getCDCrafts", callback = "getCDCrafts" },
		{ key = "getCraftingFrameStatus", callback = "CraftingGUI:GetStatus" },
	}
	TSM.tooltipOptions = { callback = "Options:LoadTooltipOptions" }
	TSM.slashCommands = {
		{ key = "profession", label = L["Opens the Crafting window to the first profession."], callback = "CraftingGUI:OpenFirstProfession" },
		{ key = "restock_help", label = "Tells you why a specific item is not being restocked and added to the queue.", callback = "RestockHelp" },
	}
	TSM.sync = { callback = "Sync:Callback" }
	TSMAPI:NewModule(TSM)
end

TSM.operationDefaults = {
	minRestock = 1, -- min of 1
	maxRestock = 3, -- max of 3
	minProfit = 1000000,
	craftPriceMethod = nil,
	ignorePlayer = {},
	ignoreFactionrealm = {},
	relationships = {},
}

function TSM:GetOperationInfo(name)
	TSMAPI:UpdateOperation("Crafting", name)
	local operation = TSM.operations[name]
	if not operation then return end
	if operation.minProfit then
		return format(L["Restocking to a max of %d (min of %d) with a min profit."], operation.maxRestock, operation.minRestock)
	else
		return format(L["Restocking to a max of %d (min of %d) with no min profit."], operation.maxRestock, operation.minRestock)
	end
end

function TSM:GetTooltip(itemString)
	if not TSM.db.global.tooltip then return end
	local text = {}
	local moneyCoinsTooltip = TSMAPI:GetMoneyCoinsTooltip()
	TSM:UpdateCraftReverseLookup()
	itemString = TSMAPI:GetBaseItemString(itemString) -- show craft costs against random enchants

	if TSM.craftReverseLookup[itemString] then
		if TSM.db.global.tooltip then
			local spellID, cost, buyout, profit = TSM.Cost:GetLowestCraftPrices(itemString)
			local color

			if profit and profit < 0 then
				color = "|cffff0000"
			else
				color = "|cff00ff00"
				
			end

			if cost then
				local costText, profitText
				if moneyCoinsTooltip then
					costText = (TSMAPI:FormatTextMoneyIcon(cost, "|cffffffff", true) or "|cffffffff---|r")
					profitText = (TSMAPI:FormatTextMoneyIcon(profit, color, true) or "|cffffffff---|r")
				else
					costText = (TSMAPI:FormatTextMoney(cost, "|cffffffff", true) or "|cffffffff---|r")
					profitText = (TSMAPI:FormatTextMoney(profit, color, true) or "|cffffffff---|r")
				end
				if profit then
					local profitPercent = profit / cost * 100
					local profitPercText = format("%s%.0f%%|r",color, profitPercent)
				
					if profit>0 then
						tinsert(text, { left = "  " .. L["Crafting Cost"], right = format("%s (%s | %s profit)", costText, profitText, profitPercText) })
					else
						tinsert(text, { left = "  " .. L["Crafting Cost"], right = format("%s (%s | %s loss)", costText, profitText, profitPercText) })
					end
				else
					-- tinsert(text, { left = "  " .. L["Crafting Cost"], right = format(L["%s (%s profit)"], costText, profitText) })
					tinsert(text, { left = "  " .. L["Crafting Cost"], right = format("%s", costText) })
				end 
				
				if TSM.db.global.matsInTooltip and TSM.db.factionrealm.crafts[spellID] then
					for matItemString, matQuantity in pairs(TSM.db.factionrealm.crafts[spellID].mats) do
						local name, _, quality = TSMAPI:GetSafeItemInfo(matItemString)
						if name then
							local mat = TSM.db.factionrealm.mats[matItemString]
							
							
							
							-- Get Cheapest vellum, lower vellum types can be replaced by III
							local velName
							if strfind(name, "Vellum") then
								velName = name
							end
							if (velName ~= nil) and (not strfind(velName, "III")) then					
								local VellumReplacePrice = TSM.Cost:GetMatCost(matItemString)

								if strfind(velName, "Weapon") then						
									if VellumReplacePrice > TSM.Cost:GetMatCost("item:52511:0:0:0:0:0:0") then 
										matItemString = "item:52511:0:0:0:0:0:0"
										name = TSMAPI:GetSafeItemInfo(matItemString)
									end
								else
									if VellumReplacePrice > TSM.Cost:GetMatCost("item:52510:0:0:0:0:0:0") then 
										matItemString = "item:52510:0:0:0:0:0:0"
										name = TSMAPI:GetSafeItemInfo(matItemString)						
									end
								end
							end
							
							
				
							
							if mat then
								local cost = TSM:GetCustomPrice(mat.customValue or TSM.db.global.defaultMatCostMethod, matItemString)
								if cost then
									-- local colorName = format("|c%s%s%s%s|r",select(4,GetItemQualityColor(quality)),name, " x ", matQuantity)
									local colorName = format("%s%s%s%s|r",select(4,GetItemQualityColor(quality)), name, " x ", matQuantity)
									if matQuantity > 1 then
										if moneyCoinsTooltip then
											tinsert(text, { left = "    " .. colorName, right = "ea: "..TSMAPI:FormatTextMoneyIcon(cost, "|cffffffff", true).." | total: "..TSMAPI:FormatTextMoneyIcon(cost*matQuantity, "|cffffffff", true)})
										else
											tinsert(text, { left = "    " .. colorName, right = "ea: "..TSMAPI:FormatTextMoney(cost, "|cffffffff", true).." | total: "..TSMAPI:FormatTextMoney(cost*matQuantity, "|cffffffff", true)})
										end
									else
										if moneyCoinsTooltip then
											tinsert(text, { left = "    " .. colorName, right = TSMAPI:FormatTextMoneyIcon(cost*matQuantity, "|cffffffff", true) })
										else
											tinsert(text, { left = "    " .. colorName, right = TSMAPI:FormatTextMoney(cost*matQuantity, "|cffffffff", true) })
										end
									end
								end
							end
						end
					end
				end
			end
		end
	end
	if TSM.db.global.materialTooltip then
		local mat = TSM.db.factionrealm.mats[itemString]
		if mat then
			local cost = TSM:GetCustomPrice(mat.customValue or TSM.db.global.defaultMatCostMethod, itemString)
			if cost then
				local costText
				if moneyCoinsTooltip then
					costText = (TSMAPI:FormatTextMoneyIcon(cost, "|cffffffff", true) or "|cffffffff---|r")
				else
					costText = (TSMAPI:FormatTextMoney(cost, "|cffffffff", true) or "|cffffffff---|r")
				end
				tinsert(text, { left = "  " .. L["Mat Cost"], right = format("%s", costText) })
			end
		end
	end


	if #text > 0 then
		tinsert(text, 1, "|cffffff00" .. "TSM Crafting:")
		return text
	end
end

function TSM:GetCraftingCost(link)
	link = select(2, TSMAPI:GetSafeItemInfo(link))
	local itemString = TSMAPI:GetBaseItemString(link)
	if not itemString then return end

	TSM:UpdateCraftReverseLookup()
	local _, cost = TSM.Cost:GetLowestCraftPrices(itemString)
	if cost then
		TSM.db.factionrealm.craftingCostCache[itemString] = cost
	end
	return TSM.db.factionrealm.craftingCostCache[itemString]
end

function TSM:GetCraftingMatCost(link)
	link = select(2, TSMAPI:GetSafeItemInfo(link))
	local itemString = TSMAPI:GetBaseItemString(link)
	if not itemString then return end

	TSM:UpdateCraftReverseLookup()
	return TSM.Cost:GetMatCost(itemString)
end

local reverseLookupUpdate = 0
function TSM:UpdateCraftReverseLookup()
	-- if reverseLookupUpdate >= time() - 30 then return end
	reverseLookupUpdate = time()
	TSM.craftReverseLookup = {}

	for spellID, data in pairs(TSM.db.factionrealm.crafts) do
		TSM.craftReverseLookup[data.itemID] = TSM.craftReverseLookup[data.itemID] or {}
		tinsert(TSM.craftReverseLookup[data.itemID], spellID)
	end
end

function TSM:GetCustomPrice(priceMethod, itemString)
	local func = TSMAPI:ParseCustomPrice(priceMethod)
	return func and func(itemString)
end

function TSM:getCDCrafts()
	local crafts = {}
	for spellID, data in pairs(TSM.db.factionrealm.crafts) do
		if data.hasCD then
			crafts[spellID] = data.name
		end
	end
	return crafts
end

function TSM:RestockHelp(link)
	local itemString = TSMAPI:GetItemString(link)
	if not itemString then
		return print("No item specified. Usage: /tsm restock_help [ITEM_LINK]")
	end
	
	TSM:Printf("Restock help for %s:", link)
	
	-- check if the item is in a group
	local groupPath = TSMAPI:GetGroupPath(itemString)
	if not groupPath then
		return print("This item is not in a TSM group.")
	end
	
	-- check that there's a crafting operation applied
	local operation = (TSMAPI:GetItemOperation(itemString, "Crafting") or {})[1]
	if not operation then
		return print(format("There is no TSM_Crafting operation applied to this item's TSM group (%s).", TSMAPI:FormatGroupPath(groupPath)))
	end
	
	-- check if it's an invalid operation
	local opSettings = TSM.operations[operation]
	if opSettings.minRestock > opSettings.maxRestock then
		return print(format(L["'%s' is an invalid operation! Min restock of %d is higher than max restock of %d."], operation, opSettings.minRestock, opSettings.maxRestock))
	end
	
	-- check that this item is craftable
	TSM:UpdateCraftReverseLookup()
	local spellID = TSM.craftReverseLookup[itemString] and TSM.craftReverseLookup[itemString][1]
	if not spellID or not TSM.db.factionrealm.crafts[spellID] then
		return print("You don't know how to craft this item.")
	end
	
	-- check the restock quantity
	local numHave = TSM.Inventory:GetTotalQuantity(itemString)
	if numHave >= opSettings.maxRestock then
		return print(format("You already have at least your max restock quantity of this item. You have %d and the max restock quantity is %d", numHave, opSettings.maxRestock))
	elseif (opSettings.maxRestock - numHave) < opSettings.minRestock then
		return print(format("The number which would be queued (%d) is less than the min restock quantity (%d).", (opSettings.maxRestock - numHave), opSettings.minRestock))
	end
	
	-- check the prices on the item and the min profit
	if opSettings.minProfit then
		local cheapestSpellID, cost, craftedValue, profit = TSM.Cost:GetLowestCraftPrices(itemString)
		
		-- check that there's a crafted value
		if not craftedValue then
			local craftPriceMethod = operation and operation.craftPriceMethod or TSM.db.global.defaultCraftPriceMethod
			return print(format("The 'Craft Value Method' (%s) did not return a value for this item. If it is based on some price database (AuctionDB, TSM_WoWuction, TUJ, etc), then ensure that you have scanned for or downloaded the data as appropriate.", craftPriceMethod))
		end
		
		-- check that there's a crafted cost
		if not cost then
			return print("This item does not have a crafting cost. Check that all of its mats have mat prices. If the mat prices are based on some price database (AuctionDB, TSM_WoWuction, TUJ, etc), then ensure that you have scanned for or downloaded the data as appropriate.")
		end
		
		-- check that there's a profit
		if not profit then
			return print("There is a crafting cost and crafted item value, but TSM_Crafting wasn't able to calculate a profit. This shouldn't happen!")
		end
		
		local minProfit = TSM:GetCustomPrice(opSettings.minProfit, itemString)
		if not minProfit then
			return print(format("The min profit (%s) did not evalulate to a valid value for this item.", opSettings.minProfit))
		end
		
		if profit < minProfit then
			return print(format("The profit of this item (%s) is below the min profit (%s).", TSMAPI:FormatTextMoney(profit), TSMAPI:FormatTextMoney(minProfit)))
		end
	end
	
	print("This item will be added to the queue when you restock its group. If this isn't happening, make a post on the TSM forums with a screenshot of the item's tooltip, operation settings, and your general TSM_Crafting options.")
end