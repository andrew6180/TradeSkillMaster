-- ------------------------------------------------------------------------------ --
--                                TradeSkillMaster                                --
--                http://www.curse.com/addons/wow/tradeskill-master               --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- This is the main TSM file that holds the majority of the APIs that modules will use.

-- register this file with Ace libraries
local TSM = select(2, ...)
TSM = LibStub("AceAddon-3.0"):NewAddon(TSM, "TradeSkillMaster", "AceEvent-3.0", "AceConsole-3.0", "AceHook-3.0")
TSM.moduleObjects = {}
TSM.moduleNames = {}

local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster") -- loads the localization table
TSM._version = GetAddOnMetadata("TradeSkillMaster", "Version") -- current version of the addon

TSMAPI = {}

TSM.designDefaults = {
	frameColors = {
		frameBG = { backdrop = { 24, 24, 24, .93 }, border = { 30, 30, 30, 1 } },
		frame = { backdrop = { 24, 24, 24, 1 }, border = { 255, 255, 255, 0.03 } },
		content = { backdrop = { 42, 42, 42, 1 }, border = { 0, 0, 0, 0 } },
	},
	textColors = {
		iconRegion = { enabled = { 249, 255, 247, 1 } },
		text = { enabled = { 255, 254, 250, 1 }, disabled = { 147, 151, 139, 1 } },
		label = { enabled = { 216, 225, 211, 1 }, disabled = { 150, 148, 140, 1 } },
		title = { enabled = { 132, 219, 9, 1 } },
		link = { enabled = { 49, 56, 133, 1 } },
	},
	inlineColors = {
		link = { 153, 255, 255, 1 },
		link2 = { 153, 255, 255, 1 },
		category = { 36, 106, 36, 1 },
		category2 = { 85, 180, 8, 1 },
		tooltip = { 130, 130, 250, 1 },
		advanced = { 255, 30, 0, 1 },
	},
	edgeSize = 1.5,
	fonts = {
		content = "Fonts\\ARIALN.TTF",
		bold = "Interface\\Addons\\TradeSkillMaster\\Media\\DroidSans-Bold.ttf",
	},
	fontSizes = {
		normal = 15,
		medium = 13,
		small = 12,
	},
}

local savedDBDefaults = {
	global = {
		vendorItems = {},
		ignoreRandomEnchants = nil,
		globalOperations = false,
		operations = {},
		customPriceSources = {},
		bankUITab = "Warehousing",
		chatFrame = "",
		infoMessage = 1000,
		bankUIframeScale = 1,
		frameStatus = {},
		customPriceTooltips = {},
	},
	profile = {
		minimapIcon = {
			-- minimap icon position and visibility
			hide = false,
			minimapPos = 220,
			radius = 80,
		},
		auctionFrameMovable = true,
		auctionFrameScale = 1,
		showBids = false,
		openAllBags = true,
		auctionResultRows = 12,
		groups = {},
		items = {},
		operations = {},
		groupTreeStatus = {},
		customPriceSourceTreeStatus = {},
		directSubgroupAdd = true,
		pricePerUnit = true,
		moneyCoinsTooltip = true,
		moneyTextTooltip = false,
		tooltip = true,
		postDuration = 3,
		destroyValueSource = "DBMarket",
		detailedDestroyTooltip = true,
		deTooltip = true,
		millTooltip = true,
		prospectTooltip = true,
		vendorBuyTooltip = true,
		vendorSellTooltip = true,
		isBankui = true,
		defaultAuctionTab = "Shopping",
		gotoNewGroup = true,
		gotoNewCustomPriceSource = true,
		defaultGroupTab = 1,
		moveImportedItems = false,
		importParentOnly = false,
		keepInParent = true,
		savedThemes = {},
		groupTreeCollapsedStatus = {},
		groupTreeSelectedGroupStatus = {},
		exportSubGroups = false,
		colorGroupName = true,
		embeddedTooltip = true,
	},
	factionrealm = {
		accountKey = nil,
		characters = {},
		syncAccounts = {},
		numPagesCache = {},
		bankUIBankFramePosition = {100, 300},
		bankUIGBankFramePosition = {100, 300},
	},
}

