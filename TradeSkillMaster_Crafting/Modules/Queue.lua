-- ------------------------------------------------------------------------------ --
--                            TradeSkillMaster_Crafting                           --
--            http://www.curse.com/addons/wow/tradeskillmaster_crafting           --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- load the parent file (TSM) into a local variable and register this file as a module
local TSM = select(2, ...)
local Queue = TSM:NewModule("Queue")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster_Crafting") -- loads the localization table

local MAX_QUEUE_STAGES = 10
local inventoryTotals = {}


local notified = {}
function Queue:ValidateOperation(operation)
	if not operation then return end

	if operation.minRestock > operation.maxRestock then
		-- invalid cause min > max restock quantity (shouldn't happen)
		if not notified[opName] then
			notified[opName] = true
			TSM:Printf(L["'%s' is an invalid operation! Min restock of %d is higher than max restock of %d."], opName, operation.minRestock, operation.maxRestock)
		end
		return
	end
	return true
end

function Queue:CreateRestockQueue(groupInfo)
	TSM:UpdateCraftReverseLookup()
	local numItems = 0

	for _, data in pairs(groupInfo) do
		for _, opName in ipairs(data.operations) do
			TSMAPI:UpdateOperation("Crafting", opName)
			local opSettings = TSM.operations[opName]
			if Queue:ValidateOperation(opSettings) then
				-- it's a valid operation
				for itemString in pairs(data.items) do
					itemString = TSMAPI:GetItemString(itemString)
					local spellID = TSM.craftReverseLookup[itemString] and TSM.craftReverseLookup[itemString][1]
					if spellID and TSM.db.factionrealm.crafts[spellID] then
						local maxQueueCount = max(opSettings.maxRestock - TSM.Inventory:GetTotalQuantity(itemString), 0)
						local numToQueue = 0

						if spellID and not opSettings.minProfit then
							-- no minimum, so queue as many as we can
							numToQueue = maxQueueCount
						elseif spellID then
							-- queue it if the profit is at least the min profit
							local cheapestSpellID, cost, _, profit = TSM.Cost:GetLowestCraftPrices(itemString)
							local minProfit = TSM:GetCustomPrice(opSettings.minProfit, itemString)
							if minProfit and profit and profit >= minProfit then
								spellID = cheapestSpellID
								numToQueue = maxQueueCount
							end
						end

						local craft = TSM.db.factionrealm.crafts[spellID]
						craft.queued = floor(numToQueue / craft.numResult)
						craft.queued = craft.queued >= opSettings.minRestock and craft.queued or 0
						if craft.queued > 0 then
							numItems = numItems + 1
						end
					end
				end
			end
		end
	end
	
	TSMAPI:FireEvent("CRAFTING:QUEUE:RESTOCKED", numItems)
end

function Queue:HasLoop(itemString, steps, visited)
	steps = steps + 1
	if steps > 10 then return true end
	if visited[itemString] then return true end
	visited[itemString] = true
	local craftCost = TSM:GetCustomPrice("Crafting", itemString)
	local mat = TSM.db.factionrealm.mats[itemString]
	local lowestCost = TSM:GetCustomPrice(mat.customValue or TSM.db.global.defaultMatCostMethod, itemString)
	if craftCost and lowestCost and craftCost <= lowestCost and (not TSM.db.global.neverCraftInks or not TSMAPI.InkConversions[itemString]) then
		local spellID = TSM.Cost:GetLowestCraftPrices(itemString, true)
		if spellID and TSM.db.factionrealm.crafts[spellID] then
			for matItemString in pairs(TSM.db.factionrealm.crafts[spellID].mats) do
				if Queue:HasLoop(matItemString, steps, CopyTable(visited)) then
					return true
				end
			end
		end
	end
end

function Queue:GetIntermediateCrafts(mats, usedItems, usedMats, tempMats)
	local subCrafts = {}
	for profession, data in pairs(mats) do
		tempMats[profession] = tempMats[profession] or {}
		for itemString, quantity in pairs(data) do
			usedItems[itemString] = usedItems[itemString] or 0
			local numHave = (inventoryTotals[itemString] or 0) - usedItems[itemString]
			if TSMAPI.SOULBOUND_MATS[itemString] then
				numHave = numHave + GetItemCount(itemString, true)
			end
			if numHave > 0 then
				if numHave >= quantity then
					usedItems[itemString] = usedItems[itemString] + quantity
					tempMats[profession][itemString] = (tempMats[profession][itemString] or 0) + quantity
					quantity = 0
					mats[profession][itemString] = nil
				else
					usedItems[itemString] = numHave
					quantity = quantity - numHave
					tempMats[profession][itemString] = (tempMats[profession][itemString] or 0) + numHave
					mats[profession][itemString] = mats[profession][itemString] - numHave
				end
			end

			if quantity > 0 and not Queue:HasLoop(itemString, 0, {}) then
				local mat = TSM.db.factionrealm.mats[itemString]
				local craftCost = TSM:GetCustomPrice("Crafting", itemString)
				local lowestCost = TSM:GetCustomPrice(mat.customValue or TSM.db.global.defaultMatCostMethod, itemString)
				if craftCost and lowestCost and craftCost <= lowestCost and (not TSM.db.global.neverCraftInks or not TSMAPI.InkConversions[itemString]) then
					local spellID = TSM.Cost:GetLowestCraftPrices(itemString, true)
					if spellID and TSM.db.factionrealm.crafts[spellID] then
						local numResult = TSM.db.factionrealm.crafts[spellID].numResult
						quantity = ceil(quantity / numResult)
						subCrafts[TSM.db.factionrealm.crafts[spellID].profession] = subCrafts[TSM.db.factionrealm.crafts[spellID].profession] or {}
						subCrafts[TSM.db.factionrealm.crafts[spellID].profession][spellID] = (subCrafts[TSM.db.factionrealm.crafts[spellID].profession][spellID] or 0) + quantity
						TSM.db.factionrealm.crafts[spellID].queued = TSM.db.factionrealm.crafts[spellID].queued + quantity
						TSM.db.factionrealm.crafts[spellID].intermediateQueued = (TSM.db.factionrealm.crafts[spellID].intermediateQueued or 0) + quantity
						mats[profession][itemString] = nil
						usedMats[profession] = usedMats[profession] or {}
						usedMats[profession][itemString] = numHave
					end
				end
			end
		end
	end

	local newSubCrafts
	for profession, data in pairs(subCrafts) do
		for spellID, quantity in pairs(data) do
			newSubCrafts = true
			for itemString, matQuantity in pairs(TSM.db.factionrealm.crafts[spellID].mats) do
				mats[profession] = mats[profession] or {}
				mats[profession][itemString] = (mats[profession][itemString] or 0) + matQuantity * quantity
			end
		end
	end
	return newSubCrafts and subCrafts
end

function Queue:GetQueue()
	local tempCrafts, queuedCrafts, mats = {}, {}, {}
	local totalCost, totalProfit

	-- first queue up all the normally queued stuff
	for spellID, data in pairs(TSM.db.factionrealm.crafts) do
		if data.intermediateQueued then
			data.queued = max(data.queued - data.intermediateQueued, 0)
			data.intermediateQueued = nil
		end
		if data.queued > 0 then
			local cost, buyout, profit = TSM.Cost:GetCraftPrices(spellID)
			if cost then
				totalCost = (totalCost or 0) + cost * data.queued
			end
			if profit then
				totalProfit = (totalProfit or 0) + profit * data.queued
			end
			tempCrafts[data.profession] = tempCrafts[data.profession] or {}
			tempCrafts[data.profession][spellID] = data.queued
			for itemString, quantity in pairs(data.mats) do
				mats[data.profession] = mats[data.profession] or {}
				mats[data.profession][itemString] = (mats[data.profession][itemString] or 0) + quantity * data.queued
			end
		end
	end
	for profession, data in pairs(tempCrafts) do
		queuedCrafts[profession] = queuedCrafts[profession] or {}
		tinsert(queuedCrafts[profession], 1, { crafts = data })
	end

	-- queue intermediate crafts
	local usedItems, usedMats, tempMats = {}, {}, {}
	inventoryTotals = select(4, TSM.Inventory:GetTotals())
	for i = 1, MAX_QUEUE_STAGES - 1 do
		local subCrafts = Queue:GetIntermediateCrafts(mats, usedItems, usedMats, tempMats)
		if not subCrafts then break end

		for profession, data in pairs(subCrafts) do
			queuedCrafts[profession] = queuedCrafts[profession] or {}
			tinsert(queuedCrafts[profession], 1, { crafts = data })
		end
	end

	-- readd usedMats back in
	for profession, data in pairs(tempMats) do
		for itemString, quantity in pairs(data) do
			mats[profession][itemString] = (mats[profession][itemString] or 0) + quantity
		end
	end

	for profession, data in pairs(usedMats) do
		if mats[profession] then
			for itemString, quantity in pairs(data) do
				mats[profession][itemString] = (mats[profession][itemString] or 0) + quantity
			end
		end
	end

	-- give each stage the appropriate name
	for profession, stages in pairs(queuedCrafts) do
		for i, stageInfo in ipairs(stages) do
			stageInfo.name = format(L["Stage %d"], i)
		end
	end

	totalCost = totalCost or "---"
	totalProfit = totalProfit or "---"
	return queuedCrafts, mats, totalCost, totalProfit
end

function Queue:ClearQueue()
	for spellID, data in pairs(TSM.db.factionrealm.crafts) do
		data.queued = 0
		data.intermediateQueued = nil
	end
end

function Queue:addQueue(spellID, quantity)
	local craft = TSM.db.factionrealm.crafts[spellID]
	if not craft then return end
	quantity = quantity or 1
	craft.queued = craft.queued + quantity
	TSM.CraftingGUI:UpdateQueue()
end

function Queue:removeQueue(spellID, quantity)
	local craft = TSM.db.factionrealm.crafts[spellID]
	if not craft then return end
	quantity = quantity or 1
	craft.queued = max(craft.queued - quantity, 0)
	TSM.CraftingGUI:UpdateQueue()
end

function Queue:getQueue(spellID)
	local craft = TSM.db.factionrealm.crafts[spellID]
	return craft.queued
end