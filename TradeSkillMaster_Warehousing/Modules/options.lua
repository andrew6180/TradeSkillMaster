-- ------------------------------------------------------------------------------ --
--                          TradeSkillMaster_Warehousing                          --
--          http://www.curse.com/addons/wow/tradeskillmaster_warehousing          --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- load the parent file (TSM) into a local variable and register this file as a module
local TSM = select(2, ...)
local Options = TSM:NewModule("Options", "AceEvent-3.0", "AceHook-3.0")
local AceGUI = LibStub("AceGUI-3.0") -- load the AceGUI libraries

local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster_Warehousing") -- loads the localization table

local function getHelpString1()
	return
	L["Warehousing will try to get the right number of items, if there are not enough in the bank to fill out the order, it will grab all that there is."]
end

local function getHelpString2()
	return
	L["1) Select Operations on the left menu and type a name in the textbox labeled \"Operation Name\", hit okay"] .. "\n" ..
			L["2) You can delete an operation by selecting the operation and then under Operation Management click the button labelled \"Delete Operation\". "]
end

local function getHelpString3()
	return
	L["Simply hit empty bags, warehousing will remember what you had so that when you hit restore, it will grab all those items again. If you hit empty bags while your bags are empty it will overwrite the previous bag state, so you will not be able to use restore."]
end

local function getHelpString4()
	return
	L["1) Open up a bank (either the gbank or personal bank)"] .. "\n" ..
	L["2) You should see a window on your right with a list of groups"] .. "\n" ..
	format(L["3) Select one or more groups and hit either %s or %s"], "\"" .. L["Move Group To Bank"] .. "\"", "\"" .. L["Move Group To Bags"] .. "\"")
end

local function getHelpString5()
	return
	L["You can use the following slash commands to get items from or put items into your bank or guildbank."] .. "\n" ..
	L["/tsm get/put X Y - X can be either an itemID, ItemLink (shift-click item) or partial text. Y is optionally the quantity you want to move."] .. "\n\n" ..
	L["Example 1: /tsm get glyph 20 - get up to 20 of each item in your bank/guildbank where the name contains" .. "\"" .. "glyph" .. "\"" .. " and place them in your bags."] .. "\n\n" ..
	L["Example 2: /tsm put 74249 - get all of item 74249 (Spirit Dust) from your bags and put them in your bank/guildbank"]
end

local function getHelpString6()
	return
	L["You can toggle the Bank UI by typing the command "] .. "/tsm bankui "
end

local function CreateOperation(name)
	TSM.operations[name] = CopyTable(TSM.operationDefaults)
end

local function DeleteOperation(name)
	TSM.operations[name] = nil
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

	Options.treeGroup:SetTree({ { value = 1, text = L["Help"] }, { value = 2, text = L["Operations"], children = operationTreeChildren } })
end

function Options:SelectTree(treeGroup, _, selection)
	treeGroup:ReleaseChildren()

	local major, minor = ("\001"):split(selection)
	major = tonumber(major)
	if major == 1 then
		Options:DrawHelp(treeGroup)
	elseif minor then
		Options:DrawOperationSettings(treeGroup, minor)
	else
		Options:DrawNewOperation(treeGroup)
	end
end

