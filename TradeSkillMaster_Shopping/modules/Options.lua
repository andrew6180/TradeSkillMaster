-- ------------------------------------------------------------------------------ --
--                            TradeSkillMaster_Shopping                           --
--            http://www.curse.com/addons/wow/tradeskillmaster_shopping           --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- load the parent file (TSM) into a local variable and register this file as a module
local TSM = select(2, ...)
local Options = TSM:NewModule("Options", "AceEvent-3.0", "AceHook-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster_Shopping") -- loads the localization table
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
			Options.treeGroup:SelectByPath(2)
			Options.currentGroup = nil
		else
			Options.treeGroup:SelectByPath(2, operation)
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

	Options.treeGroup:SetTree({ { value = 1, text = L["Options"] }, { value = 2, text = L["Operations"], children = operationTreeChildren } })
end

function Options:SelectTree(treeGroup, _, selection)
	treeGroup:ReleaseChildren()

	local major, minor = ("\001"):split(selection)
	major = tonumber(major)
	if major == 1 then
		Options:DrawGeneralSettings(treeGroup)
	elseif minor then
		Options:DrawOperationSettings(treeGroup, minor)
	else
		Options:DrawNewOperation(treeGroup)
	end
end

function Options:DrawGeneralSettings(container)
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
							type = "EditBox",
							label = L["Default Post Undercut Amount"],
							settingInfo = { TSM.db.global, "postUndercut" },
							relativeWidth = 0.5,
							acceptCustom = true,
							callback = function(_, _, value) TSMAPI.AuctionControl.undercut = value end,
							tooltip = L["What to set the default undercut to when posting items with Shopping."],
						},
						{
							type = "EditBox",
							label = L["Market Value Price Source"],
							settingInfo = { TSM.db.global, "marketValueSource" },
							relativeWidth = 0.5,
							acceptCustom = true,
							tooltip = L["This is how Shopping calculates the '% Market Value' column in the search results."],
						},
						{
							type = "Slider",
							label = L["Max Disenchant Search Percent"],
							settingInfo = { TSM.db.global, "maxDeSearchPercent" },
							min = .1,
							max = 1,
							step = .01,
							isPercent = true,
							relativeWidth = 1,
							tooltip = L["This is the maximum percentage of disenchant value that the Other > Disenchant search will display results for."],
						},
						{
							type = "Slider",
							label = L["Min Disenchant Level"],
							settingInfo = { TSM.db.global, "minDeSearchLvl" },
							min = 1,
							max = 450,
							step = 1,
							isPercent = false,
							relativeWidth = 0.5,
							callback = function(self, _, value)
								if value > TSM.db.global.maxDeSearchLvl then
									TSM:Print(TSMAPI.Design:GetInlineColor("link2") .. L["Warning: The min disenchant level must be lower than the max disenchant level."] .. "|r")
								end
								TSM.db.global.minDeSearchLvl = min(value, TSM.db.global.maxDeSearchLvl)
							end,
							tooltip = L["This is the minimum item level that the Other > Disenchant search will display results for."],
						},
						{
							type = "Slider",
							label = L["Max Disenchant Level"],
							settingInfo = { TSM.db.global, "maxDeSearchLvl" },
							min = 1,
							max = 450,
							step = 1,
							isPercent = false,
							callback = function(self, _, value)
								if value < TSM.db.global.minDeSearchLvl then
									TSM:Print(TSMAPI.Design:GetInlineColor("link2") .. L["Warning: The max disenchant level must be higher than the min disenchant level."] .. "|r")
								end
								TSM.db.global.maxDeSearchLvl = max(value, TSM.db.global.minDeSearchLvl)
							end,
							relativeWidth = 0.5,
							tooltip = L["This is the maximum item level that the Other > Disenchant search will display results for."],
						},
					},
				},
				{
					type = "Spacer",
				},
				{
					type = "InlineGroup",
					layout = "flow",
					title = "Posting Options",
					children = {
						{
							type = "Slider",
							label = L["Bid Percent"],
							settingInfo = { TSM.db.global, "postBidPercent" },
							min = .1,
							max = 1,
							step = .01,
							isPercent = true,
							relativeWidth = 0.5,
							tooltip = L["This is the percentage of your buyout price that your bid will be set to when posting auctions with Shopping."],
						},
						{
							type = "EditBox",
							label = L["Normal Post Price"],
							settingInfo = { TSM.db.global, "normalPostPrice" },
							relativeWidth = 0.49,
							acceptCustom = true,
							tooltip = L["This is the default price Shopping will suggest to post items at when there's no others posted."],
						},
						{
							type = "HeadingLine"
						},
						{
							type = "Dropdown",
							label = L["Quick Posting Duration"],
							list = { AUCTION_DURATION_ONE, AUCTION_DURATION_TWO, AUCTION_DURATION_THREE },
							settingInfo = { TSM.db.global, "quickPostingDuration" },
							relativeWidth = 0.5,
							tooltip = L["The duration at which items will be posted via the 'Quick Posting' frame."],
						},
						{
							type = "EditBox",
							label = L["Quick Posting Price"],
							settingInfo = { TSM.db.global, "quickPostingPrice" },
							relativeWidth = 0.49,
							acceptCustom = true,
							tooltip = L["This price is used to determine what items will be posted at through the 'Quick Posting' frame."],
						},
					},
				},
				{
					type = "InlineGroup",
					layout = "flow",
					title = L["Sniper Options"],
					children = {
						{
							type = "CheckBox",
							label = L["Below Vendor Sell Price"],
							settingInfo = { TSM.db.global, "sniperVendorPrice" },
							relativeWidth = 0.5,
							tooltip = L["Items which are below their vendor sell price will be displayed in Sniper searches."],
						},
						{
							type = "CheckBox",
							label = L["Below Max Price"],
							settingInfo = { TSM.db.global, "sniperMaxPrice" },
							relativeWidth = 0.49,
							tooltip = L["Items which are below their maximum price (per their group / Shopping operation) will be displayed in Sniper searches."],
						},
						{
							type = "EditBox",
							label = L["Below Custom Price ('0c' to disable)"],
							settingInfo = { TSM.db.global, "sniperCustomPrice" },
							relativeWidth = 0.5,
							acceptCustom = true,
							tooltip = L["Items which are below this custom price will be displayed in Sniper searches."],
						},
					},
				},
			},
		},
	}

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
							text = L["Shopping operations contain settings items which you regularly buy from the auction house."],
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
								Options.treeGroup:SelectByPath(2, name)
								TSMAPI:NewOperationCallback("Shopping", currentGroup, name)
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
	tg:SetTabs({ { value = 1, text = L["General"] }, { value = 2, text = L["Relationships"] }, { value = 3, text = L["Management"] } })
	tg:SetCallback("OnGroupSelected", function(self, _, value)
		tg:ReleaseChildren()
		TSMAPI:UpdateOperation("Shopping", operationName)
		if value == 1 then
			Options:DrawOperationGeneral(self, operationName)
		elseif value == 2 then
			Options:DrawOperationRelationships(self, operationName)
		elseif value == 3 then
			TSMAPI:DrawOperationManagement(TSM, self, operationName)
		end
	end)
	container:AddChild(tg)
	tg:SelectTab(1)