-- Called once the player has loaded WOW.
function TSM:OnInitialize()
	TSMAPI:RegisterForTracing(TSMAPI, "TSMAPI")
	
	TSM.moduleObjects = nil
	TSM.moduleNames = nil

	-- load the savedDB into TSM.db
	TSM.db = LibStub:GetLibrary("AceDB-3.0"):New("TradeSkillMasterDB", savedDBDefaults, true)
	TSM.db:RegisterCallback("OnProfileChanged", TSM.UpdateModuleProfiles)
	TSM.db:RegisterCallback("OnProfileCopied", TSM.UpdateModuleProfiles)
	TSM.db:RegisterCallback("OnProfileReset", TSM.UpdateModuleProfiles)
	TSM.db:RegisterCallback("OnDatabaseShutdown", TSM.ModuleOnDatabaseShutdown)
	if TSM.db.global.globalOperations then
		TSM.operations = TSM.db.global.operations
	else
		TSM.operations = TSM.db.profile.operations
	end
	
	-- Prepare the TradeSkillMasterAppDB database
	-- We're not using AceDB here on purpose due to bugs in AceDB, but are emulating the parts of it that we need.

	for name, module in pairs(TSM.modules) do
		TSM[name] = module
	end

	-- TSM core must be registered as a module just like the modules
	TSM:RegisterModule()

	-- create account key for multi-account syncing if necessary
	TSM.db.factionrealm.accountKey = TSM.db.factionrealm.accountKey or (GetRealmName() .. random(time()))
	-- add this character to the list of characters on this realm
	TSM.db.factionrealm.characters[UnitName("player")] = true

	if not TSM.db.profile.design then
		TSM:LoadDefaultDesign()
	end
	TSM:SetDesignDefaults(TSM.designDefaults, TSM.db.profile.design)

	-- create / register the minimap button
	TSM.LDBIcon = LibStub("LibDataBroker-1.1", true) and LibStub("LibDBIcon-1.0", true)
	local TradeSkillMasterLauncher = LibStub("LibDataBroker-1.1", true):NewDataObject("TradeSkillMasterMinimapIcon", {
		icon = "Interface\\Addons\\TradeSkillMaster\\Media\\TSM_Icon",
		OnClick = function(_, button) -- fires when a user clicks on the minimap icon
			if button == "LeftButton" then
				-- does the same thing as typing '/tsm'
				TSM.Modules:ChatCommand("")
			end
		end,
		OnTooltipShow = function(tt) -- tooltip that shows when you hover over the minimap icon
			local cs = "|cffffffcc"
			local ce = "|r"
			tt:AddLine("TradeSkillMaster " .. TSM._version)
			tt:AddLine(format(L["%sLeft-Click%s to open the main window"], cs, ce))
			tt:AddLine(format(L["%sDrag%s to move this button"], cs, ce))
		end,
	})
	TSM.LDBIcon:Register("TradeSkillMaster", TradeSkillMasterLauncher, TSM.db.profile.minimapIcon)
	local TradeSkillMasterLauncher2 = LibStub("LibDataBroker-1.1", true):NewDataObject("TradeSkillMaster", {
		type = "launcher",
		icon = "Interface\\Addons\\TradeSkillMaster\\Media\\TSM_Icon2",
		OnClick = function(_, button) -- fires when a user clicks on the minimap icon
			if button == "LeftButton" then
				-- does the same thing as typing '/tsm'
				TSM.Modules:ChatCommand("")
			end
		end,
		OnTooltipShow = function(tt) -- tooltip that shows when you hover over the minimap icon
			local cs = "|cffffffcc"
			local ce = "|r"
			tt:AddLine("TradeSkillMaster " .. TSM._version)
			tt:AddLine(format(L["%sLeft-Click%s to open the main window"], cs, ce))
			tt:AddLine(format(L["%sDrag%s to move this button"], cs, ce))
		end,
	})

	-- create the main TSM frame
	TSM:CreateMainFrame()

	-- fix any items with spaces in them
	for itemString, groupPath in pairs(TSM.db.profile.items) do
		if strfind(itemString, " ") then
			local newItemString = gsub(itemString, " ", "")
			TSM.db.profile.items[newItemString] = groupPath
			TSM.db.profile.items[itemString] = nil
		end
	end
	
	if TSM.db.profile.deValueSource then
		TSM.db.profile.destroyValueSource = TSM.db.profile.deValueSource
		TSM.db.profile.deValueSource = nil
	end
	collectgarbage()
