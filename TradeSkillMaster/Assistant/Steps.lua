-- ------------------------------------------------------------------------------ --
--                                TradeSkillMaster                                --
--                http://www.curse.com/addons/wow/tradeskill-master               --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

local TSM = select(2, ...)
local Assistant = TSM.modules.Assistant
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster") -- loads the localization table
local private = {stepData = {recentEvents = {}}}
TSMAPI:RegisterForTracing(private, "TradeSkillMaster.Steps_private")
local eventObj = TSMAPI:GetEventObject()

function Assistant:ClearStepData()
	private.stepData = {recentEvents={}}
end

function private.OnEvent(event, arg)
	if not private.stepData then return end
	local order = (private.stepData.recentEvents._order or 0) + 1
	private.stepData.recentEvents[event] = {arg=arg, order=order}
	private.stepData.recentEvents._order = order
end
eventObj:SetCallbackAnyEvent(private.OnEvent)

function private:IsTSMFrameIconSelected(iconText)
	local path = TSM:GetTSMFrameSelectionPath()
	return path and path[1].value == iconText
end
function private:GetPathLevelValue(iconText, level)
	local path = TSM:GetTSMFrameSelectionPath()
	return path and path[1] and path[1].value == iconText and path[level] and path[level].value
end
function private:GetGroupTreeSelection()
	return private:GetPathLevelValue(L["Groups"], 2)