function Options:DrawHelp(container)
	local page = {
		{
			type = "ScrollFrame",
			layout = "List",
			children = {
				{
					type = "InlineGroup",
					layout = "flow",
					title = "TSM_Warehousing",
					children = {
						{
							type = "Label",
							text = getHelpString1(),
							relativeWidth = 1,
						},
					},
				},
				{
					type = "Spacer",
				},
				{
					type = "InlineGroup",
					layout = "flow",
					title = L["To create a Warehousing Operation"],
					children = {
						{
							type = "Label",
							text = getHelpString2(),
							relativeWidth = 1,
						},
					},
				},
				{
					type = "Spacer",
				},
				{
					type = "InlineGroup",
					layout = "flow",
					title = L["Empty Bags/Restore Bags"],
					children = {
						{
							type = "Label",
							text = getHelpString3(),
							relativeWidth = 1,
						},
					},
				},
				{
					type = "Spacer",
				},
				{
					type = "InlineGroup",
					layout = "flow",
					title = L["To move a Group"],
					children = {
						{
							type = "Label",
							text = getHelpString4(),
							relativeWidth = 1,
						},
					},
				},
				{
					type = "Spacer",
				},
				{
					type = "InlineGroup",
					layout = "flow",
					title = L["Slash Commands"],
					children = {
						{
							type = "Label",
							text = getHelpString5(),
							relativeWidth = 1,
						},
					},
				},
				{
					type = "InlineGroup",
					layout = "flow",
					title = L["Bank UI"],
					children = {
						{
							type = "Label",
							text = getHelpString6(),
							relativeWidth = 1,
						},
					},
				}
			}
		}
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
							text = L["Warehousing operations contain settings for moving the items in a group. Type the name of the new operation into the box below and hit 'enter' to create a new Warehousing operation."],
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
								CreateOperation(name)
								Options:UpdateTree()
								Options.treeGroup:SelectByPath(2, name)
								TSMAPI:NewOperationCallback("Warehousing", currentGroup, name)
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
			TSMAPI:UpdateOperation("Warehousing", operationName)
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
					title = L["Move Quantity Settings"],
					children = {
						{
							type = "CheckBox",
							label = L["Set Move Quantity"],
							relativeWidth = 0.35,
							settingInfo = {operationSettings, "moveQtyEnabled"},
							callback = function() container:ReloadTab() end,
							tooltip = L["Enable this to set the quantity to move, if disabled Warehousing will move all of the item"],
						},
						{
							-- slider to set the move quantity
							type = "Slider",
							settingInfo = {operationSettings, "moveQuantity"},
							label = L["Move Quantity"],
							disabled = not operationSettings.moveQtyEnabled,
							isPercent = false,
							min = 1,
							max = 5000,
							step = 1,
							relativeWidth = 0.65,
							tooltip = L["Warehousing will move this number of each item"],
						},
						{
							type = "Spacer",
						},
						{
							type = "CheckBox",
							label = L["Set Stack Size for bags"],
							relativeWidth = 0.35,
							settingInfo = {operationSettings, "stackSizeEnabled"},
							callback = function() container:ReloadTab() end,
							tooltip = L["Enable this to set the stack size multiple to be moved"],
						},
						{
							-- slider to set the move quantity
							type = "Slider",
							settingInfo = {operationSettings, "stackSize"},
							label = L["Stack Size Multiple"],
							disabled = not operationSettings.stackSizeEnabled,
							isPercent = false,
							min = 1,
							max = 200,
							step = 1,
							relativeWidth = 0.65,
							tooltip = L["Warehousing will only move items in multiples of the stack size set when moving to your bags, this is useful for milling/prospecting etc to ensure you don't move items you can't process"],
						},
						{
							type = "Spacer",
						},
						{
							type = "CheckBox",
							settingInfo = {operationSettings, "keepBagQtyEnabled"},
							label = L["Set Keep in Bags Quantity"],
							relativeWidth = 0.35,
							callback = function() container:ReloadTab() end,
							tooltip = L["Enable this to set the quantity to keep back in your bags"],
						},
						{
							-- slider to set the keep bags qty
							type = "Slider",
							settingInfo = {operationSettings, "keepBagQuantity"},
							label = L["Keep in Bags Quantity"],
							disabled = not operationSettings.keepBagQtyEnabled,
							isPercent = false,
							min = 1,
							max = 5000,
							step = 1,
							relativeWidth = 0.65,
							tooltip = L["Warehousing will ensure this number remain in your bags when moving items to the bank / guildbank."],
						},
						{
							type = "Spacer",
						},
						{
							type = "CheckBox",
							settingInfo = {operationSettings, "keepBankQtyEnabled"},
							label = L["Set Keep in Bank Quantity"],
							relativeWidth = 0.35,
							callback = function() container:ReloadTab() end,
							tooltip = L["Enable this to set the quantity to keep back in your bank / guildbank"],
						},
						{
							-- slider to set the keep bank qty
							type = "Slider",
							settingInfo = {operationSettings, "keepBankQuantity"},
							label = L["Keep in Bank/GuildBank Quantity"],
							disabled = not operationSettings.keepBankQtyEnabled,
							isPercent = false,
							min = 1,
							max = 5000,
							step = 1,
							relativeWidth = 0.65,
							tooltip = L["Warehousing will ensure this number remain in your bank / guildbank when moving items to your bags."],
						},
					},
				},
				{
					type = "Spacer",
				},
				{
					type = "InlineGroup",
					layout = "flow",
					title = L["Restock Settings"],
					children = {
						{
							type = "CheckBox",
							settingInfo = {operationSettings, "restockQtyEnabled"},
							label = L["Enable Restock"],
							relativeWidth = 0.25,
							callback = function() container:ReloadTab() end,
							tooltip = L["Enable this to set the restock quantity"],
						},
						{
							-- slider to set the move quantity
							type = "Slider",
							settingInfo = {operationSettings, "restockQuantity"},
							label = L["Restock Quantity"],
							disabled = not operationSettings.restockQtyEnabled,
							isPercent = false,
							min = 1,
							max = 5000,
							step = 1,
							relativeWidth = 0.75,
							tooltip = L["Warehousing will restock your bags up to this number of items"],
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
			label = L["Move Quantity Settings"],
			{key="moveQtyEnabled", label=L["Set Move Quantity"]},
			{key="moveQuantity", label=L["Move Quantity"]},
			{key="keepBagQtyEnabled", label=L["Set Keep in Bags Quantity"]},
			{key="keepBagQuantity", label=L["Keep in Bags Quantity"]},
			{key="keepBankQtyEnabled", label=L["Set Keep in Bank Quantity"]},
			{key="keepBankQuantity", label=L["Keep in Bank/GuildBank Quantity"]},
		},
		{
			label = L["Restock Settings"],
			{key="restockQtyEnabled", label=L["Enable Restock"]},
			{key="restockQuantity", label=L["Restock Quantity"]},
		},
	}
	TSMAPI:ShowOperationRelationshipTab(TSM, container, TSM.operations[operationName], settingInfo)
end