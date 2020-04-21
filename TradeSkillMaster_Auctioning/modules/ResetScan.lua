-- ------------------------------------------------------------------------------ --
--                           TradeSkillMaster_Auctioning                          --
--           http://www.curse.com/addons/wow/tradeskillmaster_auctioning          --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

local TSM = select(2, ...)
local Reset = TSM:NewModule("Reset", "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster_Auctioning") -- loads the localization table

local resetData, summarySTCache, showCache, itemsReset, justBought = {}, {}, {}, {}, {}
local isScanning, doneScanningText, currentItem, GUI
local summaryST, auctionST, resetButtons

function Reset:Show(frame)
	summaryST = summaryST or Reset:CreateSummaryST(frame.content)
	summaryST:Show()
	summaryST:SetData({})
	
	auctionST = auctionST or Reset:CreateAuctionST(frame.content)
	auctionST:Hide()
	auctionST:SetData({})
	
	resetButtons = resetButtons or Reset:CreateResetButtons(frame)
	resetButtons:Show()
	resetButtons.stop:Enable()
	resetButtons.stop.isDone = nil
	resetButtons.stop:SetText(L["Stop"])
	resetButtons:Disable()
end

function Reset:Hide()
	if summaryST then
		summaryST:SetData({})
		summaryST:Hide()
		
		auctionST:SetData({})
		auctionST:Hide()
		
		resetButtons:Hide()
		Reset.isSearching = nil
	end
end

local function ColSortMethod(st, aRow, bRow, col)
	local a, b = st:GetCell(aRow, col), st:GetCell(bRow, col)
	local column = st.cols[col]
	local direction = column.sort or column.defaultsort or "dsc"
	local aValue, bValue = ((a.args or {})[1] or a.value), ((b.args or {})[1] or b.value)
	if direction == "asc" then
		return aValue < bValue
	else
		return aValue > bValue
	end
end

function Reset:CreateSummaryST(parent)
	local stCols = {
		{
			name = L["Item"],
			width = 0.31,
		},
		{
			name = L["Operation"],
			width = 0.17,
		},
		{
			name = L["Quantity (Yours)"],
			width = 0.13,
			align = "CENTER"
		},
		{
			name = L["Total Cost"],
			width = 0.12,
			align = "RIGHT",
		},
		{
			name = L["Target Price"],
			width = 0.12,
			align = "RIGHT",
		},
		{
			name = L["Profit Per Item"],
			width = 0.12,
			align = "RIGHT",
		},
	}
	
	local handlers = {
		OnEnter = function(_, data, self)
			if not data.operation then return end
			local prices = TSM.Util:GetItemPrices(operation, data.itemString, true)
			GameTooltip:SetOwner(self, "ANCHOR_NONE")
			GameTooltip:SetPoint("BOTTOMLEFT", self, "TOPLEFT")
			GameTooltip:AddLine(data.itemLink)				
			GameTooltip:AddLine(L["Max Cost:"].." "..(TSMAPI:FormatTextMoney(prices.resetMaxCost, "|cffffffff") or "---"))
			GameTooltip:AddLine(L["Min Profit:"].." "..(TSMAPI:FormatTextMoney(prices.resetMinProfit, "|cffffffff") or "---"))
			GameTooltip:AddLine(L["Max Quantity:"].." "..(TSMAPI:FormatTextMoney(data.operation.resetMaxQuantity, "|cffffffff") or "---"))
			GameTooltip:AddLine(L["Max Price Per:"].." "..(TSMAPI:FormatTextMoney(data.operation.resetMaxPricePer, "|cffffffff") or "---"))
			
			if TSM.Reset:IsScanning() then
				GameTooltip:AddLine("\n"..L["Must wait for scan to finish before starting to reset."])
			else
				GameTooltip:AddLine(TSMAPI.Design:GetInlineColor("link2").."\n"..L["Click to show auctions for this item."].."|r")
				GameTooltip:AddLine(TSMAPI.Design:GetInlineColor("link2")..L["Shift-Right-Click to show the options for this item's Auctioning group."].."|r")
			end
			GameTooltip:Show()
		end,
		OnLeave = function()
			GameTooltip:Hide()
		end,
		OnClick = function(_, data, _, button)
			if TSM.Reset:IsScanning() then return end
			if button == "LeftButton" then
				summaryST:Hide()
				auctionST:Show()
				resetButtons.summaryButton:Enable()
				
				currentItem = CopyTable(data)
				Reset:UpdateAuctionST()
				Reset:SelectAuctionRow(auctionST.rowData[1])
				currentItem.isReset = true
				TSM.Manage:SetInfoText(currentItem)
			elseif button == "RightButton" then
				if IsShiftKeyDown() then
					TSMAPI:ShowOperationOptions("Auctioning", TSM.operationNameLookup[data.operation])
				end
			end
		end,
	}
	
	local st = TSMAPI:CreateScrollingTable(parent, stCols, handlers)
	st:SetParent(parent)
	st:SetAllPoints()
	st:EnableSorting(true)
	return st
