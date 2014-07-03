-- ------------------------------------------------------------------------------ --
--                           TradeSkillMaster_AuctionDB                           --
--           http://www.curse.com/addons/wow/tradeskillmaster_auctiondb           --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- load the parent file (TSM) into a local variable and register this file as a module
local TSM = select(2, ...)
local Config = TSM:NewModule("Config", "AceHook-3.0")
local AceGUI = LibStub("AceGUI-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster_AuctionDB") -- loads the localization table

local searchPage = 0
local filter = { text = nil, class = nil, subClass = nil }
local items = {}

-- options page
function Config:Load(parent)
	filter = {}

	local tg = AceGUI:Create("TSMTabGroup")
	tg:SetLayout("Fill")
	tg:SetFullHeight(true)
	tg:SetFullWidth(true)
	tg:SetTabs({ { value = 1, text = SEARCH }, { value = 2, text = L["Options"] } })
	tg:SetCallback("OnGroupSelected", function(self, _, value)
		tg:ReleaseChildren()
		parent:DoLayout()

		if value == 1 then
			Config:LoadSearch(tg)
		elseif value == 2 then
			Config:LoadOptions(tg)
		end
		tg.children[1]:DoLayout()
	end)
	parent:AddChild(tg)
	tg:SelectTab(1)
end

function Config:UpdateItems()
	wipe(items)
	local cache = {}
	local sortMethod = TSM.db.profile.resultsSortMethod
	local fClass = filter.class and select(filter.class, GetAuctionItemClasses())
	local fSubClass = filter.subClass and select(filter.subClass, GetAuctionItemSubClasses(filter.class))
	if filter.text or fClass then
		for itemID, data in pairs(TSM.data) do
			TSM:DecodeItemData(itemID)
			local name, _, rarity, ilvl, minlvl, class, subClass = GetItemInfo(itemID)
			if (name and filter.text and strfind(strlower(name), strlower(filter.text))) and (not fClass or (class == fClass and (not fSubClass or subClass == fSubClass))) and (not TSM.db.profile.hidePoorQualityItems or rarity > 0) then
				tinsert(items, itemID)
				if sortMethod == "name" then
					cache[itemID] = name
				elseif sortMethod == "ilvl" then
					cache[itemID] = ilvl
				elseif sortMethod == "minlvl" then
					cache[itemID] = minlvl
				elseif sortMethod == "marketvalue" then
					cache[itemID] = data.marketValue
				elseif sortMethod == "minbuyout" then
					cache[itemID] = data.minBuyout
				end
			end
		end
	end

	if TSM.db.profile.resultsSortOrder == "ascending" then
		sort(items, function(a, b) return (cache[a] or math.huge) < (cache[b] or math.huge) end)
	else
		sort(items, function(a, b) return (cache[a] or 0) > (cache[b] or 0) end)
	end
end

