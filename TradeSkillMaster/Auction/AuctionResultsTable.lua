-- ------------------------------------------------------------------------------ --
--                                TradeSkillMaster                                --
--                http://www.curse.com/addons/wow/tradeskill-master               --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

local TSM = select(2, ...)
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster") -- loads the localization table

local RT_COUNT = 1

local HEAD_HEIGHT = 27
local HEAD_SPACE = 2
local purchaseCache = {}
local resultsTables = {}


local function OnSizeChanged(rt, width)
	for i, col in ipairs(rt.headCols) do
		col:SetWidth(col.info.width*width)
	end
	
	for _, row in ipairs(rt.rows) do
		for i, col in ipairs(row.cols) do
			col:SetWidth(rt.headCols[i].info.width*width)
		end
	end
end

local rowTextFunctions = {
	GetPriceText = function(buyout, displayBid)
		local bidLine = TSMAPI:FormatTextMoney(displayBid, "|cff999999", true) or "|cff999999---|r"
		local buyoutLine = buyout and buyout > 0 and TSMAPI:FormatTextMoney(buyout, nil, true) or "---"
		
		if TSM.db.profile.showBids then
			return bidLine.."\n"..buyoutLine
		else
			return buyoutLine
		end
	end,

	GetTimeLeftText = function(timeLeft)
		return _G["AUCTION_TIME_LEFT"..(timeLeft or "")] or ""
	end,

	GetNameText = function(_, link)
		return gsub(gsub(link, "%[", ""), "%]", "")
	end,

	GetAuctionsText = function(num, player, isExpandable, totalNum)
		num = totalNum or num
		local playerText = player and (" |cffffff00("..player..")|r") or ""

		if isExpandable then
			return TSMAPI.Design:GetInlineColor("link2")..num.."|r"..playerText
		else
			return num..playerText
		end
	end,

	GetSellerText = function(seller)
		if TSMAPI:IsPlayer(seller) then
			return "|cffffff00"..seller.."|r"
		else
			return seller or ""
		end
	end,

	GetPercentText = function(pct)
		if not pct then return "---" end
		return TSMAPI:GetAuctionPercentColor(pct)..floor(pct+0.5).."%|r"
	end
}

