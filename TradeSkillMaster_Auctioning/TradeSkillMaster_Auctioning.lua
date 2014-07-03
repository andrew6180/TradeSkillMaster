-- ------------------------------------------------------------------------------ --
--                           TradeSkillMaster_Auctioning                          --
--           http://www.curse.com/addons/wow/tradeskillmaster_auctioning          --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

local TSM = select(2, ...)
TSM = LibStub("AceAddon-3.0"):NewAddon(TSM, "TSM_Auctioning", "AceEvent-3.0", "AceConsole-3.0")
TSM.status = {}
local AceGUI = LibStub("AceGUI-3.0")

local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster_Auctioning") -- loads the localization table
TSM.operationLookup = {}
TSM.operationNameLookup = {}
local status = TSM.status
local statusLog, logIDs, lastSeenLogID = {}, {}


local savedDBDefaults = {
	profile = {
	},
	global = {
		optionsTreeStatus = {},
		scanCompleteSound = 1,
		cancelWithBid = false,
		matchWhitelist = true,
		roundNormalPrice = false,
		disableInvalidMsg = false,
		defaultOperationTab = 1,
		priceColumn = 1,
		tooltip = true,
	},
	factionrealm = {
		player = {},
		whitelist = {},
		lastSoldFilter = 0,
	},
}

-- Addon loaded
function TSM:OnInitialize()
	-- load the savedDB into TSM.db
	TSM.db = LibStub:GetLibrary("AceDB-3.0"):New("TradeSkillMaster_AuctioningDB", savedDBDefaults, true)

	for name, module in pairs(TSM.modules) do
		TSM[name] = module
	end

	-- Add this character to the alt list so it's not undercut by the player
	TSM.db.factionrealm.player[UnitName("player")] = true
	
	-- register this module with TSM
	TSM:RegisterModule()

	-- clear out 1.x settings
	if TSM.db.profile.groups then
		for _, profile in ipairs(TSM.db:GetProfiles()) do
			TSM.db:SetProfile(profile)
			TSM.db:ResetProfile()
		end
	end

	for _ in TSMAPI:GetTSMProfileIterator() do
		for _, operation in pairs(TSM.operations) do
			operation.resetMaxInventory = operation.resetMaxInventory or TSM.operationDefaults.resetMaxInventory
			operation.aboveMax = operation.aboveMax or TSM.operationDefaults.aboveMax
			operation.keepQuantity = operation.keepQuantity or TSM.operationDefaults.keepQuantity
		end
	end
end

-- registers this module with TSM by first setting all fields and then calling TSMAPI:NewModule().
function TSM:RegisterModule()
	TSM.operations = { maxOperations = 5, callbackOptions = "Options:Load", callbackInfo = "GetOperationInfo" }
	TSM.auctionTab = { callbackShow = "GUI:ShowSelectionFrame", callbackHide = "GUI:HideSelectionFrame" }
	TSM.bankUiButton = { callback = "Util:createTab" }
	TSM.tooltipOptions = { callback = "Options:LoadTooltipOptions" }

	TSMAPI:NewModule(TSM)
end

function TSM:GetOperationInfo(operationName)
	TSMAPI:UpdateOperation("Auctioning", operationName)
	local operation = TSM.operations[operationName]
	if not operation then return end
	local parts = {}

	-- get the post string
	if operation.postCap == 0 then
		tinsert(parts, L["No posting."])
	else
		tinsert(parts, format(L["Posting %d stack(s) of %d for %d hours."], operation.postCap, operation.stackSize, operation.duration))
	end

	-- get the cancel string
	if operation.cancelUndercut and operation.cancelRepost then
		tinsert(parts, format(L["Canceling undercut auctions and to repost higher."]))
	elseif operation.cancelUndercut then
		tinsert(parts, format(L["Canceling undercut auctions."]))
	elseif operation.cancelRepost then
		tinsert(parts, format(L["Canceling to repost higher."]))
	else
		tinsert(parts, L["Not canceling."])
	end

	-- get the reset string
	if operation.resetEnabled then
		tinsert(parts, L["Resetting enabled."])
	else
		tinsert(parts, L["Not resetting."])
	end
	return table.concat(parts, " ")
end

TSM.operationDefaults = {
	-- general
	matchStackSize = nil,
	ignoreLowDuration = 0,
	ignorePlayer = {},
	ignoreFactionrealm = {},
	relationships = {},
	-- post
	stackSize = 1,
	stackSizeIsCap = nil,
	postCap = 1,
	keepQuantity = 0,
	duration = 24,
	bidPercent = 1,
	undercut = 1,
	minPrice = 50000,
	maxPrice = 5000000,
	normalPrice = 1000000,
	priceReset = "none",
	aboveMax = "normalPrice",
	-- cancel
	cancelUndercut = true,
	keepPosted = 0,
	cancelRepost = true,
	cancelRepostThreshold = 10000,
	-- reset
	resetEnabled = nil,
	resetMaxQuantity = 5,
	resetMaxInventory = 10,
	resetMaxCost = 500000,
	resetMinProfit = 500000,
	resetResolution = 100,
	resetMaxItemCost = 1000000,
}

function TSM:GetTooltip(itemString)
	if not TSM.db.global.tooltip then return end
	local text = {}
	local moneyCoinsTooltip = TSMAPI:GetMoneyCoinsTooltip()
	itemString = TSMAPI:GetBaseItemString(itemString, true)
	local operations = TSMAPI:GetItemOperation(itemString, "Auctioning")
	if not operations or not operations[1] or not TSM.operations[operations[1]] then return end
	
	TSMAPI:UpdateOperation("Auctioning", operations[1])
	local prices = TSM.Util:GetItemPrices(TSM.operations[operations[1]], itemString)
	if prices then
		local minPrice, normPrice, maxPrice
		if moneyCoinsTooltip then
			minPrice = (TSMAPI:FormatTextMoneyIcon(prices.minPrice, "|cffffffff") or "|cffffffff---|r")
			normPrice = (TSMAPI:FormatTextMoneyIcon(prices.normalPrice, "|cffffffff") or "|cffffffff---|r")
			maxPrice = (TSMAPI:FormatTextMoneyIcon(prices.maxPrice, "|cffffffff") or "|cffffffff---|r")
		else
			minPrice = (TSMAPI:FormatTextMoney(prices.minPrice, "|cffffffff") or "|cffffffff---|r")
			normPrice = (TSMAPI:FormatTextMoney(prices.normalPrice, "|cffffffff") or "|cffffffff---|r")
			maxPrice = (TSMAPI:FormatTextMoney(prices.maxPrice, "|cffffffff") or "|cffffffff---|r")
		end
		tinsert(text, { left = "  " .. L["Auctioning Prices:"], right = format(L["Min (%s), Normal (%s), Max (%s)"], minPrice, normPrice, maxPrice) })
	end

	if #text > 0 then
		tinsert(text, 1, "|cffffff00" .. "TSM Auctioning:")
		return text
	end
end

function TSM:GetAuctionPlayer(player, player_full)
	local realm = GetRealmName() or ""
	if player_full and strjoin("-", player, realm) ~= player_full then
		return player_full
	else
		return player
	end
end