end

function TSM:RegisterModule()
	TSM.icons = {
		{ side = "options", desc = L["TSM Status / Options"], callback = "LoadOptions", icon = "Interface\\Icons\\Achievement_Quests_Completed_04" },
		{ side = "options", desc = L["Groups"], callback = "LoadGroupOptions", slashCommand = "groups", icon = "Interface\\Icons\\INV_DataCrystal08" },
		{ side = "options", desc = L["Module Operations / Options"], slashCommand = "operations", callback = "LoadOperationOptions", icon = "Interface\\Icons\\INV_Gizmo_Felironbolts" },
		{ side = "options", desc = L["Tooltip Options"], slashCommand = "tooltips", callback = "LoadTooltipOptions", icon = "Interface\\Icons\\INV_Misc_Gear_01" },
	}

	TSM.priceSources = {}
	
	-- Auctioneer
	if select(4, GetAddOnInfo("Auc-Advanced")) == 1 and AucAdvanced then
		if AucAdvanced.Modules.Util.Appraiser and AucAdvanced.Modules.Util.Appraiser.GetPrice then
			tinsert(TSM.priceSources, { key = "AucAppraiser", label = L["Auctioneer - Appraiser"], callback = AucAdvanced.Modules.Util.Appraiser.GetPrice })
		end
		if AucAdvanced.Modules.Util.SimpleAuction and AucAdvanced.Modules.Util.SimpleAuction.Private.GetItems then
			tinsert(TSM.priceSources, { key = "AucMinBuyout", label = L["Auctioneer - Minimum Buyout"], callback = function(itemLink) return select(6, AucAdvanced.Modules.Util.SimpleAuction.Private.GetItems(itemLink)) end })
		end
		if AucAdvanced.API.GetMarketValue then
			tinsert(TSM.priceSources, { key = "AucMarket", label = L["Auctioneer - Market Value"], callback = AucAdvanced.API.GetMarketValue })
		end
	end
	
	-- Auctionator
	if select(4, GetAddOnInfo("Auctionator")) == 1 and Atr_GetAuctionBuyout then
		tinsert(TSM.priceSources, { key = "AtrValue", label = L["Auctionator - Auction Value"], callback = Atr_GetAuctionBuyout })
	end
	-- Vendor Buy Price
	tinsert(TSM.priceSources, { key = "VendorBuy", label = L["Buy from Vendor"], callback = function(itemLink) return TSMAPI:GetVendorCost(TSMAPI:GetItemString(itemLink)) end })

	-- Vendor Buy Price
	tinsert(TSM.priceSources, { key = "VendorSell", label = L["Sell to Vendor"], callback = function(itemLink) local sell = select(11, GetItemInfo(itemLink)) return (sell or 0) > 0 and sell or nil end })

	-- Disenchant Value
	tinsert(TSM.priceSources, { key = "Disenchant", label = L["Disenchant Value"], callback = "GetDisenchantValue" })


	TSM.slashCommands = {
		{ key = "version", label = L["Prints out the version numbers of all installed modules"], callback = function() TSM:Print(L["TSM Version Info:"]) local chatFrame = TSMAPI:GetChatFrame() for _, module in ipairs(TSM.Modules:GetInfo()) do chatFrame:AddMessage(module.name.." |cff99ffff"..module.version.."|r") end end },
		{ key = "freset", label = L["Resets the position, scale, and size of all applicable TSM and module frames."], callback = "ResetFrames" },
		{ key = "bankui", label = L["Toggles the bankui"], callback = "toggleBankUI" },
		{ key = "sources", label = L["Prints out the available price sources for use in custom price boxes."], callback = "PrintPriceSources" },
		{ key = "price", label = L["Allows for testing of custom prices."], callback = "TestPriceSource" },
		{ key = "assist", label = L["Opens the TradeSkillMaster Assistant window."], callback = "Assistant:Open" },
	}

	TSM.moduleAPIs = {
		{ key = "deValue", callback = "GetDisenchantValue" },
	}

	TSM.sync = { callback = "SyncCallback" }

	TSMAPI:NewModule(TSM)
