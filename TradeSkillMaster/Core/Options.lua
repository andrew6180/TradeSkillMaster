-- ------------------------------------------------------------------------------ --
--                                TradeSkillMaster                                --
--                http://www.curse.com/addons/wow/tradeskill-master               --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- This file contains all the code for the stuff that shows under the "Status" icon in the main TSM window.

local TSM = select(2, ...)
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster") -- loads the localization table
local AceGUI = LibStub("AceGUI-3.0") -- load the AceGUI libraries

local lib = TSMAPI
local private = {}
TSMAPI:RegisterForTracing(private, "TradeSkillMaster.Options_private")

local presetThemes = {
	light = { L["Light (by Ravanys - The Consortium)"], "inlineColors{link{49,56,133,1}link2{153,255,255,1}category{36,106,36,1}category2{85,180,8,1}}textColors{iconRegion{enabled{105,105,105,1}}title{enabled{49,56,85,1}}label{enabled{45,44,40,1}disabled{150,148,140,1}}text{enabled{245,244,240,1}disabled{95,98,90,1}}link{enabled{49,56,133,1}}}fontSizes{normal{15}medium{13}small{12}}edgeSize{1.5}frameColors{frameBG{backdrop{219,219,219,1}border{30,30,30,1}}content{backdrop{60,60,60,1}border{40,40,40,1}}frame{backdrop{228,228,228,1}border{199,199,199,1}}}" },
	goblineer = { L["Goblineer (by Sterling - The Consortium)"], "inlineColors{link{153,255,255,1}link2{153,255,255,1}category{36,106,36,1}category2{85,180,8,1}}textColors{iconRegion{enabled{249,255,247,1}}title{enabled{132,219,9,1}}label{enabled{216,225,211,1}disabled{150,148,140,1}}text{enabled{255,254,250,1}disabled{147,151,139,1}}link{enabled{49,56,133,1}}}fontSizes{normal{15}medium{13}small{12}}edgeSize{1.5}frameColors{frameBG{backdrop{24,24,24,0.93}border{30,30,30,1}}content{backdrop{42,42,42,1}border{0,0,0,0}}frame{backdrop{24,24,24,1}border{255,255,255,0.03}}}" },
	jaded = { L["Jaded (by Ravanys - The Consortium)"], "frameColors{frameBG{backdrop{0,0,0,0.6}border{0,0,0,0.4}}content{backdrop{62,62,62,1}border{72,72,72,1}}frame{backdrop{32,32,32,1}border{2,2,2,0.48}}}textColors{text{enabled{99,219,136,1}disabled{95,98,90,1}}iconRegion{enabled{43,255,156,1}}title{enabled{75,255,150,1}}label{enabled{99,219,136,1}disabled{177,176,168,1}}}edgeSize{1}fontSizes{normal{15}medium{13}small{12}}" },
	tsmdeck = { L["TSMDeck (by Jim Younkin - Power Word: Gold)"], "inlineColors{link2{153,255,255,1}category2{85,180,8,1}link{89,139,255,1}category{80,222,22,1}}textColors{iconRegion{enabled{117,117,122,1}}title{enabled{247,248,255,1}}label{enabled{238,249,237,1}disabled{110,110,110,1}}text{enabled{245,240,251,1}disabled{115,115,115,1}}link{enabled{49,56,133,1}}}fontSizes{normal{14}medium{13}small{12}}edgeSize{1}frameColors{frameBG{backdrop{29,29,29,1}border{20,20,20,1}}content{backdrop{27,27,27,1}border{67,67,65,1}}frame{backdrop{39,39,40,1}border{20,20,20,1}}}" },
	tsmclassic = { L["TSM Classic (by Jim Younkin - Power Word: Gold)"], "inlineColors{link{89,139,255,1}link2{153,255,255,1}category{80,222,22,1}category2{85,180,8,1}}textColors{text{enabled{245,240,251,1}disabled{115,115,115,1}}iconRegion{enabled{216,216,224,1}}title{enabled{247,248,255,1}}label{enabled{238,249,237,1}disabled{110,110,110,1}}}fontSizes{normal{14}medium{13}small{12}}edgeSize{1}frameColors{frameBG{backdrop{8,8,8,1}border{4,2,147,1}}content{backdrop{18,18,18,1}border{102,108,105,1}}frame{backdrop{2,2,2,1}border{4,2,147,1}}}" },
	functional = { L["The Functional Gold Maker (by Xsinthis - The Golden Crusade)"], "inlineColors{category{3,175,222,1}link2{153,255,255,1}tooltip{130,130,250}link{89,139,255,1}category2{6,24,180,1}}textColors{iconRegion{enabled{216,216,224,1}}title{enabled{247,248,255,1}}label{enabled{238,249,237,1}disabled{110,110,110,1}}text{enabled{245,240,251,1}disabled{115,115,115,1}}link{enabled{49,56,133,1}}}fontSizes{normal{14}small{12}}edgeSize{0.5}frameColors{frameBG{backdrop{28,28,28,1}border{74,5,0,1}}content{backdrop{18,18,18,0.64000001549721}border{84,7,3,1}}frame{backdrop{2,2,2,0.48000001907349}border{72,9,4,1}}}" },
}
local defaultTheme = presetThemes.goblineer

