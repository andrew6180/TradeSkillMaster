-- ------------------------------------------------------------------------------ --
--                            TradeSkillMaster_Mailing                            --
--            http://www.curse.com/addons/wow/tradeskillmaster_mailing            --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

local TSM = select(2, ...)
local Options = TSM:NewModule("Options", "AceEvent-3.0")
local AceGUI = LibStub("AceGUI-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster_Mailing") -- loads the localization table

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
							text = L["Mailing operations contain settings for easy mailing of items to other characters."],
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
								TSMAPI:NewOperationCallback("Mailing", currentGroup, name)
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
			TSMAPI:UpdateOperation("Mailing", operationName)
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
					title = L["Operation Settings"],
					children = {
						{
							type = "EditBox",
							label = L["Target Player"],
							settingInfo = {operationSettings, "target"},
							autoComplete = AUTOCOMPLETE_LIST.MAIL,
							relativeWidth = 0.5,
							disabled = operationSettings.relationships.target,
							tooltip = L["The name of the player you want to mail items to."].."\n\n"..TSM.SPELLING_WARNING,
						},
						{
							type = "Slider",
							label = L["Keep Quantity"],
							settingInfo = {operationSettings, "keepQty"},
							relativeWidth = 0.5,
							disabled = operationSettings.relationships.keepQty,
							min = 0,
							max = 500,
							step = 1,
							tooltip = L["Mailing will keep this number of items in the current player's bags and not mail them to the target."],
						},
						{
							type = "HeadingLine"
						},
						{	-- first line of text
							type = "CheckBox",
							label = L["Set Max Quantity"],
							settingInfo = {operationSettings, "maxQtyEnabled"},
							disabled = operationSettings.relationships.maxQtyEnabled,
							callback = function() Options.treeGroup:SelectByPath(2, operationName) end,
							tooltip = L["If checked, a maximum quantity to send to the target can be set. Otherwise, Mailing will send as many as it can."],
						},
						{
							type = "Slider",
							label = L["Maximum Quantity"],
							settingInfo = {operationSettings, "maxQty"},
							disabled = not operationSettings.maxQtyEnabled or operationSettings.relationships.maxQty,
							relativeWidth = 0.5,
							min = 1,
							max = 500,
							step = 1,
							tooltip = L["Sets the maximum quantity of each unique item to send to the target at a time."],
						},
						{
							type = "CheckBox",
							label = L["Restock Target to Max Quantity"],
							settingInfo = {operationSettings, "restock"},
							disabled = not operationSettings.maxQtyEnabled or operationSettings.relationships.restock,
							callback = function() Options.treeGroup:SelectByPath(2, operationName) end,
							tooltip = L["If checked, the target's current inventory will be taken into account when determing how many to send. For example, if the max quantity is set to 10, and the target already has 3, Mailing will send at most 7 items."],
						},
						{
							type = "CheckBox",
							label = L["Include Guild Bank in Restock"],
							settingInfo = {operationSettings, "restockGBank"},
							disabled = not operationSettings.restock or operationSettings.relationships.restockGBank,
							tooltip = L["If checked, the target's guild bank will be included in their inventory for the 'Restock Target to Max Quantity' option."],
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
			{key="target", label=L["Target Player"]},
			{key="keepQty", label=L["Keep Quantity"]},
			{key="maxQtyEnabled", label=L["Set Max Quantity"]},
			{key="maxQty", label=L["Maximum Quantity"]},
			{key="restock", label=L["Restock Target to Max Quantity"]},
			{key="restockGBank", label=L["Include Guild Bank in Restock"]},
		},
	}
	TSMAPI:ShowOperationRelationshipTab(TSM, container, TSM.operations[operationName], settingInfo)
end

