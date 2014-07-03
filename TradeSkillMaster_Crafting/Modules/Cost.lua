-- ------------------------------------------------------------------------------ --
--                            TradeSkillMaster_Crafting                           --
--            http://www.curse.com/addons/wow/tradeskillmaster_crafting           --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- load the parent file (TSM) into a local variable and register this file as a module
local TSM = select(2, ...)
local Cost = TSM:NewModule("Cost", "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster_Crafting") -- loads the localization table


local currentVisited = {}
local cache = { time = 0 }
function Cost:GetMatCost(itemString)
	local mat = TSM.db.factionrealm.mats[itemString]
	if not mat then return end

	if cache.time < (time() - 1) then
		cache = {}
		cache.time = time()
	end
	if cache[itemString] then return cache[itemString] end

	if currentVisited[itemString] then return end
	currentVisited[itemString] = true
	local cost = TSM:GetCustomPrice(mat.customValue or TSM.db.global.defaultMatCostMethod, itemString)
	currentVisited[itemString] = nil

	cache[itemString] = cost
	return cost
end

-- gets the value of a crafted item
function Cost:GetCraftValue(itemString)
	if type(itemString) == "number" then
		-- we got passed a spell
		if not TSM.db.factionrealm.crafts[itemString] then return end
		itemString = TSM.db.factionrealm.crafts[itemString].itemID
	end
	if type(itemString) ~= "string" then return end
	local operation = TSMAPI:GetItemOperation(itemString, "Crafting")
	TSMAPI:UpdateOperation("Crafting", operation and operation[1])
	operation = operation and TSM.operations[operation[1]]
	local priceMethod = operation and operation.craftPriceMethod or TSM.db.global.defaultCraftPriceMethod
	return TSM:GetCustomPrice(priceMethod, itemString)
end

-- gets the cost to create this craft
function Cost:GetCraftCost(itemID)
	local spellIDs
	if type(itemID) == "string" then
		-- we got passed an item
		spellIDs = TSM.craftReverseLookup[TSMAPI:GetBaseItemstring(itemID)]
	elseif type(itemID) == "number" then
		-- we got passed a spell
		if TSM.db.factionrealm.crafts[itemID] then
			spellIDs = { itemID }
		end
	end
	if not spellIDs or #spellIDs == 0 then return end

	local lowestCost
	for _, spellID in ipairs(spellIDs) do
		local craft = TSM.db.factionrealm.crafts[spellID]
		local cost, costIsValid = 0, true
		if #spellIDs >= 2 and TSM.db.global.ignoreCDCraftCost and TSM.db.factionrealm.crafts[spellID].hasCD then
			costIsValid = false
		end
		for matID, matQuantity in pairs(craft.mats) do
			local matCost = Cost:GetMatCost(matID)
			if not matCost or matCost == 0 then
				costIsValid = false
				break
			end
			cost = cost + matQuantity * matCost
		end
		cost = floor(cost / (craft.numResult) + 0.5) --rounds to nearest gold

		if costIsValid then
			if not lowestCost or cost < lowestCost then
				lowestCost = cost
			end
		end
	end

	return lowestCost
end

-- calulates the cost, buyout, and profit for a crafted item
function Cost:GetCraftPrices(itemID)
	if not itemID then return end

	local cost, buyout, profit
	cost = Cost:GetCraftCost(itemID)
	buyout = Cost:GetCraftValue(itemID)

	if cost and buyout then
		profit = floor(buyout - buyout * TSM.db.global.profitPercent - cost + 0.5)
	end

	return cost, buyout, profit
end

-- gets the spellID, cost, buyout, and profit for the cheapest way to craft the given item
function Cost:GetLowestCraftPrices(itemString, intermediate)
	local spellIDs = TSM.craftReverseLookup[itemString]
	if not spellIDs then return end
	local lowestCost, cheapestSpellID
	local soh = "item:76061:0:0:0:0:0:0" -- Spirit of Harmony
	for _, spellID in ipairs(spellIDs) do
		if TSM.db.factionrealm.crafts[spellID] then
			if intermediate and (TSM.db.factionrealm.crafts[spellID].mats[soh] or TSM.db.factionrealm.crafts[spellID].hasCD) then
				break
			end --exclude spells using SOH or have cooldown from intermediate crafts
			local cost = Cost:GetCraftCost(spellID)
			if cost and (not lowestCost or cost < lowestCost) then
				-- exclude spells with cooldown if option to ignore is enabled or more than one way to craft and not soulbound e.g. BoE
				if not TSM.db.global.ignoreCDCraftCost then
					if TSM.db.factionrealm.crafts[spellID].hasCD then
						if TSMAPI.SOULBOUND_MATS[itemString] or #spellIDs == 1 then
							lowestCost = cost
							cheapestSpellID = spellID
						end
					else
						lowestCost = cost
						cheapestSpellID = spellID
					end
				elseif not TSM.db.factionrealm.crafts[spellID].hasCD then
					lowestCost = cost
					cheapestSpellID = spellID
				end
			end
		end
	end

	if not lowestCost or not cheapestSpellID then return end
	local profit, buyout
	buyout = Cost:GetCraftValue(itemString)
	if buyout then
		profit = floor(buyout - buyout * TSM.db.global.profitPercent - lowestCost + 0.5)
	end

	return cheapestSpellID, lowestCost, buyout, profit
end