end

function Reset:CreateAuctionST(parent)
	local stCols = {
		{
			name = L["Seller"],
			width = 0.4,
		},
		{
			name = L["Stack Size"],
			width = 0.2,
			align = "CENTER",
		},
		{
			name = L["Auction Buyout"],
			width = 0.35,
			align = "RIGHT",
		},
	}
	
	local handlers = {
		OnClick = function(_, data)
			Reset:SelectAuctionRow(data)
		end,
	}
	
	local st = TSMAPI:CreateScrollingTable(parent, stCols, handlers)
	st:SetParent(parent)
	st:SetAllPoints()
	st:EnableSorting(false)
	return st
end

function Reset:CreateResetButtons(parent)
	local height = 24
	local frame = CreateFrame("Frame", nil, parent)
	frame:SetHeight(height)
	frame:SetWidth(210)
	frame:SetPoint("BOTTOMRIGHT", -92, 6)
	
	frame.Disable = function(self)
		self.buyout:Disable()
		self.cancel:Disable()
		self.summaryButton:Disable()
	end
	
	local function OnCancelClick(self)
		if self.auction then
			for i=GetNumAuctionItems("owner"), 1, -1 do
				if Reset:VerifyAuction(i, "owner", self.auction.record, self.auction.itemString) then
					CancelAuction(i)
					break
				end
			end
		end
		self.auction = nil
		self:Disable()
		Reset:RegisterMessage("TSM_AH_EVENTS", Reset.RemoveCurrentAuction)
		TSMAPI:WaitForAuctionEvents("Cancel")
	end
	
	local function OnStopClick(self)
		if self.isDone then
			Reset:Hide()
			TSM.GUI:ShowSelectionFrame()
		else
			TSM.Manage:OnGUIEvent("stop")
			GUI:Stopped(true)
			Reset:DoneScanning()
		end
	end
	
	local function ReturnToSummary()
		frame:Disable()
		auctionST:Hide()
		summaryST:Show()
		Reset:UpdateSummaryST()
	end
	
	local button = TSMAPI.GUI:CreateButton(frame, 22, "TSMAuctioningResetBuyoutButton")
	button:SetPoint("TOPLEFT", -5, 0)
	button:SetWidth(80)
	button:SetHeight(height)
	button:SetText(BUYOUT)
	button:SetScript("OnClick", Reset.BuyAuction)
	frame.buyout = button
	
	local button = TSMAPI.GUI:CreateButton(frame, 18, "TSMAuctioningResetCancelButton")
	button:SetPoint("TOPLEFT", frame.buyout, "TOPRIGHT", 5, 0)
	button:SetWidth(70)
	button:SetHeight(height)
	button:SetText(L["Cancel"])
	button:SetScript("OnClick", OnCancelClick)
	frame.cancel = button
	
	local button = TSMAPI.GUI:CreateButton(frame, 18, "TSMAuctioningResetStopButton")
	button:SetPoint("TOPLEFT", frame.cancel, "TOPRIGHT", 5, 0)
	button:SetWidth(60)
	button:SetHeight(height)
	button:SetText(L["Stop"])
	button:SetScript("OnClick", OnStopClick)
	button.isDone = nil
	frame.stop = button
	
	local summaryButton = TSMAPI.GUI:CreateButton(frame, 16)
	summaryButton:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -10, -50)
	summaryButton:SetHeight(17)
	summaryButton:SetWidth(150)
	summaryButton:SetScript("OnClick", ReturnToSummary)
	summaryButton:SetText(L["Return to Summary"])
	frame.summaryButton = summaryButton
	
	return frame