end

function TSM:OnTSMDBShutdown()
	local function GetOperationPrice(module, settingKey, itemString)
		local operations = TSMAPI:GetItemOperation(itemString, module)
		local operation = operations and operations[1] ~= "" and operations[1] and TSM.operations[module][operations[1]]
		if operation and operation[settingKey] then
			if type(operation[settingKey]) == "number" and operation[settingKey] > 0 then
				return operation[settingKey]
			elseif type(operation[settingKey]) == "string" then
				local func = TSMAPI:ParseCustomPrice(operation[settingKey])
				local value = func and func(itemString)
				if not value or value <= 0 then return end
				return value
			else
				return
			end
		end
	end

	-- save group info into TSM.appDB
	for profile in TSMAPI:GetTSMProfileIterator() do
		local profileGroupData = {}
		for itemString, groupPath in pairs(TSM.db.profile.items) do
			if strfind(itemString, "item") then
				local shortItemString = gsub(gsub(itemString, "item:", ""), ":0:0:0:0:0:", ":")
				local itemPrices = {}
				itemPrices.sm = GetOperationPrice("Shopping", "maxPrice", itemString)
				itemPrices.am = GetOperationPrice("Auctioning", "minPrice", itemString)
				itemPrices.an = GetOperationPrice("Auctioning", "normalPrice", itemString)
				itemPrices.ax = GetOperationPrice("Auctioning", "maxPrice", itemString)
				if next(itemPrices) then
					itemPrices.gr = groupPath
					local itemID, rand = (":"):split(shortItemString)
					if rand == "0" then
						shortItemString = itemID
					end
					profileGroupData[shortItemString] = itemPrices
				end
			end
		end
		if next(profileGroupData) then
			TSM.appDB.profile.groupInfo = profileGroupData
			TSM.appDB.profile.lastUpdate = time()
		end
	end
end


function TSMAPI:GetTSMProfileIterator()
	local originalProfile = TSM.db:GetCurrentProfile()
	local profiles = CopyTable(TSM.db:GetProfiles())

	return function()
		local profile = tremove(profiles)
		if profile then
			TSM.db:SetProfile(profile)
			return profile
		end
		TSM.db:SetProfile(originalProfile)
	end
end

function TSMAPI:AddPriceSource(key, label, callback)
	assert(type(key) == "string", "Invalid type of key: " .. type(key))
	assert(type(label) == "string", "Invalid type of label: " .. type(label))
	assert(type(callback) == "function", "Invalid type of callback: " .. type(callback))

	tinsert(TSM.priceSources, { key = key, label = label, callback = callback })
end

