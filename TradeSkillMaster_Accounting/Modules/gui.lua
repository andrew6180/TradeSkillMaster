-- ------------------------------------------------------------------------------ --
--                           TradeSkillMaster_Accounting                          --
--           http://www.curse.com/addons/wow/tradeskillmaster_accounting          --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- create a local reference to the TradeSkillMaster_Crafting table and register a new module
local TSM = select(2, ...)
local GUI = TSM:NewModule("GUI", "AceEvent-3.0", "AceHook-3.0")
local AceGUI = LibStub("AceGUI-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster_Accounting") -- loads the localization table
local private = {}
TSMAPI:RegisterForTracing(private, "TSM_Accounting.GUI_private")

local scrollingTables = {}

local ITEM_SELL_BUY_ST_COLS = {
	{name=L["Item Name"], width=0.34, headAlign="LEFT"},
	{name=L["Player"], width=0.1, headAlign="LEFT"},
	{name=L["Type"], width=0.06, headAlign="LEFT"},
	{name=L["Stack"], width=0.05, headAlign="LEFT"},
	{name=L["Aucs"], width=0.05, headAlign="LEFT"},
	{name=L["Per Item"], width=0.12, headAlign="LEFT"},
	{name=L["Total Price"], width=0.13, headAlign="LEFT"},
	{name=L["Time"], width=0.14, headAlign="LEFT"},
	defaultSort = -8,
}
local ITEM_AUCTION_ST_COLS = {
	{name=L["Item Name"], width=0.5, headAlign="LEFT"},
	{name=L["Player"], width=0.15, headAlign="LEFT"},
	{name=L["Stack"], width=0.1, headAlign="LEFT"},
	{name=L["Aucs"], width=0.1, headAlign="LEFT"},
	{name=L["Time"], width=0.15, headAlign="LEFT"},
	defaultSort = -5,
}
local ITEM_MONEY_ST_COLS = {
	{name=L["Type"], width=0.2, headAlign="LEFT"},
	{name=L["Player"], width=0.2, headAlign="LEFT"},
	{name=L["Other Player"], width=0.2, headAlign="LEFT"},
	{name=L["Amount"], width=0.15, headAlign="LEFT"},
	{name=L["Time"], width=0.15, headAlign="LEFT"},
	defaultSort = -5,
}
local ITEM_SUMMARY_ST_COLS_AVG = {
	{name=L["Item Name"], width=0.38, headAlign="LEFT"},
	{name=L["Market Value"], width=0.15, headAlign="LEFT"},
	{name=L["Sold"], width=0.06, headAlign="LEFT"},
	{name=L["Avg Sell Price"], width=0.15, headAlign="LEFT"},
	{name=L["Bought"], width=0.07, headAlign="LEFT"},
	{name=L["Avg Buy Price"], width=0.15, headAlign="LEFT"},
	defaultSort = 1,
}
local ITEM_SUMMARY_ST_COLS_TOTAL = {
	{name=L["Item Name"], width=0.38, headAlign="LEFT"},
	{name=L["Market Value"], width=0.15, headAlign="LEFT"},
	{name=L["Sold"], width=0.06, headAlign="LEFT"},
	{name=L["Total Sale Price"], width=0.15, headAlign="LEFT"},
	{name=L["Bought"], width=0.07, headAlign="LEFT"},
	{name=L["Total Buy Price"], width=0.15, headAlign="LEFT"},
	defaultSort = 1,
}
local ITEM_RESALE_ST_COLS_AVG = {
	{name=L["Item Name"], width=0.37, headAlign="LEFT"},
	{name=L["Sold"], width=0.06, headAlign="LEFT"},
	{name=L["Avg Sell Price"], width=0.14, headAlign="LEFT"},
	{name=L["Bought"], width=0.07, headAlign="LEFT"},
	{name=L["Avg Buy Price"], width=0.14, headAlign="LEFT"},
	{name=L["Avg Resale Profit"], width=0.21, headAlign="LEFT"},
	defaultSort = -6,
}
local ITEM_RESALE_ST_COLS_TOTAL = {
	{name=L["Item Name"], width=0.37, headAlign="LEFT"},
	{name=L["Sold"], width=0.06, headAlign="LEFT"},
	{name=L["Total Sale Price"], width=0.14, headAlign="LEFT"},
	{name=L["Bought"], width=0.07, headAlign="LEFT"},
	{name=L["Total Buy Price"], width=0.14, headAlign="LEFT"},
	{name=L["Avg Resale Profit"], width=0.21, headAlign="LEFT"},
	defaultSort = -6,
}


function private:UpdateSTData(st, filters)
	st:SetData(st.accountingDataFunc(filters or {}))
end

