-- ------------------------------------------------------------------------------ --
--                            TradeSkillMaster_Shopping                           --
--            http://www.curse.com/addons/wow/tradeskillmaster_shopping           --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

local TSM = select(2, ...)
local Search = TSM:NewModule("Search", "AceEvent-3.0", "AceHook-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster_Shopping") -- loads the localization table
local private = {}

-- ------------------------------------------------ --
--					GUI Creation functions					 --
-- ------------------------------------------------ --

function Search:Show(frame)
	TSM.Util:SetParent(frame)
	private.searchBar = private.searchBar or private:CreateSearchBar(frame)
	private.searchBar:Show()
	private.searchBar.editBox:SetFocus()
	private.searchBar.editBox:SetText("")
	private.searchBar:Enable()
	private.searchBar.normal:Click()
	TSM.Sidebar:Show(frame)
	if TSM.db.global.sidebarBtn > #private.searchBar.buttons then
		TSM.db.global.sidebarBtn = 0
	end
	if TSM.db.global.sidebarBtn > 0 then
		if not private.searchBar.buttons[TSM.db.global.sidebarBtn].isSelected then
			private.searchBar.buttons[TSM.db.global.sidebarBtn]:Click()
		end
	else
		TSM.Sidebar:Hide()
	end
end

function Search:Hide()
	if not private.searchBar then return end
	private.searchBar:Hide()
	TSM.Util:HideSearchFrame()
	TSMAPI.AuctionControl:HideControlButtons()
	TSMAPI.AuctionScan:StopScan()
	TSM.Sidebar:Hide()
end