function TSM:GetTooltip(itemString, quantity)
	local text = {}
	quantity = max(quantity or 0, 1)
	if TSM.db.profile.tooltip then
		local base
		local path = TSM.db.profile.items[itemString]
		if not path then
			path = TSM.db.profile.items[TSMAPI:GetBaseItemString(itemString)]
			base = true
		end
		if path and TSM.db.profile.groups[path] then
			if not base then
				tinsert(text, { left = "  " .. L["Group:"], right = "|cffffffff" .. TSMAPI:FormatGroupPath(path) })
			else
				tinsert(text, { left = "  " .. L["Group(Base Item):"], right = "|cffffffff" .. TSMAPI:FormatGroupPath(path) })
			end
			local modules = {}
			for module, operations in pairs(TSM.db.profile.groups[path]) do
				if operations[1] and operations[1] ~= "" then
					tinsert(modules, { module = module, operations = table.concat(operations, ", ") })
				end
			end
			sort(modules, function(a, b) return a.module < b.module end)
			for _, info in ipairs(modules) do
				tinsert(text, { left = "  " .. format(L["%s operation(s):"], info.module), right = "|cffffffff" .. info.operations .. "|r" })
			end
		end
	end

	local moneyCoinsTooltip = TSMAPI:GetMoneyCoinsTooltip()

	-- add disenchant value info
	if TSM.db.profile.deTooltip then
		local deValue = TSM:GetDisenchantValue(itemString)
		if deValue > 0 then
			if moneyCoinsTooltip then
				if IsShiftKeyDown() then
					tinsert(text, { left = "  " .. format(L["Disenchant Value x%s:"], quantity), right = TSMAPI:FormatTextMoneyIcon(deValue * quantity, "|cffffffff", true) })
				else
					tinsert(text, { left = "  " .. L["Disenchant Value:"], right = TSMAPI:FormatTextMoneyIcon(deValue, "|cffffffff", true) })
				end
			else
				if IsShiftKeyDown() then
					tinsert(text, { left = "  " .. format(L["Disenchant Value x%s:"], quantity), right = TSMAPI:FormatTextMoney(deValue * quantity, "|cffffffff", true) })
				else
					tinsert(text, { left = "  " .. L["Disenchant Value:"], right = TSMAPI:FormatTextMoney(deValue, "|cffffffff", true) })
				end
			end
			
			if TSM.db.profile.detailedDestroyTooltip then
				local _, itemLink, quality, ilvl, _, iType = TSMAPI:GetSafeItemInfo(itemString)
				local itemString = TSMAPI:GetItemString(itemLink)
				local WEAPON, ARMOR = GetAuctionItemClasses()

				for _, data in ipairs(TSMAPI.DisenchantingData.disenchant) do
					for item, itemData in pairs(data) do
						if item ~= "desc" and itemData.itemTypes[iType] and itemData.itemTypes[iType][quality] then
							for _, deData in ipairs(itemData.itemTypes[iType][quality]) do
								if ilvl >= deData.minItemLevel and ilvl <= deData.maxItemLevel then
									local matValue = TSM:GetCustomPrice(TSM.db.profile.destroyValueSource, item)
									local value = (matValue or 0) * deData.amountOfMats
									local name, _, matQuality = TSMAPI:GetSafeItemInfo(item)
									if matQuality then
										-- local colorName = format("|c%s%s%s%s|r",select(4,GetItemQualityColor(matQuality)),name, " x ", deData.amountOfMats)
										local colorName = format("%s%s%s%s|r",select(4,GetItemQualityColor(matQuality)),name, " x ", deData.amountOfMats)
										if value > 0 then
											if moneyCoinsTooltip then
												tinsert(text, { left = "    " .. colorName, right = TSMAPI:FormatTextMoneyIcon(value, "|cffffffff", true) })
											else
												tinsert(text, { left = "    " .. colorName, right = TSMAPI:FormatTextMoney(value, "|cffffffff", true) })
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
	end
	
	-- add mill value info
	if TSM.db.profile.millTooltip then
		local millValue = TSM:GetMillValue(itemString)
		if millValue > 0 then
			if moneyCoinsTooltip then
				if IsShiftKeyDown() then
					tinsert(text, { left = "  " .. format(L["Mill Value x%s:"], quantity), right = TSMAPI:FormatTextMoneyIcon(millValue * quantity, "|cffffffff", true) })
				else
					tinsert(text, { left = "  " .. L["Mill Value:"], right = TSMAPI:FormatTextMoneyIcon(millValue, "|cffffffff", true) })
				end
			else
				if IsShiftKeyDown() then
					tinsert(text, { left = "  " .. format(L["Mill Value x%s:"], quantity), right = TSMAPI:FormatTextMoney(millValue * quantity, "|cffffffff", true) })
				else
					tinsert(text, { left = "  " .. L["Mill Value:"], right = TSMAPI:FormatTextMoney(millValue, "|cffffffff", true) })
				end
			end
			
			if TSM.db.profile.detailedDestroyTooltip then
				for _, targetItem in ipairs(TSMAPI:GetConversionTargetItems("mill")) do
					local herbs = TSMAPI:GetItemConversions(targetItem)
					if herbs[itemString] then
						local value = (TSM:GetCustomPrice(TSM.db.profile.destroyValueSource, targetItem) or 0) * herbs[itemString].rate
						local name, _, matQuality = TSMAPI:GetSafeItemInfo(targetItem)
						if matQuality then
							-- local colorName = format("|c%s%s%s%s|r",select(4,GetItemQualityColor(matQuality)),name, " x ", herbs[itemString].rate)
							local colorName = format("%s%s%s%s|r",select(4,GetItemQualityColor(matQuality)),name, " x ", herbs[itemString].rate)
							if value > 0 then
								if moneyCoinsTooltip then
									tinsert(text, { left = "    " .. colorName, right = TSMAPI:FormatTextMoneyIcon(value, "|cffffffff", true) })
								else
									tinsert(text, { left = "    " .. colorName, right = TSMAPI:FormatTextMoney(value, "|cffffffff", true) })
								end
							end
						end
					end
				end
			end
		end
	end
	
	-- add prospect value info
	if TSM.db.profile.prospectTooltip then
		local prospectValue = TSM:GetProspectValue(itemString)
		if prospectValue > 0 then
			if moneyCoinsTooltip then
				if IsShiftKeyDown() then
					tinsert(text, { left = "  " .. format(L["Prospect Value x%s:"], quantity), right = TSMAPI:FormatTextMoneyIcon(prospectValue * quantity, "|cffffffff", true) })
				else
					tinsert(text, { left = "  " .. L["Prospect Value:"], right = TSMAPI:FormatTextMoneyIcon(prospectValue, "|cffffffff", true) })
				end
			else
				if IsShiftKeyDown() then
					tinsert(text, { left = "  " .. format(L["Prospect Value x%s:"], quantity), right = TSMAPI:FormatTextMoney(prospectValue * quantity, "|cffffffff", true) })
				else
					tinsert(text, { left = "  " .. L["Prospect Value:"], right = TSMAPI:FormatTextMoney(prospectValue, "|cffffffff", true) })
				end
			end
			
			if TSM.db.profile.detailedDestroyTooltip then
				for _, targetItem in ipairs(TSMAPI:GetConversionTargetItems("prospect")) do
					local gems = TSMAPI:GetItemConversions(targetItem)
					if gems[itemString] then
						local value = (TSM:GetCustomPrice(TSM.db.profile.destroyValueSource, targetItem) or 0) * gems[itemString].rate
						local name, _, matQuality = TSMAPI:GetSafeItemInfo(targetItem)
						if matQuality then
							-- local colorName = format("|c%s%s%s%s|r",select(4,GetItemQualityColor(matQuality)),name, " x ", gems[itemString].rate)
							local colorName = format("%s%s%s%s|r",select(4,GetItemQualityColor(matQuality)),name, " x ", gems[itemString].rate)
							if value > 0 then
								if moneyCoinsTooltip then
									tinsert(text, { left = "    " .. colorName, right = TSMAPI:FormatTextMoneyIcon(value, "|cffffffff", true) })
								else
									tinsert(text, { left = "    " .. colorName, right = TSMAPI:FormatTextMoney(value, "|cffffffff", true) })
								end
							end
						end
					end
				end
			end
		end
	end

	-- add Vendor Buy Price
	if TSM.db.profile.vendorBuyTooltip then
		local vendorValue = TSMAPI:GetVendorCost(itemString) or 0
		if vendorValue and vendorValue > 0 then
			if quantity then
				if moneyCoinsTooltip then
					if IsShiftKeyDown() then
						tinsert(text, { left = "  " .. format(L["Vendor Buy Price x%s:"], quantity), right = TSMAPI:FormatTextMoneyIcon(vendorValue * quantity, "|cffffffff", true) })
					else
						tinsert(text, { left = "  " .. L["Vendor Buy Price:"], right = TSMAPI:FormatTextMoneyIcon(vendorValue, "|cffffffff", true) })
					end
				else
					if IsShiftKeyDown() then
						tinsert(text, { left = "  " .. format(L["Vendor Buy Price x%s:"], quantity), right = TSMAPI:FormatTextMoney(vendorValue * quantity, "|cffffffff", true) })
					else
						tinsert(text, { left = "  " .. L["Vendor Buy Price:"], right = TSMAPI:FormatTextMoney(vendorValue, "|cffffffff", true) })
					end
				end
			end
		end
	end

	-- add Vendor sell Price
	if TSM.db.profile.vendorSellTooltip then
		local vendorValue = select(11, TSMAPI:GetSafeItemInfo(itemString))
		if vendorValue and vendorValue > 0 then
			if quantity then
				if moneyCoinsTooltip then
					if IsShiftKeyDown() then
						tinsert(text, { left = "  " .. format(L["Vendor Sell Price x%s:"], quantity), right = TSMAPI:FormatTextMoneyIcon(vendorValue * quantity, "|cffffffff", true) })
					else
						tinsert(text, { left = "  " .. L["Vendor Sell Price:"], right = TSMAPI:FormatTextMoneyIcon(vendorValue, "|cffffffff", true) })
					end
				else
					if IsShiftKeyDown() then
						tinsert(text, { left = "  " .. format(L["Vendor Sell Price x%s:"], quantity), right = TSMAPI:FormatTextMoney(vendorValue * quantity, "|cffffffff", true) })
					else
						tinsert(text, { left = "  " .. L["Vendor Sell Price:"], right = TSMAPI:FormatTextMoney(vendorValue, "|cffffffff", true) })
					end
				end
			end
		end
	end
	
	for name, method in pairs(TSM.db.global.customPriceSources) do
		if TSM.db.global.customPriceTooltips[name] then
			local price = TSM:GetCustomPrice(name, itemString)
			if price then
				tinsert(text, {left="  "..L["Custom Price Source"].." '"..name.."':", right=TSMAPI:FormatTextMoney(price, "|cffffffff", true)})
			end
		end
	end

	-- add heading
	if #text > 0 then
		tinsert(text, 1, "|cffffff00" .. L["TradeSkillMaster Info:"])
		return text
	end
