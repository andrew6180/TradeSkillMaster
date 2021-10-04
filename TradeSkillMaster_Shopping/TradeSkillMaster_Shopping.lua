-- ------------------------------------------------------------------------------ --
--                            TradeSkillMaster_Shopping                           --
--            http://www.curse.com/addons/wow/tradeskillmaster_shopping           --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

local TSM = select(2, ...)
TSM = LibStub("AceAddon-3.0"):NewAddon(TSM, "TSM_Shopping", "AceEvent-3.0", "AceConsole-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster_Shopping") -- loads the localization table
local AceGUI = LibStub("AceGUI-3.0")

local savedDBDefaults = {
	global = {
		optionsTreeStatus = {},
		previousSearches = {},
		treeGroupStatus = {},
		favoriteSearches = {},
		normalPostPrice = "150% dbmarket",
		postBidPercent = 0.95,
		quickPostingPrice = "100% dbmarket",
		quickPostingDuration = 2,
		quickPostingHideGrouped = true,
		sidebarBtn = 1,
		postUndercut = 1,
		marketValueSource = "dbmarket",
		destroyingTargetItems = {},
		tooltip = true,
		minDeSearchLvl = 1,
		maxDeSearchLvl = 600,
		maxDeSearchPercent = 1,
		sniperVendorPrice = true,
		sniperMaxPrice = true,
		sniperCustomPrice = "0c",
	},
}

function TSM:OnInitialize()
	TSM.db = LibStub("AceDB-3.0"):New("TradeSkillMaster_ShoppingDB", savedDBDefaults)

	for name, module in pairs(TSM.modules) do
		TSM[name] = module
	end
	TSMAPI.AuctionControl.undercut = TSM.db.global.postUndercut

	-- register with TSM
	TSM:RegisterModule()

	TSM.db.profile.dealfinding = nil
	TSM.db.global.appInfo = nil
end

-- registers this module with TSM by first setting all fields and then calling TSMAPI:NewModule().
function TSM:RegisterModule()
	TSM.operations = { maxOperations = 1, callbackOptions = "Options:Load", callbackInfo = "GetOperationInfo" }
	TSM.auctionTab = { callbackShow = "Search:Show", callbackHide = "Search:Hide" }
	TSM.tooltipOptions = { callback = "Options:LoadTooltipOptions" }
	TSM.moduleAPIs = {
		{ key = "runSearch", callback = "StartFilterSearch" },
		{ key = "runDestroySearch", callback = "StartDestroySearch" },
		{ key = "getSidebarPage", callback = "Sidebar:GetCurrentPage" },
		{ key = "getSearchMode", callback = "Search:GetCurrentSearchMode" },
	}

	TSMAPI:NewModule(TSM)
end

TSM.operationDefaults = {
	maxPrice = 1,
	evenStacks = nil,
	showAboveMaxPrice = nil,
	ignorePlayer = {},
	ignoreFactionrealm = {},
	relationships = {},
}

function TSM:GetOperationInfo(operationName)
	TSMAPI:UpdateOperation("Shopping", operationName)
	local operation = TSM.operations[operationName]
	if not operation then return end

	if operation.showAboveMaxPrice and operation.evenStacks then
		return format(L["Shopping for even stacks including those above the max price"])
	elseif operation.showAboveMaxPrice then
		return format(L["Shopping for auctions including those above the max price."])
	elseif operation.evenStacks then
		return format(L["Shopping for even stacks with a max price set."])
	else
		return format(L["Shopping for auctions with a max price set."])
	end
end

function TSM:StartFilterSearch(searchQuery, callback)
	if not TSMAPI:AHTabIsVisible("Shopping") then return end
	TSM.Search:StartFilterSearch(searchQuery, nil, true)
	TSM.moduleAPICallback = callback
end

function TSM:StartDestroySearch(searchQuery, callback)
	if not TSMAPI:AHTabIsVisible("Shopping") then return end
	local filters = TSM.Search:GetFilters(searchQuery)
	if filters and #filters == 1 then
		for itemString, name in pairs(TSM.db.global.destroyingTargetItems) do
			if strlower(name) == strlower(filters.currentFilter) then
				TSM.Destroying:StartDestroyingSearch(itemString, filters[1], true)
				TSM.Search:SetSearchText(searchQuery)
				TSM.moduleAPICallback = callback
				return
			end
		end
	end
end


function TSM:GetMaxPrice(operationPrice, itemString)
	local price, err
	if type(operationPrice) == "number" then
		price = operationPrice
	elseif type(operationPrice) == "string" then
		local func, parseErr = TSMAPI:ParseCustomPrice(operationPrice)
		err = parseErr
		price = func and func(itemString)
	end
	return price ~= 0 and price or nil, err
end

function TSM:AddSidebarFeature(...)
	TSM.modules.Sidebar:AddSidebarFeature(...)
end

function TSM:GetTooltip(itemString)
	if not TSM.db.global.tooltip then return end
	local text = {}
	local moneyCoinsTooltip = TSMAPI:GetMoneyCoinsTooltip()
	itemString = TSMAPI:GetBaseItemString(itemString, true)
	local operations = TSMAPI:GetItemOperation(itemString, "Shopping")
	if not operations then return end
	local operationName = operations[1]
	TSMAPI:UpdateOperation("Shopping", operationName)
	local operation = TSM.operations[operationName]
	if operation then
		local maxPrice = TSM:GetMaxPrice(operation.maxPrice, itemString)
		if maxPrice then
			local priceText
			if moneyCoinsTooltip then
				priceText = (TSMAPI:FormatTextMoneyIcon(maxPrice, "|cffffffff", true) or "|cffffffff---|r")
			else
				priceText = (TSMAPI:FormatTextMoney(maxPrice, "|cffffffff", true) or "|cffffffff---|r")
			end
			tinsert(text, { left = "  " .. L["Max Shopping Price:"], right = format("%s", priceText) })
		end
	end
	if #text > 0 then
		tinsert(text, 1, "|cffffff00" .. "TSM Shopping:")
		return text
	end
end