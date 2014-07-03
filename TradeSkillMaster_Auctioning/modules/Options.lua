-- ------------------------------------------------------------------------------ --
--                           TradeSkillMaster_Auctioning                          --
--           http://www.curse.com/addons/wow/tradeskillmaster_auctioning          --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- load the parent file (TSM) into a local variable and register this file as a module
local TSM = select(2, ...)
local Options = TSM:NewModule("Options", "AceEvent-3.0", "AceHook-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster_Auctioning") -- loads the localization table
local AceGUI = LibStub("AceGUI-3.0") -- load the AceGUI libraries


function Options:Load(parent, operation, group)
	Options.treeGroup = AceGUI:Create("TSMTreeGroup")
	Options.treeGroup:SetLayout("Fill")
	Options.treeGroup:SetCallback("OnGroupSelected", function(...) Options:SelectTree(...) end)
	Options.treeGroup:SetStatusTable(TSM.db.global.optionsTreeStatus)
	parent:AddChild(Options.treeGroup)

	Options:UpdateTree()
	if operation then
		if operation == "" then
			Options.currentGroup = group
			Options.treeGroup:SelectByPath(3)
			Options.currentGroup = nil
		else
			Options.treeGroup:SelectByPath(3, operation)
		end
	else
		Options.treeGroup:SelectByPath(1)
	end
end

function Options:UpdateTree()
	local operationTreeChildren = {}

	for name in pairs(TSM.operations) do
		tinsert(operationTreeChildren, { value = name, text = name })
	end

	sort(operationTreeChildren, function(a, b) return a.value < b.value end)

	Options.treeGroup:SetTree({ { value = 1, text = L["Options"] }, { value = 2, text = L["Whitelist"] }, { value = 3, text = L["Operations"], children = operationTreeChildren } })
end

function Options:SelectTree(treeGroup, _, selection)
	treeGroup:ReleaseChildren()

	local major, minor = ("\001"):split(selection)
	major = tonumber(major)
	if major == 1 then
		Options:DrawGeneralSettings(treeGroup)
	elseif major == 2 then
		Options:DrawWhitelistSettings(treeGroup)
	elseif minor then
		Options:DrawOperationSettings(treeGroup, minor)
	else
		Options:DrawNewOperation(treeGroup)
	end
end