end


function TSM:GetDisenchantValue(link)
	local _, itemLink, quality, ilvl, _, iType = TSMAPI:GetSafeItemInfo(link)
	local itemString = TSMAPI:GetItemString(itemLink)
	local WEAPON, ARMOR = GetAuctionItemClasses()
	if not itemString or TSMAPI.DisenchantingData.notDisenchantable[itemString] or not (iType == ARMOR or iType == WEAPON) then return 0 end

	local value = 0
	for _, data in ipairs(TSMAPI.DisenchantingData.disenchant) do
		for item, itemData in pairs(data) do
			if item ~= "desc" and itemData.itemTypes[iType] and itemData.itemTypes[iType][quality] then
				for _, deData in ipairs(itemData.itemTypes[iType][quality]) do
					if ilvl >= deData.minItemLevel and ilvl <= deData.maxItemLevel then
						local matValue = TSM:GetCustomPrice(TSM.db.profile.destroyValueSource, item)
						value = value + (matValue or 0) * deData.amountOfMats
					end
				end
			end
		end
	end

	return value
end

function TSM:GetMillValue(itemString)
	local value = 0
	
	for _, targetItem in ipairs(TSMAPI:GetConversionTargetItems("mill")) do
		local herbs = TSMAPI:GetItemConversions(targetItem)
		if herbs[itemString] then
			local matValue = TSM:GetCustomPrice(TSM.db.profile.destroyValueSource, targetItem)
			value = value + (matValue or 0) * herbs[itemString].rate
		end
	end
	
	return value