end

function Options:DrawOperationGeneral(container, operationName)
	local operation = TSM.operations[operationName]
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
							type = "EditBox",
							label = L["Maximum Auction Price (per item)"],
							settingInfo = { operation, "maxPrice" },
							relativeWidth = 0.49,
							acceptCustom = true,
							disabled = operation.relationships.maxprice,
							tooltip = L["The highest price per item you will pay for items in affected by this operation."],
						},
						{
							type = "CheckBox",
							label = L["Show Auctions Above Max Price"],
							settingInfo = { operation, "showAboveMaxPrice" },
							disabled = operation.relationships.showAboveMaxPrice,
							tooltip = L["If checked, auctions above the max price will be shown."],
						},
						{
							type = "CheckBox",
							label = L["Even (5/10/15/20) Stacks Only"],
							settingInfo = { operation, "evenStacks" },
							disabled = operation.relationships.evenStacks,
							tooltip = L["If checked, only auctions posted in even quantities will be considered for purchasing."],
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
			{ key = "maxPrice", label = L["Maximum Auction Price (per item)"] },
			{ key = "showAboveMaxPrice", label = L["Show Auctions Above Max Price"] },
			{ key = "evenStacks", label = L["Even (5/10/15/20) Stacks Only"] },
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
					label = L["Show Shopping Max Price in Tooltip"],
					settingInfo = { TSM.db.global, "tooltip" },
					callback = function(_, _, value) container:ReloadTab() end,
					tooltip = L["If checked, the maximum shopping price will be shown in the tooltip for the item."],
				},
			},
		},
	}

	TSMAPI:BuildPage(container, page)
end