function Options:LoadGeneralSettings(container)
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
					relativeWidth = 1,
					children = {
						{
							type = "CheckBox",
							label = L["Make Mailing Default Mail Tab"],
							settingInfo = {TSM.db.global, "defaultMailTab"},
							tooltip = L["If checked, the Mailing tab of the mailbox will be the default tab."],
						},
						{
							type = "Dropdown",
							label = L["Default Mailing Page"],
							relativeWidth = 0.49,
							list = {L["Inbox"], L["TSM Groups"], L["Quick Send"], L["Other"]},
							settingInfo = {TSM.db.global, "defaultPage"},
							tooltip = L["Specifies the default page that'll show when you select the TSM_Mailing tab."],
						},
						{
							type = "CheckBox",
							label = L["Auto Recheck Mail"],
							settingInfo = {TSM.db.global, "autoCheck"},
							tooltip = L["Automatically rechecks mail every 60 seconds when you have too much mail.\n\nIf you loot all mail with this enabled, it will wait and recheck then keep auto looting."],
						},
						{
							type = "CheckBox",
							label = L["Show Reload UI Button"],
							settingInfo = {TSM.db.global, "showReloadBtn"},
							tooltip = L["If checked, a 'Reload UI' button will be shown while waiting for the inbox to refresh. Reloading will cause the mailbox to refresh and may be faster than waiting for the next refresh."],
						},
						{
							type = "CheckBox",
							label = L["Leave Gold with Open All"],
							settingInfo = {TSM.db.global, "openAllLeaveGold"},
							tooltip = L["If checked, the 'Open All' button will leave any mail containing gold."],
						},
						{
							type = "CheckBox",
							label = L["Send Items Individually"],
							settingInfo = {TSM.db.global, "sendItemsIndividually"},
							tooltip = L["Sends each unique item in a seperate mail."],
						},
						{
							type = "Slider",
							value = TSM.db.global.sendDelay,
							label = L["Mail Send Delay"],
							min = 0.1,
							max = 2,
							step = 0.1,
							relativeWidth = 0.49,
							disabled = not TSM.db.global.sendDelay,
							callback = function(self,_,value)
								if value < 0.1 then value = 0.1 end
								if value > 2 then value = 2 end
								self:SetValue(value)
								TSM.db.global.sendDelay = value
							end,
							tooltip = L["This slider controls how long the mail sending code waits between consecutive mails. If this is set too low, you will run into internal mailbox errors."],
						},
						{
							type = "Slider",
							value = TSM.db.global.resendDelay,
							label = L["Restart Delay (minutes)"],
							min = 0.5,
							max = 10,
							step = 0.5,
							relativeWidth = 0.49,
							disabled = not TSM.db.global.resendDelay,
							callback = function(self,_,value)
								if value < 0.5 then value = 0.5 end
								if value > 10 then value = 10 end
								self:SetValue(value)
								TSM.db.global.resendDelay = value
							end,
							tooltip = L["When you shift-click a send mail button, after the initial send, it will check for new items to send at this interval."],
						},
						{
							type = "Slider",
							value = TSM.db.global.keepMailSpace,
							label = L["Keep Free Bag Space"],
							min = 0,
							max = 20,
							step = 1,
							relativeWidth = 0.49,
							callback = function(self,_,value)
								TSM.db.global.keepMailSpace = value
							end,
							tooltip = L["This slider controls how much free space to keep in your bags when looting from the mailbox. This only applies to bags that any item can go in."],
						},
					},
				},
				{
					type = "InlineGroup",
					layout = "flow",
					title = L["Chat Message Options"],
					relativeWidth = 1,
					children = {
						{
							type = "CheckBox",
							label = L["Enable Inbox Chat Messages"],
							settingInfo = {TSM.db.global, "inboxMessages"},
							tooltip = L["If checked, information on mails collected by TSM_Mailing will be printed out to chat."],
						},
						{
							type = "CheckBox",
							label = L["Display Total Money Received"],
							settingInfo = {TSM.db.global, "displayMoneyCollected"},
							tooltip = L["If checked, the total amount of gold received will be shown at the end of automatically collecting mail."],
						},
						{
							type = "CheckBox",
							label = L["Enable Sending Chat Messages"],
							settingInfo = {TSM.db.global, "sendMessages"},
							tooltip = L["If checked, information on mails sent by TSM_Mailing will be printed out to chat."],
						},
					},
				},
			},
		},
	}

	TSMAPI:BuildPage(container, page)
end