end

function Reset:GetTotalQuantity(itemString)
	local playerTotal, altTotal = TSMAPI:ModuleAPI("ItemTracker", "playertotal", itemString)
	if playerTotal and altTotal then
		local guildTotal = TSMAPI:ModuleAPI("ItemTracker", "guildtotal", itemString) or 0
		local auctionTotal = TSMAPI:ModuleAPI("ItemTracker", "auctionstotal", itemString) or 0
		return playerTotal + altTotal + guildTotal + auctionTotal
	else
		return GetItemCount(itemString, true)
	end
end



function Reset:ValidateOperation(itemString, operation)
	local itemLink = select(2, TSMAPI:GetSafeItemInfo(itemString)) or itemString
	local prices = TSM.Util:GetItemPrices(operation, itemString, true)

	-- don't reset this item if their settings are invalid
	if not prices.minPrice then
		if not TSM.db.global.disableInvalidMsg then
			TSM:Printf(L["Did not reset %s because your minimum price (%s) is invalid. Check your settings."], itemLink, operation.minPrice)
		end
	elseif not prices.maxPrice then
		if not TSM.db.global.disableInvalidMsg then
			TSM:Printf(L["Did not reset %s because your maximum price (%s) is invalid. Check your settings."], itemLink, operation.maxPrice)
		end
	elseif not prices.normalPrice then
		if not TSM.db.global.disableInvalidMsg then
			TSM:Printf(L["Did not reset %s because your normal price (%s) is invalid. Check your settings."], itemLink, operation.normalPrice)
		end
	elseif not prices.resetMaxCost then
		if not TSM.db.global.disableInvalidMsg then
			TSM:Printf(L["Did not reset %s because your reset max cost (%s) is invalid. Check your settings."], itemLink, operation.resetMaxCost)
		end
	elseif not prices.resetMinProfit then
		if not TSM.db.global.disableInvalidMsg then
			TSM:Printf(L["Did not reset %s because your reset min profit (%s) is invalid. Check your settings."], itemLink, operation.resetMinProfit)
		end
	elseif not prices.resetResolution then
		if not TSM.db.global.disableInvalidMsg then
			TSM:Printf(L["Did not reset %s because your reset resolution (%s) is invalid. Check your settings."], itemLink, operation.resetResolution)
		end
	elseif not prices.resetMaxItemCost then
		if not TSM.db.global.disableInvalidMsg then
			TSM:Printf(L["Did not reset %s because your reset max item cost (%s) is invalid. Check your settings."], itemLink, operation.resetMaxItemCost)
		end
	elseif not prices.undercut then
		if not TSM.db.global.disableInvalidMsg then
			TSM:Printf(L["Did not reset %s because your undercut (%s) is invalid. Check your settings."], itemLink or itemString, operation.undercut)
		end
	elseif prices.maxPrice < prices.minPrice then
		if not TSM.db.global.disableInvalidMsg then
			TSM:Printf(L["Did not reset %s because your maximum price (%s) is lower than your minimum price (%s). Check your settings."], itemLink, operation.maxPrice, operation.minPrice)
		end
	elseif prices.normalPrice < prices.minPrice then
		if not TSM.db.global.disableInvalidMsg then
			TSM:Printf(L["Did not reset %s because your normal price (%s) is lower than your minimum price (%s). Check your settings."], itemLink, operation.normalPrice, operation.minPrice)
		end
	elseif Reset:GetTotalQuantity(itemString) >= operation.resetMaxInventory then
		-- already have at least max inventory - do nothing here
	else
		return true
	end
end

function Reset:GetScanListAndSetup(GUIRef, options)
	local scanList, tempList, groupTemp = {}, {}, {}
	
	GUI = GUIRef
	doneScanningText = nil
	isScanning = true
	wipe(resetData)
	wipe(summarySTCache)
	wipe(showCache)
	wipe(itemsReset)
	wipe(TSM.operationLookup)
	
	local temp = {}
	for itemString, operations in pairs(options.itemOperations) do
		for _, operation in ipairs(operations) do
			if operation.resetEnabled and Reset:ValidateOperation(itemString, operation) then
				temp[itemString] = temp[itemString] or {}
				tinsert(temp[itemString], operation)
			end
		end
	end
	
	for itemString, operations in pairs(temp) do
		TSM.operationLookup[itemString] = operations
		tinsert(scanList, itemString)
	end
	
	return scanList