local function GetRowTable(rt, auction, isExpandable)
	if not auction then return end
	
	local bid, buyout
	if TSM.db.profile.pricePerUnit then
		bid = auction:GetItemDisplayedBid()
		buyout = auction:GetItemBuyout()
	else
		bid = auction:GetDisplayedBid()
		buyout = auction.buyout
	end
	
	local auctionsData, rowTable
	local itemString = auction.parent:GetItemString()
	if rt.expanded[itemString] then
		auctionsData = {#auction.parent.records, nil, nil, auction.numAuctions}
	else
		auctionsData = {#auction.parent.records, auction.parent.records[1].playerAuctions, isExpandable}
	end
	local name, iLvl
	if strmatch(auction.parent.itemLink, "battlepet") then
		local _, speciesID, itemLvl = strsplit(":", auction.parent.itemLink)
		local itemName = C_PetJournal.GetPetInfoBySpeciesID(speciesID)
		name, iLvl = itemName, itemLvl
	else
		local itemName, _, _, itemLvl = GetItemInfo(auction.parent.itemLink)
		name, iLvl = itemName, itemLvl
	end
	local pct = auction:GetPercent()
	if not pct or pct < 0 or pct == math.huge then
		pct = nil
	end
	
	if rt.isDestroying then
		local destroyingBid = auction:GetItemDestroyingDisplayedBid()
		local destroyingBuyout = auction:GetItemDestroyingBuyout()
		rowTable = {
			{value=rowTextFunctions.GetNameText, 		args={name, auction.parent.itemLink}},
			{value=rowTextFunctions.GetAuctionsText, 	args=auctionsData},
			{value=auction.count, 							args={auction.count}},
			{value=rowTextFunctions.GetSellerText,		args={auction.seller}},
			{value=rowTextFunctions.GetPriceText,		args={destroyingBuyout, destroyingBid}},
			{value=rowTextFunctions.GetPriceText,		args={buyout, bid}},
			{value=rowTextFunctions.GetPercentText, 	args={pct}},
		}
	else
		rowTable = {
			{value=rowTextFunctions.GetNameText, 		args={name, auction.parent.itemLink}},
			{value=(iLvl or "---"), 						args={iLvl or 0}},
			{value=rowTextFunctions.GetAuctionsText, 	args=auctionsData},
			{value=auction.count, 							args={auction.count}},
			{value=rowTextFunctions.GetTimeLeftText, 	args={auction.timeLeft}},
			{value=rowTextFunctions.GetSellerText,		args={auction.seller}},
			{value=rowTextFunctions.GetPriceText,		args={buyout, bid}},
			{value=rowTextFunctions.GetPercentText, 	args={pct}},
		}
	end
	
	rowTable.itemString = itemString
	rowTable.auctionRecord = auction
	rowTable.expandable = isExpandable
	rowTable.texture = auction.parent:GetTexture()
	rowTable.link = auction.parent.itemLink
	
	return rowTable
end

local function GetTableIndex(tbl, value)
	for i, v in pairs(tbl) do
		if value == v then
			return i
		end
	end
end

local function OnColumnClick(self, ...)
	local button = ...
	local rt = self.rt
	local column = GetTableIndex(rt.headCols, self)
	
	if button == "RightButton" and column == #rt.headCols-1 then
		TSM.db.profile.pricePerUnit = not TSM.db.profile.pricePerUnit
		local priceColName = TSM.db.profile.pricePerUnit and L["Price Per Item"] or L["Price Per Stack"]
		self:SetText(priceColName)
		rt:RefreshRowData()
		return
	end
	
	local ascending = rt.sortInfo.ascending
	rt:SetSort(column, rt.sortInfo.column ~= column or not ascending)
	
	local handler = self.rt.handlers.OnColumnClick
	if handler then
		handler(self.rt, self.row.data, self, ...)
	end
end

local methods = {
	DrawRows = function(rt)
		if not rt.auctionData then return end
		for i=1, rt.NUM_ROWS do
			rt.rows[i]:Hide()
		end
	
		wipe(rt.displayRows)
		local itemsUsed = {}
		for i, data in ipairs(rt.data) do
			local itemString = data.itemString
			if not itemsUsed[itemString] or rt.expanded[itemString] then
				tinsert(rt.displayRows, data)
				itemsUsed[itemString] = true
			elseif i == rt.selected then
				rt.selected = nil
			end
		end
	
		FauxScrollFrame_Update(rt.scrollFrame, #rt.displayRows, rt.NUM_ROWS, rt.ROW_HEIGHT)
		local offset = FauxScrollFrame_GetOffset(rt.scrollFrame)
		rt.offset = offset

		for i=1, min(rt.NUM_ROWS, #rt.displayRows) do
			rt.rows[i]:Show()
			local data = rt.displayRows[i+offset]
			local cols = rt.rows[i].cols
			rt.rows[i].data = data
			
			if rt.selected == GetTableIndex(rt.data, data) then
				rt.rows[i].highlight:Show()
			else
				rt.rows[i].highlight:Hide()
			end
			
			for j, col in ipairs(rt.rows[i].cols) do
				local colData = data[j]
				
				if j == 1 then
					col.icon:SetTexture(data.texture)
					if data.indented then
						col.spacer:SetWidth(10)
						col.icon:SetAlpha(0.5)
						col:GetFontString():SetAlpha(0.7)
					else
						col.spacer:SetWidth(1)
						col.icon:SetAlpha(1)
						col:GetFontString():SetAlpha(1)
					end
				end
				
				if type(colData.value) == "function" then
					col:SetText(colData.value(unpack(colData.args)))
				else
					col:SetText(colData.value)
				end
			end
		end
		
		rt:UpdateActiveRows()
	end,

	RefreshRowData = function(rt)
		if not rt.auctionData then return end
		wipe(rt.data)
		wipe(rt.displayRows)
		
		local function RowSort(a, b)
			local aVal = a[rt.sortInfo.column].args[1]
			local bVal = b[rt.sortInfo.column].args[1]
			if type(aVal) ~= "string" or type(bVal) ~= "string" then
				aVal = tonumber(aVal) or 0
				bVal = tonumber(bVal) or 0
			end
			if aVal == bVal then
				-- make this a stable sort (abitrarily) by using table reference strings
				return tostring(a) < tostring(b)
			end
			if rt.sortInfo.ascending then
				return aVal < bVal
			else
				return aVal > bVal
			end
		end
		
		local tmp = {}
		for _, auction in ipairs(rt.auctionData) do
			local itemString = auction:GetItemString()
			local itemRowData = {}
			for i, data in ipairs(auction.compactRecords) do
				local rowTbl = GetRowTable(rt, data, #auction.compactRecords > 1)
				rowTbl.indented = true
				tinsert(itemRowData, rowTbl)
			end
			
			sort(itemRowData, RowSort)
			if itemRowData[1] then
				itemRowData[1].indented = false
			end
			tinsert(tmp, itemRowData)
		end
		
		sort(tmp, function(a, b) return RowSort(a[1], b[1]) end)
		
		for _, itemRows in ipairs(tmp) do
			for _, row in ipairs(itemRows) do
				tinsert(rt.data, row)
			end
		end
		
		rt:DrawRows()
	end,

	SetData = function(rt, auctionData)
		rt.auctionData = auctionData
		rt:RefreshRowData()
	end,

	ClearSelection = function(rt)
		rt.selected = nil
		rt:DrawRows()
	end,

	SetSelectedAuction = function(rt, auction)
		rt.selected = nil
		for i, data in ipairs(rt.data) do
			if type(auction) == "table" then
				if data.auctionRecord == auction or data.auctionRecord:Equals(auction) then
					rt.selected = i
					break
				end
			elseif type(auction) == "string" then
				if data.itemString == auction then
					rt.selected = i
					break
				end
			end
		end
		rt:DrawRows()
	end,
	
	GetSelectedAuction = function(rt)
		if not rt.selected or not rt.data[rt.selected] then return end
		return rt.data[rt.selected].auctionRecord
	end,
	
	SetExpanded = function(rt, itemString, expanded)
		rt.expanded[itemString] = expanded
		rt:RefreshRowData()
	end,
	
	ToggleExpanded = function(rt, itemString)
		rt.expanded[itemString] = not rt.expanded[itemString]
		rt:RefreshRowData()
	end,
	
	SetSort = function(rt, column, ascending)
		if not rt.headCols[column or 0] then return end
		rt.sortInfo.column = column
		rt.sortInfo.ascending = ascending

		for _, col in ipairs(rt.headCols) do
			local tex = col:GetNormalTexture()
			tex:SetTexture("Interface\\WorldStateFrame\\WorldStateFinalScore-Highlight")
			tex:SetTexCoord(0.017, 1, 0.083, 0.909)
			tex:SetAlpha(0.5)
		end

		if ascending then
			rt.headCols[column]:GetNormalTexture():SetTexture(0.6, 0.8, 1, 0.8)
		else
			rt.headCols[column]:GetNormalTexture():SetTexture(0.8, 0.6, 1, 0.8)
		end
		rt:RefreshRowData()
	end,
	
	SetDisabled = function(rt, disabled)
		rt.disabled = disabled
	end,
	
	SetColHeadText = function(rt, column, text)
		rt.headCols[column]:SetText(text)
	end,
	
	UpdateActiveRows = function(rt)
		if not rt.quickBuyout then return end
		for _, row in ipairs(rt.rows) do
			row:HideActiveBorder()
			if row.data then
				local rowRecord = row.data.auctionRecord
				for i=1, GetNumAuctionItems("list") do
					local itemString = TSMAPI:GetItemString(GetAuctionItemLink("list", i))
					local _, _, count, _, _, _, _, _, _, buyout, _, _, _, seller = GetAuctionItemInfo("list", i)
					if itemString == row.data.itemString and rowRecord.count == count and rowRecord.buyout == buyout and rowRecord.seller == seller then
						row:ShowActiveBorder()
						break
					end
				end
			end
		end
		wipe(purchaseCache)
	end,
}

local defaultColScripts = {
	OnEnter = function(self, ...)
		if self.rt.disabled then return end
		
		if self ~= self.row.cols[1] or not self.rt.isShowingItemTooltip then
			GameTooltip:SetOwner(self, "ANCHOR_NONE")
			GameTooltip:SetPoint("BOTTOMLEFT", self, "TOPLEFT")

			local data = self.row.data
			local extra = ""
			if self.row.isActive then
				extra = TSMAPI.Design:GetInlineColor("link").."\n\n"..L["Alt-Click to immediately buyout this auction."].."|r"
			end
			if self.rt.expanded[data.itemString] then
				GameTooltip:AddLine(L["Double-click to collapse this item and show only the cheapest auction."]..extra, 1, 1, 1, true)
			elseif data.expandable then
				GameTooltip:AddLine(L["Double-click to expand this item and show all the auctions."]..extra, 1, 1, 1, true)
			else
				GameTooltip:AddLine(L["There is only one price level and seller for this item."]..extra, 1, 1, 1, true)
			end
			GameTooltip:Show()
		end
		
		self.row.highlight:Show()
		
		local handler = self.rt.handlers.OnEnter
		if handler then
			handler(self.rt, self.row.data, self, ...)
		end
	end,
	
	OnLeave = function(self, ...)
		if self.rt.disabled then return end
		
		if self ~= self.row.cols[1] or not self.rt.isShowingItemTooltip then
			GameTooltip:Hide()
		end
		
		if not self.rt.selected or self.rt.selected ~= GetTableIndex(self.rt.data, self.row.data) then
			self.row.highlight:Hide()
		end
		
		local handler = self.rt.handlers.OnLeave
		if handler then
			handler(self.rt, self.row.data, self, ...)
		end
	end,
	
	OnClick = function(self, button, ...)
		if self.rt.disabled then return end
		self.rt:ClearSelection()
		self.rt.selected = GetTableIndex(self.rt.data, self.row.data)
		self.row.highlight:Show()
		
		if self.rt.quickBuyout and IsAltKeyDown() then
			local rowRecord = self.row.data.auctionRecord
			for i=GetNumAuctionItems("list"), 1, -1 do
				local link = GetAuctionItemLink("list", i)
				if not purchaseCache[link] then
					local itemString = TSMAPI:GetItemString(link)
					local _, _, count, _, _, _, _, _, _, buyout, _, _, _, seller = GetAuctionItemInfo("list", i)
					if itemString == self.row.data.itemString and rowRecord.count == count and rowRecord.buyout == buyout and rowRecord.seller == seller then
						PlaceAuctionBid("list", i, rowRecord.buyout)
						TSM:AuctionControlCallback("OnBuyout", {itemString=TSMAPI:GetItemString(rowRecord.parent.itemLink), link=rowRecord.parent.itemLink, count=rowRecord.count, seller=rowRecord.seller, buyout=rowRecord.buyout, destroyingNum=rowRecord.parent.destroyingNum})
						purchaseCache[link] = true
						return
					end
				end
			end
		end
		
		local handler = self.rt.handlers.OnClick
		if handler then
			handler(self.rt, self.row.data, self, button, ...)
		end
	end,
	
	OnDoubleClick = function(self, ...)
		if self.rt.disabled then return end
		local data = self.row.data
		if data.expandable then
			self.rt:ToggleExpanded(data.itemString)
		end
		
		local handler = self.rt.handlers.OnDoubleClick
		if handler then
			handler(self.rt, self.row.data, self, ...)
		end
	end,
}

function TSMAPI:CreateAuctionResultsTable(parent, handlers, quickBuyout, isDestroying)
	local priceColName = TSM.db.profile.pricePerUnit and "Price Per Item" or "Price Per Stack"
	local colInfo = isDestroying and {
			{name=L["Item"], width=0.43},
			{name=L["Auctions"], width=0.07, align="CENTER"},
			{name=L["Stack Size"], width=0.05, align="CENTER"},
			{name=L["Seller"], width=0.11, align="CENTER"},
			{name=L["Price Per Target Item"], width=0.13, align="RIGHT", isPrice=true},
			{name=priceColName, width=0.13, align="RIGHT", isPrice=true},
			{name=L["% Market Value"], width=0.08, align="CENTER"},
		} or {
			{name=L["Item"], width=0.42},
			{name=L["Item Level"], width=0.05, align="CENTER"},
			{name=L["Auctions"], width=0.07, align="CENTER"},
			{name=L["Stack Size"], width=0.05, align="CENTER"},
			{name=L["Time Left"], width=0.09, align="CENTER"},
			{name=L["Seller"], width=0.11, align="CENTER"},
			{name=priceColName, width=0.13, align="RIGHT", isPrice=true},
			{name=L["% Market Value"], width=0.08, align="CENTER"},
		}
	
	local rtName = "TSMAuctionResultsTable"..RT_COUNT
	RT_COUNT = RT_COUNT + 1
	local rt = CreateFrame("Frame", rtName, parent)
	rt.NUM_ROWS = TSM.db.profile.auctionResultRows
	rt.ROW_HEIGHT = (parent:GetHeight()-HEAD_HEIGHT-HEAD_SPACE)/rt.NUM_ROWS
	
	rt:SetScript("OnShow", function()
			local priceColName = TSM.db.profile.pricePerUnit and L["Price Per Item"] or L["Price Per Stack"]
			rt:SetColHeadText(#rt.headCols-1, priceColName)
			rt:RefreshRowData()
		end)
	
	local contentFrame = CreateFrame("Frame", rtName.."Content", rt)
	contentFrame:SetPoint("TOPLEFT")
	contentFrame:SetPoint("BOTTOMRIGHT", -15, 0)
	contentFrame:SetScript("OnSizeChanged", function(_, width) OnSizeChanged(rt, width) end)
	rt.contentFrame = contentFrame
	
	-- frame to hold the header columns and the rows
	local scrollFrame = CreateFrame("ScrollFrame", rtName.."ScrollFrame", rt, "FauxScrollFrameTemplate")
	scrollFrame:SetScript("OnVerticalScroll", function(self, offset)
		FauxScrollFrame_OnVerticalScroll(self, offset, rt.ROW_HEIGHT, function() rt:DrawRows() end) 
	end)
	scrollFrame:SetAllPoints(contentFrame)
	rt.scrollFrame = scrollFrame
	
	-- make the scroll bar consistent with the TSM theme
	local scrollBar = _G[scrollFrame:GetName().."ScrollBar"]
	scrollBar:ClearAllPoints()
	scrollBar:SetPoint("BOTTOMRIGHT", rt, -1, 1)
	scrollBar:SetPoint("TOPRIGHT", rt, -1, -HEAD_HEIGHT)
	scrollBar:SetWidth(12)
	local thumbTex = scrollBar:GetThumbTexture()
	thumbTex:SetPoint("CENTER")
	TSMAPI.Design:SetFrameColor(thumbTex)
	thumbTex:SetHeight(150)
	thumbTex:SetWidth(scrollBar:GetWidth())
	_G[scrollBar:GetName().."ScrollUpButton"]:Hide()
	_G[scrollBar:GetName().."ScrollDownButton"]:Hide()
	
	-- create the header columns
	rt.headCols = {}
	for i, info in ipairs(colInfo) do
		local col = CreateFrame("Button", rtName.."HeadCol"..i, rt.contentFrame)
		col:SetHeight(HEAD_HEIGHT)
		if i == 1 then
			col:SetPoint("TOPLEFT")
		else
			col:SetPoint("TOPLEFT", rt.headCols[i-1], "TOPRIGHT")
		end
		col.info = info
		col.rt = rt
		col:RegisterForClicks("AnyUp")
		col:SetScript("OnClick", OnColumnClick)
		
		local text = col:CreateFontString()
		text:SetJustifyH("CENTER")
		text:SetJustifyV("CENTER")
		text:SetFont(TSMAPI.Design:GetContentFont("small"))
		TSMAPI.Design:SetWidgetTextColor(text)
		col:SetFontString(text)
		col:SetText(info.name or "")
		text:SetAllPoints()

		local tex = col:CreateTexture()
		tex:SetAllPoints()
		tex:SetTexture("Interface\\WorldStateFrame\\WorldStateFinalScore-Highlight")
		tex:SetTexCoord(0.017, 1, 0.083, 0.909)
		tex:SetAlpha(0.5)
		col:SetNormalTexture(tex)

		local tex = col:CreateTexture()
		tex:SetAllPoints()
		tex:SetTexture("Interface\\Buttons\\UI-Listbox-Highlight")
		tex:SetTexCoord(0.025, 0.957, 0.087, 0.931)
		tex:SetAlpha(0.2)
		col:SetHighlightTexture(tex)
		
		tinsert(rt.headCols, col)
	end
	
	-- create the rows
	rt.rows = {}
	for i=1, rt.NUM_ROWS do
		local row = CreateFrame("Frame", rtName.."Row"..i, rt.contentFrame)
		row:SetHeight(rt.ROW_HEIGHT)
		if i == 1 then
			row:SetPoint("TOPLEFT", 0, -(HEAD_HEIGHT+HEAD_SPACE))
			row:SetPoint("TOPRIGHT", 0, -(HEAD_HEIGHT+HEAD_SPACE))
		else
			row:SetPoint("TOPLEFT", rt.rows[i-1], "BOTTOMLEFT")
			row:SetPoint("TOPRIGHT", rt.rows[i-1], "BOTTOMRIGHT")
		end
		local highlight = row:CreateTexture()
		highlight:SetAllPoints()
		highlight:SetTexture(1, .9, 0, .5)
		highlight:Hide()
		row.highlight = highlight
		row.rt = rt
		
		row.cols = {}
		for j=1, #colInfo do
			local col = CreateFrame("Button", nil, row)
			local text = col:CreateFontString()
			if TSM.db.profile.showBids and colInfo[j].isPrice then
				text:SetFont(TSMAPI.Design:GetContentFont(), min(13, rt.ROW_HEIGHT/2 - 2))
			else
				text:SetFont(TSMAPI.Design:GetContentFont(), min(14, rt.ROW_HEIGHT))
			end
			text:SetJustifyH(colInfo[j].align or "LEFT")
			text:SetJustifyV("CENTER")
			text:SetPoint("TOPLEFT", 1, -1)
			text:SetPoint("BOTTOMRIGHT", -1, 1)
			col:SetFontString(text)
			col:SetHeight(rt.ROW_HEIGHT)
			col:RegisterForClicks("AnyUp")
			for name, func in pairs(defaultColScripts) do
				col:SetScript(name, func)
			end
			col.rt = rt
			col.row = row
			col.rowNum = i
			
			if j == 1 then
				col:SetPoint("TOPLEFT")
			else
				col:SetPoint("TOPLEFT", row.cols[j-1], "TOPRIGHT")
			end
			
			if j%2 == 1 then
				local tex = col:CreateTexture()
				tex:SetAllPoints()
				tex:SetTexture(1, 1, 1, .03)
				col:SetNormalTexture(tex)
			end
			
			-- special first column to hold spacer / item name / item icon
			if j == 1 then
				local spacer = CreateFrame("Frame", nil, col)
				spacer:SetPoint("TOPLEFT")
				spacer:SetHeight(rt.ROW_HEIGHT)
				spacer:SetWidth(1)
				col.spacer = spacer
				
				local iconBtn = CreateFrame("Button", nil, col)
				iconBtn:SetBackdrop({edgeFile="Interface\\Buttons\\WHITE8X8", edgeSize=1.5})
				iconBtn:SetBackdropBorderColor(0, 1, 0, 0)
				iconBtn:SetPoint("TOPLEFT", spacer, "TOPRIGHT")
				iconBtn:SetHeight(rt.ROW_HEIGHT)
				iconBtn:SetWidth(rt.ROW_HEIGHT)
				iconBtn:SetScript("OnEnter", function(self)
						if row.data.link then
							GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
							TSMAPI:SafeTooltipLink(row.data.link)
							GameTooltip:Show()
							rt.isShowingItemTooltip = true
						end
					end)
				iconBtn:SetScript("OnLeave", function(self)
						BattlePetTooltip:Hide()
						GameTooltip:ClearLines()
						GameTooltip:Hide()
						rt.isShowingItemTooltip = false
					end)
				iconBtn:SetScript("OnClick", function(_, ...)
						if IsModifiedClick() then
							HandleModifiedItemClick(row.data.auctionRecord.parent.itemLink)
						else
							col:GetScript("OnClick")(col, ...)
						end
					end)
				iconBtn:SetScript("OnDoubleClick", function(_, ...)
						col:GetScript("OnDoubleClick")(col, ...)
					end)
				local icon = iconBtn:CreateTexture(nil, "ARTWORK")
				icon:SetPoint("TOPLEFT", 2, -2)
				icon:SetPoint("BOTTOMRIGHT", -2, 2)
				col.iconBtn = iconBtn
				col.icon = icon
				
				row.ShowActiveBorder = function()
					if rt.quickBuyout then
						row.isActive = true
						iconBtn:SetBackdropBorderColor(0, 1, 0, .7)
					end
				end
				
				row.HideActiveBorder = function()
					row.isActive = nil
					iconBtn:SetBackdropBorderColor(0, 0, 0, 0)
				end
				
				text:ClearAllPoints()
				text:SetPoint("TOPLEFT", iconBtn, "TOPRIGHT", 2, 0)
				text:SetPoint("BOTTOMRIGHT")
			end
			tinsert(row.cols, col)
		end
		
		if i%2 == 0 then
			local tex = row:CreateTexture()
			tex:SetAllPoints()
			tex:SetTexture("Interface\\WorldStateFrame\\WorldStateFinalScore-Highlight")
			tex:SetTexCoord(0.017, 1, 0.083, 0.909)
			tex:SetAlpha(0.3)
		end
		
		tinsert(rt.rows, row)
	end
	
	rt:SetAllPoints()
	rt.data = {}
	rt.expanded = {}
	rt.displayRows = {}
	rt.handlers = handlers or {}
	rt.sortInfo = {}
	rt.quickBuyout = quickBuyout
	rt.isDestroying = isDestroying
	tinsert(resultsTables, rt)
	
	for name, func in pairs(methods) do
		rt[name] = func
	end
	LibStub("AceEvent-3.0").RegisterEvent(rt, "AUCTION_ITEM_LIST_UPDATE", "UpdateActiveRows")
	
	return rt
end