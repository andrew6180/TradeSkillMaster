-- ------------------------------------------------------------------------------ --
--                            TradeSkillMaster_Crafting                           --
--            http://www.curse.com/addons/wow/tradeskillmaster_crafting           --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- load the parent file (TSM) into a local variable and register this file as a module
local TSM = select(2, ...)
local Options = TSM:NewModule("Options", "AceEvent-3.0", "AceHook-3.0")
local AceGUI = LibStub("AceGUI-3.0") -- load the AceGUI libraries

local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster_Crafting") -- loads the localization table

-- scrolling tables
local matST, craftST
local ROW_HEIGHT = 16
local filters = {}

local function getIndex(t, value)
	for i, v in pairs(t) do
		if v == value then
			return i
		end
	end
end

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
		Options:LoadGeneralSettings(treeGroup)
	elseif minor then
		Options:DrawOperationSettings(treeGroup, minor)
	else
		Options:DrawNewOperation(treeGroup)
	end
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
							text = L["Crafting operations contain settings for restocking the items in a group. Type the name of the new operation into the box below and hit 'enter' to create a new Crafting operation."],
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
								TSMAPI:NewOperationCallback("Crafting", currentGroup, name)
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
	tg:SetTabs({{value=1, text=L["General"]}, {value=2, text=L["Relationships"]}, {value=3, text=L["Management"]}})
	tg:SetCallback("OnGroupSelected", function(self,_,value)
			tg:ReleaseChildren()
			TSMAPI:UpdateOperation("Crafting", operationName)
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
	local operationSettings = TSM.operations[operationName]

	local page = {
		{
			-- scroll frame to contain everything
			type = "ScrollFrame",
			layout = "List",
			children = {
				{
					type = "InlineGroup",
					layout = "flow",
					title = L["Restock Quantity Settings"],
					children = {
						{
							-- slider to set the stock number
							type = "Slider",
							value = operationSettings.minRestock,
							label = L["Min Restock Quantity"],
							isPercent = false,
							min = 1,
							max = 2000,
							step = 1,
							relativeWidth = 0.49,
							disabled = operationSettings.relationships.minRestock,
							callback = function(self, _, value)
								if value > operationSettings.maxRestock then
									TSM:Print(TSMAPI.Design:GetInlineColor("link2") .. L["Warning: The min restock quantity must be lower than the max restock quantity."] .. "|r")
								end
								operationSettings.minRestock = min(value, operationSettings.maxRestock)
							end,
							tooltip = L["Items will only be added to the queue if the number being added is greater than this number. This is useful if you don't want to bother with crafting singles for example."],
						},
						{
							-- slider to set the stock number
							type = "Slider",
							value = operationSettings.maxRestock,
							label = L["Max Restock Quantity"],
							isPercent = false,
							min = 1,
							max = 2000,
							step = 1,
							relativeWidth = 0.49,
							disabled = operationSettings.relationships.maxRestock,
							callback = function(self, _, value)
								if value < operationSettings.minRestock then
									TSM:Print(TSMAPI.Design:GetInlineColor("link2") .. L["Warning: The min restock quantity must be lower than the max restock quantity."] .. "|r")
								end
								operationSettings.maxRestock = max(value, operationSettings.minRestock)
							end,
							tooltip = L["When you click on the \"Restock Queue\" button enough of each craft will be queued so that you have this maximum number on hand. For example, if you have 2 of item X on hand and you set this to 4, 2 more will be added to the craft queue."],
						},
						{
							type = "CheckBox",
							value = operationSettings.minProfit,
							label = L["Set Minimum Profit"],
							relativeWidth = 0.5,
							disabled = operationSettings.relationships.minProfit,
							callback = function(_, _, value)
								if value then
									operationSettings.minProfit = TSM.operationDefaults.minProfit
								else
									operationSettings.minProfit = nil
								end
								container:ReloadTab()
							end,
						},
						{
							type = "EditBox",
							label = L["Minimum Profit"],
							disabled = not operationSettings.minProfit or operationSettings.relationships.minProfit,
							settingInfo = {operationSettings, "minProfit"},
							relativeWidth = 0.49,
							acceptCustom = true,
							tooltip = L["Crafting will not queue any items affected by this operation with a profit below this value. As an example, a min profit of 'max(10g, 10% crafting)' would ensure a profit of at least 10g or 10% of the craft cost, whichever is highest."],
						},
					},
				},
				{
					type = "Spacer",
				},
				{
					type = "InlineGroup",
					layout = "flow",
					title = L["Price Settings"],
					children = {
						{
							type = "CheckBox",
							value = operationSettings.craftPriceMethod,
							label = L["Override Default Craft Value Method"],
							relativeWidth = 1,
							disabled = operationSettings.relationships.craftPriceMethod,
							callback = function(_, _, value)
								if value then
									operationSettings.craftPriceMethod = TSM.db.global.defaultCraftPriceMethod
								else
									operationSettings.craftPriceMethod = nil
								end
								container:ReloadTab()
							end,
						},
						{
							type = "EditBox",
							label = L["Craft Value Method"],
							disabled = not operationSettings.craftPriceMethod or operationSettings.relationships.craftPriceMethod,
							settingInfo = {operationSettings, "craftPriceMethod"},
							relativeWidth = 1,
							acceptCustom = "crafting",
							tooltip = L["This is the default method Crafting will use for determining the value of crafted items."],
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
			label = L["Restock Settings"],
			{key="maxRestock", label=L["Max Restock Quantity"]},
			{key="minRestock", label=L["Min Restock Quantity"]},
			{key="minProfit", label=L["Minimum Profit"]},
		},
		{
			label = L["Price Settings"],
			{key="craftPriceMethod", label=L["Craft Value Method"]},
		},
	}
	TSMAPI:ShowOperationRelationshipTab(TSM, container, TSM.operations[operationName], settingInfo)
end


function Options:LoadGeneralSettings(container)
	-- inventory tracking characters / guilds
	local altCharacters, altGuilds = {}, {}
	for _, name in ipairs(TSMAPI:ModuleAPI("ItemTracker", "playerlist") or {}) do
		altCharacters[name] = name
	end
	for _, name in ipairs(TSMAPI:ModuleAPI("ItemTracker", "guildlist") or {}) do
		altGuilds[name] = name
	end

	local oldScale = TSM.CraftingGUI.frame and TSM.CraftingGUI.frame.options.scale*UIParent:GetScale() or nil
	local page = {
		{
			-- scroll frame to contain everything
			type = "ScrollFrame",
			layout = "List",
			children = {
				{
					type = "InlineGroup",
					layout = "flow",
					title = L["General Settings"],
					children = {
						{
							-- slider to set the % to deduct from profits
							type = "Slider",
							label = TSM.CraftingGUI.frame and L["Profession Frame Scale"] or "Open Profession to Enable",
							value = TSM.CraftingGUI.frame and TSM.CraftingGUI.frame.options.scale or 1,
							disabled = not TSM.CraftingGUI.frame,
							min = 0.1,
							max = 3,
							step = 0.01,
							relativeWidth = 0.49,
							callback = function(_,_,value)
								local options = TSM.CraftingGUI.frame.options
								options.scale = value
								local x = TSM.CraftingGUI.frame:GetLeft()
								local y = TSM.CraftingGUI.frame:GetBottom()
								local newScale = UIParent:GetScale()*options.scale
								x = x * oldScale / newScale
								y = y * oldScale / newScale
								options.x = x
								options.y = y
								oldScale = options.scale*UIParent:GetScale()
								TSM.CraftingGUI.frame:RefreshPosition()
							end,
							tooltip = L["The scale of the profession frame."],
						},
						{
							-- slider to set the % to deduct from profits
							type = "Slider",
							label = L["Profit Deduction"],
							settingInfo = {TSM.db.global, "profitPercent"},
							isPercent = true,
							min = 0,
							max = 0.25,
							step = 0.01,
							relativeWidth = 0.49,
							tooltip = L["Percent to subtract from buyout when calculating profits (5% will compensate for AH cut)."],
						},
						{
							type = "CheckBox",
							relativeWidth = 0.5,
							label = L["Never Queue Inks as Sub-Craftings"],
							settingInfo = { TSM.db.global, "neverCraftInks" },
							tooltip = L["If checked, Crafting will never try and craft inks as intermediate crafts."],
						},
						{
							type = "CheckBox",
							label = L["Gather All Professions by Default if Only One Crafter"],
							settingInfo = { TSM.db.factionrealm.gathering, "gatherAll" },
							relativeWidth = 1,
							tooltip = L["If checked, if there is only one crafter for the craft queue clicking gather will gather for all professions for that crafter"],
						},
					},
				},
				{
					type = "Spacer"
				},
				{
					type = "InlineGroup",
					layout = "flow",
					title = L["Inventory Settings"],
					children = {
						{
							type = "Dropdown",
							label = L["Characters (Bags/Bank/AH/Mail) to Ignore:"],
							value = TSM.db.global.ignoreCharacters,
							list = altCharacters,
							relativeWidth = 0.49,
							multiselect = true,
							callback = function(self, _, key, value)
								TSM.db.global.ignoreCharacters[key] = value
							end,
						},
						{
							type = "Dropdown",
							label = L["Guilds (Guild Banks) to Ignore:"],
							value = TSM.db.global.ignoreGuilds,
							list = altGuilds,
							relativeWidth = 0.49,
							multiselect = true,
							callback = function(_, _, key, value)
								TSM.db.global.ignoreGuilds[key] = value
							end,
						},
					},
				},
				{
					type = "Spacer"
				},
				{
					type = "InlineGroup",
					layout = "flow",
					title = L["Default Price Settings"],
					children = {
						{
							type = "EditBox",
							label = L["Default Material Cost Method"],
							settingInfo = {TSM.db.global, "defaultMatCostMethod"},
							relativeWidth = 1,
							acceptCustom = true,
							tooltip = L["This is the default method Crafting will use for determining material cost."],
						},
						{
							type = "EditBox",
							label = L["Default Craft Value Method"],
							settingInfo = {TSM.db.global, "defaultCraftPriceMethod"},
							relativeWidth = 1,
							acceptCustom = "crafting",
							tooltip = L["This is the default method Crafting will use for determining the value of crafted items."],
						},
						{
							type = "Spacer"
						},
						{
							type = "CheckBox",
							label = L["Exclude Crafts with a Cooldown from Craft Cost"],
							settingInfo = { TSM.db.global, "ignoreCDCraftCost" },
							relativeWidth = 1,
							tooltip = L["If checked, if there is more than one way to craft the item then the craft cost will exclude any craft with a daily cooldown when calculating the lowest craft cost."],
						},
					},
				},
			},
		},
	}

	TSMAPI:BuildPage(container, page)
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
					label = L["Show Crafting Cost in Tooltip"],
					settingInfo = { TSM.db.global, "tooltip" },
					callback = function(_, _, value) container:ReloadTab() end,
					tooltip = L["If checked, the crafting cost of items will be shown in the tooltip for the item."],
				},
				{
					type = "CheckBox",
					label = L["Show Material Cost in Tooltip"],
					settingInfo = { TSM.db.global, "materialTooltip" },
					callback = function(_, _, value) container:ReloadTab() end,
					tooltip = L["If checked, the material cost of items will be shown in the tooltip for the item."],
				},
				{
					type = "CheckBox",
					label = L["List Mats in Tooltip"],
					settingInfo = { TSM.db.global, "matsInTooltip" },
					callback = function(_, _, value) container:ReloadTab() end,
					tooltip = L["If checked, the mats needed to craft an item and their prices will be shown in item tooltips."],
				},
			},
		},
	}

	TSMAPI:BuildPage(container, page)
end

function Options:LoadCrafting(parent)
	local tg = AceGUI:Create("TSMTabGroup")
	tg:SetLayout("Fill")
	tg:SetFullHeight(true)
	tg:SetFullWidth(true)
	tg:SetTabs({ { value = 1, text = L["Crafts"] }, { value = 2, text = L["Materials"] } })
	tg:SetCallback("OnGroupSelected", function(self, _, value)
		tg:ReleaseChildren()
		if matST then matST:Hide() end
		if craftST then craftST:Hide() end
		if Options.OpenWindow then Options.OpenWindow:Hide() end
		parent:DoLayout()

		if value == 1 then
			Options:LoadCraftsPage(tg)
		elseif value == 2 then
			Options:LoadMaterialsPage(tg)
		end
		tg.children[1]:DoLayout()
	end)
	tg:SetCallback("OnRelease", function()
			if matST then matST:Hide() end
			if craftST then craftST:Hide() end
			if Options.OpenWindow then Options.OpenWindow:Hide() end
		end)
	parent:AddChild(tg)
	tg:SelectTab(1)
end

function Options:UpdateCraftST()
	if not craftST then return end
	local stData = {}
	local bagTotal, auctionTotal, otherTotal = TSM.Inventory:GetTotals()
	for spellID, data in pairs(TSM.db.factionrealm.crafts) do
		local isFiltered
		local name, link = TSMAPI:GetSafeItemInfo(data.itemID)
	
		if not name or not link or (filters.filter ~= "" and not strfind(strlower(name), strlower(filters.filter))) then
			isFiltered = true
		elseif filters.profession ~= "" and filters.profession ~= data.profession then
			isFiltered = true
		elseif filters.haveMats then
			for itemString, quantity in pairs(data.mats) do
				if (bagTotal[itemString] or 0) < quantity and not TSMAPI:GetVendorCost(itemString) then
					isFiltered = true
					break
				end
			end
		end
		
		if not isFiltered then
			local bags, auctions, other = bagTotal[data.itemID] or 0, auctionTotal[data.itemID] or 0, otherTotal[data.itemID] or 0
			local cost, buyout, profit = TSM.Cost:GetCraftPrices(spellID)
			local percent = profit and floor(100*profit/cost+0.5) or nil
			local operations = TSMAPI:GetItemOperation(data.itemID, "Crafting")
			local operation = operations and operations[1] and TSM.operations[operations[1]] and operations[1] or "---"
			local row = {
				cols = {
					{
						value = data.queued,
						sortArg = data.queued,
					},
					{
						value = link,
						sortArg = strlower(name),
					},
					{
						value = operation,
						sortArg = operation,
					},
					{
						value = bags,
						sortArg = bags,
					},
					{
						value = auctions,
						sortArg = auctions,
					},
					{
						value = other,
						sortArg = other,
					},
					{
						value = TSMAPI:FormatTextMoney(cost) or "---",
						sortArg = cost or -math.huge,
					},
					{
						value = TSMAPI:FormatTextMoney(buyout) or "---",
						sortArg = buyout or -math.huge,
					},
					{
						value = profit and (profit > 0 and TSMAPI:FormatTextMoney(profit, "|cff00ff00") or TSMAPI:FormatTextMoney(-profit, "|cffff0000")) or "---",
						sortArg = profit or -math.huge,
					},
					{
						value = percent and (percent > 0 and "|cff00ff00"..percent.."%|r" or "|cffff0000"..(-percent).."%|r") or "---",
						sortArg = percent or -math.huge,
					},
				},
				name = data.name,
				itemString = data.itemID,
				spellID = spellID,
			}
			tinsert(stData, row)
		end
	end
	craftST:SetData(stData)
end

-- Crafts Page
function Options:LoadCraftsPage(container)
	filters = {filter="", profession="", dpSelection="all", haveMats=nil, queueIncr=1}

	local professionList = { [""] = L["<None>"] }
	for _, data in pairs(TSM.db.factionrealm.crafts) do
		professionList[data.profession] = data.profession
	end

	local page = {
		{
			type = "SimpleGroup",
			layout = "Flow",
			children = {
				{
					type = "EditBox",
					label = L["Search"],
					relativeWidth = 0.3,
					onTextChanged = true,
					callback = function(_, _, value)
						filters.filter = TSMAPI:StrEscape(strlower(value:trim()))
						Options:UpdateCraftST()
					end,
				},
				{
					type = "Dropdown",
					label = L["Profession Filter"],
					relativeWidth = 0.2,
					list = professionList,
					settingInfo = {filters, "profession"},
					callback = Options.UpdateCraftST,
				},
				{
					type = "CheckBox",
					label = L["Have Mats"],
					relativeWidth = 0.19,
					settingInfo = {filters, "haveMats"},
					callback = Options.UpdateCraftST,
					tooltip = L["If checked, only crafts which you can craft with items in your bags (ignoring vendor items) will be shown below."],
				},
				{
					type = "Slider",
					label = L["Queue Increment"],
					relativeWidth = 0.29,
					settingInfo = {filters, "queueIncr"},
					min = 1,
					max = 20,
					step = 1,
					tooltip = L["This slider sets the quantity to add/remove from the queue when left/right clicking on a row below."],
				},
				{
					type = "Label",
					text = L["You can left/right click on a row to add/remove a craft from the crafting queue."],
					relativeWidth = 1,
				},
				{
					type = "HeadingLine",
				},
				{
					type = "SimpleGroup",
					fullHeight = true,
					layout = "flow",
					children = {},
				},
			},
		},
	}

	TSMAPI:BuildPage(container, page)

	local stParent = container.children[1].children[#container.children[1].children].frame
	if not craftST then
		local cols = {
			{
				name = L["Queue"],
				width = 0.06,
				align = "CENTER",
				headAlign = "CENTER",
			},
			{
				name = L["Craft Name"],
				width = 0.22,
				align = "LEFT",
				headAlign = "CENTER",
			},
			{
				name = L["Operation Name"],
				width = 0.15,
				align = "CENTER",
				headAlign = "CENTER",
			},
			{
				name = L["Bags"],
				width = 0.05,
				align = "CENTER",
				headAlign = "CENTER",
			},
			{
				name = L["AH"],
				width = 0.05,
				align = "CENTER",
				headAlign = "CENTER",
			},
			{
				name = L["Other"],
				width = 0.05,
				align = "CENTER",
				headAlign = "CENTER",
			},
			{
				name = L["Crafting Cost"],
				width = 0.12,
				align = "LEFT",
				headAlign = "CENTER",
			},
			{
				name = L["Item Value"],
				width = 0.12,
				align = "LEFT",
				headAlign = "CENTER",
			},
			{
				name = L["Profit"],
				width = 0.12,
				align = "LEFT",
				headAlign = "CENTER",
			},
			{
				name = "%",
				width = 0.06,
				align = "LEFT",
				headAlign = "CENTER",
			},
		}
		local handlers = {
			OnClick = function(st, data, self, button)
				if not data then return end
				local craft = TSM.db.factionrealm.crafts[data.spellID]
				if button == "LeftButton" then
					craft.queued = craft.queued + filters.queueIncr
				elseif button == "RightButton" then
					craft.queued = max(craft.queued - filters.queueIncr, 0)
				end
				data.cols[1].value = craft.queued
				data.cols[1].sortArg = craft.queued
				st.updateSort = true
				st:RefreshRows()
				craftST = nil
				TSM.CraftingGUI:UpdateQueue()
				craftST = st
			end,
			OnEnter = function(_, data, self)
				if not data then return end

				GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
				TSMAPI:SafeTooltipLink(data.itemString)
				GameTooltip:Show()
			end,
			OnLeave = function()
				GameTooltip:ClearLines()
				GameTooltip:Hide()
			end
		}
		TSMAPI:CreateTimeDelay(0, function()
				craftST = TSMAPI:CreateScrollingTable(stParent, cols, handlers)
				craftST:EnableSorting(true, 2)
				craftST:Show()
				craftST:SetParent(stParent)
				craftST:SetAllPoints()
				Options:UpdateCraftST()
			end)
	else
		craftST:Show()
		craftST:SetParent(stParent)
		craftST:SetAllPoints()
		Options:UpdateCraftST()
	end
end

function Options:ResetDefaultPrice()
	for itemString, data in pairs(TSM.db.factionrealm.mats) do
		if data.customValue then
			data.customValue = nil
		end
	end
	Options:UpdateMatST()
end

function Options:UpdateMatST()
	local items = {}
	for _, data in pairs(TSM.db.factionrealm.crafts) do
		if filters.ddSelection == "none" or data.profession == filters.ddSelection then
			for itemString in pairs(data.mats) do
				if filters.dpSelection == "all" or (filters.dpSelection == "default" and not TSM.db.factionrealm.mats[itemString].customValue) or (filters.dpSelection == "custom" and TSM.db.factionrealm.mats[itemString].customValue) then
					if TSM.db.factionrealm.mats[itemString] and TSM.db.factionrealm.mats[itemString].name then -- sanity check
						items[itemString] = TSM.db.factionrealm.mats[itemString].name
					end
				end
			end
		end
	end


	local stData = {}
	local inventoryTotals = select(4, TSM.Inventory:GetTotals())
	for itemString, name in pairs(items) do
		if strfind(strlower(name), filters.filter) then
			local professions = {}
			local professionList = {}
			for _, data in pairs(TSM.db.factionrealm.crafts) do
				if data.mats[itemString] then
					if not professions[data.profession] then
						professions[data.profession] = true
						tinsert(professionList, data.profession)
					end
				end
			end
			sort(professionList)
			local professionsUsed = table.concat(professionList, ",")

			local mat = TSM.db.factionrealm.mats[itemString]
			local cost = TSM:GetCustomPrice(mat.customValue or TSM.db.global.defaultMatCostMethod, itemString) or 0
			local quantity = inventoryTotals[itemString] or 0
			tinsert(stData, {
				cols = {
					{
						value = select(2, TSMAPI:GetSafeItemInfo(itemString)) or name,
						sortArg = name,
					},
					{
						value = cost > 0 and TSMAPI:FormatTextMoney(cost) or "---",
						sortArg = cost,
					},
					{
						value = professionsUsed,
						sortArg = professionsUsed,
					},
					{
						value = quantity,
						sortArg = quantity,
					},
				},
				itemString = itemString,
				name = name,
			})
		end
	end

	sort(stData, function(a, b) return a.name < b.name end) -- sort rows by the item name
	matST:SetData(stData)
end

-- Materials Page
function Options:LoadMaterialsPage(container)
	filters = {filter="", ddSelection="none", dpSelection="all"}

	local ddList = { ["none"] = L["<None>"] }
	for _, data in pairs(TSM.db.factionrealm.crafts) do
		ddList[data.profession] = data.profession
	end

	local dpList = { ["all"] = L["All"], ["default"] = L["Default Price"], ["custom"] = L["Custom Price"] }

	local page = {
		{
			type = "SimpleGroup",
			layout = "Flow",
			children = {
				{
					type = "EditBox",
					label = L["Search"],
					relativeWidth = 0.41,
					onTextChanged = true,
					callback = function(_, _, value)
						filters.filter = TSMAPI:StrEscape(strlower(value:trim()))
						Options:UpdateMatST()
					end,
				},
				{
					type = "Dropdown",
					label = L["Profession Filter"],
					relativeWidth = 0.29,
					list = ddList,
					value = "none",
					callback = function(_, _, value)
						filters.ddSelection = value
						Options:UpdateMatST()
					end,
				},
				{
					type = "Dropdown",
					label = L["Price Source Filter"],
					relativeWidth = 0.29,
					list = dpList,
					value = "all",
					callback = function(_, _, value)
						filters.dpSelection = value
						Options:UpdateMatST()
					end,
				},
				{
					type = "Button",
					text = L["Reset All Custom Prices to Default"],
					relativeWidth = .5,
					callback = function(self)
						StaticPopupDialogs["TSM_CRAFTING_RESET_MAT_PRICES"] = StaticPopupDialogs["TSM_CRAFTING_RESET_MAT_PRICES"] or {
							text = L["Are you sure you want to reset all material prices to the default value?"],
							button1 = YES,
							button2 = CANCEL,
							timeout = 0,
							hideOnEscape = true,
							OnAccept = Options.ResetDefaultPrice,
							preferredIndex = 3,
						}
						TSMAPI:ShowStaticPopupDialog("TSM_CRAFTING_RESET_MAT_PRICES")
					end,
					tooltip = L["Reset all Custom Prices to Default Price Source."],
				},
				{
					type = "Label",
					text = L["You can click on one of the rows of the scrolling table below to view or adjust how the price of a material is calculated."],
					relativeWidth = 1,
				},
				{
					type = "HeadingLine",
				},
				{
					type = "SimpleGroup",
					fullHeight = true,
					layout = "flow",
					children = {},
				},
			},
		},
	}

	TSMAPI:BuildPage(container, page)

	local stParent = container.children[1].children[#container.children[1].children].frame
	if not matST then
		local matCols = {
			{
				name = L["Item Name"],
				width = 0.3,
				align = "LEFT",
				headAlign = "LEFT",
			},
			{
				name = L["Mat Price"],
				width = 0.12,
				align = "LEFT",
				headAlign = "LEFT",
			},
			{
				name = L["Professions Used In"],
				width = 0.45,
				align = "LEFT",
				headAlign = "LEFT",
			},
			{
				name = L["Number Owned"],
				width = 0.12,
				align = "LEFT",
				headAlign = "LEFT",
			},
		}
		local handlers = {
			OnClick = function(_, data, self)
				if not data then return end
				Options:ShowMatOptionsWindow(self, data.itemString)
			end,
			OnEnter = function(_, data, self)
				if not data then return end

				GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
				TSMAPI:SafeTooltipLink(data.itemString)
				GameTooltip:Show()
			end,
			OnLeave = function()
				GameTooltip:ClearLines()
				GameTooltip:Hide()
			end
		}
		matST = TSMAPI:CreateScrollingTable(stParent, matCols, handlers)
		matST:EnableSorting(true)
	end
	Options:UpdateMatST()
	matST:Show()
	matST:SetParent(stParent)
	matST:SetAllPoints()
end

-- Material Options Window
function Options:ShowMatOptionsWindow(parent, itemString)
	if Options.OpenWindow then Options.OpenWindow:Hide() end
	local mat = TSM.db.factionrealm.mats[itemString]
	if not mat then return end
	local link = select(2, TSMAPI:GetSafeItemInfo(itemString)) or mat.name
	local cost = TSM:GetCustomPrice(mat.customValue or TSM.db.global.defaultMatCostMethod, itemString) or 0

	local window = AceGUI:Create("TSMWindow")
	window.frame:SetParent(parent)
	window.frame:SetFrameStrata("FULLSCREEN_DIALOG")
	window:SetWidth(600)
	window:SetHeight(545)
	window:SetTitle(L["Material Cost Options"])
	window:SetLayout("Flow")
	window.frame:SetPoint("CENTER", UIParent, "CENTER", 0, 100)
	window:SetCallback("OnClose", function(self)
		self:ReleaseChildren()
		Options.OpenWindow = nil
		window.frame:Hide()
		Options:UpdateMatST()
	end)
	Options.OpenWindow = window

	local RefreshPage

	local page = {
		{
			type = "InteractiveLabel",
			text = link,
			fontObject = GameFontHighlight,
			relativeWidth = 0.6,
			callback = function() SetItemRef(itemString, itemString) end,
			tooltip = itemString,
		},
		{
			type = "Label",
			text = TSMAPI.Design:GetInlineColor("link") .. L["Price:"] .. " |r" .. (TSMAPI:FormatTextMoneyIcon(cost) or "---"),
			relativeWidth = 0.39,
		},
		{
			type = "HeadingLine",
		},
		{
			type = "ScrollFrame",
			layout = "Flow",
			fullHeight = true,
			children = {},
		},
	}

	TSMAPI:BuildPage(window, page)

	local function GetMoneyText(copperValue, additionalRequirement)
		if additionalRequirement ~= false then
			return TSMAPI:FormatTextMoney(copperValue) or "---"
		else
			return TSMAPI:FormatTextMoney(copperValue, "|cff777777", nil, nil, true) or "---"
		end
	end


	local sPage = {
		{
			type = "SimpleGroup",
			layout = "Flow",
			children = {
				{
					type = "Label",
					text = L["Here you can view and adjust how Crafting is calculating the price for this material."],
					relativeWidth = 1,
				},
				{
					type = "HeadingLine",
				},
				{
					type = "EditBox",
					value = TSMAPI:FormatTextMoney(mat.customValue) or mat.customValue or TSM.db.global.defaultMatCostMethod,
					label = L["Custom Price per Item"],
					relativeWidth = 1,
					acceptCustom = true,
					callback = function(self, _, value)
						mat.customValue = value
						Options:ShowMatOptionsWindow(parent, itemString)
					end,
					tooltip = L["Custom Price for this item."],
				},
				{
					type = "Spacer",
				},
				{
					type = "Button",
					text = L["Reset to Default"],
					relativeWidth = .5,
					callback = function(self)
						mat.customValue = nil
						Options:ShowMatOptionsWindow(parent, itemString)
					end,
					tooltip = L["Resets the material price for this item to the defualt value."],
				},
			},
		},
	}

	if window.children[4] then
		window.children[4]:ReleaseChildren()
	end
	TSMAPI:BuildPage(window.children[4], sPage)
end