function Options:DrawGeneralSettings(container)
	local macroOptions = { down = true, up = true, ctrl = true, shift = false, alt = false }

	local page = {
		{
			type = "ScrollFrame",
			layout = "list",
			children = {
				{
					type = "InlineGroup",
					layout = "flow",
					title = L["General Options"],
					children = {
						{
							type = "CheckBox",
							label = L["Cancel Auctions with Bids"],
							settingInfo = { TSM.db.global, "cancelWithBid" },
							tooltip = L["Will cancel auctions even if they have a bid on them, you will take an additional gold cost if you cancel an auction with bid."],
						},
						{
							type = "CheckBox",
							label = L["Round Normal Price"],
							settingInfo = { TSM.db.global, "roundNormalPrice" },
							tooltip = L["If checked, whenever you post an item at its normal price, the buyout will be rounded up to the nearest gold."],
						},
						{
							type = "CheckBox",
							label = L["Disable Invalid Price Warnings"],
							settingInfo = { TSM.db.global, "disableInvalidMsg" },
							tooltip = L["If checked, TSM will not print out a chat message when you have an invalid price for an item. However, it will still show as invalid in the log."],
						},
						{
							type = "Dropdown",
							label = L["Default Operation Tab"],
							list = { L["General"], L["Post"], L["Cancel"], L["Reset"] },
							settingInfo = { TSM.db.global, "defaultOperationTab" },
							tooltip = L["This dropdown determines the default tab when you visit an operation."],
						},
						{
							type = "Dropdown",
							label = L["Enable Sounds"],
							list = {L["None"], "AuctionWindowOpen", "Fishing Reel in", "HumanExploration", "LEVELUP", "MapPing", "MONEYFRAMEOPEN", "QUESTCOMPLETED", "ReadyCheck"},
							settingInfo = { TSM.db.global, "scanCompleteSound" },
							tooltip = L["Play the selected sound when a post / cancel scan is complete and items are ready to be posted / canceled (the gray bar is all the way across).Select None to disable sounds"],
						},
						{
							type = "Button",
							text = L["Test Selected Sound"],
							callback = function()
								if TSM.db.global.scanCompleteSound ~= 1 then
									PlaySound(TSM.Options:GetScanCompleteSound(TSM.db.global.scanCompleteSound), "Master")
								end
							end,
						},
					},
				},
				{
					type = "Spacer",
				},
				{
					type = "InlineGroup",
					layout = "flow",
					title = L["Macro Help"],
					children = {
						{
							type = "Label",
							text = format(L["There are two ways of making clicking the Post / Cancel Auction button easier. You can put %s and %s in a macro (on separate lines), or use the utility below to have a macro automatically made and bound to scrollwheel for you."], "\"" .. TSMAPI.Design:GetInlineColor("link") .. "/click TSMAuctioningPostButton|r\"", "\"" .. TSMAPI.Design:GetInlineColor("link") .. "/click TSMAuctioningCancelButton|r\""),
							relativeWidth = 1,
						},
						{
							type = "HeadingLine"
						},
						{
							type = "Label",
							text = L["ScrollWheel Direction (both recommended):"],
							relativeWidth = 0.59,
						},
						{
							type = "CheckBox",
							label = L["Up"],
							relativeWidth = 0.2,
							settingInfo = { macroOptions, "up" },
							tooltip = L["Will bind ScrollWheelUp (plus modifiers below) to the macro created."],
						},
						{
							type = "CheckBox",
							label = L["Down"],
							relativeWidth = 0.2,
							settingInfo = { macroOptions, "down" },
							tooltip = L["Will bind ScrollWheelDown (plus modifiers below) to the macro created."],
						},
						{
							type = "Label",
							text = L["Modifiers:"],
							relativeWidth = 0.24,
							fontObject = GameFontNormal,
						},
						{
							type = "CheckBox",
							label = "ALT",
							relativeWidth = 0.25,
							settingInfo = { macroOptions, "alt" },
						},
						{
							type = "CheckBox",
							label = "CTRL",
							relativeWidth = 0.25,
							settingInfo = { macroOptions, "ctrl" },
						},
						{
							type = "CheckBox",
							label = "SHIFT",
							relativeWidth = 0.25,
							settingInfo = { macroOptions, "shift" },
						},
						{
							type = "Button",
							relativeWidth = 1,
							text = L["Create Macro and Bind ScrollWheel (with selected options)"],
							callback = function()
								DeleteMacro("TSMAucBClick")
								CreateMacro("TSMAucBClick", 1, "/click TSMAuctioningCancelButton\n/click TSMAuctioningPostButton")

								local modString = ""
								if macroOptions.ctrl then
									modString = modString .. "CTRL-"
								end
								if macroOptions.alt then
									modString = modString .. "ALT-"
								end
								if macroOptions.shift then
									modString = modString .. "SHIFT-"
								end

								local bindingNum = GetCurrentBindingSet()
								bindingNum = (bindingNum == 1) and 2 or 1

								if macroOptions.up then
									SetBinding(modString .. "MOUSEWHEELUP", nil, bindingNum)
									SetBinding(modString .. "MOUSEWHEELUP", "MACRO TSMAucBClick", bindingNum)
								end
								if macroOptions.down then
									SetBinding(modString .. "MOUSEWHEELDOWN", nil, bindingNum)
									SetBinding(modString .. "MOUSEWHEELDOWN", "MACRO TSMAucBClick", bindingNum)
								end
								SaveBindings(2)

								TSM:Print(L["Macro created and keybinding set!"])
							end,
						},
					},
				},
			},
		},
	}

	TSMAPI:BuildPage(container, page)
end