end

function Reset:ProcessItem(itemString)
	local operations = TSM.operationLookup[itemString]
	if not operations then return end
	
	for _, operation in ipairs(operations) do
		Reset:ProcessItemOperation(itemString, operation)
	end
end

function Reset:ProcessItemOperation(itemString, operation)
	local scanData = TSM.Scan.auctionData[itemString]
	if not scanData then return end
	local prices = TSM.Util:GetItemPrices(operation, itemString, true)
	local priceLevels = {}
	local addNormal, isFirstItem = true, true
	local currentPriceLevel = -math.huge
	
	for _, record in ipairs(scanData.compactRecords) do
		local itemBuyout = record:GetItemBuyout()
		if itemBuyout then
			if not isFirstItem and itemBuyout > prices.minPrice and itemBuyout < prices.maxPrice and itemBuyout > (currentPriceLevel + prices.resetResolution) then
				if itemBuyout >= prices.normalPrice then
					addNormal = false
				end
				currentPriceLevel = itemBuyout
				tinsert(priceLevels, itemBuyout)
			end
			isFirstItem = false
		end
	end
	
	if addNormal then
		tinsert(priceLevels, prices.normalPrice)
	end
	
	for _, targetPrice in ipairs(priceLevels) do
		local playerCost, cost, quantity, maxItemCost, playerQuantity = 0, 0, 0, 0, 0
		
		for _, record in ipairs(scanData.compactRecords) do
			local itemBuyout = record:GetItemBuyout()
			if itemBuyout then
				if itemBuyout >= targetPrice then
					break
				end
				
				if itemBuyout > maxItemCost then
					maxItemCost = itemBuyout
				end
				
				if not record:IsPlayer() then
					cost = cost + (record:GetItemBuyout() * record.totalQuantity)
				else
					playerQuantity = playerQuantity + record.totalQuantity
					playerCost = playerCost + (record:GetItemBuyout() * record.totalQuantity)
				end
				quantity = quantity + record.totalQuantity
			end
		end
		
		local profit = (targetPrice * quantity - (cost + playerCost)) / quantity
		if profit > 0 then
			tinsert(resetData, {prices=prices, itemString=itemString, targetPrice=targetPrice, cost=cost, quantity=quantity, profit=profit, maxItemCost=maxItemCost, playerQuantity=playerQuantity, operation=operation})
		end
	end
	
	Reset:UpdateSummaryST()
end

function Reset:ShouldShow(data)
	local result = {validCost=true, validQuantity=true, validProfit=true, isValid=true}
	
	if data.cost > data.prices.resetMaxCost or data.maxItemCost > data.prices.resetMaxItemCost then
		result.validCost = false
	end
	
	if data.quantity > data.operation.resetMaxQuantity or data.quantity > (data.operation.resetMaxInventory - Reset:GetTotalQuantity(itemString)) then
		result.validQuantity = false
	end
	
	if data.profit < data.prices.resetMinProfit then
		result.validProfit = false
	end
	
	return (result.validCost and result.validQuantity and result.validProfit), result
end