function private:LoadHelpPage(parent)
	local color = lib.Design:GetInlineColor("link")
	local moduleText = {
		TSMAPI.Design:ColorText("Accounting", "link") .. " - " .. L["Keeps track of all your sales and purchases from the auction house allowing you to easily track your income and expenditures and make sure you're turning a profit."] .. "\n",
		TSMAPI.Design:ColorText("Additions", "link") .. " - " .. L["Provides extra functionality that doesn't fit well in other modules."] .. "\n",
		TSMAPI.Design:ColorText("AuctionDB", "link") .. " - " .. L["Performs scans of the auction house and calculates the market value of items as well as the minimum buyout. This information can be shown in items' tooltips as well as used by other modules."] .. "\n",
		TSMAPI.Design:ColorText("Auctioning", "link") .. " - " .. L["Posts and cancels your auctions to / from the auction house according to pre-set rules. Also, this module can show you markets which are ripe for being reset for a profit."] .. "\n",
		TSMAPI.Design:ColorText("Crafting", "link") .. " - " .. L["Allows you to build a queue of crafts that will produce a profitable, see what materials you need to obtain, and actually craft the items."] .. "\n",
		TSMAPI.Design:ColorText("Destroying", "link") .. " - " .. L["Mills, prospects, and disenchants items at super speed!"] .. "\n",
		TSMAPI.Design:ColorText("ItemTracker", "link") .. " - " .. L["Tracks and manages your inventory across multiple characters including your bags, bank, and guild bank."] .. "\n",
		TSMAPI.Design:ColorText("Mailing", "link") .. " - " .. L["Allows you to quickly and easily empty your mailbox as well as automatically send items to other characters with the single click of a button."] .. "\n",
		TSMAPI.Design:ColorText("Shopping", "link") .. " - " .. L["Provides interfaces for efficiently searching for items on the auction house. When an item is found, it can easily be bought, canceled (if it's yours), or even posted from your bags."] .. "\n",
		TSMAPI.Design:ColorText("Warehousing", "link") .. " - " .. L["Manages your inventory by allowing you to easily move stuff between your bags, bank, and guild bank."] .. "\n",
		--TSMAPI.Design:ColorText("WoWuction", "link") .. " - " .. L["Allows you to use data from http://wowuction.com in other TSM modules and view its various price points in your item tooltips."] .. "\n",
	}

	local page = {
		{
			type = "ScrollFrame",
			layout = "flow",
			children = {
				-- {
					-- type = "InlineGroup",
					-- title = L["Resources:"],
					-- layout = "flow",
					-- relativeWidth = 1,
					-- noBorder = true,
					-- children = {
						-- {
							-- type = "Label",
							-- relativeWidth = .499,
							-- text = L["Using our website you can get help with TSM, suggest features, and give feedback."].."\n",
						-- },
						-- {
							-- type = "Image",
							-- sizeRatio = .15625,
							-- relativeWidth = .5,
							-- image = "Interface\\Addons\\TradeSkillMaster\\Media\\banner",
						-- },
						-- {
							-- type = "HeadingLine"
						-- },
						-- {
							-- type = "Image",
							-- sizeRatio = .15628,
							-- relativeWidth = 1,
							-- image = "Interface\\Addons\\TradeSkillMaster\\Media\\AppBanner",
						-- },
						-- {
							-- type = "Label",
							-- relativeWidth = 1,
							-- text = format("\n" .. L["Check out our completely free, desktop application which has tons of features including deal notification emails, automatic updating of AuctionDB and WoWuction prices, automatic TSM setting backup, and more! You can find this app by going to %s."], TSMAPI.Design:ColorText("http://tradeskillmaster.com/tsm_app", "link")),
						-- }
					-- },
				-- },
				-- {
					-- type = "Spacer",
				-- },
				{
					type = "InlineGroup",
					title = L["Module Information:"],
					layout = "List",
					relativeWidth = 1,
					noBorder = true,
					children = {},
				},
				{
					type = "InlineGroup",
					layout = "flow",
					title = L["TradeSkillMaster Team"],
					children = {
						{
							type = "Label",
							text = TSMAPI.Design:ColorText(L["Lead Developer and Co-Founder:"], "link") .. " Sapu94 [US-Tichondrius(H)]",
							relativeWidth = 1,
						},
						{
							type = "Label",
							text = TSMAPI.Design:ColorText(L["Application and Addon Developer:"], "link") .. " Bart39 [EU-Darkspear(A)]",
							relativeWidth = 1,
						},
						{
							type = "Label",
							text = TSMAPI.Design:ColorText(L["Web Master:"], "link") .. " Drethic [US-Sentinels(A)]",
							relativeWidth = 1,
						},
						{
							type = "Label",
							text = TSMAPI.Design:ColorText("Logo / Graphic Designer:", "link") .. " Pwnstein",
							relativeWidth = 1,
						},
						{
							type = "Label",
							text = TSMAPI.Design:ColorText(L["Testers (Special Thanks):"], "link") .. " Cryan, GoblinRaset, Mithrildar, PhatLewts, WoWProfitz",
							relativeWidth = 1,
						},
						{
							type = "Label",
							text = TSMAPI.Design:ColorText(L["Past Contributors:"], "link") .. " Geemoney, Mischanix, Xubera, cduhn, cjo20",
							relativeWidth = 1,
						},
						{
							type = "Label",
							text = TSMAPI.Design:ColorText(L["Co-Founder:"], "link") .. " Cente [US-Illidan(H)]",
							relativeWidth = 1,
						},
					},
				},
			},
		},
	}

	for _, text in ipairs(moduleText) do
		tinsert(page[1].children[#page[1].children-1].children, {
			type = "Label",
			text = text,
			relativeWidth = 1,
		})
	end

	lib:BuildPage(parent, page)
end