end
function private:GetGroupTab()
	local temp = private:GetPathLevelValue(L["Groups"], 2)
	return temp and temp[#temp] == private.stepData.selectedGroup and private:GetPathLevelValue(L["Groups"], 3)
end
function private:GetOperationModuleSelection()
	return private:GetPathLevelValue(L["Module Operations / Options"], 2)
end
function private:GetOperationTreeSelection(module)
	if private:GetOperationModuleSelection() ~= module then return end
	return private:GetPathLevelValue(L["Module Operations / Options"], 3)
end
function private:GetOperationTab(module)
	if not private:GetOperationTreeSelection(module) then return end
	local temp = private:GetPathLevelValue(L["Module Operations / Options"], 3)
	return temp and temp and temp[#temp] == private.stepData.selectedOperation and private:GetPathLevelValue(L["Module Operations / Options"], 4)
end

function private:GetIsDoneStep(title, description, isDoneFunc)
	local step = {
			title = title,
			description = description,
			doneButton = L["I'm done."],
			isDone = function(self) return private.stepData[self] and (not isDoneFunc or isDoneFunc()) end,
			onDoneButtonClicked = function(self) private.stepData[self] = true end,
			isCheckPoint = true
	}
	return step
end

function private:GetEventIsDone(targetEvent)
	local function isDone(self)
		if private.stepData[self] then return true end
		if not private.stepData.recentEvents[targetEvent] then return end
		wipe(private.stepData.recentEvents)
		private.stepData[self] = true
		return true
	end
	
	return isDone
end

function private:PrependCreateOperationSteps(tbl, moduleLong, moduleShort, description, operationsIndex)
	local steps = {
		{
			title = L["Go to the 'Operations' Tab"],
			description = format(L["We will add a %s operation to this group through its 'Operations' tab. Click on that tab now."], moduleLong),
			isDone = function() return private:GetGroupTab() == 1 end,
			isCheckPoint = true,
		},
		{
			title = format(L["Create a %s Operation %d/5"], moduleShort, 1),
			description = description,
			isDone = function() return private:GetOperationTreeSelection(moduleShort) end,
		},
		{
			title = format(L["Create a %s Operation %d/5"], moduleShort, 2),
			description = L["Select the 'Operations' page from the list on the left of the TSM window."],
			isDone = function()
				local selection = private:GetOperationTreeSelection(moduleShort)
				if selection and #selection == 1 and selection[1] == tostring(operationsIndex) then
					private.stepData.operationsPageClicked = true
				end
				return private.stepData.operationsPageClicked
			end,
		},
		{
			title = format(L["Create a %s Operation %d/5"], moduleShort, 3),
			description = format(L["Create a new %s operation by typing a name for the operation into the 'Operation Name' box and pressing the <Enter> key."], moduleLong),
			isDone = function()
				local selection = private:GetOperationTreeSelection(moduleShort)
				return selection and #selection > 1 and selection[1] == tostring(operationsIndex)
			end,
		},
		{
			title = format(L["Create a %s Operation %d/5"], moduleShort, 4),
			description = L["Assign this operation to the group you previously created by clicking on the 'Yes' button in the popup that's now being shown."],
			isDone = function()
				for i=1, 100 do
					local popup = _G["StaticPopup"..i]
					if not popup then break end
					if popup:IsVisible() and popup.which == "TSM_NEW_OPERATION_ADD" then
						return
					end
				end
				return true
			end,
		},
		{
			title = format(L["Create a %s Operation %d/5"], moduleShort, 5),
			description = L["Select your new operation in the list of operation along the left of the TSM window (if it's not selected automatically) and click on the button below.\n\nCurrently Selected Operation: %s"],
			getDescArgs = function()
				local selection = private:GetOperationTreeSelection(moduleShort)
				if selection and #selection > 1 then
					return TSMAPI.Design:GetInlineColor("link")..selection[#selection].."|r"
				else
					return TSMAPI.Design:GetInlineColor("link")..L["<No Operation Selected>"].."|r"
				end
			end,
			isDone = function() return private:GetOperationTab(moduleShort) end,
			doneButton = L["My new operation is selected."],
			onDoneButtonClicked = function()
				local selection = private:GetOperationTreeSelection(moduleShort)
				if selection and #selection > 1 then
					private.stepData.selectedOperation = selection[#selection]
				else
					TSM:Print(L["Please select the new operation you've created."])
				end
			end,
			isCheckPoint = true,
		},
	}
	
	-- prepend all the steps to the passed table
	for i, step in ipairs(steps) do
		tinsert(tbl, i, step)
	end
end

local tsmSteps = {
	["notYetImplemented"] = {
		private:GetIsDoneStep(
			"Not Yet Implemented",
			"This step is not yet implemented.\n\nTHIS SHOULD NEVER BE SEEN IN A RELEASE VERSION OF TSM!"
		),
	},
	["openTSM"] = {
		{
			title = L["Open the TSM Window"],
			description = L["Type '/tsm' or click on the minimap icon to open the main TSM window."],
			isDone = function() return TSM:TSMFrameIsVisible() end,
		},
	},
	["openGroups"] = {
		{
			title = L["Click on the Groups Icon"],
			description = L["Along top of the window, on the left side, click on the 'Groups' icon to open up the TSM group settings."],
			isDone = function() return private:IsTSMFrameIconSelected(L["Groups"]) end,
		},
	},
	["newGroup"] = {
		{
			title = L["Go to the 'Groups' Page"],
			description = L["In the list on the left, select the top-level 'Groups' page."],
			isDone = function()
				local selection = private:GetGroupTreeSelection()
				if selection and #selection == 1 and selection[1] == "1" then
					private.stepData.groupsPageClicked = true
				end
				return private.stepData.groupsPageClicked
			end,
		},
		{
			title = L["Create a New Group"],
			description = L["Create a new group by typing a name for the group into the 'Group Name' box and pressing the <Enter> key."],
			isDone = private:GetEventIsDone("TSM:GROUPS:NEWGROUP"),
		},
	},
	["selectGroup"] = {
		{
			title = L["Select Existing Group"],
			description = L["Select the group you'd like to use. Once you have done this, click on the button below.\n\nCurrently Selected Group: %s"],
			getDescArgs = function()
				local selection = private:GetGroupTreeSelection()
				if selection and #selection > 1 then
					return TSMAPI:FormatGroupPath(selection[#selection], true)
				else
					return TSMAPI.Design:GetInlineColor("link")..L["<No Group Selected>"].."|r"
				end
			end,
			isDone = function() return private:GetGroupTab() end,
			doneButton = L["My group is selected."],
			onDoneButtonClicked = function()
				local selection = private:GetGroupTreeSelection()
				if selection and #selection > 1 then
					private.stepData.selectedGroup = selection[#selection]
				else
					TSM:Print(L["Please select the group you'd like to use."])
				end
			end,
		},
	},
	["groupImportItems"] = {
		{
			title = L["Go to the 'Import/Export' Tab"],
			description = L["We will import items into this group using the import list you have."],
			isDone = function() return private:GetGroupTab() == 3 or private.stepData.importedItems end,
		},
		{
			title = L["Enter Import String"],
			description = L["Paste your import string into the 'Import String' box and hit the <Enter> key to import the list of items."],
			isDone = function()
				if private.stepData.importedItems then return true end
				if not private.stepData.recentEvents["TSM:GROUPS:ADDITEMS"] then return end
				local arg = CopyTable(private.stepData.recentEvents["TSM:GROUPS:ADDITEMS"].arg)
				wipe(private.stepData.recentEvents)
				if arg.isImport then
					if arg.num == 0 then
						TSM:Print(L["Looks like no items were imported. This might be because they are already in another group in which case you might consider checking the 'Move Already Grouped Items' box to force them to move to this group."])
					else
						private.stepData.importedItems = true
						return true
					end
				end
			end,
		},
	},
	["groupAddFromBags"] = {
		{
			title = L["Go to the 'Items' Tab"],
			description = L["We will add items to this group through its 'Items' tab. Click on that tab now."],
			isDone = function() return private:GetGroupTab() == 2 or private.stepData.addedItems end,
		},
		{
			title = L["Add Items to this Group"],
			description = L["Select the items you want to add in the left column and then click on the 'Add >>>' button at the top to add them to this group."],
			isDone = function()
				if private.stepData.addedItems then return true end
				if not private.stepData.recentEvents["TSM:GROUPS:ADDITEMS"] then return end
				local arg = CopyTable(private.stepData.recentEvents["TSM:GROUPS:ADDITEMS"].arg)
				wipe(private.stepData.recentEvents)
				if not arg.isImport then
					private.stepData.addedItems = true
					return true
				end
			end,
		},
	},
}

local craftingSteps = {
	["openCrafting"] = {
		{
			title = L["Click on the Crafting Icon"],
			description = L["Along top of the window, on the right side, click on the 'Crafting' icon to open up the TSM_Crafting page."],
			isDone = function() return private:GetPathLevelValue("Crafting", 2) == 1 end,
		},
	},
	["craftingCraftsTab"] = {
		{
			title = L["Select the 'Crafts' Tab"],
			description = L["At the top, switch to the 'Crafts' tab in order to view a list of crafts you can make."],
			isDone = function() return TSM:TSMFrameIsVisible() end,
		},
		private:GetIsDoneStep(
			L["Queue Profitable Crafts"],
			L["You can use the filters at the top of the page to narrow down your search and click on a column to sort by that column. Then, left-click on a row to add one of that item to the queue, and right-click to remove one.\n\nOnce you're done adding items to the queue, click the button below."]
		),
	},
	["openProfession"] = {
		{
			title = L["Open up Your Profession"],
			description = L["Open one of the professions which you would like to use to craft items."],
			isDone = function() return TSMAPI:ModuleAPI("Crafting", "getCraftingFrameStatus") end,
		},
	},
	["useProfessionQueue"] = {
		{
			title = L["Show the Queue"],
			description = L["Click on the 'Show Queue' button at the top of the TSM_Crafting window to show the queue if it's not already visible."],
			isDone = function() local status = TSMAPI:ModuleAPI("Crafting", "getCraftingFrameStatus") return status and status.queue end,
		},
		private:GetIsDoneStep(
			L["Craft Items from Queue"],
			L["You can craft items either by clicking on rows in the queue which are green (meaning you can craft all) or blue (meaning you can craft some) or by clicking on the 'Craft Next' button at the bottom.\n\nClick on the button below when you're done reading this. There is another guide which tells you how to buy mats required for your queue."]
		),
	},
	["craftingOperation"] = {
		{
			title = L["Select the 'General' Tab"],
			description = "Select the 'General' tab within the operation to set the general options for the TSM_Crafting operation.",
			isDone = function() return private:GetOperationTab("Crafting") == 1 end
		},
		private:GetIsDoneStep(
			L["Set Max Restock Quantity"],
			L["The 'Max Restock Quantity' defines how many of each item you want to restock up to when using the restock queue, taking your inventory into account.\n\nOnce you're done adjusting this setting, click the button below."]
		),
		private:GetIsDoneStep(
			L["Set Minimum Profit"],
			L["If you'd like, you can adjust the value in the 'Minimum Profit' box in order to specify the minimum profit before Crafting will queue these items.\n\nOnce you're done adjusting this setting, click the button below."]
		),
		private:GetIsDoneStep(
			L["Set Other Options"],
			L["You can look through the tooltips of the other options to see what they do and decide if you want to change their values for this operation.\n\nOnce you're done, click on the button below."]
		),
	},
	["professionRestock"] = {
		{
			title = L["Switch to the 'TSM Groups' Tab"],
			description = L["Along the top of the TSM_Crafting window, click on the 'TSM Groups' button."],
			isDone = function() local status = TSMAPI:ModuleAPI("Crafting", "getCraftingFrameStatus") return status and status.page == "groups" end,
		},
		{
			title = L["Select Group and Click Restock Button"],
			description = L["First, ensure your new group is selected in the group-tree and then click on the 'Restock Selected Groups' button at the bottom."],
			isDone = function(self)
				if private.stepData[self] then return true end
				if not private.stepData.recentEvents["CRAFTING:QUEUE:RESTOCKED"] then return end
				local arg = private.stepData.recentEvents["CRAFTING:QUEUE:RESTOCKED"].arg
				wipe(private.stepData.recentEvents)
				if arg == 0 then
					TSM:Print(L["Looks like no items were added to the queue. This may be because you are already at or above your restock levels, or there is nothing profitable to queue."])
				else
					private.stepData[self] = true
					return true
				end
			end,
		},
	},
	["craftFromProfession"] = {
		{
			title = L["Switch to the 'Professions' Tab"],
			description = L["Along the top of the TSM_Crafting window, click on the 'Professions' button."],
			isDone = function() local status = TSMAPI:ModuleAPI("Crafting", "getCraftingFrameStatus") return status and status.page == "profession" end,
		},
		private:GetIsDoneStep(
			L["Select the Craft"],
			L["Just like the default profession UI, you can select what you want to craft from the list of crafts for this profession. Click on the one you want to craft.\n\nOnce you're done, click the button below."]
		),
		private:GetIsDoneStep(
			L["Create the Craft"],
			L["You can now use the buttons near the bottom of the TSM_Crafting window to create this craft.\n\nOnce you're done, click the button below."]
		),
	},
}
private:PrependCreateOperationSteps(craftingSteps["craftingOperation"], "TSM_Crafting", "Crafting", L["A TSM_Crafting operation will allow you automatically queue profitable items from the group you just made. To create one for this group, scroll down to the 'Crafting' section, and click on the 'Create Crafting Operation' button."], 2)

local auctioningSteps = {
	["auctioningOperationPost"] = {
		{
			title = L["Select the Post Tab"],
			description = L["Select the 'Post' tab within the operation to set the posting options for the TSM_Auctioning operation."],
			isDone = function() return private:GetOperationTab("Auctioning") == 2 end
		},
		private:GetIsDoneStep(
			L["Set Auction Settings"],
			L["The first set of posting settings are under the 'Auction Settings' header. These control things like stack size and auction duration. Read the tooltips of the individual settings to see what they do and set them appropriately."]
		),
		private:GetIsDoneStep(
			L["Set Auction Price Settings"],
			L["The second set of posting settings are under the 'Auction Price Settings' header. These include the percentage of the buyout which the bid will be set to, and how much you want to undercut by. Read the tooltips of the individual settings to see what they do and set them appropriately."]
		),
		private:GetIsDoneStep(
			L["Set Posting Price Settings"],
			L["The final set of posting settings are under the 'Posting Price Settings' header. These define the price ranges which Auctioning will post your items within. Read the tooltips of the individual settings to see what they do and set them appropriately."]
		),
	},
	["auctioningOperationCancel"] = {
		{
			title = L["Select the Cancel Tab"],
			description = L["Select the 'Cancel' tab within the operation to set the canceling options for the TSM_Auctioning operation."],
			isDone = function() return private:GetOperationTab("Auctioning") == 3 end
		},
		private:GetIsDoneStep(
			L["Set Cancel Settings"],
			L["These settings control when TSM_Auctioning will cancel your auctions. Read the tooltips of the individual settings to see what they do and set them appropriately."]
		),
	},
	["openAuctioningAHTab"] = {
		{
			title = L["Open the Auction House"],
			description = L["Go to the Auction House and open it."],
			isDone = function() return AuctionFrame and AuctionFrame:IsVisible() end,
		},
		{
			title = L["Click on the Auctioning Tab"],
			description = L["Along the bottom of the AH are various tabs. Click on the 'Auctioning' AH tab."],
			isDone = function() return TSMAPI:AHTabIsVisible("Auctioning") end,
		},
	},
	["auctioningPostScan"] = {
		{
			title = L["Select Group and Start Scan"],
			description = L["First, ensure your new group is selected in the group-tree and then click on the 'Start Post Scan' button at the bottom of the tab."],
			isDone = private:GetEventIsDone("AUCTIONING:POST:START"),
		},
	},
	["auctioningCancelScan"] = {
		{
			title = L["Select Group and Start Scan"],
			description = L["First, ensure your new group is selected in the group-tree and then click on the 'Start Cancel Scan' button at the bottom of the tab."],
			isDone = private:GetEventIsDone("AUCTIONING:CANCEL:START"),
		},
	},
	["auctioningWaitForScan"] = {
		{
			title = L["Waiting for Scan to Finish"],
			description = L["Please wait..."],
			isDone = private:GetEventIsDone("AUCTIONING:SCANDONE"),
		},
		private:GetIsDoneStep(
			L["Act on Scan Results"],
			L["Now that the scan is finished, you can look through the results shown in the log, and for each item, decide what action you want to take.\n\nOnce you're done, click on the button below."]
		),
	},
}
private:PrependCreateOperationSteps(auctioningSteps["auctioningOperationPost"], "TSM_Auctioning", "Auctioning", L["A TSM_Auctioning operation will allow you to set rules for how auctionings are posted/canceled/reset on the auction house. To create one for this group, scroll down to the 'Auctioning' section, and click on the 'Create Auctioning Operation' button."], 3)
private:PrependCreateOperationSteps(auctioningSteps["auctioningOperationCancel"], "TSM_Auctioning", "Auctioning", L["A TSM_Auctioning operation will allow you to set rules for how auctionings are posted/canceled/reset on the auction house. To create one for this group, scroll down to the 'Auctioning' section, and click on the 'Create Auctioning Operation' button."], 3)

local shoppingSteps = {
	["shoppingOperation"] = {
		{
			title = L["Select the 'General' Tab"],
			description = L["Select the 'General' tab within the operation to set the general options for the TSM_Shopping operation."],
			isDone = function() return private:GetOperationTab("Shopping") == 1 end
		},
		private:GetIsDoneStep(
			L["Set a Maximum Price"],
			L["The 'Maxium Auction Price (per item)' is the most you want to pay for the items you've added to your group. If you're not sure what to set this to and have TSM_AuctionDB installed (and it contains data from recent scans), you could try '90% dbmarket' for this option.\n\nOnce you're done adjusting this setting, click the button below."]
		),
		private:GetIsDoneStep(
			L["Set Other Options"],
			L["You can look through the tooltips of the other options to see what they do and decide if you want to change their values for this operation.\n\nOnce you're done, click on the button below."]
		),
	},
	["openShoppingOptions"] = {
		{
			title = L["Click on the Module Operations / Options Icon"],
			description = L["Along top of the window, on the left side, click on the 'Module Operations / Options' icon to open up the TSM module settings."],
			isDone = function() return private:IsTSMFrameIconSelected(L["Module Operations / Options"]) end,
		},
		{
			title = L["Click on the Shopping Tab"],
			description = L["Select the 'Shopping' tab to open up the settings for TSM_Shopping."],
			isDone = function() return private:GetOperationModuleSelection() == "Shopping" end,
		},
		{
			title = L["Select the Options Page"],
			description = L["Select the 'Options' page to change general settings for TSM_Shopping"],
			isDone = function() return private:GetOperationTreeSelection("Shopping")[1] == "1" end,
		},
	},
	["openShoppingAHTab"] = {
		{
			title = L["Open the Auction House"],
			description = L["Go to the Auction House and open it."],
			isDone = function() return AuctionFrame and AuctionFrame:IsVisible() end,
		},
		{
			title = L["Click on the Shopping Tab"],
			description = L["Along the bottom of the AH are various tabs. Click on the 'Shopping' AH tab."],
			isDone = function() return TSMAPI:AHTabIsVisible("Shopping") end,
		},
	},
	["shoppingGroupSearch"] = {
		{
			title = L["Show the 'TSM Groups' Sidebar Tab"],
			description = L["Underneath the search bar at the top of the 'Shopping' AH tab are a handful of buttons which change what's displayed in the sidebar window. Click on the 'TSM Groups' one."],
			isDone = function() return TSMAPI:ModuleAPI("Shopping", "getSidebarPage") == "groups" end,
		},
		{
			title = L["Select Group and Start Scan"],
			description = L["First, ensure your new group is selected in the group-tree and then click on the 'Start Search' button at the bottom of the sidebar window."],
			isDone = private:GetEventIsDone("SHOPPING:GROUPS:STARTSCAN"),
		},
	},
	["shoppingFilterSearch"] = {
		{
			title = L["Show the 'Custom Filter' Sidebar Tab"],
			description = L["Underneath the search bar at the top of the 'Shopping' AH tab are a handful of buttons which change what's displayed in the sidebar window. Click on the 'Custom Filter' one."],
			isDone = function() return TSMAPI:ModuleAPI("Shopping", "getSidebarPage") == "custom" end,
		},
		{
			title = L["Enter Filters and Start Scan"],
			description = L["You can use this sidebar window to help build AH searches. You can also type the filter directly in the search bar at the top of the AH window.\n\nEnter your filter and start the search."],
			isDone = private:GetEventIsDone("SHOPPING:SEARCH:STARTFILTERSCAN"),
		},
	},
	["shoppingSearchFromBags"] = {
		{
			title = L["Shift-Click Item in Your Bags"],
			description = L["If you open your bags and shift-click the item in your bags, it will be placed in Shopping's search bar. You may need to put your cursor in the search bar first. Alternatively, you can type the name of the item manually in the search bar and then hit enter or click the 'Search' button."],
			isDone = private:GetEventIsDone("SHOPPING:SEARCH:STARTFILTERSCAN"),
		},
	},
	["shoppingOtherSidebar"] = {
		{
			title = L["Show the 'Other' Sidebar Tab"],
			description = L["Underneath the search bar at the top of the 'Shopping' AH tab are a handful of buttons which change what's displayed in the sidebar window. Click on the 'Other' one."],
			isDone = function() return TSMAPI:ModuleAPI("Shopping", "getSidebarPage") == "other" end,
		},
	},
	["shoppingVendorSearch"] = {
		{
			title = L["Start Vendor Search"],
			description = L["Click on the 'Start Vendor Search' button in the sidebar window."],
			isDone = private:GetEventIsDone("SHOPPING:SEARCH:STARTVENDORSCAN"),
		},
	},
	["shoppingSniperSearch"] = {
		{
			title = L["Start Sniper"],
			description = L["Click on the 'Start Sniper' button in the sidebar window."],
			isDone = private:GetEventIsDone("SHOPPING:SEARCH:STARTSNIPER"),
		},
		private:GetIsDoneStep(
			L["Sniping Scan in Progress"],
			L["The 'Sniper' feature will constantly search the last page of the AH which shows items as they are being posted. This does not search existing auctions, but lets you buy items which are posted cheaply right as they are posted and buy them before anybody else can.\n\nYou can adjust the settings for what auctions are shown in TSM_Shopping's options.\n\nClick the button below when you're done reading this."]
		),
	},
	["shoppingDestroySearch"] = {
		{
			title = L["Switch to Destroy Mode"],
			description = L["Under the search bar, on the left, you can switch between normal and destroy mode for TSM_Shopping. Switch to 'Destroy Mode' now."],
			isDone = function() return TSMAPI:ModuleAPI("Shopping", "getSearchMode") == "destroy" end,
		},
		{
			title = L["Start a Destroy Search"],
			description = L["Type a raw material you would like to obtain via destroying in the search bar and start the search. For example: 'Ink of Dreams' or 'Spirit Dust'."],
			isDone = private:GetEventIsDone("SHOPPING:SEARCH:STARTDESTROYSCAN"),
		},
	},
	["shoppingWaitForScan"] = {
		{
			title = L["Waiting for Scan to Finish"],
			description = L["Please wait..."],
			isDone = function(self)
				if private.stepData[self] then return true end
				if not AuctionFrame:IsVisible() or not TSMAPI:AHTabIsVisible("Shopping") then return end
				if not private.stepData.recentEvents["SHOPPING:SEARCH:SCANDONE"] then return end
				local arg = private.stepData.recentEvents["SHOPPING:SEARCH:SCANDONE"].arg
				wipe(private.stepData.recentEvents)
				if arg == 0 then
					TSM:Print(L["Looks like no items were found. You can either try searching for something else, or simply close the Assistant window if you're done."])
				else
					private.stepData[self] = true
					return true
				end
			end,
		},
	},
	["shoppingWaitForScanSilent"] = {
		{
			title = L["Waiting for Scan to Finish"],
			description = L["Please wait..."],
			isDone = private:GetEventIsDone("SHOPPING:SEARCH:SCANDONE"),
		},
	},
	["shoppingPostFromResults"] = {
		{
			title = L["Post Your Items"],
			description = L["If there are no auctions currently posted for this item, simmply click the 'Post' button at the bottom of the AH window. Otherwise, select the auction you'd like to undercut first."],
			isDone = private:GetEventIsDone("TSM:AUCTIONCONTROL:POSTSHOWN"),
		},
		{
			title = L["Adjust Post Parameters"],
			description = L["In the confirmation window, you can adjust the buyout price, stack sizes, and auction duration. Once you're done, click the 'Post' button to post your items to the AH."],
			isDone = private:GetEventIsDone("TSM:AUCTIONCONTROL:ITEMPOSTED"),
		},
	},
	["shoppingQuickPostingSettings"] = {
		private:GetIsDoneStep(
			L["Set Quick Posting Duration"],
			L["Underneath the 'Posting Options' header, there are two settings which control the Quick Posting feature of TSM_Shopping. The first one is the duration which Quick Posting should use when posting your items to the AH. Change this to your preferred duration for Quick Posting."]
		),
		private:GetIsDoneStep(
			L["Set Quick Posting Price"],
			L["Underneath the 'Posting Options' header, there are two settings which control the Quick Posting feature of TSM_Shopping. The second one is the price at which the Quick Posting will post items to the AH. This should generally not be a fixed gold value, since it will apply to every item. Change this setting to what you'd like to post items at with Quick Posting."]
		),
	},
	["shoppingQuickPosting"] = {
		{
			title = L["Show the 'Quick Posting' Sidebar Tab"],
			description = L["Underneath the search bar at the top of the 'Shopping' AH tab are a handful of buttons which change what's displayed in the sidebar window. Click on the 'Custom Filter' one."],
			isDone = function() return TSMAPI:ModuleAPI("Shopping", "getSidebarPage") == "quick" end,
		},
		{
			title = L["Post an Item"],
			description = L["Shift-Click an item in the sidebar window to immediately post it at your quick posting price."],
			isDone = private:GetEventIsDone("SHOPPING:QUICKPOST:POSTEDITEM"),
		},
	},
}
private:PrependCreateOperationSteps(shoppingSteps["shoppingOperation"], "TSM_Shopping", "Shopping", L["A TSM_Shopping operation will allow you to set a maximum price we want to pay for the items in the group you just made. To create one for this group, scroll down to the 'Shopping' section, and click on the 'Create Shopping Operation' button."], 2)

do
	Assistant.STEPS = {}
	local addonSteps = {
		["TradeSkillMaster"] = tsmSteps,
		["TradeSkillMaster_Auctioning"] = auctioningSteps,
		["TradeSkillMaster_Crafting"] = craftingSteps,
		["TradeSkillMaster_Shopping"] = shoppingSteps,
	}
	for addon, moduleSteps in pairs(addonSteps) do
		if select(4, GetAddOnInfo(addon)) then
			for key, steps in pairs(moduleSteps) do
				assert(not Assistant.STEPS[key], format("Multiples steps with key '%s' exist!", key))
				Assistant.STEPS[key] = steps
			end
		end
	end
end