function Reset:GetSummarySTRow(data)
	local function GetQuantityText(quantity, playerQuantity, isValid)
		if isValid then
			if playerQuantity > 0 then
				return quantity..TSMAPI.Design:GetInlineColor("link2").."("..playerQuantity..")|r"
			else
				return quantity
			end
		end
		
		return "|cffff2222"..quantity.."|r"
	end
	
	local function GetPriceText(amount, isValid)
		local color
		if not isValid then
			color = "|cffff2222"
		end
	
		return TSMAPI:FormatTextMoney(amount, color, true) or "---"
	end

	local name, itemLink = TSMAPI:GetSafeItemInfo(data.itemString)
	local _, shouldShowDetails = Reset:ShouldShow(data)

	local row = {
		cols = {
			{
				value = itemLink,
				sortArg = name,
			},
			{
				value = data.operation and TSM.operationNameLookup[data.operation] or "---",
				sortArg = data.operation and TSM.operationNameLookup[data.operation] or "---",
			},
			{
				value = GetQuantityText(data.quantity, data.playerQuantity, shouldShowDetails.validQuantity),
				sortArg = data.quantity,
			},
			{
				value = GetPriceText(data.cost or 0, shouldShowDetails.validCost),
				sortArg = data.cost or 0,
			},
			{
				value = GetPriceText(data.targetPrice, true),
				sortArg = data.targetPrice,
			},
			{
				value = GetPriceText(data.profit, shouldShowDetails.validProfit),
				sortArg = data.profit,
			},
		},
		itemString = data.itemString,
		targetPrice = data.targetPrice,
		num = data.quantity,
		profit = data.profit,
		operation = operation,
	}
	
	return row
end

function Reset:UpdateSummaryST()
	local rows = {}
	local num = 0
	
	for _, data in ipairs(resetData) do
		if not itemsReset[data.itemString] then
			if showCache[data] == nil then
				showCache[data] = Reset:ShouldShow(data) or false
			end
			if showCache[data] then
				local key = data.itemString .. data.targetPrice
				if not summarySTCache[key] then num = num + 1 end
				summarySTCache[key] = summarySTCache[key] or Reset:GetSummarySTRow(data)
				tinsert(rows, summarySTCache[key])
			end
		end
	end

	summaryST:SetData(rows)
	
	if doneScanningText then
		TSM.Manage:SetInfoText(doneScanningText)
	end
end

function Reset:GetAuctionSTRow(record, index)
	local function GetSellerText(name)
		if TSMAPI:IsPlayer(name) then
			return "|cff99ffff" .. name .. "|r"
		elseif TSM.db.factionrealm.whitelist[strlower(name)] then
			return name .. " |cffff2222(" .. L["Whitelist"] .. ")|r"
		end
		
		return name
	end
	
	local row = {
		cols = {
			{
				value = GetSellerText(record.seller),
				sortArg = record.seller,
			},
			{
				value = record.count,
				sortArg = record.count,
			},
			{
				value = TSMAPI:FormatTextMoney(record.buyout, nil, true) or "---",
				sortArg = record.buyout,
			},
		},
		record = record,
		itemString = TSMAPI:GetBaseItemString(record.parent:GetItemString(), true),
		index = index,
	}
	
	return row
end

function Reset:UpdateAuctionST()
	local scanData = TSM.Scan.auctionData[currentItem.itemString]
	
	local rows = {}
	
	for i, record in ipairs(scanData.records) do
		local itemBuyout = record:GetItemBuyout()
		if itemBuyout and itemBuyout >= currentItem.targetPrice then
			break
		end
		
		tinsert(rows, Reset:GetAuctionSTRow(record, i))
	end
	
	auctionST:SetData(rows)
end

function Reset:SelectAuctionRow(data)
	local function OnAuctionFound(index)
		local row = auctionST.rowData[auctionST:GetSelection()]
		
		resetButtons.summaryButton:Enable()
		resetButtons.buyout:Enable()
		resetButtons.buyout.auction = {index=index, row=row.itemString, record=row.record}
	end
	
	local row = data
	resetButtons.buyout:Disable()
	resetButtons.cancel:Disable()
	justBought = {}
	
	if row.record:IsPlayer() then
		resetButtons.summaryButton:Enable()
		resetButtons.cancel:Enable()
		resetButtons.cancel.auction = {record=row.record, itemString=row.itemString}
	else
		Reset:FindCurrentAuctionForBuyout(row.itemString, row.record.buyout, row.record.count)
	end
end

function Reset:RemoveCurrentAuction()
	Reset:UnregisterMessage("TSM_AH_EVENTS")
	if not currentItem then return end
	local scanData = TSM.Scan.auctionData[currentItem.itemString]
	if not scanData then return end
	local row = auctionST.rowData[auctionST:GetSelection()]
	if not row then return end

	scanData:RemoveRecord(row.index)
	itemsReset[row.itemString] = true
	Reset:UpdateAuctionST()
	
	if #auctionST.rowData == 0 then
		TSM.Scan.auctionData[row.itemString] = nil
		resetButtons.summaryButton:Enable()
		resetButtons.summaryButton:Click()
		Reset:UpdateSummaryST()
	else
		TSMAPI:CreateTimeDelay("resetBuyDelay", 0.2, function() Reset:SelectAuctionRow(auctionST.rowData[1]) end)
	end