function Options:DrawWhitelistSettings(container)
	local function AddPlayer(self, _, value)
		value = string.trim(strlower(value or ""))
		if value == "" then return TSM:Print(L["No name entered."]) end

		if TSM.db.factionrealm.whitelist[value] then
			TSM:Printf(L["The player \"%s\" is already on your whitelist."], TSM.db.factionrealm.whitelist[value])
			return
		end

		for player in pairs(TSM.db.factionrealm.player) do
			if strlower(player) == value then
				TSM:Printf(L["You do not need to add \"%s\", alts are whitelisted automatically."], player)
				return
			end
		end

		TSM.db.factionrealm.whitelist[strlower(value)] = value
		container:SelectByPath(2)
	end

	local page = {
		{
			-- scroll frame to contain everything
			type = "ScrollFrame",
			layout = "List",
			children = {
				{
					type = "InlineGroup",
					layout = "flow",
					title = L["Help"],
					children = {
						{
							type = "Label",
							relativeWidth = 1,
							fontObject = GameFontNormal,
							text = L["Whitelists allow you to set other players besides you and your alts that you do not want to undercut; however, if somebody on your whitelist matches your buyout but lists a lower bid it will still consider them undercutting."],
						},
						{
							type = "CheckBox",
							relativeWidth = 0.49,
							label = L["Match Whitelist Players"],
							settingInfo = { TSM.db.global, "matchWhitelist" },
							tooltip = L["If enabled, instead of not posting when a whitelisted player has an auction posted, Auctioning will match their price."],
						},
					},
				},
				{
					type = "InlineGroup",
					layout = "flow",
					title = L["Add player"],
					children = {
						{
							type = "EditBox",
							label = L["Player name"],
							relativeWidth = 0.5,
							callback = AddPlayer,
							tooltip = L["Add a new player to your whitelist."],
						},
					},
				},
				{
					type = "InlineGroup",
					layout = "flow",
					title = L["Whitelist"],
					children = {},
				},
			},
		},
	}

	for name in pairs(TSM.db.factionrealm.whitelist) do
		tinsert(page[1].children[3].children,
			{
				type = "Label",
				text = TSM.db.factionrealm.whitelist[name],
				fontObject = GameFontNormal,
			})
		tinsert(page[1].children[3].children,
			{
				type = "Button",
				text = L["Delete"],
				relativeWidth = 0.3,
				callback = function(self)
					TSM.db.factionrealm.whitelist[name] = nil
					container:SelectByPath(2)
				end,
			})
	end

	if #(page[1].children[3].children) == 0 then
		tinsert(page[1].children[3].children,
			{
				type = "Label",
				text = L["You do not have any players on your whitelist yet."],
				fontObject = GameFontNormal,
				relativeWidth = 1,
			})
	end

	TSMAPI:BuildPage(container, page)
end

function Options:DrawNewOperation(container)
	local currentGroup = Options.currentGroup
	local page = {
		{
			-- scroll frame to contain everything
			type = "ScrollFrame",
			layout = "List",
			children = {
				{
					type = "InlineGroup",
					layout = "flow",
					title = L["New Operation"],
					children = {
						{
							type = "Label",
							text = L["Auctioning operations contain settings for posting, canceling, and resetting items in a group. Type the name of the new operation into the box below and hit 'enter' to create a new Crafting operation."],
							relativeWidth = 1,
						},
						{
							type = "EditBox",
							label = L["Operation Name"],
							relativeWidth = 0.8,
							callback = function(self, _, name)
								name = (name or ""):trim()
								if name == "" then return end
								if TSM.operations[name] then
									self:SetText("")
									return TSM:Printf(L["Error creating operation. Operation with name '%s' already exists."], name)
								end
								TSM.operations[name] = CopyTable(TSM.operationDefaults)
								Options:UpdateTree()
								Options.treeGroup:SelectByPath(3, name)
								TSMAPI:NewOperationCallback("Auctioning", currentGroup, name)
							end,
							tooltip = L["Give the new operation a name. A descriptive name will help you find this operation later."],
						},
					},
				},
			},
		},
	}
	TSMAPI:BuildPage(container, page)
end

