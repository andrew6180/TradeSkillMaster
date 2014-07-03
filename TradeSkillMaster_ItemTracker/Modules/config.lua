-- ------------------------------------------------------------------------------ --
--                          TradeSkillMaster_ItemTracker                          --
--          http://www.curse.com/addons/wow/tradeskillmaster_itemtracker          --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- load the parent file (TSM) into a local variable and register this file as a module
local TSM = select(2, ...)
local Config = TSM:NewModule("Config", "AceEvent-3.0", "AceHook-3.0")
local AceGUI = LibStub("AceGUI-3.0") -- load the AceGUI libraries
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster_ItemTracker")

local viewerST
local filters = { characters = {}, guilds = {}, name = "", group = nil }

function Config:Load(container)
	local tabGroup = AceGUI:Create("TSMTabGroup")
	tabGroup:SetLayout("Fill")
	tabGroup:SetTabs({ { text = L["Inventory Viewer"], value = 1 }, { text = L["Options"], value = 2 } })
	tabGroup:SetCallback("OnGroupSelected", function(self, _, value)
		tabGroup:ReleaseChildren()
		if viewerST then viewerST:Hide() end
		if value == 1 then
			Config:LoadInventoryViewer(self)
		elseif value == 2 then
			Config:LoadOptions(self)
		end
		tabGroup.children[1]:DoLayout()
	end)
	container:AddChild(tabGroup)
	tabGroup:SelectTab(1)

	Config:HookScript(tabGroup.frame, "OnHide", function()
		Config:UnhookAll()
		if viewerST then viewerST:Hide() end
	end)
end