function Config:LoadSearch(container)
	local searchDataTmp = Config:GetSearchData()
	local results = {}
	local totalResults = #items
	local minIndex = searchPage * TSM.db.profile.resultsPerPage + 1
	local maxIndex = min(TSM.db.profile.resultsPerPage * (searchPage + 1), totalResults)
	if totalResults == 0 then
		if filter.text then
			results = {
				{
					type = "Spacer",
					quantity = 2,
				},
				{
					type = "Label",
					relativeWidth = 0.4
				},
				{
					type = "Label",
					relativeWidth = 0.6,
					text = L["No items found"],
					fontObject = GameFontNormalLarge,
				},
			}
		else
			results = {
				{
					type = "Spacer",
					quantity = 2,
				},
				{
					type = "Label",
					relativeWidth = 0.05
				},
				{
					type = "Label",
					relativeWidth = 0.949,
					text = "|cffffffff" .. L["Use the search box and category filters above to search the AuctionDB data."] .. "|r",
					fontObject = GameFontNormalLarge,
				},
			}
		end
	end

	local classes, subClasses = {}, {}
	for i, className in ipairs({ GetAuctionItemClasses() }) do
		classes[i] = className
		subClasses[i] = {}
		for j, subClassName in ipairs({ GetAuctionItemSubClasses(i) }) do
			subClasses[i][j] = subClassName
		end
		tinsert(subClasses[i], "")
	end
	tinsert(classes, "")
	
	local lastScanInfo
	if TSM.db.factionrealm.lastCompleteScan > 0 then
		if TSM.db.factionrealm.lastCompleteScan == TSM.db.factionrealm.appDataUpdate then
			lastScanInfo = format(L["Last updated from the TSM Application %s ago."], SecondsToTime(time() - TSM.db.factionrealm.appDataUpdate))
		else
			lastScanInfo = format(L["Last updated from in-game scan %s ago."], SecondsToTime(time() - TSM.db.factionrealm.lastCompleteScan))
		end
	else
		lastScanInfo = L["No scans found."]
	end

	local page = {
		{
			type = "SimpleGroup",
			layout = "Flow",
			fullHeight = true,
			children = {
				{
					type = "Label",
					text = L["You can use this page to lookup an item or group of items in the AuctionDB database. Note that this does not perform a live search of the AH."],
					relativeWidth = 1,
				},
				{
					type = "Label",
					text = lastScanInfo,
					relativeWidth = 1,
				},
				{
					type = "HeadingLine",
				},
				{
					type = "EditBox",
					label = SEARCH,
					settingInfo = {filter, "text"},
					relativeWidth = 0.49,
					callback = function(_, _, value)
						searchPage = 0
						container:ReloadTab()
					end,
					tooltip = L["Any items in the AuctionDB database that contain the search phrase in their names will be displayed."],
				},
				{
					type = "Dropdown",
					label = L["Item Type Filter"],
					list = classes,
					value = filter.class or #classes,
					relativeWidth = 0.25,
					callback = function(self, _, value)
						filter.text = TSMAPI:StrEscape(filter.text or "")
						if value ~= filter.class then
							filter.subClass = nil
						end
						if value == #classes then
							filter.class = nil
						else
							filter.class = value
						end
						searchPage = 0
						container:ReloadTab()
					end,
					tooltip = L["You can filter the results by item type by using this dropdown. For example, if you want to search for all herbs, you would select \"Trade Goods\" in this dropdown and \"Herbs\" as the subtype filter."],
				},
				{
					type = "Dropdown",
					label = L["Item SubType Filter"],
					disabled = filter.class == nil or (subClasses[filter.class] and #subClasses[filter.class] == 0),
					list = subClasses[filter.class or 0],
					value = filter.subClass or #(subClasses[filter.class or 0] or {}),
					relativeWidth = 0.25,
					callback = function(_, _, value)
						if value == #subClasses[filter.class] then
							filter.subClass = nil
						else
							filter.subClass = value
						end
						searchPage = 0
						container:ReloadTab()
					end,
					tooltip = L["You can filter the results by item subtype by using this dropdown. For example, if you want to search for all herbs, you would select \"Trade Goods\" in the item type dropdown and \"Herbs\" in this dropdown."],
				},
				{
					type = "Label",
					relativeWidth = 0.15
				},
				{
					type = "Button",
					text = REFRESH,
					relativeWidth = 0.2,
					callback = function()
						searchPage = 0
						Config:UpdateItems()
						container:ReloadTab()
						container:DoLayout()
					end,
					tooltip = L["Refreshes the current search results."],
				},
				{
					type = "Label",
					relativeWidth = 0.15
				},
				{
					type = "Icon",
					image = "Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up",
					width = 24,
					imageWidth = 24,
					imageHeight = 24,
					disabled = minIndex == 1,
					callback = function(self)
						searchPage = searchPage - 1
						container:ReloadTab()
					end,
					tooltip = L["Previous Page"],
				},
				{
					type = "Label",
					relativeWidth = 0.03
				},
				{
					type = "Label",
					text = format(L["Items %s - %s (%s total)"], minIndex, maxIndex, totalResults),
					relativeWidth = 0.35,
				},
				{
					type = "Icon",
					image = "Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up",
					width = 24,
					imageWidth = 24,
					imageHeight = 24,
					disabled = maxIndex == totalResults,
					callback = function(self)
						searchPage = searchPage + 1
						container:ReloadTab()
					end,
					tooltip = L["Next Page"],
				},
				{
					type = "HeadingLine"
				},
				{
					type = "SimpleGroup",
					fullHeight = true,
					layout = "Flow",
					children = results,
				},
			},
		},
	}

	TSMAPI:BuildPage(container, page)

	local stParent = container.children[1].children[#container.children[1].children].frame

	if not Config.st then
		local stCols = {
			{
				name = L["Item Link"],
				width = 0.40,
			},
			{
				name = L["Minimum Buyout"],
				width = 0.19,
			},
			{
				name = L["Market Value"],
				width = 0.19,
			},
			{
				name = L["Last Scanned"],
				width = 0.22,
			},
		}
		local handlers = {
			OnClick = function(_, data, _, button)
				if data and IsShiftKeyDown() and button == "RightButton" then
					TSM.data[data.itemID] = nil
					TSM:Printf(L["Removed %s from AuctionDB."], select(2, GetItemInfo(data.itemID)) or data.itemID)
				end
			end,
			OnEnter = function(_, data, self)
				GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
				GameTooltip:SetHyperlink("item:" .. data.itemID)
				GameTooltip:AddLine("\n")
				GameTooltip:AddLine(TSMAPI.Design:GetInlineColor("link2") .. L["Shift-Right-Click to clear all data for this item from AuctionDB."] .. "|r")
				GameTooltip:Show()
			end,
			OnLeave = function()
				GameTooltip:ClearLines()
				GameTooltip:Hide()
			end
		}
		Config.st = TSMAPI:CreateScrollingTable(stParent, stCols, handlers)
		Config.st:EnableSorting(true)
	end

	Config:UnhookAll()
	Config:HookScript(stParent, "OnHide", function() Config:UnhookAll() Config.st:Hide() end)
	Config.st:Show()
	Config.st:SetParent(stParent)
	Config.st:SetAllPoints()
	Config.st:SetData(searchDataTmp)
end

function Config:GetSearchData()
	Config:UpdateItems()
	local stData = {}

	local totalResults = #items
	local minIndex = searchPage * TSM.db.profile.resultsPerPage + 1
	local maxIndex = min(TSM.db.profile.resultsPerPage * (searchPage + 1), totalResults)
	if totalResults > 0 then
		for i = minIndex, maxIndex do
			local itemID = items[i]
			TSM:DecodeItemData(itemID)
			local data = TSM.data[itemID]
			local timeDiff = data.lastScan and SecondsToTime(time() - data.lastScan)
			local name, link = GetItemInfo(itemID)
			tinsert(stData, {
				cols = {
					{
						value = link or "???",
						sortArg = name or "",
					},
					{
						value = TSMAPI:FormatTextMoney(data.minBuyout, "|cffffffff") or "---",
						sortArg = data.minBuyout or 0,
					},
					{
						value = TSMAPI:FormatTextMoney(data.marketValue, "|cffffffff") or "---",
						sortArg = data.marketValue or 0,
					},
					{
						value = (timeDiff and TSMAPI.Design:GetInlineColor("link2") .. format(L["%s ago"], timeDiff) .. "|r" or TSMAPI.Design:GetInlineColor("link2") .. "---|r"),
						sortArg = data.lastScan and (time() - data.lastScan) or 0,
					},
				},
				itemID = itemID,
			})
		end
	end

	return stData
end

function Config:LoadOptions(container)
	local page = {
		{
			type = "ScrollFrame",
			layout = "Flow",
			children = {
				{
					type = "InlineGroup",
					title = "General Options",
					layout = "Flow",
					children = {
						{
							type = "CheckBox",
							label = L["Show AuctionDB AH Tab (Requires Reload)"],
							settingInfo = { TSM.db.profile, "showAHTab" },
							relativeWidth = 0.5,
							tooltip = L["If checked, AuctionDB will add a tab to the AH to allow for in-game scans. If you are using the TSM app exclusively for your scans, you may want to hide it by unchecking this option. This option requires a reload to take effect."],
						},
					},
				},
				{
					type = "InlineGroup",
					title = L["Search Options"],
					layout = "Flow",
					children = {
						{
							type = "EditBox",
							label = L["Items per page"],
							value = TSM.db.profile.resultsPerPage,
							relativeWidth = 0.2,
							callback = function(_, _, value)
								value = tonumber(value)
								if value and value <= 500 and value >= 5 then
									TSM.db.profile.resultsPerPage = value
								else
									TSM:Print(L["Invalid value entered. You must enter a number between 5 and 500 inclusive."])
								end
							end,
							tooltip = L["This determines how many items are shown per page in results area of the \"Search\" tab of the AuctionDB page in the main TSM window. You may enter a number between 5 and 500 inclusive. If the page lags, you may want to decrease this number."],
						},
						{
							type = "Label",
							relativeWidth = 0.1
						},
						{
							type = "Dropdown",
							label = L["Sort items by"],
							list = { ["name"] = NAME, ["rarity"] = RARITY, ["ilvl"] = STAT_AVERAGE_ITEM_LEVEL, ["minlvl"] = L["Item MinLevel"], ["marketvalue"] = L["Market Value"], ["minbuyout"] = L["Minimum Buyout"] },
							settingInfo = {TSM.db.profile, "resultsSortMethod"},
							relativeWidth = 0.34,
							tooltip = L["Select how you would like the search results to be sorted. After changing this option, you may need to refresh your search results by hitting the \"Refresh\" button."],
						},
						{
							type = "Label",
							relativeWidth = 0.02
						},
						{
							type = "Dropdown",
							label = L["Result Order:"],
							settingInfo = {TSM.db.profile, "resultsSortOrder"},
							list = { ascending = L["Ascending"], descending = L["Descending"] },
							relativeWidth = 0.3,
							tooltip = L["Select whether to sort search results in ascending or descending order."],
						},
						{
							type = "CheckBox",
							label = L["Hide poor quality items"],
							settingInfo = { TSM.db.profile, "hidePoorQualityItems" },
							tooltip = L["If checked, poor quality items won't be shown in the search results."],
						},
					},
				},
			},
		},
	}

	TSMAPI:BuildPage(container, page)
end

function Config:LoadTooltipOptions(container)
	local page = {
		{
			type = "SimpleGroup",
			layout = "Flow",
			fullHeight = true,
			children = {
				{
					type = "CheckBox",
					label = L["Enable display of AuctionDB data in tooltip."],
					relativeWidth = 1,
					settingInfo = { TSM.db.profile, "tooltip" },
					callback = function(_, _, value)
						container:ReloadTab()
					end,
				},
				{
					type = "CheckBox",
					label = L["Display market value in tooltip."],
					disabled = not TSM.db.profile.tooltip,
					settingInfo = { TSM.db.profile, "marketValueTooltip" },
					tooltip = L["If checked, the market value of the item will be displayed"],
				},
				{
					type = "CheckBox",
					label = L["Display lowest buyout value seen in the last scan in tooltip."],
					disabled = not TSM.db.profile.tooltip,
					settingInfo = { TSM.db.profile, "minBuyoutTooltip" },
					tooltip = L["If checked, the lowest buyout value seen in the last scan of the item will be displayed."],
				},
			},
		},
	}

	TSMAPI:BuildPage(container, page)
end