function private:CreateSearchBar(parent)
	local function StartSearch(searchQuery)
		if private.mode == "normal" then
			Search:StartFilterSearch(searchQuery)
		elseif private.mode == "destroy" then
			private.searchBar.editBox:SetText(searchQuery)
			local filters = Search:GetFilters(searchQuery)
			if filters and #filters == 1 then
				for itemString, name in pairs(TSM.db.global.destroyingTargetItems) do
					if strlower(name) == strlower(filters.currentFilter) then
						return TSM.Destroying:StartDestroyingSearch(itemString, filters[1])
					end
				end
				TSM:Printf(L["Invalid target item for destroy search: '%s'"], filters.currentFilter)
			else
				TSM:Printf(L["Invalid destroy search: '%s'"], searchQuery)
			end
		end
	end

	local function HandleModifiedItemClick(link)
		local putIntoChat = Search.hooks.HandleModifiedItemClick(link)
		if not putIntoChat and private.searchBar:IsVisible() and not private.searchBar.isDisabled and TSMAPI:AHTabIsVisible("Shopping") then
			local name = TSMAPI:GetSafeItemInfo(link)
			if name then
				StartSearch(name.."/exact")
				return true
			end
		end
		return putIntoChat
	end
	local function InsertLink(link)
		local putIntoChat = Search.hooks.ChatEdit_InsertLink(link)
		if not putIntoChat then
			if private.searchBar:IsVisible() and not private.searchBar.isDisabled and TSMAPI:AHTabIsVisible("Shopping") then
				local name = TSMAPI:GetSafeItemInfo(link)
				if name then
					StartSearch(name.."/exact")
					return true
				end
			end
		end
		return putIntoChat
	end
	Search:RawHook("ChatEdit_InsertLink", InsertLink, true)
	Search:RawHook("HandleModifiedItemClick", HandleModifiedItemClick, true)

	local function OnChar(self)
		local text = self:GetText()
		if private.mode == "normal" then
			for i=1, #TSM.db.global.previousSearches do
				local prevSearch = strlower(TSM.db.global.previousSearches[i])
				if strsub(prevSearch, 1, #text) == strlower(text) then
					self:SetText(prevSearch)
					self:HighlightText(#text, -1)
					break
				end
			end
		elseif private.mode == "destroy" then
			for _, name in pairs(TSM.db.global.destroyingTargetItems) do
				name = strlower(name)
				if strsub(name, 1, #text) == strlower(text) then
					self:SetText(name)
					self:HighlightText(#text, -1)
					break
				end
			end
		end
	end
	
	local function OnEditFocusGained(self)
		self:HighlightText()
	end
	
	local function OnEditFocusLost(self)
		self:HighlightText()
	end
	
	local function OnUpdate(self)
		-- if self:IsEnabled() and not TSMAPI:AHTabIsVisible("Shopping") then
		if not TSMAPI:AHTabIsVisible("Shopping") then
			self:ClearFocus()
		end
	end
	
	local function OnEnter(self)
		GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
		GameTooltip:SetMinimumWidth(400)
		GameTooltip:AddLine(L["Enter what you want to search for in this box. You can also use the following options for more complicated searches."].."\n", 1, 1, 1, 1)
		GameTooltip:AddLine(format("|cffffff00"..L["Multiple Search Terms:|r You can search for multiple things at once by simply separated them with a ';'. For example '%scopper ore; gold ore|r' will search for both copper and gold ore."].."\n", TSMAPI.Design:GetInlineColor("link2")), 1, 1, 1, 1)
		GameTooltip:AddLine(format("|cffffff00"..L["Inline Filters:|r You can easily add common search filters to your search such as rarity, level, and item type. For example '%sarmor/leather/epic/80/i200/i285|r' will search for all leather armor of epic quality that requires level 80 and has an ilvl between 200 and 285 inclusive. Also, '%sinferno ruby/exact|r' will display only raw inferno rubys (none of the cuts)."].."\n", TSMAPI.Design:GetInlineColor("link2"), TSMAPI.Design:GetInlineColor("link2")), 1, 1, 1, 1)
		GameTooltip:Show()
	end

	
	local searchBarFrame = CreateFrame("Frame", nil, parent)
	searchBarFrame:SetAllPoints()
	searchBarFrame:Hide()

	local eb = TSMAPI.GUI:CreateInputBox(searchBarFrame)
	eb:SetPoint("TOPLEFT", 85, -5)
	eb:SetHeight(22)
	eb:SetWidth(600)
	eb:SetScript("OnShow", eb.SetFocus)
	eb:SetScript("OnEnterPressed", function() StartSearch(private.searchBar.editBox:GetText()) end)
	eb:SetScript("OnChar", OnChar)
	eb:SetScript("OnEditFocusGained", OnEditFocusGained)
	eb:SetScript("OnEditFocusLost", OnEditFocusLost)
	eb:SetScript("OnEnter", OnEnter)
	eb:SetScript("OnLeave", function() GameTooltip:Hide() end)
	eb:SetScript("OnUpdate", OnUpdate)
	searchBarFrame.editBox = eb
	
	local btn = TSMAPI.GUI:CreateButton(searchBarFrame, 20)
	btn:SetPoint("TOPLEFT", eb, "TOPRIGHT", 4, 0)
	btn:SetPoint("BOTTOMLEFT", eb, "BOTTOMRIGHT", 4, 0)
	btn:SetWidth(85)
	btn:SetText(SEARCH)
	btn:SetScript("OnClick", function() StartSearch(private.searchBar.editBox:GetText()) end)
	searchBarFrame.button = btn
	
	local btn = TSMAPI.GUI:CreateButton(searchBarFrame, 16)
	btn:SetPoint("TOPLEFT", searchBarFrame.button, "TOPRIGHT", 4, 0)
	btn:SetPoint("BOTTOMLEFT", searchBarFrame.button, "BOTTOMRIGHT", 4, 0)
	btn:SetPoint("TOPRIGHT", -5, -5)
	btn:SetText(L["Stop"])
	btn:Disable()
	btn:SetScript("OnClick", function() TSM.Util:StopScan() searchBarFrame:Enable() end)
	searchBarFrame.stop = btn
	
	local function OnModeChange(self)
		searchBarFrame.normal:UnlockHighlight()
		searchBarFrame.destroy:UnlockHighlight()
		self:LockHighlight()
		if self.mode ~= private.mode then
			private.mode = self.mode
			private:UpdateMode()
		end
	end
	
	local btn = TSMAPI.GUI:CreateButton(searchBarFrame, 14)
	btn:SetPoint("TOPLEFT", eb, "BOTTOMLEFT", 0, -8)
	btn:SetHeight(16)
	btn:SetWidth(110)
	btn:SetText(L["Normal Mode"])
	btn:SetScript("OnClick", OnModeChange)
	btn.mode = "normal"
	btn.tooltip = L["When in normal mode, you may run simple and filtered searches of the auction house."]
	searchBarFrame.normal = btn
	
	local btn = TSMAPI.GUI:CreateButton(searchBarFrame, 14)
	btn:SetPoint("TOPLEFT", searchBarFrame.normal, "BOTTOMLEFT", 0, -4)
	btn:SetPoint("TOPRIGHT", searchBarFrame.normal, "BOTTOMRIGHT", 0, -4)
	btn:SetHeight(16)
	btn:SetText(L["Destroy Mode"])
	btn:SetScript("OnClick", OnModeChange)
	btn.mode = "destroy"
	btn.tooltip = L["When in destroy mode, you simply enter a target item (ink/pigment, enchanting mat, gem, etc) into the search box to search for everything you can destroy to get that item."]
	searchBarFrame.destroy = btn
	
	local line = TSMAPI.GUI:CreateHorizontalLine(searchBarFrame, 0)
	line:ClearAllPoints()
	line:SetHeight(4)
	line:SetPoint("TOPLEFT", eb, "BOTTOMLEFT", 120, -7)
	line:SetPoint("TOPRIGHT", 0, -34)
	
	local pagesLabel = TSMAPI.GUI:CreateLabel(searchBarFrame)
	pagesLabel:SetPoint("TOPLEFT", eb, "BOTTOMLEFT", 125, -15)
	pagesLabel:SetHeight(20)
	pagesLabel:SetJustifyH("CENTER")
	pagesLabel:SetJustifyV("CENTER")
	pagesLabel:SetText(L["Sidebar Pages:"])
	pagesLabel:SetWidth(pagesLabel:GetWidth() + 5)
	
	local buttons = {}
	local function OnClick(self)
		self.isSelected = not self.isSelected
		for _, btn in ipairs(buttons) do
			btn:UnlockHighlight()
			if btn ~= self then
				btn.isSelected = false
			end
		end
		if self.isSelected then
			TSM.db.global.sidebarBtn = self.index
			self:LockHighlight()
			TSM.Sidebar:Show()
		else
			TSM.db.global.sidebarBtn = 0
			self:UnlockHighlight()
			TSM.Sidebar:Hide()
		end
		TSM.Sidebar:ButtonClick(self.label)
	end
	local pages, callbacks = TSM.Sidebar:GetPages()
	for i, label in ipairs(pages) do
		local btn = TSMAPI.GUI:CreateButton(searchBarFrame, 16)
		btn:SetPoint("TOPLEFT", buttons[i-1] or pagesLabel, "TOPRIGHT", 5, 0)
		btn:SetHeight(20)
		btn:SetText(label)
		btn:SetWidth(ceil(btn:GetTextWidth()+10))
		btn:SetScript("OnClick", OnClick)
		btn.label = label
		btn.index = i
		buttons[i] = btn
	end
	searchBarFrame.buttons = buttons
	
	local line = TSMAPI.GUI:CreateHorizontalLine(searchBarFrame, 0)
	line:ClearAllPoints()
	line:SetHeight(4)
	line:SetPoint("TOPLEFT", eb, "BOTTOMLEFT", 120, -40)
	line:SetPoint("TOPRIGHT", 0, -67)
	
	local line = TSMAPI.GUI:CreateVerticalLine(searchBarFrame, 0)
	line:ClearAllPoints()
	line:SetPoint("TOPLEFT", eb, "BOTTOMLEFT", 120, -7)
	line:SetHeight(33)
	line:SetWidth(4)
	
	searchBarFrame.Disable = function(self)
		self.isDisabled = true
		self.editBox:ClearFocus()
		self.editBox:HighlightText(0, 0)
		-- self.editBox:Disable()
		self.button:Disable()
		self.stop:Enable()
	end
	searchBarFrame.Enable = function(self)
		self.isDisabled = nil
		-- self.editBox:Enable()
		self.button:Enable()
		self.stop:Disable()
	end
	
	return searchBarFrame
end

function private:UpdateMode()
	private.searchBar.editBox:SetText("")
	if private.mode == "nomal" then
		TSM.Util:ShowSearchFrame(nil, L["% Market Value"], true)
	elseif private.mode == "destroy" then
		TSM.Util:ShowSearchFrame(true, L["% Target Value"], true)
	end
	TSM.Util:StopScan()
	private.searchBar:Enable()
end

local function ScanCallback(event, ...)
	if TSM.searchCallback then
		TSM.searchCallback(event)
	end
	if event == "filter" then
		local filter = ...
		return filter.maxPrice
	elseif event == "process" then
		local itemString, auctionItem = ...
		if auctionItem.query.maxPrice then
			auctionItem:FilterRecords(function(record)
					return (record:GetItemBuyout() or 0) > auctionItem.query.maxPrice
				end)
		end
		if TSM.isCrafting then
			local func = TSMAPI:ParseCustomPrice("matprice")
			local price = func and func(itemString) or nil
			auctionItem:SetMarketValue(price)
		else
			auctionItem:SetMarketValue(TSM:GetMaxPrice(TSM.db.global.marketValueSource, itemString))
		end
		return auctionItem
	elseif event == "done" then
		private.searchBar:Enable()
		return
	end
end

function Search:StartFilterSearch(filter, callback, isCrafting)
	TSM.isCrafting = isCrafting
	TSM.searchCallback = callback
	if strfind(filter, "item:([0-9]+):?([0-9]*):?([0-9]*):?([0-9]*):?([0-9]*):?([0-9]*):?%-?([0-9]*)$") then --or strfind(filter, "battlepet:([0-9]+):?([0-9]*):?([0-9]*):?([0-9]*):?([0-9]*):?([0-9]*):?([0-9]*)$") then
		filter = TSMAPI:GetSafeItemInfo(filter) or filter
	end
	if TSM.isCrafting then
		TSM.Util:ShowSearchFrame(nil, L["% Mat Price"])
	else
		TSM.Util:ShowSearchFrame(nil, L["% Market Value"])
	end
	private.searchBar.editBox:SetText(filter)
	private.searchBar:Disable()
	if filter ~= "" then
		for i=#TSM.db.global.previousSearches, 1, -1 do
			if strlower(TSM.db.global.previousSearches[i]) == strlower(filter) then
				tremove(TSM.db.global.previousSearches, i)
			end
		end
		tinsert(TSM.db.global.previousSearches, 1, filter)
		while #TSM.db.global.previousSearches > 100 do
			tremove(TSM.db.global.previousSearches)
		end
		TSM.Sidebar:UpdateCurrentFrame()
	end
	local isItemList, itemList = true, {}
	for _, searchTerm in ipairs({(";"):split(filter)}) do
		if tonumber(searchTerm) then
			tinsert(itemList, TSMAPI:GetItemString(searchTerm))
		else
			isItemList = nil
		end
	end
	TSMAPI:FireEvent("SHOPPING:SEARCH:STARTFILTERSCAN")
	
	if isItemList then
		TSM.Util:StartItemScan(itemList, ScanCallback)
	else
		TSM.Util:StartFilterScan(Search:GetFilters(filter), ScanCallback)
	end
end

function Search:SetSearchBarDisabled(disabled)
	if disabled then
		private.searchBar:Disable()
	else
		private.searchBar:Enable()
	end
end

function Search:SetMode(mode)
	if mode == "normal" then
		private.searchBar.normal:Click()
	elseif mode == "destroy" then
		private.searchBar.destroy:Click()
	end
end

function Search:SetSearchText(text)
	private.searchBar.editBox:SetText(text)
end


-- ------------------------------------------------ --
--				Search Filter Util functions				 --
-- ------------------------------------------------ --

local function GetMaxQuantity(str)
	if #str > 1 and strsub(str, 1, 1) == "x" then
		return tonumber(strsub(str, 2))
	end
end

local function GetItemLevel(str)
	if #str > 1 and strsub(str, 1, 1) == "i" then
		return tonumber(strsub(str, 2))
	end
end

local function GetItemClass(str)
	for i, class in ipairs({GetAuctionItemClasses()}) do
		if strlower(str) == strlower(class) then
			return i
		end
	end
end

local function GetItemSubClass(str, class)
	if not class then return end

	for i, subClass in ipairs({GetAuctionItemSubClasses(class)}) do
		if strlower(str) == strlower(subClass) then
			return i
		end
	end
end

local function GetItemRarity(str)
	for i=0, 4 do
		local text =  _G["ITEM_QUALITY"..i.."_DESC"]
		if strlower(str) == strlower(text) then
			return i
		end
	end
end

local function GetSearchFilterOptions(searchTerm)
	local parts = {("/"):split(searchTerm)}
	local queryString, class, subClass, minLevel, maxLevel, minILevel, maxILevel, rarity, usableOnly, exactOnly, evenOnly, maxQuantity, maxPrice
	
	if #parts == 1 then
		return true, parts[1]
	elseif #parts == 0 then
		return false, L["Invalid Filter"]
	end
	
	for i, str in ipairs(parts) do
		str = str:trim()
		
		if tonumber(str) then
			if not minLevel then
				minLevel = tonumber(str)
			elseif not maxLevel then
				maxLevel = tonumber(str)
			else
				return false, L["Invalid Min Level"]
			end
		elseif GetMaxQuantity(str) then
			if not maxQuantity then
				maxQuantity = GetMaxQuantity(str)
			else
				return false, L["Invalid Max Quantity"]
			end
		elseif GetItemLevel(str) then
			if not minILevel then
				minILevel = GetItemLevel(str)
			elseif not maxILevel then
				maxILevel = GetItemLevel(str)
			else
				return false, L["Invalid Item Level"]
			end
		elseif not class and GetItemClass(str) then
			if not class then
				class = GetItemClass(str)
			else
				return false, L["Invalid Item Type"]
			end
		elseif GetItemSubClass(str, class) then
			if not subClass then
				subClass = GetItemSubClass(str, class)
			else
				return false, L["Invalid Item SubType"]
			end
		elseif GetItemRarity(str) then
			if not rarity then
				rarity = GetItemRarity(str)
			else
				return false, L["Invalid Item Rarity"]
			end
		elseif strlower(str) == "usable" then
			if not usableOnly then
				usableOnly = 1
			else
				return false, L["Invalid Usable Only Filter"]
			end
		elseif strlower(str) == "exact" then
			if not exactOnly then
				exactOnly = 1
			else
				return false, L["Invalid Exact Only Filter"]
			end
		elseif strlower(str) == "even" then
			if not evenOnly then
				evenOnly = 1
			else
				return false, L["Invalid Even Only Filter"]
			end
		elseif TSMAPI:UnformatTextMoney(str) then
			maxPrice = TSMAPI:UnformatTextMoney(str)
		elseif i == 1 then
			if strfind(str, "item:([0-9]+):?([0-9]*):?([0-9]*):?([0-9]*):?([0-9]*):?([0-9]*):?%-?([0-9]*)$") then --or strfind(str, "battlepet:([0-9]+):?([0-9]*):?([0-9]*):?([0-9]*):?([0-9]*):?([0-9]*):?([0-9]*)$") then
				queryString = TSMAPI:GetSafeItemInfo(str)
			else
				queryString = str
			end
		else
			return false, L["Unknown Filter"]
		end
	end
	
	if maxLevel and minLevel and maxLevel < minLevel then
		local oldMaxLevel = maxLevel
		maxLevel = minLevel
		minLevel = oldMaxLevel
	end
	
	if maxILevel and minILevel and maxILevel < minILevel then
		local oldMaxILevel = maxILevel
		maxILevel = minILevel
		minILevel = oldMaxILevel
	end
	
	return true, queryString or "", class or 0, subClass or 0, minLevel or 0, maxLevel or 0, minILevel or 0, maxILevel or 0, rarity or -1, usableOnly or 0, exactOnly or nil, evenOnly or nil, maxQuantity or 0, maxPrice
	--return true, queryString or "", class or 0, subClass or 0, minLevel or 0, maxLevel or 0, minILevel or 0, maxILevel or 0, rarity or 0, usableOnly or 0, exactOnly or nil, evenOnly or nil, maxQuantity or 0, maxPrice
end

-- gets all the filters for a given search term (possibly semicolon-deliminated list of search terms)
function Search:GetFilters(searchQuery)
	local filters = {}
	local searchTerms = {(";"):split(searchQuery)}
	filters.num = 0
	
	for i=1, #searchTerms do
		local searchTerm = searchTerms[i]:trim()
		if tonumber(searchTerm) then
			local filter = TSMAPI:GetAuctionQueryInfo(TSMAPI:GetItemString(searchTerm))
			if filter then
				tinsert(filters, filter)
				filters.num = filters.num + 1
				if filters.currentFilter then
					filters.currentFilter = filters.currentFilter.."; "..searchTerm
				else
					filters.currentFilter = searchTerm
				end
				if filters.currentSearchTerm then
					filters.currentSearchTerm = filters.currentSearchTerm .. "; "..searchTerm
				else
					filters.currentSearchTerm = searchTerm
				end
			end
		else
			local isValid, queryString, class, subClass, minLevel, maxLevel, minILevel, maxILevel, rarity, usableOnly, exactOnly, evenOnly, maxQuantity, maxPrice = GetSearchFilterOptions(searchTerm)
					
			if not isValid then
				TSM:Print(L["Skipped the following search term because it's invalid."])
				TSM:Print("\""..searchTerm.."\": "..queryString)
			elseif strlenutf8(queryString) > 63 then
				TSM:Print(L["Skipped the following search term because it's too long. Blizzard does not allow search terms over 63 characters."])
				TSM:Print("\""..searchTerm.."\"")
				isValid = nil
			end
		
			if isValid then
				filters.num = filters.num + 1
				if filters.currentFilter then
					filters.currentFilter = filters.currentFilter.."; "..queryString
				else
					filters.currentFilter = queryString
				end
				if filters.currentSearchTerm then
					filters.currentSearchTerm = filters.currentSearchTerm .. "; "..searchTerm
				else
					filters.currentSearchTerm = searchTerm
				end
				tinsert(filters, {name=queryString, usable=usableOnly, minLevel=minLevel, maxLevel=maxLevel, quality=rarity, class=class, subClass=subClass, minILevel=minILevel, maxILevel=maxILevel, exactOnly=exactOnly, evenOnly=evenOnly, maxQuantity=maxQuantity, maxPrice=maxPrice})
			end
		end
	end
	
	return filters
end

function Search:GetCurrentSearchMode()
	return private.mode
end