function Options:DrawOperationSettings(container, operationName)
	local tg = AceGUI:Create("TSMTabGroup")
	tg:SetLayout("Fill")
	tg:SetFullHeight(true)
	tg:SetFullWidth(true)
	tg:SetTabs({ { value = 1, text = L["General"] }, { value = 2, text = L["Post"] }, { value = 3, text = L["Cancel"] }, { value = 4, text = L["Reset"] }, { value = 5, text = TSMAPI.Design:GetInlineColor("advanced") .. L["Relationships"] .. "|r" }, { value = 6, text = L["Management"] } })
	tg:SetCallback("OnGroupSelected", function(self, _, value)
		tg:ReleaseChildren()
		TSMAPI:UpdateOperation("Auctioning", operationName)
		if value == 1 then
			Options:DrawOperationGeneral(self, operationName)
		elseif value == 2 then
			Options:DrawOperationPost(self, operationName)
		elseif value == 3 then
			Options:DrawOperationCancel(self, operationName)
		elseif value == 4 then
			Options:DrawOperationReset(self, operationName)
		elseif value == 5 then
			Options:DrawOperationRelationships(self, operationName)
		elseif value == 6 then
			TSMAPI:DrawOperationManagement(TSM, self, operationName)
		end
	end)
	container:AddChild(tg)
	tg:SelectTab(TSM.db.global.defaultOperationTab)
end

function Options:DrawOperationGeneral(container, operationName)
	local operation = TSM.operations[operationName]
	local durationList = { [0] = L["<none>"] }
	for i = 1, 3 do -- go up to long duration
		durationList[i] = format("%s (%s)", _G["AUCTION_TIME_LEFT" .. i], _G["AUCTION_TIME_LEFT" .. i .. "_DETAIL"])
	end

	local page = {
		{
			type = "ScrollFrame",
			layout = "list",
			children = {
				{
					type = "InlineGroup",
					layout = "flow",
					title = L["General Operation Options"],
					children = {
						{
							type = "CheckBox",
							label = L["Match Stack Size"],
							settingInfo = { operation, "matchStackSize" },
							disabled = operation.relationships.matchStackSize,
							tooltip = L["If checked, Auctioning will ignore all auctions that are posted at a different stack size than your auctions. For example, if there are stacks of 1, 5, and 20 up and you're posting in stacks of 1, it'll ignore all stacks of 5 and 20."],
						},
						{
							type = "Dropdown",
							label = L["Ignore Low Duration Auctions"],
							settingInfo = { operation, "ignoreLowDuration" },
							relativeWidth = 0.5,
							list = durationList,
							disabled = operation.relationships.ignoreLowDuration,
							tooltip = L["Any auctions at or below the selected duration will be ignored. Selecting \"<none>\" will cause no auctions to be ignored based on duration."],
						},
					},
				},
			},
		},
	}

	TSMAPI:BuildPage(container, page)
end