function private:CreateScrollingTable(container, dataType, dataFunc, stCols, tab, subTab)
	local stParent = container.children[1].children[#container.children[1].children].frame

	if not scrollingTables[dataType] then
		local handlers = {
			OnClick = function(_, data, self)
				if not data then return end
				private:HideScrollingTables()
				GUI:DrawItemLookup(container, data.itemString, tab, subTab)
				container.children[1]:DoLayout()
			end,
			OnEnter = function(_, data, self)
				if not data then return end

				GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
				GameTooltip:SetText(L["Click for a detailed report on this item."], 1, .82, 0, 1)
				GameTooltip:Show()
			end,
			OnLeave = function()
				GameTooltip:ClearLines()
				GameTooltip:Hide()
			end
		}
		TSMAPI:CreateTimeDelay(0, function()
				scrollingTables[dataType] = TSMAPI:CreateScrollingTable(stParent, stCols, tab and handlers or nil)
				scrollingTables[dataType]:EnableSorting(true, stCols.defaultSort)
				scrollingTables[dataType]:DisableSelection(true)
				scrollingTables[dataType]:Show()
				scrollingTables[dataType]:SetParent(stParent)
				scrollingTables[dataType]:SetAllPoints()
				scrollingTables[dataType].accountingDataFunc = dataFunc
				private:UpdateSTData(scrollingTables[dataType])
			end)
	else
		scrollingTables[dataType]:Show()
		scrollingTables[dataType]:SetParent(stParent)
		scrollingTables[dataType]:SetAllPoints()
		private:UpdateSTData(scrollingTables[dataType])
	end
end

function private:GetMultiLabelLine(description, data, key, isPerDay, isNumber)
	local color, color2 = TSMAPI.Design:GetInlineColor("link2"), TSMAPI.Design:GetInlineColor("category2")
	local total = data[key].total
	local month = data[key].month
	local week = data[key].week
	if isPerDay then
		total = TSM:Round(total/data.totalTime)
		month = TSM:Round(month/data.monthTime)
		week = TSM:Round(week/data.weekTime)
	end
	local lines
	if isNumber then
		lines = {
			{ text = color2 .. description, relativeWidth = 0.19 },
			{ text = color .. L["Total:"] .. " |r" .. (total or 0), relativeWidth = 0.22 },
			{ text = color .. L["Last 30 Days:"] .. " |r" .. (month or 0), relativeWidth = 0.29 },
			{ text = color .. L["Last 7 Days:"] .. " |r" .. (week or 0), relativeWidth = 0.29 }
		}
	else
		lines = {
			{ text = color2 .. description, relativeWidth = 0.19 },
			{ text = color .. L["Total:"] .. " |r" .. (TSMAPI:FormatTextMoney(total) or "---"), relativeWidth = 0.22 },
			{ text = color .. L["Last 30 Days:"] .. " |r" .. (TSMAPI:FormatTextMoney(month) or "---"), relativeWidth = 0.29 },
			{ text = color .. L["Last 7 Days:"] .. " |r" .. (TSMAPI:FormatTextMoney(week) or "---"), relativeWidth = 0.29 }
		}
	end
	return lines
end

function private:HideScrollingTables()
	for _, st in pairs(scrollingTables) do
		st:Hide()
		st:SetData({})
	end
end

function GUI:Load(parent)
	local simpleGroup = AceGUI:Create("SimpleGroup")
	simpleGroup:SetLayout("Fill")
	parent:AddChild(simpleGroup)	
	local tabGroup = AceGUI:Create("TSMTabGroup")
	tabGroup:SetLayout("Fill")
	tabGroup:SetTabs({ { text = L["Revenue"], value = 1 }, { text = L["Expenses"], value = 2 }, { text = L["Failed Auctions"], value = 3 }, { text = L["Items"], value = 4 }, { text = L["Summary"], value = 5 }, { text = L["Player Gold"], value = 6 }, { text = L["Options"], value = 7 } })
	tabGroup:SetCallback("OnGroupSelected", function(self, _, value)
		tabGroup:ReleaseChildren()
		private:HideScrollingTables()
		if GUI.lineGraph then
			GUI.lineGraph:Hide()
		end
		if value == 1 then
			GUI:DrawRevenueTab(self)
		elseif value == 2 then
			GUI:DrawExpenseTab(self)
		elseif value == 3 then
			GUI:DrawFailedAucsTab(self)
		elseif value == 4 then
			GUI:DrawItemSummary(self)
		elseif value == 5 then
			GUI:DrawGoldSummary(self)
		elseif value == 6 then
			GUI:DrawGoldGraph(self)
		elseif value == 7 then
			GUI:DrawOptions(self)
		end
		tabGroup.children[1]:DoLayout()
	end)	
	simpleGroup:SetWidth(parent.frame:GetWidth() + 32) --fix blank space
	simpleGroup:AddChild(tabGroup)
	TSM.Data:PopulateDataCaches()
	tabGroup:SelectTab(1)
	GUI:HookScript(simpleGroup.frame, "OnHide", function()
		GUI:UnhookAll()
		private:HideScrollingTables()
		if GUI.lineGraph then
			GUI.lineGraph:Hide()
		end
	end)
end

function GUI:DrawRevenueTab(container)
	local simpleGroup = AceGUI:Create("SimpleGroup")
	simpleGroup:SetLayout("Fill")		
	container:AddChild(simpleGroup)
	local tabNum = 1
	local tabGroup = AceGUI:Create("TSMTabGroup")	
	tabGroup:SetLayout("Fill")
	tabGroup:SetTabs({ { text = L["Sales"], value = 1 }, { text = L["Other Income"], value = 2 }, { text = L["Resale"], value = 3 } })
	tabGroup:SetCallback("OnGroupSelected", function(self, _, value)
		tabGroup:ReleaseChildren()
		private:HideScrollingTables()
		if value == 1 then
			GUI:CreateFiltersWidgetsItem(self, "sales", {"Auction", "COD", "Trade", "Vendor"})
			private:CreateScrollingTable(self, "sales", TSM.Data.GetSaleSTData, ITEM_SELL_BUY_ST_COLS, tabNum, value)
		elseif value == 2 then
			GUI:CreateFiltersWidgetsMoney(self, "income", {"Transfer"})
			private:CreateScrollingTable(self, "income", TSM.Data.GetIncomeSTData, ITEM_MONEY_ST_COLS)
		elseif value == 3 then
			GUI:CreateFiltersWidgetsItem(self, "resale", {"Auction", "COD", "Trade", "Vendor"})
			local stCols = TSM.db.factionrealm.priceFormat == "avg" and ITEM_RESALE_ST_COLS_AVG or ITEM_RESALE_ST_COLS_TOTAL
			private:CreateScrollingTable(self, "resale", TSM.Data.GetResaleSTData, stCols, tabNum, value)
		end
		tabGroup.children[1]:DoLayout()
	end)
	simpleGroup:AddChild(tabGroup)
	TSM.Data:PopulateDataCaches()
	tabGroup:SelectTab(1)
end

function GUI:DrawExpenseTab(container)
	local simpleGroup = AceGUI:Create("SimpleGroup")
	simpleGroup:SetLayout("Fill")			
	container:AddChild(simpleGroup)
	local tabNum = 2
	local tabGroup = AceGUI:Create("TSMTabGroup")
	tabGroup:SetLayout("Fill")
	tabGroup:SetTabs({ { text = L["Purchases"], value = 1 }, { text = L["Other"], value = 2 } })
	tabGroup:SetCallback("OnGroupSelected", function(self, _, value)
		tabGroup:ReleaseChildren()
		private:HideScrollingTables()
		if value == 1 then
			GUI:CreateFiltersWidgetsItem(self, "buy", {"Auction", "COD", "Trade", "Vendor"})
			private:CreateScrollingTable(self, "buy", TSM.Data.GetBuySTData, ITEM_SELL_BUY_ST_COLS, tabNum, value)
		elseif value == 2 then
			GUI:CreateFiltersWidgetsMoney(self, "expense", {"Postage", "Repair", "Transfer"})
			private:CreateScrollingTable(self, "expense", TSM.Data.GetExpenseSTData, ITEM_MONEY_ST_COLS)
		end
		tabGroup.children[1]:DoLayout()
	end)
	simpleGroup:AddChild(tabGroup)
	TSM.Data:PopulateDataCaches()
	tabGroup:SelectTab(1)
end

function GUI:DrawFailedAucsTab(container)
	local simpleGroup = AceGUI:Create("SimpleGroup")
	simpleGroup:SetLayout("Fill")
	container:AddChild(simpleGroup)

	local tabNum = 3
	local tabGroup = AceGUI:Create("TSMTabGroup")
	tabGroup:SetLayout("Fill")
	tabGroup:SetTabs({ { text = L["Expired"], value = 1 }, { text = L["Cancelled"], value = 2 } })
	tabGroup:SetCallback("OnGroupSelected", function(self, _, value)
		tabGroup:ReleaseChildren()
		private:HideScrollingTables()
		if value == 1 then
			GUI:CreateFiltersWidgetsItem(self, "expired", {})
			private:CreateScrollingTable(self, "expired", TSM.Data.GetExpireSTData, ITEM_AUCTION_ST_COLS, tabNum, value)
		elseif value == 2 then
			GUI:CreateFiltersWidgetsItem(self, "cancelled", {})
			private:CreateScrollingTable(self, "cancelled", TSM.Data.GetCancelSTData, ITEM_AUCTION_ST_COLS, tabNum, value)
		end
		tabGroup.children[1]:DoLayout()
	end)
	simpleGroup:AddChild(tabGroup)
	TSM.Data:PopulateDataCaches()
	tabGroup:SelectTab(1)		
end

function GUI:DrawItemSummary(container)
	GUI:CreateFiltersWidgetsItem(container, "itemSummary", {"Auction", "COD", "Trade", "Vendor"})
	local stCols = TSM.db.factionrealm.priceFormat == "avg" and ITEM_SUMMARY_ST_COLS_AVG or ITEM_SUMMARY_ST_COLS_TOTAL
	private:CreateScrollingTable(container, "itemSummary", TSM.Data.GetItemSummarySTData, stCols, 4)	
end

function GUI:DrawItemLookup(container, itemString, returnTab, returnSubTab)
	container:ReleaseChildren()
	local itemID = TSMAPI:GetItemID(itemString)
	local itemData = TSM.Data.GetItemDetailData(itemString)

	local color, color2 = TSMAPI.Design:GetInlineColor("link2"), TSMAPI.Design:GetInlineColor("category2")

	local buyers, sellers = {}, {}
	for name, quantity in pairs(itemData.sales.players) do
		tinsert(buyers, { name = name, quantity = quantity })
	end
	for name, quantity in pairs(itemData.buys.players) do
		tinsert(sellers, { name = name, quantity = quantity })
	end
	sort(buyers, function(a, b) return a.quantity > b.quantity end)
	sort(sellers, function(a, b) return a.quantity > b.quantity end)

	local buyersText, sellersText = "", ""
	for i = 1, min(#buyers, 5) do
		buyersText = buyersText .. "|cffffffff" .. buyers[i].name .. "|r" .. color .. "(" .. buyers[i].quantity .. ")|r, "
	end
	for i = 1, min(#sellers, 5) do
		sellersText = sellersText .. "|cffffffff" .. sellers[i].name .. "|r" .. color .. "(" .. sellers[i].quantity .. ")|r, "
	end

	local page = {
		{
			type = "SimpleGroup",
			layout = "Flow",
			children = {
				{
					type = "SimpleGroup",
					layout = "Flow",
					children = {
						{
							type = "Label",
							relativeWidth = 0.1,
						},
						{
							type = "InteractiveLabel",
							text = select(2, TSMAPI:GetSafeItemInfo(itemString)) or TSM.items[itemString].name,
							fontObject = GameFontNormalLarge,
							relativeWidth = 0.4,
							callback = function() SetItemRef("item:" .. itemID, itemID) end,
							tooltip = itemID,
						},
						{
							type = "Label",
							relativeWidth = 0.1,
						},
						{
							type = "Button",
							text = L["Back to Previous Page"],
							relativeWidth = 0.29,
							callback = function()
								if returnSubTab then
									local topTabGroup = container.parent.parent
									-- not sure why, but sometimes the details get displayed within the top tabgroup, rather than the sub-tabgroup
									if topTabGroup.type == "TSMMainFrame" then
										topTabGroup = container
									end
									if topTabGroup.localstatus.selected ~= returnTab then
										topTabGroup:SelectTab(returnTab)
									end
									TSMAPI:CreateTimeDelay("accountingReturnDelay", 0, function() container:SelectTab(returnSubTab) end)
								else
									container:SelectTab(returnTab)
								end
							end,
						},
					},
				},
				{
					type = "HeadingLine",
				},
				{
					type = "InlineGroup",
					title = L["Sale Data"],
					layout = "Flow",
					backdrop = true,
					children = {},
				},
				{
					type = "InlineGroup",
					title = L["Purchase Data"],
					layout = "Flow",
					backdrop = true,
					children = {},
				},
				{
					type = "Spacer",
					quantity = 2,
				},
				{
					type = "ScrollFrame",
					layout = "Flow",
					fullHeight = true,
				},
			},
		},
	}

	local sellWidgets, buyWidgets
	if itemData.sales.hasData then
		sellWidgets = {
			{
				type = "MultiLabel",
				labelInfo = private:GetMultiLabelLine(L["Average Prices:"], itemData.sales, "avg"),
				relativeWidth = 1,
			},
			{
				type = "MultiLabel",
				labelInfo = private:GetMultiLabelLine(L["Quantity Sold:"], itemData.sales, "num", nil, true),
				relativeWidth = 1,
			},
			{
				type = "MultiLabel",
				labelInfo = private:GetMultiLabelLine(L["Gold Earned:"], itemData.sales, "price"),
				relativeWidth = 1,
			},
			{
				type = "Label",
				relativeWidth = 1,
				text = color2 .. L["Top Buyers:"] .. " |r" .. buyersText,
			},
		}
	else
		sellWidgets = {
			{
				type = "Label",
				relativeWidth = 1,
				text = "|cffffffff" .. L["There is no sale data for this item."] .. "|r",
			},
		}
	end

	if itemData.buys.hasData then
		buyWidgets = {
			{
				type = "MultiLabel",
				labelInfo = private:GetMultiLabelLine(L["Average Prices:"], itemData.buys, "avg"),
				relativeWidth = 1,
			},
			{
				type = "MultiLabel",
				labelInfo = private:GetMultiLabelLine(L["Quantity Bought:"], itemData.buys, "num", nil, true),
				relativeWidth = 1,
			},
			{
				type = "MultiLabel",
				labelInfo = private:GetMultiLabelLine(L["Total Spent:"], itemData.buys, "price"),
				relativeWidth = 1,
			},
			{
				type = "Label",
				relativeWidth = 1,
				text = color2 .. L["Top Sellers:"] .. " |r" .. sellersText,
			},
		}
	else
		buyWidgets = {
			{
				type = "Label",
				relativeWidth = 1,
				text = "|cffffffff" .. L["There is no purchase data for this item."] .. "|r",
			},
		}
	end

	local index
	for i = 2, #page[1].children do
		if page[1].children[i].type == "InlineGroup" then
			index = i
			break
		end
	end

	for i = 1, #sellWidgets do
		tinsert(page[1].children[index].children, sellWidgets[i])
	end
	for i = 1, #buyWidgets do
		tinsert(page[1].children[index + 1].children, buyWidgets[i])
	end

	TSMAPI:BuildPage(container, page)

	local stParent = container.children[1].children[#container.children[1].children].frame
	if not scrollingTables.itemDetail then
		local stCols = {
			{
				name = L["Activity Type"],
				width = 0.15,
				align = "LEFT",
				headAlign = "LEFT",
			},
			{
				name = L["Source"],
				width = 0.14,
				align = "LEFT",
				headAlign = "LEFT",
			},
			{
				name = L["Buyer/Seller"],
				width = 0.15,
				align = "LEFT",
				headAlign = "LEFT",
			},
			{
				name = L["Quantity"],
				width = 0.1,
				align = "LEFT",
				headAlign = "LEFT",
			},
			{
				name = L["Per Item"],
				width = 0.15,
				align = "LEFT",
				headAlign = "LEFT",
			},
			{
				name = L["Total Price"],
				width = 0.15,
				align = "LEFT",
				headAlign = "LEFT",
			},
			{
				name = L["Time"],
				width = 0.15,
				align = "LEFT",
				headAlign = "LEFT",
			},
		}
		local handlers = {
			OnClick = function(_, data, self, button)
				if not data then return end
				if button == "RightButton" and IsShiftKeyDown() then
					if data.recordType == "Sale" then
						for i, v in ipairs(TSM.items[itemString].sales) do
							if v == data.record then
								tremove(TSM.items[itemString].sales, i)
								break
							end
						end
					elseif data.recordType == "Purchase" then
						for i, v in ipairs(TSM.items[itemString].buys) do
							if v == data.record then
								tremove(TSM.items[itemString].buys, i)
								break
							end
						end
					end
					for i, v in ipairs(itemData.stData) do
						if v == data then
							tremove(itemData.stData, i)
							break
						end
					end
					scrollingTables.itemDetail:SetData(itemData.stData)
					TSM:Print(L["Removed record."])
				end
			end,
			OnEnter = function(_, data, self)
				if not data then return end

				GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
				GameTooltip:SetText(L["Shift-Right-Click to delete this record."], 1, .82, 0, 1)
				GameTooltip:Show()
			end,
			OnLeave = function()
				GameTooltip:ClearLines()
				GameTooltip:Hide()
			end
		}
		TSMAPI:CreateTimeDelay(0, function()
				scrollingTables.itemDetail = TSMAPI:CreateScrollingTable(stParent, stCols, handlers)
				scrollingTables.itemDetail:EnableSorting(true, -7)
				scrollingTables.itemDetail:DisableSelection(true)
				scrollingTables.itemDetail:Show()
				scrollingTables.itemDetail:SetParent(stParent)
				scrollingTables.itemDetail:SetAllPoints()
				scrollingTables.itemDetail:SetData(itemData.stData)
			end)
	else
		scrollingTables.itemDetail:Show()
		scrollingTables.itemDetail:SetParent(stParent)
		scrollingTables.itemDetail:SetAllPoints()
		scrollingTables.itemDetail:SetData(itemData.stData)
	end
end


local goldSummaryFilters = {}
function GUI:DrawGoldSummary(container)
	if goldSummaryFilters.isReloading then
		goldSummaryFilters.isReloading = nil
	else
		goldSummaryFilters = {} -- reset options on fresh update
	end
	
	local data = TSM.Data.GetSummaryData(goldSummaryFilters)
	local color, color2 = TSMAPI.Design:GetInlineColor("link2"), TSMAPI.Design:GetInlineColor("category2")
	
	local playerList = CopyTable(TSM.Data.playerListCache)
	playerList["all"] = L["All"]
	
	local page = {
		{
			type = "ScrollFrame",
			layout = "Flow",
			children = {
				{
					type = "SimpleGroup",
					layout = "Flow",
					children = {
						{
							type = "GroupBox",
							label = L["Group"],
							relativeWidth = 0.5,
							value = TSMAPI:FormatGroupPath(goldSummaryFilters.group),
							callback = function(_, _, value)
								goldSummaryFilters.group = value
								goldSummaryFilters.isReloading = true
								container:ReloadTab()
							end,
						},
						{
							type = "Dropdown",
							label = L["Player"],
							relativeWidth = 0.49,
							list = playerList,
							value = goldSummaryFilters.player,
							callback = function(_, _, value)
								if value == "all" then
									goldSummaryFilters.player = nil
								else
									goldSummaryFilters.player = value
								end
								goldSummaryFilters.isReloading = true
								container:ReloadTab()
							end,
						},
					},
				},
				-- {
					-- type = "HeadingLine",
				-- },
				{
					type = "InlineGroup",
					layout = "Flow",
					title = L["Sales"],
					backdrop = true,
					children = {
						{
							type = "MultiLabel",
							labelInfo = private:GetMultiLabelLine(L["Gold Earned:"], data, "sales"),
							relativeWidth = 1,
						},
						{
							type = "MultiLabel",
							labelInfo = private:GetMultiLabelLine(L["Earned Per Day:"], data, "sales", true),
							relativeWidth = 1,
						},
						{
							type = "Label",
							relativeWidth = 0.28,
							text = color2 .. L["Top Item by Gold / Quantity:"] .. "|r",
						},
						{
							type = "InteractiveLabel",
							text = data.sales.topGold.link .. " (" .. (TSMAPI:FormatTextMoney(data.sales.topGold.copper) or "---") .. ")",
							relativeWidth = 0.36,
							callback = function() SetItemRef("item:" .. data.sales.topGold.itemID, data.sales.topGold.itemID) end,
							tooltip = data.sales.topGold.itemID,
						},
						{
							type = "InteractiveLabel",
							text = data.sales.topQuantity.link .. " (" .. (data.sales.topQuantity.num or "---") .. ")",
							relativeWidth = 0.36,
							callback = function() SetItemRef("item:" .. data.sales.topQuantity.itemID, data.sales.topQuantity.itemID) end,
							tooltip = data.sales.topQuantity.itemID,
						},
					},
				},
				{
					type = "InlineGroup",
					layout = "Flow",
					title = L["Other Income"],
					backdrop = true,
					children = {
						{
							type = "MultiLabel",
							labelInfo = private:GetMultiLabelLine(L["Gold Earned:"], data, "income"),
							relativeWidth = 1,
						},
						{
							type = "MultiLabel",
							labelInfo = private:GetMultiLabelLine(L["Earned Per Day:"], data, "income", true),
							relativeWidth = 1,
						},
						{
							type = "Label",
							relativeWidth = 0.28,
							text = color2 .. L["Top Income by Gold / Quantity:"] .. "|r",
						},
						{
							type = "Label",
							text = (data.income.topGold.key or L["none"]) .. " (" .. (TSMAPI:FormatTextMoney(data.income.topGold.copper) or "---") .. ")",
							relativeWidth = 0.36,
						},
						{
							type = "Label",
							text = (data.income.topQuantity.key or L["none"]) .. " (" .. (data.income.topQuantity.num or "---") .. ")",
							relativeWidth = 0.36,
						},
					},
				},
				{
					type = "InlineGroup",
					layout = "Flow",
					title = L["Purchases"],
					backdrop = true,
					children = {
						{
							type = "MultiLabel",
							labelInfo = private:GetMultiLabelLine(L["Gold Spent:"], data, "buys"),
							relativeWidth = 1,
						},
						{
							type = "MultiLabel",
							labelInfo = private:GetMultiLabelLine(L["Spent Per Day:"], data, "buys", true),
							relativeWidth = 1,
						},
						{
							type = "Label",
							relativeWidth = 0.28,
							text = color2 .. L["Top Item by Gold / Quantity:"] .. "|r",
						},
						{
							type = "InteractiveLabel",
							text = data.buys.topGold.link .. " (" .. (TSMAPI:FormatTextMoney(data.buys.topGold.copper) or "---") .. ")",
							relativeWidth = 0.36,
							callback = function() SetItemRef("item:" .. data.buys.topGold.itemID, data.buys.topGold.itemID) end,
							tooltip = data.buys.topGold.itemID,
						},
						{
							type = "InteractiveLabel",
							text = data.buys.topQuantity.link .. " (" .. (data.buys.topQuantity.num or "---") .. ")",
							relativeWidth = 0.36,
							callback = function() SetItemRef("item:" .. data.buys.topQuantity.itemID, data.buys.topQuantity.itemID) end,
							tooltip = data.buys.topQuantity.itemID,
						},
					},
				},
				{
					type = "InlineGroup",
					layout = "Flow",
					title = L["Expenses"],
					backdrop = true,
					children = {
						{
							type = "MultiLabel",
							labelInfo = private:GetMultiLabelLine(L["Gold Spent:"], data, "expense"),
							relativeWidth = 1,
						},
						{
							type = "MultiLabel",
							labelInfo = private:GetMultiLabelLine(L["Spent Per Day:"], data, "expense", true),
							relativeWidth = 1,
						},
						{
							type = "Label",
							relativeWidth = 0.28,
							text = color2 .. L["Top Expense by Gold / Quantity:"] .. "|r",
						},
						{
							type = "Label",
							text = (data.expense.topGold.key or L["none"]) .. " (" .. (TSMAPI:FormatTextMoney(data.expense.topGold.copper) or "---") .. ")",
							relativeWidth = 0.36,
						},
						{
							type = "Label",
							text = (data.expense.topQuantity.key or L["none"]) .. " (" .. (data.expense.topQuantity.num or "---") .. ")",
							relativeWidth = 0.36,
						},
					},
				},
				{
					type = "InlineGroup",
					layout = "Flow",
					title = L["Balance"],
					backdrop = true,
					children = {
						{
							type = "MultiLabel",
							labelInfo = private:GetMultiLabelLine(L["Profit:"], data, "profit"),
							relativeWidth = 1,
						},
						{
							type = "MultiLabel",
							labelInfo = private:GetMultiLabelLine(L["Profit Per Day:"], data, "profit", true),
							relativeWidth = 1,
						},
					},
				},
			},
		},
	}

	TSMAPI:BuildPage(container, page)
end

function private:GetGoldGraphPoints(goldLog)
	if not goldLog or #goldLog < 3 then return end
	local minY, maxY = math.huge, 0
	local minX, maxX = math.huge, 0
	local data = {}
	for _, info in ipairs(goldLog) do
		local x1, x2 = info.startMinute, info.endMinute
		local y = info.copper / COPPER_PER_GOLD / 1000
		minX = min(minX, x1)
		maxX = max(maxX, x2)
		minY = min(minY, floor(y))
		maxY = max(maxY, ceil(y))
		tinsert(data, {x1, y})
		tinsert(data, {x2, y})
	end
	return data, minX, maxX, minY, maxY
end

function private:GetGoldGraphSumData()
	local currentMinute = floor(time() / 60)
	local players = {}
	local starts = {}
	for _, playerData in pairs(TSM.db.factionrealm.goldLog) do
		if #playerData > 2 then
			local data = CopyTable(playerData)
			for i=1, #data do
				if i > 1 then
					data[i].startMinute = data[i-1].endMinute+1
				end
				data[i].copper = TSM:Round(data[i].copper, COPPER_PER_GOLD*1000)
			end
			tinsert(players, data)
			tinsert(starts, data[1].startMinute)
		end
	end
	if #players == 0 then return end
	
	local indicies = {}
	local absStartMinute = min(unpack(starts))
	for i=1, #players do
		indicies[i] = 1
	end
	
	local temp = {}
	local staticCopper = 0
	for t=absStartMinute, currentMinute do
		local copper = staticCopper
		for i=#players, 1, -1 do
			if starts[i] <= t then
				local playerData = players[i]
				local index = indicies[i]
				while true do
					if index >= #playerData then
						index = #playerData
						tremove(players, i)
						staticCopper = staticCopper + playerData[index].copper
						copper = copper + playerData[index].copper
						break
					end
					if t > playerData[index].endMinute then
						-- move to the next datapoint for this player
						index = index + 1
					else
						-- we are in the range
						copper = copper + playerData[index].copper
						break
					end
				end
				indicies[i] = index
			end
		end
		local j = #temp+1
		if j > 1 and temp[j-1].copper == copper then
			temp[j-1].endMinute = t
		else
			tinsert(temp, {startMinute=t, endMinute=t, copper=copper})
		end
	end
	if #temp == 0 then return end
	return private:GetGoldGraphPoints(temp)
end

function GUI:DrawGoldGraph(container)
	TSM.db.factionrealm.goldGraphCharacter = TSM.db.factionrealm.goldGraphCharacter or UnitName("player")
	local player = TSM.db.factionrealm.goldGraphCharacter
	local data, minX, maxX, minY, maxY
	if player == "<ALL>" then
		data, minX, maxX, minY, maxY = private:GetGoldGraphSumData()
	else
		data, minX, maxX, minY, maxY = private:GetGoldGraphPoints(TSM.db.factionrealm.goldLog[player])
	end
	
	local dropdownList = {["<ALL>"]="Sum of All Characters"}
	for player in pairs(TSM.db.factionrealm.goldLog) do
		dropdownList[player] = player
	end
	
	if not data then
		local page = {
			{
				type = "SimpleGroup",
				layout = "Flow",
				children = {
					{
						type = "Label",
						text = L["Accounting has not yet collected enough information for this tab. This is likely due to not having recorded enough data points or not seeing any significant fluctuations (over 1k gold) in your gold on hand."],
						relativeWidth = 1,
					},
					{
						type = "Spacer",
					},
					{
						type = "Dropdown",
						label = "Character to Graph",
						settingInfo = {TSM.db.factionrealm, "goldGraphCharacter"},
						relativeWidth = 0.5,
						list = dropdownList,
						callback = function() container:ReloadTab() end,
						tooltip = "",
					},
				},
			},
		}
		TSMAPI:BuildPage(container, page)
		return
	end

	local startDate, endDate
	if TSM.db.factionrealm.timeFormat == "eudate" then
		startDate = date("%d/%m/%y %H:%M", minX * 60)
		endDate = date("%d/%m/%y %H:%M", maxX * 60)
	elseif TSM.db.factionrealm.timeFormat == "aidate" then
		startDate = date("%y/%m/%d %H:%M", minX * 60)
		endDate = date("%y/%m/%d %H:%M", maxX * 60)
	else
		startDate = date("%m/%d/%y %H:%M", minX * 60)
		endDate = date("%m/%d/%y %H:%M", maxX * 60)
	end

	local page = {
		{
			type = "SimpleGroup",
			layout = "Flow",
			children = {
				{
					type = "Label",
					--text = format(L["Below is a graph of the your character's gold on hand over time.\n\nThe x-axis is time and goes from %s to %s\nThe y-axis is thousands of gold."], startDate, endDate),
					text = format("Below is a graph of the your character's gold on hand over time.\nThe x-axis is time and goes from %s to %s. The y-axis is thousands of gold.", startDate, endDate),
					relativeWidth = 1,
				},
				-- {
					-- type = "Spacer",
				-- },
				{
					type = "Dropdown",
					label = L["Character to Graph"],
					settingInfo = {TSM.db.factionrealm, "goldGraphCharacter"},
					relativeWidth = 0.5,
					list = dropdownList,
					callback = function() container:ReloadTab() end,
				},
				-- {
					-- type = "HeadingLine"
				-- },
				{
					type = "Spacer",
				},
				{
					type = "ScrollFrame",
					fullHeight = false, --true
					layout = "flow"
				},
			},
		},
	}

	TSMAPI:BuildPage(container, page)

	local parent = container.children[1].children[#container.children[1].children].frame
	
	parent:SetWidth(container.frame:GetWidth() - 80)
	parent:SetHeight(container.frame:GetHeight() - 140)

	--if not GUI.lineGraph then
		local graph = LibStub("LibGraph-2.0"):CreateGraphLine(nil, parent, "CENTER", nil, nil, nil, parent:GetWidth(), parent:GetHeight())
		graph:SetGridColor({ 0.8, 0.8, 0.8, 0.6 })
		graph:SetYLabels(true)
		GUI.lineGraph = graph
	--end
	GUI.lineGraph:Show()
	GUI.lineGraph:SetParent(parent)
	GUI.lineGraph:ClearAllPoints()
	GUI.lineGraph:SetAllPoints(parent)

	GUI.lineGraph:ResetData()
	local ySpacing = max(ceil((maxY - minY) / 20), 0.5)
	GUI.lineGraph:SetGridSpacing(nil, ySpacing)
	local xBuffer = (maxX-minX)*0.05
	local yBuffer = (maxY-minY)*0.03
	GUI.lineGraph:SetXAxis(minX-xBuffer, maxX)
	GUI.lineGraph:SetYAxis(minY-yBuffer, maxY+yBuffer)
	GUI.lineGraph:AddDataSeries(data, {1, 0.83, 0, 1})
	GUI.lineGraph:RefreshGraph()
end

function GUI:DrawOptions(container)
	local mvSources = TSMAPI:GetPriceSources()
	local daysOld = 45

	local page = {
		{
			type = "ScrollFrame",
			layout = "List",
			children = {
				{
					type = "InlineGroup",
					title = L["General Options"],
					layout = "Flow",
					children = {
						{
							type = "Dropdown",
							label = L["Time Format"],
							settingInfo = {TSM.db.factionrealm, "timeFormat"},
							relativeWidth = 0.5,
							list = { ["ago"] = L["_ Hr _ Min ago"], ["usdate"] = L["MM/DD/YY HH:MM"], ["aidate"] = L["YY/MM/DD HH:MM"], ["eudate"] = L["DD/MM/YY HH:MM"] },
							tooltip = L["Select what format Accounting should use to display times in applicable screens."],
						},
						{
							type = "Dropdown",
							label = L["Market Value Source"],
							settingInfo = {TSM.db.factionrealm, "mvSource"},
							relativeWidth = 0.49,
							list = mvSources,
							tooltip = L["Select where you want Accounting to get market value info from to show in applicable screens."],
						},
						{
							type = "Dropdown",
							label = "Items/Resale Price Format",
							settingInfo = {TSM.db.factionrealm, "priceFormat"},
							relativeWidth = 0.49,
							list = { ["avg"] = L["Per Item"], ["total"] = L["Total Value"] },
							tooltip = L["Select how you would like prices to be shown in the \"Items\" and \"Resale\" tabs; either average price per item or total value."],
						},
						{
							type = "Label",
							relativeWidth = .49
						},
						{
							type = "CheckBox",
							label = L["Track sales/purchases via trade"],
							settingInfo = { TSM.db.factionrealm, "trackTrades" },
							callback = function() container:ReloadTab() end,
							tooltip = L["If checked, whenever you buy or sell any quantity of a single item via trade, Accounting will display a popup asking if you want it to record that transaction."],
						},
						{
							type = "CheckBox",
							label = L["Don't prompt to record trades"],
							settingInfo = { TSM.db.factionrealm, "autoTrackTrades" },
							disabled = not TSM.db.factionrealm.trackTrades,
							tooltip = L["If checked, you won't get a popup confirmation about whether or not to track trades."],
						},
						{
							type = "CheckBox",
							label = L["Display Grey Items in Sales"],
							settingInfo = { TSM.db.factionrealm, "displayGreys" },
							tooltip = L["If checked, poor quality items will be shown in sales data. They will still be included in gold earned totals on the summary tab regardless of this setting"],
						},
						{
							type = "CheckBox",
							label = L["Display Money Transfers in Income/Expense/Summary"],
							settingInfo = { TSM.db.factionrealm, "displayTransfers" },
							tooltip = L["If checked, Money Transfers will be included in income / expense and summary. Accounting will still track these if disabled but will not show them."],
						},
						{
							type = "CheckBox",
							label = L["Use smart average for purchase price"],
							settingInfo = { TSM.db.factionrealm, "smartBuyPrice" },
							tooltip = L["If checked, the average purchase price that shows in the tooltip will be the average price for the most recent X you have purchased, where X is the number you have in your bags / bank / gbank using data from the ItemTracker module. Otherwise, a simple average of all purchases will be used."],
						},
					},
				},
				{
					type = "InlineGroup",
					title = L["Clear Old Data"],
					layout = "Flow",
					children = {
						{
							type = "Label",
							text = L["You can use the options below to clear old data. It is recommened to occasionally clear your old data to keep Accounting running smoothly. Select the minimum number of days old to be removed in the dropdown, then click the button.\n\nNOTE: There is no confirmation."],
							relativeWidth = 1,
						},
						{
							type = "HeadingLine",
						},
						{
							type = "Dropdown",
							label = L["Days:"],
							relativeWidth = 0.4,
							list = { "30", "45", "60", "75", "90" },
							value = 2,
							callback = function(_, _, value) daysOld = (tonumber(value) + 1) * 15 end,
							tooltip = L["Data older than this many days will be deleted when you click on the button to the right."],
						},
						{
							type = "Button",
							text = L["Remove Old Data (No Confirmation)"],
							relativeWidth = 0.59,
							callback = function() TSM.Data:RemoveOldData(daysOld) end,
							tooltip = L["Click this button to permanently remove data older than the number of days selected in the dropdown."],
						},
					},
				},
			},
		},
	}

	TSMAPI:BuildPage(container, page)
end

function GUI:LoadTooltipOptions(container)
	local page = {
		{
			type = "SimpleGroup",
			layout = "Flow",
			fullHeight = true,
			children = {
				{
					type = "CheckBox",
					label = L["Show sale info in item tooltips"],
					settingInfo = { TSM.db.factionrealm.tooltip, "sale" },
					tooltip = L["If checked, the number you have sold and the average sale price will show up in an item's tooltip."],
				},
				{
					type = "CheckBox",
					label = L["Show Expired Auctions as Failed Auctions since Last Sale in item tooltips"],
					settingInfo = { TSM.db.factionrealm, "expiredAuctions" },
					relativeWidth = 1,
					tooltip = L["If checked, the number of expired auctions since the last sale will show as up as failed auctions in an item's tooltip. if no sales then the total number of expired auctions will be shown."],
				},
				{
					type = "CheckBox",
					label = L["Show Cancelled Auctions as Failed Auctions since Last Sale in item tooltips"],
					settingInfo = { TSM.db.factionrealm, "cancelledAuctions" },
					relativeWidth = 1,
					tooltip = L["If checked, the number of cancelled auctions since the last sale will show as up as failed auctions in an item's tooltip. if no sales then the total number of cancelled auctions will be shown."],
				},
				{
					type = "CheckBox",
					label = L["Show Sale Rate in item tooltips"],
					settingInfo = { TSM.db.factionrealm, "saleRate" },
					relativeWidth = 1,
					tooltip = L["If checked, the sale rate will be shown in item tooltips. sale rate is calculated as total sold / (total sold + total expired + total cancelled)."],
				},
				{
					type = "CheckBox",
					label = L["Show purchase info in item tooltips"],
					settingInfo = { TSM.db.factionrealm.tooltip, "purchase" },
					tooltip = L["If checked, the number you have purchased and the average purchase price will show up in an item's tooltip."],
				},
			},
		},
	}

	TSMAPI:BuildPage(container, page)
end

function GUI:CreateFiltersWidgetsItem(container, dataType, types)
	local rarityList = {[0]=L["None"]}
	for i = 1, 4 do
		rarityList[i] = _G[format("ITEM_QUALITY%d_DESC", i)]
	end
	
	local timeList = { [99] = L["All"], [0] = L["Today"], [1] = L["Yesterday"], [7] = L["Last 7 Days"], [14] = L["Last 14 Days"], [30] = L["Last 30 Days"], [60] = L["Last 60 Days"] }

	local playerList = CopyTable(TSM.Data.playerListCache)
	playerList["all"] = L["All"]
	
	local typeList = {["all"] = L["All"]}
	for _, dataType in ipairs(types) do
		typeList[dataType] = dataType
	end
	
	local filters = {}
	local page = {
		{
			type = "SimpleGroup",
			layout = "Flow",
			children = {
				{
					type = "EditBox",
					label = L["Search"],
					relativeWidth = 0.18,
					onTextChanged = true,
					callback = function(_, _, value)
						value = value:trim()
						if value == "" then
							filters.name = nil
						else
							filters.name = TSMAPI:StrEscape(value)
						end
						private:UpdateSTData(scrollingTables[dataType], filters)
					end,
				},
				{
					type = "GroupBox",
					label = L["Group"],
					relativeWidth = 0.19,
					callback = function(_, _, value)
						filters.group = value
						private:UpdateSTData(scrollingTables[dataType], filters)
					end,
				},
				{
					type = "Dropdown",
					label = L["Type"],
					relativeWidth = 0.13,
					list = typeList,
					value = "all",
					callback = function(_, _, key)
						if key == "all" then
							filters.key = nil
						else
							filters.key = key
						end
						private:UpdateSTData(scrollingTables[dataType], filters)
					end,
				},
				{
					type = "Dropdown",
					label = L["Rarity"],
					relativeWidth = 0.16,
					list = rarityList,
					value = 0,
					callback = function(_, _, key)
						if key > 0 then
							filters.rarity = key
						else
							filters.rarity = nil
						end
						private:UpdateSTData(scrollingTables[dataType], filters)
					end,
				},
				{
					type = "Dropdown",
					label = L["Player"],
					relativeWidth = 0.15,
					list = playerList,
					value = "all",
					callback = function(_, _, value)
						if value == "all" then
							filters.player = nil
						else
							filters.player = value
						end
						private:UpdateSTData(scrollingTables[dataType], filters)
					end,
				},
				{
					type = "Dropdown",
					label = L["Timeframe Filter"],
					relativeWidth = 0.18,
					list = timeList,
					value = 99,
					callback = function(_, _, value)
						if value == 99 then
							filters.time = nil
						else
							filters.time = value
						end
						private:UpdateSTData(scrollingTables[dataType], filters)
					end,
				},
				{
					type = "ScrollFrame",
					fullHeight = true,
					layout = "flow"
				},
			},
		},
	}

	TSMAPI:BuildPage(container, page)
end

function GUI:CreateFiltersWidgetsMoney(container, dataType, types)
	local timeList = {[99]=L["All"], [0]=L["Today"], [1]=L["Yesterday"], [7]=L["Last 7 Days"], [14]=L["Last 14 Days"], [30]=L["Last 30 Days"], [60]=L["Last 60 Days"]}

	local playerList = CopyTable(TSM.Data.playerListCache)
	playerList["all"] = L["All"]
	
	local typeList = {["all"] = L["All"]}
	for _, dataType in ipairs(types) do
		typeList[dataType] = dataType
	end
	
	local filters = {}
	local page = {
		{
			type = "SimpleGroup",
			layout = "Flow",
			children = {
				{
					type = "Dropdown",
					label = L["Type"],
					relativeWidth = 0.13,
					list = typeList,
					value = "all",
					callback = function(_, _, key)
						if key == "all" then
							filters.key = nil
						else
							filters.key = key
						end
						private:UpdateSTData(scrollingTables[dataType], filters)
					end,
				},
				{
					type = "Dropdown",
					label = L["Player"],
					relativeWidth = 0.15,
					list = playerList,
					value = "all",
					callback = function(_, _, value)
						if value == "all" then
							filters.player = nil
						else
							filters.player = value
						end
						private:UpdateSTData(scrollingTables[dataType], filters)
					end,
				},
				{
					type = "Dropdown",
					label = L["Timeframe Filter"],
					relativeWidth = 0.18,
					list = timeList,
					value = 99,
					callback = function(_, _, value)
						if value == 99 then
							filters.time = nil
						else
							filters.time = value
						end
						private:UpdateSTData(scrollingTables[dataType], filters)
					end,
				},
				{
					type = "ScrollFrame",
					fullHeight = true,
					layout = "flow"
				},
			},
		},
	}

	TSMAPI:BuildPage(container, page)
end