end

function Reset:VerifyAuction(index, tab, record, itemString)
	local iString = TSMAPI:GetBaseItemString(GetAuctionItemLink(tab, index), true)
	local _, _, count, _, _, _, minBid, _, buyout, bid = GetAuctionItemInfo(tab, index)
	return (iString == itemString and bid == record.bid and minBid == record.minBid and buyout == record.buyout and count == record.count)
end



function Reset:GetStatus()
	return 0, 0, 100
end

function Reset:DoAction()

end

function Reset:SkipItem()

end

function Reset:Stop()
	isScanning = false
end

function Reset:DoneScanning()
	local num, totalProfit = 0, 0
	local temp = {}

	for _, data in ipairs(resetData) do
		if not temp[data.itemString] and Reset:ShouldShow(data) then
			temp[data.itemString] = true
			num = num + 1
			totalProfit = totalProfit + data.profit * data.quantity
		end
	end
	
	resetButtons.stop:SetText(L["Restart"])
	resetButtons.stop.isDone = true
	isScanning = false
	doneScanningText = format(L["Done Scanning!\n\nCould potentially reset %d items for %s profit."], num, TSMAPI:FormatTextMoneyIcon(totalProfit))
	TSM.Manage:SetInfoText(doneScanningText)
end

function Reset:SetupForAction()

end

function Reset:GetCurrentItem()

end

function Reset:IsScanning()
	return isScanning
end


local function ValidateAuction(index, listType)
	local itemString = TSMAPI:GetBaseItemString(GetAuctionItemLink(listType, index), true)
	local _, _, count, _, _, _, _, _, buyout = GetAuctionItemInfo(listType, index)
	return count == currentAuction.count and buyout == currentAuction.buyout and itemString == currentAuction.itemString
end

function Reset:BuyAuction()
	local altIndex, mainIndex, foundAuction
	TSMAPI:CancelFrame("resetFindRepeat")
	Reset.isSearching = nil

	for i=GetNumAuctionItems("list"), 1, -1 do
		if ValidateAuction(i, "list") then
			if not justBought[i] then
				mainIndex = i
				break
			else
				altIndex = altIndex or i
			end
		end
	end
	if mainIndex or altIndex then
		PlaceAuctionBid("list", mainIndex or altIndex, currentAuction.buyout)
		foundAuction = true
		justBought[mainIndex or altIndex] = true
	end
	
	resetButtons.buyout:Disable()
	if foundAuction then
		-- wait for all the events that are triggered by this action
		Reset:RegisterMessage("TSM_AH_EVENTS", Reset.RemoveCurrentAuction)
		TSMAPI:WaitForAuctionEvents("Buyout")
	else
		TSM:Print(L["Auction not found. Skipped."])
		Reset:RemoveCurrentAuction()
	end
end

function Reset:OnAuctionFound(index)
	if not Reset.isSearching then return end
	resetButtons.buyout:Enable()
end

function Reset:FindCurrentAuctionForBuyout(itemString, buyout, count)
	currentAuction = {itemString=itemString, buyout=buyout, count=count}
	TSMAPI:CancelFrame("resetFindRepeat")
	TSMAPI.AuctionScan:FindAuction(function(...) Reset:OnAuctionFound(...) end, currentAuction)
	TSMAPI:CreateTimeDelay("resetFindRepeat", 0.1, function(...)
			local isFindScanning = TSMAPI.AuctionScan:IsFindScanning()
			if TSMAPI:AHTabIsVisible("Auctioning") then
				if not isFindScanning then
					TSMAPI.AuctionScan:FindAuction(function(...) Reset:OnAuctionFound(...) end, currentAuction)
				else
					if isFindScanning ~= currentAuction.itemString then
						TSMAPI.AuctionScan:FindAuction(function(...) Reset:OnAuctionFound(...) end, currentAuction)
					end
				end
			end
		end, 0.1)
	Reset.isSearching = true
end