function Options:DrawOperationPost(container, operationName)
	local operation = TSM.operations[operationName]
	local page = {
		{
			type = "ScrollFrame",
			layout = "list",
			children = {
				{
					type = "InlineGroup",
					layout = "flow",
					title = L["Auction Settings"],
					children = {
						{
							type = "Dropdown",
							label = L["Duration"],
							settingInfo = { operation, "duration" },
							relativeWidth = 0.5,
							list = { [12] = AUCTION_DURATION_ONE, [24] = AUCTION_DURATION_TWO, [48] = AUCTION_DURATION_THREE },
							disabled = operation.relationships.duration,
							tooltip = L["How long auctions should be up for."],
						},
						{
							type = "Slider",
							label = L["Post Cap"],
							settingInfo = { operation, "postCap" },
							relativeWidth = 0.49,
							min = 0,
							max = 500,
							step = 1,
							disabled = operation.relationships.postCap,
							tooltip = L["How many auctions at the lowest price tier can be up at any one time. Setting this to 0 disables posting for any groups this operation is applied to."],
						},
						{
							type = "Slider",
							label = L["Stack Size"],
							settingInfo = { operation, "stackSize" },
							min = 1,
							max = 1000,
							step = 1,
							relativeWidth = 0.5,
							disabled = operation.relationships.stackSize,
							tooltip = L["How many items should be in a single auction, 20 will mean they are posted in stacks of 20."],
						},
						{
							type = "CheckBox",
							label = L["Use Stack Size as Cap"],
							settingInfo = { operation, "stackSizeIsCap" },
							disabled = operation.relationships.stackSizeIsCap,
							tooltip = L["If you don't have enough items for a full post, it will post with what you have."],
						},
						{
							type = "Slider",
							label = L["Keep Quantity"],
							settingInfo = { operation, "keepQuantity" },
							min = 0,
							max = 1000,
							step = 1,
							relativeWidth = 0.5,
							tooltip = L["How many items you want to keep in your bags and not have Auctioning post."],
						},
					},
				},
				{
					type = "Spacer",
				},
				{
					type = "InlineGroup",
					layout = "flow",
					title = L["Auction Price Settings"],
					children = {
						{
							type = "Slider",
							label = L["Bid percent"],
							settingInfo = { operation, "bidPercent" },
							isPercent = true,
							min = 0,
							max = 1,
							step = 0.01,
							relativeWidth = 0.5,
							disabled = operation.relationships.bidPercent,
							tooltip = L["Percentage of the buyout as bid, if you set this to 90% then a 100g buyout will have a 90g bid."],
						},
						{
							type = "EditBox",
							label = L["Undercut Amount"],
							settingInfo = { operation, "undercut" },
							relativeWidth = 0.49,
							acceptCustom = true,
							disabled = operation.relationships.undercut,
							tooltip = L["How much to undercut other auctions by. Format is in \"#g#s#c\". For example, \"50g30s\" means 50 gold, 30 silver, and no copper."],
						},
					},
				},
				{
					type = "Spacer",
				},
				{
					type = "InlineGroup",
					layout = "flow",
					title = L["Posting Price Settings"],
					children = {
						{
							type = "EditBox",
							label = L["Minimum Price"],
							settingInfo = { operation, "minPrice" },
							relativeWidth = 0.49,
							acceptCustom = true,
							disabled = operation.relationships.minPrice,
							tooltip = L["The lowest price you want an item to be posted for. Auctioning will not undercut auctions below this price."],
						},
						{
							type = "Dropdown",
							label = L["When Below Minimum"],
							relativeWidth = 0.5,
							list = { ["none"] = L["Don't Post Items"], ["minPrice"] = L["Post at Minimum Price"], ["maxPrice"] = L["Post at Maximum Price"], ["normalPrice"] = L["Post at Normal Price"], ["ignore"] = L["Ignore Auctions Below Minimum"] },
							settingInfo = { operation, "priceReset" },
							disabled = operation.relationships.priceReset,
							tooltip = L["This dropdown determines what Auctioning will do when the market for an item goes below your minimum price. You can not post the items, post at one of your configured prices, or have Auctioning ignore all the auctions below your minimum price (and likely undercut the lowest auction above your mimimum price)."],
						},
						{
							type = "EditBox",
							label = L["Maximum Price"],
							settingInfo = { operation, "maxPrice" },
							relativeWidth = 0.49,
							acceptCustom = true,
							disabled = operation.relationships.maxPrice,
							tooltip = L["The maximum price you want an item to be posted for. Auctioning will not undercut auctions above this price."],
						},
						{
							type = "Dropdown",
							label = L["When Above Maximum"],
							relativeWidth = 0.5,
							list = { ["minPrice"] = L["Post at Minimum Price"], ["maxPrice"] = L["Post at Maximum Price"], ["normalPrice"] = L["Post at Normal Price"] },
							settingInfo = { operation, "aboveMax" },
							disabled = operation.relationships.aboveMax,
							tooltip = L["This dropdown determines what Auctioning will do when the market for an item goes above your maximum price. You can post the items at one of your configured prices."],
						},
						{
							type = "EditBox",
							label = L["Normal Price"],
							settingInfo = { operation, "normalPrice" },
							relativeWidth = 0.49,
							acceptCustom = true,
							disabled = operation.relationships.normalPrice,
							tooltip = L["Price to post at if there are none of an item currently on the AH."],
						},
					},
				},
			},
		},
	}

	TSMAPI:BuildPage(container, page)
end

