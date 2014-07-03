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
			if itemString == "item:38682" then
				TSM.db.factionrealm.crafts[spellid].mats["item:38682:0:0:0:0:0:0"] = 1
				TSM.db.factionrealm.crafts[spellid].mats[itemString] = nil
			end
		end
	end
	if TSM.db.factionrealm.mats["item:38682"] then
		local name = TSMAPI:GetSafeItemInfo("item:38682:0:0:0:0:0:0") or (GetLocale() == "enUS" and "Enchanting Vellum") or nil
		TSM.db.factionrealm.mats["item:38682:0:0:0:0:0:0"] = {}
		TSM.db.factionrealm.mats["item:38682:0:0:0:0:0:0"].name = name
		TSM.db.factionrealm.mats["item:38682"] = nil
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
				tinsert(text, { left = "  " .. L["Crafting Cost"], right = format(L["%s (%s profit)"], costText, profitText) })
				
				if TSM.db.global.matsInTooltip and TSM.db.factionrealm.crafts[spellID] then
					for matItemString, matQuantity in pairs(TSM.db.factionrealm.crafts[spellID].mats) do
						local name, _, quality = TSMAPI:GetSafeItemInfo(matItemString)
						if name then
							local mat = TSM.db.factionrealm.mats[matItemString]
							if mat then
								local cost = TSM:GetCustomPrice(mat.customValue or TSM.db.global.defaultMatCostMethod, matItemString)
								if cost then
									local colorName = format("|c%s%s%s%s|r",select(4,GetItemQualityColor(quality)),name, " x ", matQuantity)
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
	if reverseLookupUpdate >= time() - 30 then return end
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