end

function TSM:GetProspectValue(itemString)
	local value = 0
	
	for _, targetItem in ipairs(TSMAPI:GetConversionTargetItems("prospect")) do
		local gems = TSMAPI:GetItemConversions(targetItem)
		if gems[itemString] then
			local matValue = TSM:GetCustomPrice(TSM.db.profile.destroyValueSource, targetItem)
			value = value + (matValue or 0) * gems[itemString].rate
		end
	end
	
	return value
end

function TSM:PrintPriceSources()
	TSM:Printf(L["Below are your currently available price sources. The %skey|r is what you would type into a custom price box."], TSMAPI.Design:GetInlineColor("link"))
	local lines = {}
	for key, label in pairs(TSMAPI:GetPriceSources()) do
		tinsert(lines, { key = key, label = label })
	end
	sort(lines, function(a, b) return strlower(a.key) < strlower(b.key) end)
	local chatFrame = TSMAPI:GetChatFrame()
	for _, info in ipairs(lines) do
		chatFrame:AddMessage(format("%s (%s)", TSMAPI.Design:GetInlineColor("link") .. info.key .. "|r", info.label))
	end
end

function TSM:TestPriceSource(price)
	local link = select(3, strfind(price, "(\124c.+\124r)"))
	if not link then return TSM:Print(L["Usage: /tsm price <ItemLink> <Price String>"]) end
	price = gsub(price, TSMAPI:StrEscape(link), ""):trim()
	if price == "" then return TSM:Print(L["Usage: /tsm price <ItemLink> <Price String>"]) end
	local func, err = TSMAPI:ParseCustomPrice(price)
	if err then
		TSM:Printf(L["%s is not a valid custom price and gave the following error: %s"], TSMAPI.Design:GetInlineColor("link") .. price .. "|r", err)
	else
		local itemString = TSMAPI:GetItemString(link)
		if not itemString then return TSM:Printf(L["%s is a valid custom price but %s is an invalid item."], TSMAPI.Design:GetInlineColor("link") .. price .. "|r", link) end
		local value = func(itemString)
		if not value then return TSM:Printf(L["%s is a valid custom price but did not give a value for %s."], TSMAPI.Design:GetInlineColor("link") .. price .. "|r", link) end
		TSM:Printf(L["A custom price of %s for %s evaluates to %s."], TSMAPI.Design:GetInlineColor("link") .. price .. "|r", link, TSMAPI:FormatTextMoney(value))
	end
end

function TSM:GetCustomPrice(priceMethod, itemString)
	local func = TSMAPI:ParseCustomPrice(priceMethod)
	return func and func(itemString)
end

function TSMAPI:GetChatFrame()
	local chatFrame = DEFAULT_CHAT_FRAME
	for i = 1, NUM_CHAT_WINDOWS do
		local name = strlower(GetChatWindowInfo(i) or "")
		if name ~= "" and name == strlower(TSM.db.global.chatFrame) then
			chatFrame = _G["ChatFrame" .. i]
			break
		end
	end
	return chatFrame
end

function TSM:GetAuctionPlayer(player, player_full)
	local realm = GetRealmName() or ""
	if player_full and strjoin("-", player, realm) ~= player_full then
		return player_full
	else
		return player
	end
end