function Options:DrawOperationCancel(container, operationName)
	local operation = TSM.operations[operationName]
	local page = {
		{
			type = "ScrollFrame",
			layout = "list",
			children = {
				{
					type = "InlineGroup",
					layout = "flow",
					title = L["Cancel Settings"],
					children = {
						{
							type = "CheckBox",
							label = L["Cancel Undercut Auctions"],
							settingInfo = { operation, "cancelUndercut" },
							callback = function() container:ReloadTab() end,
							disabled = operation.relationships.cancelUndercut,
							tooltip = L["If checked, a cancel scan will cancel any auctions which have been undercut and are still above your minimum price."],
						},
						{
							type = "Slider",
							label = L["Keep Posted"],
							settingInfo = { operation, "keepPosted" },
							disabled = not operation.cancelUndercut or operation.relationships.keepPosted,
							relativeWidth = 0.49,
							min = 0,
							max = 500,
							step = 1,
							tooltip = L["This number of undercut auctions will be kept on the auction house (not canceled) when doing a cancel scan."],
						},
						{
							type = "CheckBox",
							label = L["Cancel to Repost Higher"],
							settingInfo = { operation, "cancelRepost" },
							callback = function() container:ReloadTab() end,
							disabled = operation.relationships.cancelRepost,
							tooltip = L["If checked, a cancel scan will cancel any auctions which can be reposted for a higher price."],
						},
						{
							type = "EditBox",
							label = L["Repost Higher Threshold"],
							settingInfo = { operation, "cancelRepostThreshold" },
							disabled = not operation.cancelRepost or operation.relationships.cancelRepostThreshold,
							relativeWidth = 0.49,
							acceptCustom = true,
							tooltip = L["If an item can't be posted for at least this amount higher than its current value, it won't be canceled to repost higher."],
						},
					},
				},
			},
		},
	}

	TSMAPI:BuildPage(container, page)
end

function Options:DrawOperationReset(container, operationName)
	local operation = TSM.operations[operationName]
	local page = {
		{
			type = "ScrollFrame",
			layout = "list",
			children = {
				{
					type = "InlineGroup",
					layout = "flow",
					title = L["General Reset Settings"],
					children = {
						{
							type = "CheckBox",
							label = L["Enable Reset Scan"],
							relativeWidth = 1,
							settingInfo = { operation, "resetEnabled" },
							callback = function() container:ReloadTab() end,
							disabled = operation.relationships.resetEnabled,
							tooltip = L["If checked, groups which the opperation applies to will be included in a reset scan."],
						},
						{
							type = "Slider",
							label = L["Max Quantity to Buy"],
							settingInfo = { operation, "resetMaxQuantity" },
							disabled = not operation.resetEnabled or operation.relationships.resetMaxQuantity,
							relativeWidth = 0.5,
							min = 1,
							max = 1000,
							step = 1,
							tooltip = L["This is the maximum quantity of an item you want to buy in a single reset scan."],
						},
						{
							type = "Slider",
							label = L["Max Inventory Quantity"],
							settingInfo = { operation, "resetMaxInventory" },
							disabled = not operation.resetEnabled or operation.relationships.resetMaxInventory,
							relativeWidth = 0.49,
							min = 1,
							max = 1000,
							step = 1,
							tooltip = L["This is the maximum quantity of an item you want to have in your inventory after a reset scan."],
						},
						{
							type = "EditBox",
							label = L["Max Reset Cost"],
							settingInfo = { operation, "resetMaxCost" },
							disabled = not operation.resetEnabled or operation.relationships.resetMaxCost,
							relativeWidth = 0.49,
							acceptCustom = true,
							tooltip = L["The maximum amount that you want to spend in order to reset a particular item. This is the total amount, not a per-item amount."],
						},
						{
							type = "EditBox",
							label = L["Min Reset Profit"],
							settingInfo = { operation, "resetMinProfit" },
							disabled = not operation.resetEnabled or operation.relationships.resetMinProfit,
							relativeWidth = 0.49,
							acceptCustom = true,
							tooltip = L["The minimum profit you would want to make from doing a reset. This is a per-item price where profit is the price you reset to minus the average price you spent per item."],
						},
						{
							type = "EditBox",
							label = L["Price Resolution"],
							settingInfo = { operation, "resetResolution" },
							disabled = not operation.resetEnabled or operation.relationships.resetResolution,
							relativeWidth = 0.49,
							acceptCustom = true,
							tooltip = L["This determines what size range of prices should be considered a single price point for the reset scan. For example, if this is set to 1s, an auction at 20g50s20c and an auction at 20g49s45c will both be considered to be the same price level."],
						},
						{
							type = "EditBox",
							label = L["Max Cost Per Item"],
							settingInfo = { operation, "resetMaxItemCost" },
							disabled = not operation.resetEnabled or operation.relationships.resetMaxItemCost,
							relativeWidth = 0.49,
							acceptCustom = true,
							tooltip = L["This is the maximum amount you want to pay for a single item when reseting."],
						},
					},
				},
			},
		},
	}

	TSMAPI:BuildPage(container, page)