local function GetSubStr(str)
	if not str then return end
	local startIndex, endIndex
	local balance = 0

	for i = 1, #str do
		local c = strsub(str, i, i)
		if c == '{' then
			if startIndex then
				balance = balance + 1
			else
				startIndex = i
			end
		elseif c == '}' then
			if balance > 0 then
				balance = balance - 1
			else
				endIndex = i
				break
			end
		end
	end

	if not startIndex or not endIndex then return end
	return strsub(str, startIndex + 1, endIndex - 1), startIndex, endIndex
end

local function StringToTable(data)
	local result = {}
	while true do
		local value, s, e = GetSubStr(data, { '{', '}' })
		if not value then return end
		local key = strsub(data, 1, s - 1)
		value = tonumber(value) or value

		if type(value) == "string" and strfind(value, "{") then
			value = StringToTable(value)
		elseif type(value) == "string" and strfind(value, ",") then
			value = { (","):split(value) }
			for i = 1, 4 do
				value[i] = tonumber(value[i])
			end
		end

		if type(value) == "nil" then
			return
		end

		result[key] = value
		if e + 1 > #data then
			break
		end
		data = strsub(data, e + 1, #data)
	end
	return result
end

function TSM:SetDesignDefaults(src, dest)
	for i, v in pairs(src) do
		if dest[i] then
			if type(v) == "table" then
				TSM:SetDesignDefaults(v, dest[i])
			end
		else
			if type(v) == "table" then
				dest[i] = CopyTable(v)
			else
				dest[i] = v
			end
		end
	end
end

local function DecodeAppearanceData(encodedData)
	if not encodedData then return end
	encodedData = gsub(encodedData, " ", "")

	local result = StringToTable(encodedData, 1)
	if not result then return TSM:Print(L["Invalid appearance data."]) end
	TSM.db.profile.design = result
	TSM:SetDesignDefaults(TSM.designDefaults, TSM.db.profile.design)
	TSMAPI:UpdateDesign()
end

function TSM:LoadDefaultDesign()
	DecodeAppearanceData(defaultTheme[2])
end

local function ShowImportFrame()
	local data

	local f = AceGUI:Create("TSMWindow")
	f:SetCallback("OnClose", function(self) AceGUI:Release(self) end)
	f:SetTitle("TradeSkillMaster - " .. L["Import Appearance Settings"])
	f:SetLayout("Flow")
	f:SetHeight(200)
	f:SetHeight(300)

	local spacer = AceGUI:Create("Label")
	spacer:SetFullWidth(true)
	spacer:SetText(" ")
	f:AddChild(spacer)

	local btn = AceGUI:Create("TSMButton")

	local eb = AceGUI:Create("MultiLineEditBox")
	eb:SetLabel(L["Appearance Data"])
	eb:SetFullWidth(true)
	eb:SetMaxLetters(0)
	eb:SetCallback("OnEnterPressed", function(_, _, val) btn:SetDisabled(false) data = val end)
	f:AddChild(eb)

	btn:SetDisabled(true)
	btn:SetText(L["Import Appearance Settings"])
	btn:SetFullWidth(true)
	btn:SetCallback("OnClick", function() DecodeAppearanceData(data) f:Hide() end)
	f:AddChild(btn)

	f.frame:SetFrameStrata("FULLSCREEN_DIALOG")
	f.frame:SetFrameLevel(100)
end

local function TblToStr(tbl)
	local tmp = {}
	for key, value in pairs(tbl) do
		tinsert(tmp, key .. "{")
		if tonumber(value) then
			tinsert(tmp, value)
		elseif #value == 0 then
			tinsert(tmp, TblToStr(value))
		else
			for _, colorVal in ipairs(value) do
				tinsert(tmp, tostring(colorVal))
				tinsert(tmp, ",")
			end
			tremove(tmp, #tmp)
		end
		tinsert(tmp, "}")
	end
	return table.concat(tmp, "")
end

local function EncodeAppearanceData()
	local keys = { "frameColors", "textColors", "inlineColors", "edgeSize", "fontSizes" }
	local testTbl = {}
	for _, key in ipairs(keys) do
		testTbl[key] = TSM.db.profile.design[key]
	end
	return TblToStr(testTbl)
end

local function ShowExportFrame()
	local f = AceGUI:Create("TSMWindow")
	f:SetCallback("OnClose", function(self) AceGUI:Release(self) end)
	f:SetTitle("TradeSkillMaster - " .. L["Export Appearance Settings"])
	f:SetLayout("Fill")
	f:SetHeight(300)

	local eb = AceGUI:Create("TSMMultiLineEditBox")
	eb:SetLabel(L["Appearance Data"])
	eb:SetMaxLetters(0)
	eb:SetText(EncodeAppearanceData())
	f:AddChild(eb)

	f.frame:SetFrameStrata("FULLSCREEN_DIALOG")
	f.frame:SetFrameLevel(100)
end

function private:LoadOptionsPage(parent)
	local presetThemeList = {}
	for key, tbl in pairs(presetThemes) do
		presetThemeList[key] = tbl[1]
	end
	local savedThemeList = {}
	for _, info in ipairs(TSM.db.profile.savedThemes) do
		tinsert(savedThemeList, info.name)
	end
	local themeName = ""

	local auctionTabs, auctionTabOrder
	if AuctionFrame and AuctionFrame.numTabs then
		auctionTabs, auctionTabOrder = {}, {}
		for i = 1, AuctionFrame.numTabs do
			local text = gsub(_G["AuctionFrameTab" .. i]:GetText(), "|r", "")
			text = gsub(text, "|c[0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f]", "")
			auctionTabs[text] = text
			tinsert(auctionTabOrder, text)
		end
	end

	local characterList = {}
	for character in pairs(TSMAPI:GetCharacters()) do
		tinsert(characterList, character)
	end
	
	local chatFrameList = {}
	local chatFrameValue, defaultValue
	for i=1, NUM_CHAT_WINDOWS do
		if DEFAULT_CHAT_FRAME == _G["ChatFrame"..i] then
			defaultValue = i
		end
		local name = strlower(GetChatWindowInfo(i) or "")
		if name ~= "" then
			if name == TSM.db.global.chatFrame then
				chatFrameValue = i
			end
			tinsert(chatFrameList, name)
		end
	end
	chatFrameValue = chatFrameValue or defaultValue

	local page = {
		{
			type = "ScrollFrame",
			layout = "flow",
			children = {
				{
					type = "InlineGroup",
					layout = "flow",
					title = L["General Settings"],
					children = {
						{
							type = "CheckBox",
							label = L["Hide Minimap Icon"],
							settingInfo = { TSM.db.profile.minimapIcon, "hide" },
							relativeWidth = 0.5,
							callback = function(_, _, value)
								if value then
									TSM.LDBIcon:Hide("TradeSkillMaster")
								else
									TSM.LDBIcon:Show("TradeSkillMaster")
								end
							end,
						},
						{
							type = "CheckBox",
							label = L["Color Group Names by Depth"],
							settingInfo = { TSM.db.profile, "colorGroupName" },
							relativeWidth = 0.49,
							tooltip = L["If checked, group names will be colored based on their subgroup depth in group trees."],
						},
						{
							type = "CheckBox",
							label = L["Store Operations Globally"],
							value = TSM.db.global.globalOperations,
							relativeWidth = 0.5,
							callback = function(_, _, value)
								StaticPopupDialogs["TSM_GLOBAL_OPERATIONS"] = StaticPopupDialogs["TSM_GLOBAL_OPERATIONS"] or {
									text = L["If you have multiple profile set up with operations, enabling this will cause all but the current profile's operations to be irreversibly lost. Are you sure you want to continue?"],
									button1 = YES,
									button2 = CANCEL,
									timeout = 0,
									hideOnEscape = true,
									OnAccept = function()
										TSM.db.global.globalOperations = value
										if TSM.db.global.globalOperations then
											-- move current profile to global
											TSM.db.global.operations = CopyTable(TSM.db.profile.operations)
											-- clear out old operations
											for profile in TSMAPI:GetTSMProfileIterator() do
												TSM.db.profile.operations = nil
											end
										else
											-- move global to all profiles
											for profile in TSMAPI:GetTSMProfileIterator() do
												TSM.db.profile.operations = CopyTable(TSM.db.global.operations)
											end
											-- clear out old operations
											TSM.db.global.operations = nil
										end
										TSM:UpdateModuleProfiles()
										if parent.frame:IsVisible() then
											parent:ReloadTab()
										end
									end,
									preferredIndex = 3,
								}
								parent:ReloadTab()
								TSMAPI:ShowStaticPopupDialog("TSM_GLOBAL_OPERATIONS")
							end,
							tooltip = L["If checked, operations will be stored globally rather than by profile. TSM groups are always stored by profile. Note that if you have multiple profiles setup already with separate operation information, changing this will cause all but the current profile's operations to be lost."],
						},
						{
							type = "Dropdown",
							label = L["Forget Characters:"],
							list = characterList,
							relativeWidth = 0.49,
							callback = function(_, _, value)
								local name = characterList[value]
								TSM.db.factionrealm.characters[name] = nil
								TSM:Printf("%s removed.", name)
								parent:ReloadTab()
							end,
							tooltip = L["If you delete, rename, or transfer a character off the current faction/realm, you should remove it from TSM's list of characters using this dropdown."],
						},
						{
							type = "Dropdown",
							label = L["Default BankUI Tab"],
							list = TSM:getBankTabs(),
							settingInfo = { TSM.db.global, "bankUITab" },
							relativeWidth = 0.5,
							tooltip = L["The default tab shown in the 'BankUI' frame."],
						},
						{
							type = "Dropdown",
							label = L["Chat Tab"],
							list = chatFrameList,
							value = chatFrameValue,
							callback = function(_, _, value)
								TSM.db.global.chatFrame = chatFrameList[value]
							end,
							relativeWidth = 0.49,
							tooltip = L["This option sets which tab TSM and its modules will use for printing chat messages."],
						},
					},
				},
				{
					type = "InlineGroup",
					layout = "flow",
					title = L["Multi-Account Settings"],
					children = {
						{
							type = "Label",
							relativeWidth = 1,
							text = L["Various modules can sync their data between multiple accounts automatically whenever you're logged into both accounts."],
						},
						{
							type = "Spacer",
						},
						{
							type = "Label",
							relativeWidth = 1,
							text = L["First, log into a character on the same realm (and faction) on both accounts. Type the name of the OTHER character you are logged into in the box below. Once you have done this on both accounts, TSM will do the rest automatically. Once setup, syncing will automatically happen between the two accounts while on any character on the account (not only the one you entered during this setup)."],
						},
						{
							type = "EditBox",
							relativeWidth = 1,
							label = L["Character Name on Other Account"],
							callback = function(_, _, value)
								TSM:DoSyncSetup(value:trim())
							end,
							tooltip = L["See instructions above this editbox."],
						},
						{
							type = "HeadingLine",
						}
					},
				},
				{
					type = "InlineGroup",
					layout = "flow",
					title = L["Auction House Tab Settings"],
					children = {
						{
							type = "Dropdown",
							label = auctionTabs and L["Default Tab"] or L["Default Tab (Open Auction House to Enable)"],
							list = auctionTabs or {},
							order = auctionTabOrder,
							disabled = not auctionTabs,
							settingInfo = { TSM.db.profile, "defaultAuctionTab" },
							relativeWidth = 0.5,
						},
						{
							type = "CheckBox",
							label = L["Open All Bags with Auction House"],
							settingInfo = { TSM.db.profile, "openAllBags" },
							relativeWidth = 0.5,
							tooltip = L["If checked, your bags will be automatically opened when you open the auction house."],
						},
						{
							type = "HeadingLine",
						},
						{
							type = "CheckBox",
							label = L["Show Bids in Auction Results Table (Requires Reload)"],
							settingInfo = { TSM.db.profile, "showBids" },
							tooltip = L["If checked, all tables listing auctions will display the bid as well as the buyout of the auctions. This will not take effect immediately and may require a reload."],
						},
						{
							type = "Slider",
							label = L["Number of Auction Result Rows (Requires Reload)"],
							settingInfo = { TSM.db.profile, "auctionResultRows" },
							relativeWidth = 0.5,
							min = 8,
							max = 25,
							step = 1,
							tooltip = L["Changes how many rows are shown in the auction results tables."],
						},
						{
							type = "HeadingLine",
						},
						{
							type = "CheckBox",
							label = L["Make Auction Frame Movable"],
							settingInfo = { TSM.db.profile, "auctionFrameMovable" },
							callback = function(_, _, value)
								if AuctionFrame then
									AuctionFrame:SetMovable(value)
								end
							end,
						},
						{
							type = "Slider",
							label = L["Auction Frame Scale"],
							settingInfo = { TSM.db.profile, "auctionFrameScale" },
							isPercent = true,
							relativeWidth = 0.5,
							min = 0.1,
							max = 2,
							step = 0.05,
							callback = function(_, _, value) if AuctionFrame then AuctionFrame:SetScale(value) end end,
							tooltip = L["Changes the size of the auction frame. The size of the detached TSM auction frame will always be the same as the main auction frame."],
						},
					},
				},
				{
					type = "InlineGroup",
					layout = "flow",
					title = L["TSM Appearance Options"],
					children = {
						{
							type = "Label",
							text = L["Use the options below to change and tweak the appearance of TSM."],
							relativeWidth = 1,
						},
						{
							type = "Dropdown",
							label = L["Import Preset TSM Theme"],
							list = presetThemeList,
							relativeWidth = 1,
							callback = function(_, _, key)
								if presetThemes[key] then
									DecodeAppearanceData(presetThemes[key][2])
								end
							end,
							tooltip = L["Select a theme from this dropdown to import one of the preset TSM themes."],
						},
						{
							type = "Dropdown",
							label = L["Load Saved Theme"],
							list = savedThemeList,
							relativeWidth = 1,
							callback = function(_, _, index)
								DecodeAppearanceData(TSM.db.profile.savedThemes[index].theme)
							end,
							tooltip = L["Select a theme from this dropdown to import one of your saved TSM themes."],
						},
						{
							type = "EditBox",
							label = L["Theme Name"],
							relativeWidth = 0.5,
							callback = function(_, _, value) themeName = value:trim() end,
						},
						{
							type = "Button",
							text = L["Save Theme"],
							relativeWidth = 0.5,
							callback = function(_, _, value)
								if themeName == "" then
									return TSM:Print(L["Theme name is empty."])
								end
								TSM:Printf(L["Saved theme: %s."], themeName)
								tinsert(TSM.db.profile.savedThemes, { name = themeName, theme = EncodeAppearanceData() })
								parent:ReloadTab()
							end,
						},
						{
							type = "Button",
							text = L["Restore Default Colors"],
							relativeWidth = 1,
							callback = function() TSM:LoadDefaultDesign() parent:ReloadTab() end,
							tooltip = L["Restores all the color settings below to their default values."],
						},
						{
							type = "Button",
							text = L["Import Appearance Settings"],
							relativeWidth = 0.5,
							callback = ShowImportFrame,
							tooltip = L["This allows you to import appearance settings which other people have exported."],
						},
						{
							type = "Button",
							text = L["Export Appearance Settings"],
							relativeWidth = 0.5,
							callback = ShowExportFrame,
							tooltip = L["This allows you to export your appearance settings to share with others."],
						},
						{
							type = "HeadingLine"
						},
					},
				},
			},
		},
	}

	-- extra multi-account syncing widgets
	for account, players in pairs(TSM.db.factionrealm.syncAccounts) do
		local playerList = {}
		for player in pairs(players) do
			tinsert(playerList, player)
		end
		local widgets = {
			{
				type = "Button",
				text = DELETE,
				relativeWidth = 0.2,
				callback = function()
					TSM.db.factionrealm.syncAccounts[account] = nil
					parent:ReloadTab()
				end,
			},
			{
				type = "Label",
				relativeWidth = 0.79,
				text = table.concat(playerList, ", "),
			}
		}
		for _, widget in ipairs(widgets) do
			tinsert(page[1].children[2].children, widget)
		end
	end


	local function expandColor(tbl)
		return { tbl[1] / 255, tbl[2] / 255, tbl[3] / 255, tbl[4] }
	end

	local function compressColor(r, g, b, a)
		return { r * 255, g * 255, b * 255, a }
	end

	local frameColorOptions = {
		{ L["Frame Background - Backdrop"], "frameBG", "backdrop" },
		{ L["Frame Background - Border"], "frameBG", "border" },
		{ L["Region - Backdrop"], "frame", "backdrop" },
		{ L["Region - Border"], "frame", "border" },
		{ L["Content - Backdrop"], "content", "backdrop" },
		{ L["Content - Border"], "content", "border" },
	}
	for _, optionInfo in ipairs(frameColorOptions) do
		local label, key, subKey = unpack(optionInfo)

		local widget = {
			type = "ColorPicker",
			label = label,
			relativeWidth = 0.5,
			hasAlpha = true,
			value = expandColor(TSM.db.profile.design.frameColors[key][subKey]),
			callback = function(_, _, ...)
				TSM.db.profile.design.frameColors[key][subKey] = compressColor(...)
				TSMAPI:UpdateDesign()
			end,
		}
		tinsert(page[1].children[4].children, widget)
	end

	tinsert(page[1].children[4].children, { type = "HeadingLine" })

	local textColorOptions = {
		{ L["Icon Region"], "iconRegion", "enabled" },
		{ L["Title"], "title", "enabled" },
		{ L["Label Text - Enabled"], "label", "enabled" },
		{ L["Label Text - Disabled"], "label", "disabled" },
		{ L["Content Text - Enabled"], "text", "enabled" },
		{ L["Content Text - Disabled"], "text", "disabled" },
	}
	for _, optionInfo in ipairs(textColorOptions) do
		local label, key, subKey = unpack(optionInfo)

		local widget = {
			type = "ColorPicker",
			label = label,
			relativeWidth = 0.5,
			hasAlpha = true,
			value = expandColor(TSM.db.profile.design.textColors[key][subKey]),
			callback = function(_, _, ...)
				TSM.db.profile.design.textColors[key][subKey] = compressColor(...)
				TSMAPI:UpdateDesign()
			end,
		}
		tinsert(page[1].children[4].children, widget)
	end

	tinsert(page[1].children[4].children, { type = "HeadingLine" })

	local inlineColorOptions = {
		{ L["Link Text (Requires Reload)"], "link" },
		{ L["Link Text 2 (Requires Reload)"], "link2" },
		{ L["Category Text (Requires Reload)"], "category" },
		{ L["Category Text 2 (Requires Reload)"], "category2" },
		{ L["Item Tooltip Text"], "tooltip" },
		{ L["Advanced Option Text"], "advanced" },
	}
	for _, optionInfo in ipairs(inlineColorOptions) do
		local label, key = unpack(optionInfo)

		local widget = {
			type = "ColorPicker",
			label = label,
			relativeWidth = 0.5,
			hasAlpha = true,
			value = expandColor(TSM.db.profile.design.inlineColors[key]),
			callback = function(_, _, ...)
				TSM.db.profile.design.inlineColors[key] = compressColor(...)
				TSMAPI:UpdateDesign()
			end,
		}
		tinsert(page[1].children[4].children, widget)
	end

	tinsert(page[1].children[4].children, { type = "HeadingLine" })

	local miscWidgets = {
		{
			type = "Slider",
			relativeWidth = 0.5,
			label = L["Small Text Size (Requires Reload)"],
			min = 6,
			max = 30,
			step = 1,
			settingInfo = { TSM.db.profile.design.fontSizes, "small" },
		},
		{
			type = "Slider",
			relativeWidth = 0.5,
			label = L["Medium Text Size (Requires Reload)"],
			min = 6,
			max = 30,
			step = 1,
			settingInfo = { TSM.db.profile.design.fontSizes, "medium" },
		},
		{
			type = "Slider",
			relativeWidth = 0.5,
			label = L["Normal Text Size (Requires Reload)"],
			min = 6,
			max = 30,
			step = 1,
			settingInfo = { TSM.db.profile.design.fontSizes, "normal" },
		},
		{
			type = "Slider",
			relativeWidth = 0.5,
			label = L["Border Thickness (Requires Reload)"],
			min = 0,
			max = 3,
			step = .1,
			settingInfo = { TSM.db.profile.design, "edgeSize" },
		},
	}
	for _, widget in ipairs(miscWidgets) do
		tinsert(page[1].children[4].children, widget)
	end

	lib:BuildPage(parent, page)
end

function private:LoadProfilesPage(container)
	-- Popup Confirmation Window used in this module
	StaticPopupDialogs["TSMDeleteConfirm"] = StaticPopupDialogs["TSMDeleteConfirm"] or {
		text = L["Are you sure you want to delete the selected profile?"],
		button1 = ACCEPT,
		button2 = CANCEL,
		timeout = 0,
		whileDead = true,
		hideOnEscape = true,
		OnCancel = false,
		-- OnAccept defined later
	}
	StaticPopupDialogs["TSMCopyProfileConfirm"] = StaticPopupDialogs["TSMCopyProfileConfirm"] or {
		text = L["Are you sure you want to overwrite the current profile with the selected profile?"],
		button1 = ACCEPT,
		button2 = CANCEL,
		timeout = 0,
		whileDead = true,
		hideOnEscape = true,
		OnCancel = false,
		-- OnAccept defined later
	}

	-- profiles page
	local text = {
		default = L["Default"],
		intro = L["You can change the active database profile, so you can have different settings for every character."],
		reset_desc = L["Reset the current profile back to its default values, in case your configuration is broken, or you simply want to start over."],
		reset = L["Reset Profile"],
		choose_desc = L["You can either create a new profile by entering a name in the editbox, or choose one of the already exisiting profiles."],
		new = L["New"],
		new_sub = L["Create a new empty profile."],
		choose = L["Existing Profiles"],
		copy_desc = L["Copy the settings from one existing profile into the currently active profile."],
		copy = L["Copy From"],
		delete_desc = L["Delete existing and unused profiles from the database to save space, and cleanup the SavedVariables file."],
		delete = L["Delete a Profile"],
		profiles = L["Profiles"],
		current = L["Current Profile:"] .. " " .. TSMAPI.Design:ColorText(TSM.db:GetCurrentProfile(), "link"),
	}

	-- Returns a list of all the current profiles with common and nocurrent modifiers.
	-- This code taken from AceDBOptions-3.0.lua
	local function GetProfileList(db, common, nocurrent)
		local profiles = {}
		local tmpprofiles = {}
		local defaultProfiles = { ["Default"] = "Default" }

		-- copy existing profiles into the table
		local currentProfile = db:GetCurrentProfile()
		for i, v in pairs(db:GetProfiles(tmpprofiles)) do
			if not (nocurrent and v == currentProfile) then
				profiles[v] = v
			end
		end

		-- add our default profiles to choose from ( or rename existing profiles)
		for k, v in pairs(defaultProfiles) do
			if (common or profiles[k]) and not (nocurrent and k == currentProfile) then
				profiles[k] = v
			end
		end

		return profiles
	end

	local page = {
		{
			-- scroll frame to contain everything
			type = "ScrollFrame",
			layout = "Flow",
			children = {
				{
					type = "Label",
					text = text["intro"] .. "\n\n",
					relativeWidth = 1,
				},
				{
					type = "Label",
					text = text["reset_desc"],
					relativeWidth = 1,
				},
				{
					type = "Button",
					text = text["reset"],
					relativeWidth = .5,
					callback = function() TSM.db:ResetProfile() end,
				},
				{
					type = "Label",
					text = text["current"],
					relativeWidth = .49,
				},
				{
					type = "HeadingLine",
				},
				{
					type = "Label",
					text = text["choose_desc"],
					relativeWidth = 1,
				},
				{
					type = "EditBox",
					label = text["new"],
					value = "",
					relativeWidth = .5,
					callback = function(_, _, value)
						value = value:trim()
						if value == "" then
							return TSM:Print(L["You cannot create a profile with an empty name."])
						end
						TSM.db:SetProfile(value)
						container:ReloadTab()
					end,
				},
				{
					type = "Dropdown",
					label = text["choose"],
					list = GetProfileList(TSM.db, true, nil),
					value = TSM.db:GetCurrentProfile(),
					relativeWidth = .49,
					callback = function(_, _, value)
						if value ~= TSM.db:GetCurrentProfile() then
							TSM.db:SetProfile(value)
							container:ReloadTab()
						end
					end,
				},
				{
					type = "HeadingLine",
				},
				{
					type = "Label",
					text = text["copy_desc"],
					relativeWidth = 1,
				},
				{
					type = "Dropdown",
					label = text["copy"],
					list = GetProfileList(TSM.db, true, nil),
					value = "",
					disabled = not GetProfileList(TSM.db, true, nil) and true,
					callback = function(_, _, value)
						if value == TSM.db:GetCurrentProfile() then return end
						StaticPopupDialogs["TSMCopyProfileConfirm"].OnAccept = function()
							TSM.db:CopyProfile(value)
							container:ReloadTab()
						end
						TSMAPI:ShowStaticPopupDialog("TSMCopyProfileConfirm")
					end,
				},
				{
					type = "HeadingLine",
				},
				{
					type = "Label",
					text = text["delete_desc"],
					relativeWidth = 1,
				},
				{
					type = "Dropdown",
					label = text["delete"],
					list = GetProfileList(TSM.db, true, nil),
					value = "",
					disabled = not GetProfileList(TSM.db, true, nil) and true,
					callback = function(_, _, value)
						if TSM.db:GetCurrentProfile() == value then
							TSM:Print(L["Cannot delete currently active profile!"])
							return
						end
						StaticPopupDialogs["TSMDeleteConfirm"].OnAccept = function()
							TSM.db:DeleteProfile(value)
							container:ReloadTab()
						end
						TSMAPI:ShowStaticPopupDialog("TSMDeleteConfirm")
					end,
				},
			},
		},
	}

	TSMAPI:BuildPage(container, page)
end

local treeGroup
function private:LoadCustomPriceSources(parent)
	private.treeGroup = AceGUI:Create("TSMTreeGroup")
	private.treeGroup:SetLayout("Fill")
	private.treeGroup:SetCallback("OnGroupSelected", private.SelectTree)
	private.treeGroup:SetStatusTable(TSM.db.profile.customPriceSourceTreeStatus)
	parent:AddChild(private.treeGroup)
	
	private:UpdateTree()
	private.treeGroup:SelectByPath(1)
end

function private:UpdateTree()
	if not private.treeGroup then return end
	
	local children = {}
	for name in pairs(TSM.db.global.customPriceSources) do
		tinsert(children, {value=name, text=name})
	end
	sort(children, function(a, b) return strlower(a.value) < strlower(b.value) end)
	private.treeGroup:SetTree({{value=1, text=L["Sources"], children=children}})
end

function private.SelectTree(treeGroup, _, selection)
	treeGroup:ReleaseChildren()
	
	selection = {("\001"):split(selection)}
	if #selection == 1 then
		private:DrawNewCustomPriceSource(treeGroup)
	else
		local name = selection[#selection]
		private:DrawCustomPriceSourceOptions(treeGroup, name)
	end
end

function private:DrawNewCustomPriceSource(container)
	local page = {
		{	-- scroll frame to contain everything
			type = "ScrollFrame",
			layout = "List",
			children = {
				{
					type = "InlineGroup",
					layout = "flow",
					title = L["New Custom Price Source"],
					children = {
						{
							type = "Label",
							relativeWidth = 1,
							text = L["Custom price sources allow you to create more advanced custom prices throughout all of the TSM modules. Just as you can use the built-in price sources such as 'vendorsell' and 'vendorbuy' in your custom prices, you can use ones you make here (which themselves are custom prices)."],
						},
						{
							type = "HeadingLine",
						},
						{
							type = "EditBox",
							label = L["Custom Price Source Name"],
							relativeWidth = 0.8,
							callback = function(self,_,value)
								value = strlower((value or ""):trim())
								if value == "" then return end
								if gsub(value, "([a-z]+)", "") ~= "" then
									return TSM:Print(L["The name can ONLY contain letters. No spaces, numbers, or special characters."])
								end
								if TSM.db.global.customPriceSources[value] then
									return TSM:Printf(L["Error creating custom price source. Custom price source with name '%s' already exists."], value)
								end
								TSM.db.global.customPriceSources[value] = ""
								private:UpdateTree()
								if TSM.db.profile.gotoNewCustomPriceSource then
									private.treeGroup:SelectByPath(1, value)
								else
									self:SetText()
									self:SetFocus()
								end
							end,
							tooltip = L["Give your new custom price source a name. This is what you will type in to custom prices and is case insensitive (everything will be saved as lower case)."].."\n\n"..TSMAPI.Design:ColorText(L["The name can ONLY contain letters. No spaces, numbers, or special characters."], "link"),
						},
						{
							type = "CheckBox",
							label = L["Switch to New Custom Price Source After Creation"],
							relativeWidth = 1,
							settingInfo = {TSM.db.profile, "gotoNewCustomPriceSource"},
						},
					},
				},
			},
		},
	}
	TSMAPI:BuildPage(container, page)
end

function private:DrawCustomPriceSourceOptions(container, customPriceName)
	local page = {
		{	-- scroll frame to contain everything
			type = "ScrollFrame",
			layout = "List",
			children = {
				{
					type = "InlineGroup",
					layout = "flow",
					title = L["Custom Price Source"],
					children = {
						{
							type = "Label",
							relativeWidth = 1,
							text = L["Below, set the custom price that will be evaluated for this custom price source."],
						},
						{
							type = "HeadingLine",
						},
						{
							type = "EditBox",
							label = L["Custom Price for this Source"],
							settingInfo = {TSM.db.global.customPriceSources, customPriceName},
							relativeWidth = 0.49,
							acceptCustom = true,
							tooltip = "",
						},
					},
				},
				{
					type = "InlineGroup",
					layout = "flow",
					title = L["Management"],
					children = {
						{
							type = "EditBox",
							label = L["Rename Custom Price Source"],
							value = operationName,
							relativeWidth = 0.5,
							callback = function(self,_,name)
								name = strlower((name or ""):trim())
								if name == "" then return end
								if gsub(name, "([a-z]+)", "") ~= "" then
									return TSM:Print(L["The name can ONLY contain letters. No spaces, numbers, or special characters."])
								end
								if TSM.db.global.customPriceSources[name] then
									return TSM:Printf(L["Error renaming custom price source. Custom price source with name '%s' already exists."], name)
								end
								TSM.db.global.customPriceSources[name] = TSM.db.global.customPriceSources[customPriceName]
								TSM.db.global.customPriceSources[customPriceName] = nil
								private:UpdateTree()
								private.treeGroup:SelectByPath(1, name)
							end,
							tooltip = L["Give your new custom price source a name. This is what you will type in to custom prices and is case insensitive (everything will be saved as lower case)."].."\n\n"..TSMAPI.Design:ColorText(L["The name can ONLY contain letters. No spaces, numbers, or special characters."], "link"),
						},
						{
							type = "Button",
							text = L["Delete Custom Price Source"],
							relativeWidth = 0.5,
							callback = function()
								TSM.db.global.customPriceSources[customPriceName] = nil
								private:UpdateTree()
								private.treeGroup:SelectByPath(1)
								TSM:Printf(L["Removed '%s' as a custom price source. Be sure to update any custom prices that were using this source."], customPriceName)
							end,
						},
					},
				},
			},
		},
	}
	TSMAPI:BuildPage(container, page)
end


function TSM:LoadOptions(parent)
	local tg = AceGUI:Create("TSMTabGroup")
	tg:SetLayout("Fill")
	tg:SetFullWidth(true)
	tg:SetFullHeight(true)
	tg:SetTabs({ { value = 1, text = L["TSM Info / Help"] }, { value = 2, text = L["Options"] }, { value = 3, text = L["Profiles"] }, { value = 4, text = TSMAPI.Design:ColorText(L["Custom Price Sources"], "advanced") } })
	tg:SetCallback("OnGroupSelected", function(self, _, value)
		tg:ReleaseChildren()
		StaticPopup_Hide("TSM_GLOBAL_OPERATIONS")

		if value == 1 then
			private:LoadHelpPage(self)
		elseif value == 2 then
			private:LoadOptionsPage(self)
		elseif value == 3 then
			private:LoadProfilesPage(self)
		elseif value == 4 then
			private:LoadCustomPriceSources(self)
		end
	end)
	parent:AddChild(tg)
	tg:SelectTab(1)
end