local function GetSTData()
	local items, rowData = {}, {}

	local function AddItem(itemString, key, quantity)
		items[itemString] = items[itemString] or { total = 0, bags = 0, bank = 0, guild = 0, auctions = 0, mail = 0 }
		items[itemString].total = items[itemString].total + quantity
		items[itemString][key] = items[itemString][key] + quantity
	end

	for name, selected in pairs(filters.characters) do
		if selected then
			for itemString, quantity in pairs(TSM:GetPlayerBags(name) or {}) do
				AddItem(itemString, "bags", quantity)
			end
			for itemString, quantity in pairs(TSM:GetPlayerBank(name) or {}) do
				AddItem(itemString, "bank", quantity)
			end
			for itemString, quantity in pairs(TSM:GetPlayerMail(name) or {}) do
				AddItem(itemString, "mail", quantity)
			end
			for itemString, quantity in pairs(TSM:GetPlayerAuctions(name) or {}) do
				if itemString ~= "time" then
					AddItem(itemString, "auctions", quantity)
				end
			end
		end
	end
	for name, selected in pairs(filters.guilds) do
		if selected then
			for itemString, quantity in pairs(TSM:GetGuildBank(name) or {}) do
				AddItem(itemString, "guild", quantity)
			end
		end
	end

	for itemString, data in pairs(items) do
		local name, itemLink = TSMAPI:GetSafeItemInfo(itemString)
		local marketValue = TSMAPI:GetItemValue(itemString, TSM.db.profile.marketValue) or 0
		local groupPath = TSMAPI:GetGroupPath(itemString)
		if (not name or filters.name == "" or strfind(strlower(name), filters.name)) and (not filters.group or groupPath and strfind(groupPath, "^" .. TSMAPI:StrEscape(filters.group))) then
			tinsert(rowData, {
				cols = {
					{
						value = itemLink or name or itemString,
						sortArg = name or "",
					},
					{
						value = data.bags,
						sortArg = data.bags,
					},
					{
						value = data.bank,
						sortArg = data.bank,
					},
					{
						value = data.mail,
						sortArg = data.mail,
					},
					{
						value = data.guild,
						sortArg = data.guild,
					},
					{
						value = data.auctions,
						sortArg = data.auctions,
					},
					{
						value = data.total,
						sortArg = data.total,
					},
					{
						value = TSMAPI:FormatTextMoney(data.total * marketValue) or "---",
						sortArg = data.total * marketValue,
					},
				},
				itemString = itemString,
			})
		end
	end

	sort(rowData, function(a, b) return a.cols[#a.cols].value > b.cols[#a.cols].value end)
	return rowData
end

function Config:LoadInventoryViewer(container)
	-- top AceGUI widgets
	local playerList, guildList = {}, {}
	for name in pairs(TSM.characters) do
		playerList[name] = name
		filters.characters[name] = true
	end
	for name in pairs(TSM.guilds) do
		if not TSM.db.factionrealm.ignoreGuilds[name] then
			guildList[name] = name
			filters.guilds[name] = true
		end
	end
	filters.group = nil

	local page = {
		{
			type = "SimpleGroup",
			layout = "Flow",
			fullHeight = true,
			children = {
				{
					type = "EditBox",
					label = L["Item Search"],
					relativeWidth = 0.24,
					onTextChanged = true,
					callback = function(_, _, value)
						filters.name = value:trim()
						viewerST:SetData(GetSTData())
					end,
				},
				{
					type = "GroupBox",
					label = "Group",
					relativeWidth = 0.25,
					callback = function(_, _, value)
						filters.group = value
						viewerST:SetData(GetSTData())
					end,
				},
				{
					type = "Dropdown",
					label = L["Characters"],
					relativeWidth = 0.25,
					list = playerList,
					value = filters.characters,
					multiselect = true,
					callback = function(_, _, key, value)
						filters.characters[key] = value
						viewerST:SetData(GetSTData())
					end,
				},
				{
					type = "Dropdown",
					label = L["Guilds"],
					relativeWidth = 0.25,
					list = guildList,
					value = filters.guilds,
					multiselect = true,
					callback = function(_, _, key, value)
						filters.guilds[key] = value
						viewerST:SetData(GetSTData())
					end,
				},
				{
					type = "ScrollFrame", -- simple group didn't work here for some reason
					fullHeight = true,
					layout = "Flow",
					children = {},
				},
			},
		},
	}

	TSMAPI:BuildPage(container, page)

	-- scrolling table
	local stParent = container.children[1].children[#container.children[1].children].frame

	if not viewerST then
		local stCols = {
			{
				name = L["Item Name"],
				width = 0.35,
			},
			{
				name = L["Bags"],
				width = 0.08,
			},
			{
				name = L["Bank"],
				width = 0.08,
			},
			{
				name = L["Mail"],
				width = 0.08,
			},
			{
				name = L["GBank"],
				width = 0.08,
			},
			{
				name = L["AH"],
				width = 0.08,
			},
			{
				name = L["Total"],
				width = 0.08,
			},
			{
				name = L["Total Value"],
				width = 0.17,
			}
		}
		local handlers = {
			OnEnter = function(_, data, self)
				GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
				TSMAPI:SafeTooltipLink(data.itemString)
				GameTooltip:Show()
			end,
			OnLeave = function()
				GameTooltip:ClearLines()
				GameTooltip:Hide()
			end
		}
		viewerST = TSMAPI:CreateScrollingTable(stParent, stCols, handlers)
		viewerST:EnableSorting(true)
	end

	viewerST:Show()
	viewerST:SetParent(stParent)
	viewerST:SetAllPoints()
	viewerST:SetData(GetSTData())
end

function Config:LoadOptions(container)
	local players, guildList = {}, {}
	for _, v in ipairs(TSM:GetPlayers()) do
		players[v] = v
	end

	for name in pairs(TSM.guilds) do
		guildList[name] = name
	end

	local page = {
		{
			-- scroll frame to contain everything
			type = "ScrollFrame",
			layout = "flow",
			children = {
				{
					type = "InlineGroup",
					title = L["Options"],
					layout = "flow",
					children = {
						{
							type = "Dropdown",
							label = L["Delete Character:"],
							list = players,
							relativeWidth = 0.49,
							callback = function(self, _, value)
								if value == UnitName("player") then
									-- don't delete the current player, just reset to defaults
									TSM.characters[value] = TSM.characterDefaults
									TSM:Print(L["Reset current player's inventory data."])
									self:SetValue()
									return
								end
								local charGuild = TSM.characters[value].guild
								if charGuild then
									local hasMembersLeft = false
									for player, data in pairs(TSM.characters) do
										if player ~= value and data.guild == charGuild then
											hasMembersLeft = true
										end
									end
									if not hasMembersLeft then
										TSM.guilds[charGuild] = nil
									end
								end

								TSM.characters[value] = nil
								TSM:Printf(L["\"%s\" removed from ItemTracker."], value)
								players[value] = nil
								self:SetList(players)
								self:SetValue()
							end,
							tooltip = L["If you rename / transfer / delete one of your characters, use this dropdown to remove that character from ItemTracker. There is no confirmation. If you accidentally delete a character that still exists, simply log onto that character to re-add it to ItemTracker."],
						},
						{
							type = "Dropdown",
							label = L["Guilds (Guild Banks) to Ignore:"],
							value = TSM.db.factionrealm.ignoreGuilds,
							list = guildList,
							relativeWidth = 0.49,
							multiselect = true,
							callback = function(_, _, key, value)
								TSM.db.factionrealm.ignoreGuilds[key] = value
							end,
							tooltip = L["Select guilds to ingore in ItemTracker. Inventory will still be tracked but not displayed or taken into consideration by Itemtracker."],
						},
						{
							type = "Dropdown",
							label = L["Market Value Price Source"],
							relativeWidth = 1,
							list = TSMAPI:GetPriceSources(),
							value = TSM.db.profile.marketValue,
							callback = function(_, _, value) TSM.db.profile.marketValue = value end,
							tooltip = L["Specifies the market value price source used for \"Total Market Value\" in the Inventory Viewer."],
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
					type = "Dropdown",
					label = "Tooltip:",
					value = TSM.db.global.tooltip,
					list = { hide = L["No Tooltip Info"], simple = L["Simple"], full = L["Full"] },
					relativeWidth = 0.49,
					callback = function(_, _, value)
						TSM.db.global.tooltip = value
					end,
					tooltip = L["Here, you can choose what ItemTracker info, if any, to show in tooltips. \"Simple\" will only show totals for bags/banks and for guild banks. \"Full\" will show detailed information for every character and guild."],
				},
			},
		},
	}

	TSMAPI:BuildPage(container, page)
end