end

function Options:DrawOperationRelationships(container, operationName)
	local settingInfo = {
		{
			label = L["General Settings"],
			{ key = "matchStackSize", label = L["Match Stack Size"] },
			{ key = "ignoreLowDuration", label = L["Ignore Low Duration Auctions"] },
		},
		{
			label = L["Post Settings"],
			{ key = "duration", label = L["Duration"] },
			{ key = "postCap", label = L["Post Cap"] },
			{ key = "stackSize", label = L["Stack Size"] },
			{ key = "stackSizeIsCap", label = L["Use Stack Size as Cap"] },
			{ key = "keepQuantity", label = L["Keep Quantity"] },
			{ key = "bidPercent", label = L["Bid percent"] },
			{ key = "undercut", label = L["Undercut Amount"] },
			{ key = "minPrice", label = L["Minimum Price"] },
			{ key = "priceReset", label = L["When Below Minimum"] },
			{ key = "maxPrice", label = L["Maximum Price"] },
			{ key = "aboveMax", label = L["When Above Maximum"] },
			{ key = "normalPrice", label = L["Normal Price"] },
		},
		{
			label = L["Cancel Settings"],
			{ key = "cancelUndercut", label = L["Cancel Undercut Auctions"] },
			{ key = "keepPosted", label = L["Keep Posted"] },
			{ key = "cancelRepost", label = L["Cancel to Repost Higher"] },
			{ key = "cancelRepostThreshold", label = L["Repost Higher Threshold"] },
		},
		{
			label = L["Reset Settings"],
			{ key = "resetEnabled", label = L["Enable Reset Scan"] },
			{ key = "resetMaxQuantity", label = L["Max Quantity to Buy"] },
			{ key = "resetMaxInventory", label = L["Max Inventory Quantity"] },
			{ key = "resetMaxCost", label = L["Max Reset Cost"] },
			{ key = "resetMinProfit", label = L["Min Reset Profit"] },
			{ key = "resetResolution", label = L["Price Resolution"] },
			{ key = "resetMaxItemCost", label = L["Max Cost Per Item"] },
		},
	}
	TSMAPI:ShowOperationRelationshipTab(TSM, container, TSM.operations[operationName], settingInfo)
end

function Options:LoadTooltipOptions(container)
	local page = {
		{
			type = "SimpleGroup",
			layout = "Flow",
			fullHeight = true,
			children = {
				{
					type = "CheckBox",
					label = L["Show Auctioning values in Tooltip"],
					settingInfo = { TSM.db.global, "tooltip" },
					callback = function() container:ReloadTab() end,
					tooltip = L["If checked, the minimum, normal and maximum prices of the first operation for the item will be shown in tooltips."],
				},
			},
		},
	}

	TSMAPI:BuildPage(container, page)
end

function Options:GetScanCompleteSound(index)
	--L["None"], "AuctionWindowOpen", "Fishing Reel in", "HumanExploration", "LEVELUP", "MapPing", "MONEYFRAMEOPEN", "QUESTCOMPLETED", "ReadyCheck"
	if index == 2 then
		return "AuctionWindowOpen"
	elseif index == 3 then
		return "Fishing Reel in"
	elseif index == 4 then
		return "HumanExploration"
	elseif index == 5 then
		return "LEVELUP"
	elseif index == 6 then
		return "MapPing"
	elseif index == 7 then
		return "MONEYFRAMEOPEN"
	elseif index == 8 then
		return "QUESTCOMPLETED"
	elseif index == 9 then
		return "ReadyCheck"
	end
end