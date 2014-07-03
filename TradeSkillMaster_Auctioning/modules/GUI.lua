-- ------------------------------------------------------------------------------ --
--                           TradeSkillMaster_Auctioning                          --
--           http://www.curse.com/addons/wow/tradeskillmaster_auctioning          --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

local TSM = select(2, ...)
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster_Auctioning") -- loads the localization table
local GUI = TSM:NewModule("GUI", "AceEvent-3.0", "AceHook-3.0")
local AceGUI = LibStub("AceGUI-3.0")
local private = {}

function private:CreateButtons(parent)
	local height = 24
	local frame = CreateFrame("Frame", nil, parent)
	frame:SetHeight(height)
	frame:SetWidth(210)
	frame:SetPoint("BOTTOMRIGHT", -92, 5)
	
	frame.Enable = function(self)
		if private.mode == "Post" then
			self.post:Enable()
		elseif private.mode == "Cancel" then
			self.cancel:Enable()
		end
		self.skip:Enable()
		self.stop:Enable()
	end
	
	frame.Disable = function(self)
		if private.mode == "Post" then
			self.post:Disable()
		elseif private.mode == "Cancel" then
			self.cancel:Disable()
		end
		self.skip:Disable()
	end
	
	frame.UpdateMode = function(self)
		if private.mode == "Post" then
			self.post:Show()
			self.cancel:Hide()
			self.cancel:Disable()
		elseif private.mode == "Cancel" then
			self.post:Hide()
			self.post:Disable()
			self.cancel:Show()
		end
		self.stop:Enable()
	end
	
	local function OnClick(self)
		if self.which == "stop" and self.isDone then
			GUI:HideSelectionFrame()
			private.selectionFrame:Show()
		elseif frame:IsVisible() and private.OnAction then
			private:OnAction(self.which)
		end
	end
	
	local button = TSMAPI.GUI:CreateButton(frame, 22, "TSMAuctioningPostButton")
	button:SetPoint("TOPLEFT")
	button:SetWidth(80)
	button:SetHeight(height)
	button:SetText(L["Post"])
	button.which = "action"
	button:SetScript("OnClick", OnClick)
	frame.post = button
	
	local button = TSMAPI.GUI:CreateButton(frame, 22, "TSMAuctioningCancelButton")
	button:SetPoint("TOPLEFT")
	button:SetWidth(80)
	button:SetHeight(height)
	button:SetText(L["Cancel"])
	button.which = "action"
	button:SetScript("OnClick", OnClick)
	frame.cancel = button
	
	local button = TSMAPI.GUI:CreateButton(frame, 18)
	button:SetPoint("TOPLEFT", frame.post, "TOPRIGHT", 5, 0)
	button:SetWidth(60)
	button:SetHeight(height)
	button:SetText(L["Skip"])
	button.which = "skip"
	button:SetScript("OnClick", OnClick)
	frame.skip = button
	
	local button = TSMAPI.GUI:CreateButton(frame, 18)
	button:SetPoint("TOPLEFT", frame.skip, "TOPRIGHT", 5, 0)
	button:SetWidth(70)
	button:SetHeight(height)
	button:SetText(L["Stop"])
	button.which = "stop"
	button:SetScript("OnClick", OnClick)
	frame.stop = button
	
	return frame
end

function private:CreateContentButtons(parent)
	local frame = CreateFrame("Frame", nil, parent)
	frame:SetAllPoints(parent)
	
	frame.UpdateMode = function(self)
		if private.mode == "Post" then
			self.currAuctionsButton:Show()
			self.editPriceButton:Show()
			self.editPriceButton:Disable()
		elseif private.mode == "Cancel" then
			self.currAuctionsButton:Show()
			self.editPriceButton:Hide()
		end
	end
	
	frame.UnlockHighlight = function(self)
		self.auctionsButton:UnlockHighlight()
		self.logButton:UnlockHighlight()
		self.currAuctionsButton:UnlockHighlight()
		self.editPriceButton:UnlockHighlight()
	end
	
	local function OnClick(self)
		frame:UnlockHighlight()
		self:LockHighlight()
		frame.editPriceFrame:Hide()
		
		if self.which == "log" then
			private.auctionsST:Hide()
			private.logST:Show()
			private:UpdateLogSTData()
		elseif self.which == "auctions" then
			private.logST:Hide()
			private.auctionsST:Show()
			private.auctionsST.isCurrentItem = nil
			private:UpdateAuctionsSTData()
		elseif self.which == "currAuctions" then
			private.logST:Hide()
			private.auctionsST:Show()
			private.auctionsST.isCurrentItem = true
			private:UpdateAuctionsSTData()
		elseif self.which == "editPrice" then
			frame.editPriceFrame:Show()
		end
	end

	local auctionsButton = TSMAPI.GUI:CreateButton(frame, 16)
	auctionsButton:SetPoint("TOPRIGHT", -10, -20)
	auctionsButton:SetHeight(17)
	auctionsButton:SetWidth(150)
	auctionsButton.which = "auctions"
	auctionsButton:SetScript("OnClick", OnClick)
	auctionsButton:SetText(L["Show All Auctions"])
	frame.auctionsButton = auctionsButton
	
	local currAuctionsButton = TSMAPI.GUI:CreateButton(frame, 16)
	currAuctionsButton:SetPoint("TOPRIGHT", -170, -20)
	currAuctionsButton:SetHeight(17)
	currAuctionsButton:SetWidth(150)
	currAuctionsButton.which = "currAuctions"
	currAuctionsButton:SetScript("OnClick", OnClick)
	currAuctionsButton:SetText(L["Show Item Auctions"])
	frame.currAuctionsButton = currAuctionsButton
	
	local logButton = TSMAPI.GUI:CreateButton(frame, 16)
	logButton:SetPoint("TOPRIGHT", -10, -45)
	logButton:SetHeight(17)
	logButton:SetWidth(150)
	logButton.which = "log"
	logButton:SetScript("OnClick", OnClick)
	logButton:SetText(L["Show Log"])
	frame.logButton = logButton
	
	local editPriceButton = TSMAPI.GUI:CreateButton(frame, 16)
	editPriceButton:SetPoint("TOPRIGHT", -170, -45)
	editPriceButton:SetHeight(17)
	editPriceButton:SetWidth(150)
	editPriceButton.which = "editPrice"
	editPriceButton:SetScript("OnClick", OnClick)
	editPriceButton:SetText(L["Edit Post Price"])
	frame.editPriceButton = editPriceButton
	
	local editPriceFrame = CreateFrame("Frame", nil, frame)
	TSMAPI.Design:SetFrameBackdropColor(editPriceFrame)
	editPriceFrame:SetPoint("CENTER")
	editPriceFrame:SetFrameStrata("DIALOG")
	editPriceFrame:SetWidth(300)
	editPriceFrame:SetHeight(150)
	editPriceFrame:EnableMouse(true)
	editPriceFrame:SetScript("OnShow", function(self)
			editPriceFrame:SetFrameStrata("DIALOG")
			MoneyInputFrame_SetCopper(TSMPostPriceChangeBox, self.info.buyout)
			self.linkLabel:SetText(self.info.link)
		end)
	editPriceFrame:SetScript("OnUpdate", function()
			if not TSMAPI:AHTabIsVisible("Auctioning") then
				editPriceFrame:Hide()
			end
		end)
	frame.editPriceFrame = editPriceFrame
	
	local linkLabel = TSMAPI.GUI:CreateLabel(editPriceFrame)
	linkLabel:SetPoint("TOP", 0, -14)
	linkLabel:SetJustifyH("CENTER")
	linkLabel:SetText("")
	editPriceFrame.linkLabel = linkLabel
	
	local bg = editPriceFrame:CreateTexture(nil, "BACKGROUND")
	bg:SetPoint("TOPLEFT", linkLabel, -2, 2)
	bg:SetPoint("BOTTOMRIGHT", linkLabel, 2, -2)
	TSMAPI.Design:SetContentColor(bg)
	linkLabel.bg = bg
	
	local priceBoxLabel = TSMAPI.GUI:CreateLabel(editPriceFrame)
	priceBoxLabel:SetPoint("TOPLEFT", 14, -40)
	priceBoxLabel:SetText(L["Auction Buyout (Stack Price):"])
	editPriceFrame.priceBoxLabel = priceBoxLabel
	
	local priceBox = CreateFrame("Frame", "TSMPostPriceChangeBox", editPriceFrame, "MoneyInputFrameTemplate")
	priceBox:SetPoint("TOPLEFT", 20, -60)
	priceBox:SetHeight(20)
	priceBox:SetWidth(120)
	editPriceFrame.priceBox = priceBox
	
	local saveButton = TSMAPI.GUI:CreateButton(editPriceFrame, 16)
	saveButton:SetPoint("BOTTOMLEFT", 10, 10)
	saveButton:SetPoint("BOTTOMRIGHT", editPriceFrame, "BOTTOM", -2, 10)
	saveButton:SetHeight(20)
	saveButton:SetScript("OnClick", function()
			TSM.Post:EditPostPrice(editPriceFrame.info.itemString, MoneyInputFrame_GetCopper(TSMPostPriceChangeBox), editPriceFrame.info.operation)
			editPriceFrame:Hide()
		end)
	saveButton:SetText(L["Save New Price"])
	editPriceFrame.saveButton = saveButton
	
	local cancelButton = TSMAPI.GUI:CreateButton(editPriceFrame, 16)
	cancelButton:SetPoint("BOTTOMLEFT", editPriceFrame, "BOTTOM", 2, 10)
	cancelButton:SetPoint("BOTTOMRIGHT", -10, 10)
	cancelButton:SetHeight(20)
	cancelButton:SetScript("OnClick", function()
			editPriceFrame:Hide()
		end)
	cancelButton:SetText(L["Cancel"])
	editPriceFrame.cancelButton = cancelButton
	
	return frame
end

function private:CreateInfoText(parent)
	local frame = CreateFrame("Frame", nil, parent)
	frame:SetAllPoints()
	
	frame.SetInfo = function(self, info)
		private:UpdateLogSTHighlight()
		if type(info) == "string" then
			self.icon:Hide()
			self.linkText:Hide()
			self.linkText.bg:Hide()
			self.stackText:Hide()
			self.bidText:Hide()
			self.buyoutText:Hide()
			self.quantityText:Hide()
			self.statusText:Show()
			
			local status, _, gold, gold2 = ("\n"):split(info)
			if gold then
				self.goldText:Show()
				self.goldText2:Show()
				self.goldText:SetText(gold)
				self.goldText2:SetText(gold2)
			else
				self.goldText:Hide()
				self.goldText2:Hide()
			end
			self.statusText:SetText(status)
		elseif info.isReset then
			self.icon:Show()
			self.linkText:Show()
			self.linkText.bg:Show()
			self.stackText:Show()
			self.bidText:Show()
			self.buyoutText:Show()
			self.statusText:Hide()
			self.goldText:Hide()
			self.goldText2:Hide()
			
			local itemID = TSMAPI:GetItemID(info.itemString)
			local total = TSM.Reset:GetTotalQuantity(info.itemString)
			self.quantityText:Show()
			self.quantityText:SetText(TSMAPI.Design:GetInlineColor("link")..L["Currently Owned:"].."|r "..total)
			
			local _,link,_,_,_,_,_,_,_,texture = TSMAPI:GetSafeItemInfo(info.itemString)
			self.linkText:SetText(link)
			if self.linkText:GetStringWidth() > 200 then
				self.linkText:SetWidth(200)
			else
				self.linkText:SetWidth(self.linkText:GetStringWidth())
			end
			self.icon.link = link
			self.icon:GetNormalTexture():SetTexture(texture)
			self.stackText:SetText(format(L["%s item(s) to buy/cancel"], info.num..TSMAPI.Design:GetInlineColor("link")))
			self.bidText:SetText(TSMAPI.Design:GetInlineColor("link")..L["Target Price:"].."|r "..TSMAPI:FormatTextMoneyIcon(info.targetPrice))
			self.buyoutText:SetText(TSMAPI.Design:GetInlineColor("link")..L["Profit:"].."|r "..TSMAPI:FormatTextMoneyIcon(info.profit))
		else
			self.icon:Show()
			self.linkText:Show()
			self.linkText.bg:Show()
			self.stackText:Show()
			self.bidText:Show()
			self.buyoutText:Show()
			self.statusText:Hide()
			self.quantityText:Hide()
			self.goldText:Hide()
			self.goldText2:Hide()
		
			local _,link,_,_,_,_,_,_,_,texture = TSMAPI:GetSafeItemInfo(info.itemString)
			self.linkText:SetText(link)
			if self.linkText:GetStringWidth() > 200 then
				self.linkText:SetWidth(200)
			else
				self.linkText:SetWidth(self.linkText:GetStringWidth())
			end
			self.icon.link = link
			self.icon:GetNormalTexture():SetTexture(texture)
			
			local sText = format("%s "..TSMAPI.Design:GetInlineColor("link")..L["auctions of|r %s"], info.numStacks, info.stackSize)
			self.stackText:SetText(sText)
			
			self.bidText:SetText(TSMAPI.Design:GetInlineColor("link")..BID..":|r "..TSMAPI:FormatTextMoneyIcon(info.bid))
			self.buyoutText:SetText(TSMAPI.Design:GetInlineColor("link")..BUYOUT..":|r "..TSMAPI:FormatTextMoneyIcon(info.buyout))

			private.contentButtons.editPriceButton:Enable()
			private.contentButtons.editPriceFrame.itemString = info.itemString
			private.contentButtons.editPriceFrame.info = {itemString=info.itemString, link=link, buyout=info.buyout, operation=info.operation}
			
			TSMAPI:CreateTimeDelay("AuctioningLogHLDelay", 0.01, function() private:UpdateLogSTHighlight(info) end)
		end
	end
	
	frame.UpdateMode = function(self) end
	
	local icon = CreateFrame("Button", nil, frame)
	icon:SetPoint("TOPLEFT", 85, -20)
	icon:SetWidth(50)
	icon:SetHeight(50)
	local tex = icon:CreateTexture()
	tex:SetAllPoints(icon)
	icon:SetNormalTexture(tex)
	icon:SetScript("OnEnter", function(self)
			if self.link and self.link ~= "" then
				GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
				TSMAPI:SafeTooltipLink(self.link)
				GameTooltip:Show()
			end
		end)
	icon:SetScript("OnLeave", function()
			BattlePetTooltip:Hide()
			GameTooltip:ClearLines()
			GameTooltip:Hide()
		end)
	frame.icon = icon
	
	local linkText = TSMAPI.GUI:CreateLabel(frame)
	linkText:SetPoint("LEFT", icon, "RIGHT", 4, 0)
	linkText:SetJustifyH("LEFT")
	linkText:SetJustifyV("CENTER")
	frame.linkText = linkText
	
	local bg = frame:CreateTexture(nil, "BACKGROUND")
	bg:SetPoint("TOPLEFT", linkText, -2, 2)
	bg:SetPoint("BOTTOMRIGHT", linkText, 2, -2)
	TSMAPI.Design:SetContentColor(bg)
	linkText.bg = bg
	
	local stackText = TSMAPI.GUI:CreateLabel(frame)
	stackText:SetPoint("TOPLEFT", 350, -18)
	stackText:SetWidth(175)
	stackText:SetHeight(18)
	stackText:SetJustifyH("LEFT")
	stackText:SetJustifyV("CENTER")
	frame.stackText = stackText
	
	local bidText = TSMAPI.GUI:CreateLabel(frame)
	bidText:SetPoint("TOPLEFT", 350, -38)
	bidText:SetWidth(175)
	bidText:SetHeight(18)
	bidText:SetJustifyH("LEFT")
	bidText:SetJustifyV("CENTER")
	frame.bidText = bidText
	
	local buyoutText = TSMAPI.GUI:CreateLabel(frame)
	buyoutText:SetPoint("TOPLEFT", 350, -58)
	buyoutText:SetWidth(175)
	buyoutText:SetHeight(18)
	buyoutText:SetJustifyH("LEFT")
	buyoutText:SetJustifyV("CENTER")
	frame.buyoutText = buyoutText
	
	local statusText = TSMAPI.GUI:CreateLabel(frame)
	statusText:SetPoint("TOP", frame, "TOPLEFT", 300, -15)
	statusText:SetJustifyH("CENTER")
	statusText:SetJustifyV("CENTER")
	frame.statusText = statusText
	
	local goldText = TSMAPI.GUI:CreateLabel(frame)
	goldText:SetPoint("TOP", statusText, "BOTTOM", 0, -15)
	goldText:SetJustifyH("CENTER")
	goldText:SetJustifyV("CENTER")
	frame.goldText = goldText
	
	local goldText2 = TSMAPI.GUI:CreateLabel(frame)
	goldText2:SetPoint("TOP", goldText, "BOTTOM")
	goldText2:SetJustifyH("CENTER")
	goldText2:SetJustifyV("CENTER")
	frame.goldText2 = goldText2
	
	local quantityText = TSMAPI.GUI:CreateLabel(frame)
	quantityText:SetPoint("TOPLEFT", 535, -58)
	quantityText:SetWidth(175)
	quantityText:SetHeight(18)
	quantityText:SetJustifyH("LEFT")
	quantityText:SetJustifyV("CENTER")
	frame.quantityText = quantityText
	
	return frame
end

function private:CreateAuctionsST(parent)
	local frame = CreateFrame("Frame", nil, parent)
	frame:SetAllPoints()

	local handlers = {
		OnClick = function(_, data, self, button)
		end,
	}
	
	local rt = TSMAPI:CreateAuctionResultsTable(frame, handlers)
	rt:SetData({})
	rt:SetSort(7, true)
	rt:Hide()
	
	return rt
end

function private:CreateLogST(parent)
	local function GetPriceColumnText()
		if TSM.db.global.priceColumn == 1 then
			return L["Your Buyout"]
		elseif TSM.db.global.priceColumn == 2 then
			return L["Lowest Buyout"]
		end
	end
	
	local stCols = {
		{
			name = L["Item"],
			width = 0.31,
		},
		{
			name = L["Operation"],
			width = 0.17,
			align = "Center"
		},
		{
			name = GetPriceColumnText(),
			width = 0.12,
			align = "RIGHT",
		},
		{
			name = L["Seller"],
			width = 0.11,
			align = "CENTER",
		},
		{
			name = L["Info"],
			width = 0.28,
			align = "LEFT",
		},
		{
			name = "",
			width = 0,
		},
	}
	
	local handlers = {
		OnEnter = function(_, data, self)
			if not data.operation then return end
			local prices = TSM.Util:GetItemPrices(data.operation, data.itemString)
			
			GameTooltip:SetOwner(self, "ANCHOR_NONE")
			GameTooltip:SetPoint("BOTTOMLEFT", self, "TOPLEFT")
			GameTooltip:AddLine(data.link)
			GameTooltip:AddLine(L["Minimum Price:"].." "..(TSMAPI:FormatTextMoney(prices.minPrice, "|cffffffff") or "---"))
			GameTooltip:AddLine(L["Maximum Price:"].." "..(TSMAPI:FormatTextMoney(prices.maxPrice, "|cffffffff") or "---"))
			GameTooltip:AddLine(L["Normal Price:"].." "..(TSMAPI:FormatTextMoney(prices.normalPrice, "|cffffffff") or "---"))
			GameTooltip:AddLine(L["Lowest Buyout:"].." |r"..(TSMAPI:FormatTextMoney(data.lowestBuyout, "|cffffffff") or "---"))
			GameTooltip:AddLine(L["Log Info:"].." "..data.info)
			GameTooltip:AddLine("\n"..TSMAPI.Design:GetInlineColor("link2")..L["Click to show auctions for this item."].."|r")
			GameTooltip:AddLine(TSMAPI.Design:GetInlineColor("link2")..format(L["Right-Click to add %s to your friends list."], "|r"..(data.seller or "---")..TSMAPI.Design:GetInlineColor("link2")).."|r")
			GameTooltip:AddLine(TSMAPI.Design:GetInlineColor("link2")..L["Shift-Right-Click to show the options for this operation.".."|r"])
			GameTooltip:Show()
		end,
		OnLeave = function()
			GameTooltip:Hide()
		end,
		OnClick = function(_, data, _, button)
			if button == "LeftButton" then
				private.contentButtons:UnlockHighlight()
				private.logST:Hide()
				private.auctionsST:Show()
				private.auctionsST.isCurrentItem = data.itemString
				private:UpdateAuctionsSTData()
			elseif button == "RightButton" then
				if IsShiftKeyDown() then
					TSMAPI:ShowOperationOptions("Auctioning", TSM.operationNameLookup[data.operation])
				else
					if data.seller then
						AddFriend(data.seller)
					else
						TSM:Print(L["This item does not have any seller data."])
					end
				end
			end
		end,
		OnColumnClick = function(self, button)
			if self.colNum == 3 and button == "RightButton" then
				TSM.db.global.priceColumn = TSM.db.global.priceColumn + 1
				TSM.db.global.priceColumn = TSM.db.global.priceColumn > 2 and 1 or TSM.db.global.priceColumn
				self:SetText(GetPriceColumnText())
				wipe(private.logST.cache)
				private:UpdateLogSTData()
			end
		end,
	}
	
	local st = TSMAPI:CreateScrollingTable(parent, stCols, handlers)
	st:SetParent(parent)
	st:SetAllPoints()
	st:EnableSorting(true, 6)
	st:DisableSelection(true)
	return st
end

function private:UpdateAuctionsSTData()
	if not private.auctionsST:IsVisible() or not private.auctionsST.sortInfo then return end

	local results = {}
	if private.auctionsST.isCurrentItem then
		local itemString
		if type(private.auctionsST.isCurrentItem) == "string" or type(private.auctionsST.isCurrentItem) == "number" then
			itemString = private.auctionsST.isCurrentItem
		else
			itemString = TSM[private.mode]:GetCurrentItem().itemString
		end
		if itemString and TSM.Scan.auctionData[itemString] then
			tinsert(results, TSM.Scan.auctionData[itemString])
			private.auctionsST:SetExpanded(itemString, true)
		end
	else
		for _, auction in pairs(TSM.Scan.auctionData) do
			-- combine auctions with the same buyout / count / seller
			tinsert(results, auction)
		end
	end
	
	private.auctionsST:SetData(results)
end

function private:GetLogSTRow(record, recordIndex)
	if private.logST.cache[record] then
		return private.logST.cache[record]
	end
	
	local name, link = TSMAPI:GetSafeItemInfo(record.itemString)
	local buyout, seller, isWhitelist, isPlayer, lowestBuyout, _
	if record.reason ~= "cancelAll" then
		buyout, _, seller, isWhitelist, isPlayer = TSM.Scan:GetLowestAuction(record.itemString, record.operation)
		lowestBuyout = buyout
		if TSM.db.global.priceColumn == 1 then
			buyout = record.buyout
		end
	end
	
	local sellerText
	if seller then
		if isPlayer then
			sellerText = "|cffffff00"..seller.."|r"
		elseif isWhiteList then
			sellerText = TSMAPI.Design:GetInlineColor("link2")..seller.."|r"
		else
			sellerText = "|cffffffff"..seller.."|r"
		end
	else
		sellerText = "|cffffffff---|r"
	end
	
	local color = TSM.Log:GetColor(record.mode, record.reason)
	local infoText = (color or "|cffffffff")..(record.info or "---").."|r"
	
	local row = {
		cols = {
			{
				value = link,
				sortArg = name or "",
			},
			{
				value = record.operation and TSM.operationNameLookup[record.operation] or "---",
				sortArg = record.operation and TSM.operationNameLookup[record.operation] or "---",
			},
			{
				value = TSMAPI:FormatTextMoney(buyout, nil, true) or "---",
				sortArg = buyout or 0,
			},
			{
				value = sellerText,
				sortArg = seller or "~",
			},
			{
				value = infoText,
				sortArg = record.info or "~",
			},
			{ -- invisible column at the end for default sorting
				value = "",
				sortArg = recordIndex,
			},
		},
		link = link or name or itemString,
		itemString = record.itemString,
		operation = record.operation,
		buyout = buyout,
		lowestBuyout = lowestBuyout,
		seller = seller,
		info = infoText,
	}
	
	private.logST.cache[record] = row
	return row
end

function private:UpdateLogSTData()
	local rows = {}
	for i, record in ipairs(TSM.Log:GetData()) do
		tinsert(rows, private:GetLogSTRow(record, i))
	end
	private.logST:SetData(rows)
	
	if #private.logST.rowData > private.logST.NUM_ROWS then
		TSMAPI:CreateTimeDelay("logSTOffset", 0.08, function()
				private.logST:SetScrollOffset(#private.logST.rowData - private.logST.NUM_ROWS)
			end)
	end
end

function private:UpdateLogSTHighlight(currentItem)
	if not currentItem then return private.logST:SetHighlighted() end
	
	for i=1, #private.logST.rowData do
		local data = private.logST.rowData[i]
		if data and data.operation == currentItem.operation and data.itemString == currentItem.itemString then
			private.logST:SetHighlighted(i)
		end
	end
end

function private:UpdateSTData()
	private:UpdateLogSTData()
	private:UpdateAuctionsSTData()
end

local function SetGoldText()
	local line1, line2 = TSM.Post:GetAHGoldTotal()
	local text = format(L["Done Posting\n\nTotal value of your auctions: %s\nIncoming Gold: %s"], line1, line2)
	private.infoText:SetInfo(text)
end

function private:Stopped(notDone)
	TSM.Manage:UnregisterAllMessages()
	private.buttons:Disable(true)
	private.statusBar:UpdateStatus(100, 100)
	private.contentButtons.currAuctionsButton:Hide()
	
	if private.mode == "Post" then
		TSMAPI:CreateTimeDelay(0.5, SetGoldText)
		SetGoldText()
		private.statusBar:SetStatusText(L["Post Scan Finished"])
	elseif private.mode == "Cancel" then
		private.infoText:SetInfo(L["Done Canceling"])
		private.statusBar:SetStatusText(L["Cancel Scan Finished"])
	elseif private.mode == "Reset" then
		if not notDone then
			private.infoText:SetInfo(L["No Items to Reset"])
		end
		private.statusBar:SetStatusText(L["Reset Scan Finished"])
	end
	private.buttons.stop:SetText(L["Restart"])
	private.buttons.stop.isDone = true
end


function GUI:CreateSelectionFrame(parent)
	local frame = CreateFrame("Frame", nil, parent.content)
	frame:SetAllPoints()
	TSMAPI.Design:SetFrameBackdropColor(frame)

	local stContainer = CreateFrame("Frame", nil, frame)
	stContainer:SetPoint("TOPLEFT", 5, -20)
	stContainer:SetPoint("BOTTOMRIGHT", -200, 30)
	TSMAPI.Design:SetFrameColor(stContainer)
	frame.groupTree = TSMAPI:CreateGroupTree(stContainer, "Auctioning", "Auctioning_AH")
	
	local helpText = TSMAPI.GUI:CreateLabel(frame)
	helpText:SetPoint("TOP", stContainer, 0, 20)
	helpText:SetJustifyH("CENTER")
	helpText:SetJustifyV("CENTER")
	helpText:SetText(L["Select the groups which you would like to include in the scan."])
	frame.helpText = helpText
	
	local btnWidth = floor((stContainer:GetWidth() - 10)/3)
	local postBtn = TSMAPI.GUI:CreateButton(frame, 16)
	postBtn:SetPoint("BOTTOMLEFT", 5, 5)
	postBtn:SetHeight(20)
	postBtn:SetWidth(btnWidth)
	postBtn:SetText(L["Start Post Scan"])
	postBtn:SetScript("OnClick", function()
			private.mode = "Post"
			private.specialMode = nil
			GUI:StartScan(parent)
		end)
	frame.postBtn = postBtn
	
	local cancelBtn = TSMAPI.GUI:CreateButton(frame, 16)
	cancelBtn:SetPoint("BOTTOMLEFT", postBtn, "BOTTOMRIGHT", 5, 0)
	cancelBtn:SetHeight(20)
	cancelBtn:SetWidth(btnWidth)
	cancelBtn:SetText(L["Start Cancel Scan"])
	cancelBtn:SetScript("OnClick", function()
			private.mode = "Cancel"
			private.specialMode = nil
			GUI:StartScan(parent)
		end)
	frame.cancelBtn = cancelBtn
	
	local resetBtn = TSMAPI.GUI:CreateButton(frame, 16)
	resetBtn:SetPoint("BOTTOMLEFT", cancelBtn, "BOTTOMRIGHT", 5, 0)
	resetBtn:SetHeight(20)
	resetBtn:SetWidth(btnWidth)
	resetBtn:SetText(L["Start Reset Scan"])
	resetBtn:SetScript("OnClick", function()
			private.mode = "Reset"
			private.specialMode = nil
			GUI:StartScan(parent)
		end)
	frame.resetBtn = resetBtn
	
	local customScanFrame = CreateFrame("Frame", nil, frame)
	customScanFrame:SetPoint("TOPLEFT", stContainer:GetWidth() + 10, 0)
	customScanFrame:SetPoint("BOTTOMRIGHT")
	TSMAPI.Design:SetFrameColor(customScanFrame)
	private.customScanFrame = customScanFrame
	
	local title = TSMAPI.GUI:CreateLabel(customScanFrame)
	title:SetPoint("TOP", 0, -2)
	title:SetJustifyH("CENTER")
	title:SetJustifyV("CENTER")
	title:SetText(L["Other Auctioning Searches"])
	customScanFrame.title = title
	
	TSMAPI.GUI:CreateHorizontalLine(customScanFrame, -20)
	
	local cancelAllBtn = TSMAPI.GUI:CreateButton(customScanFrame, 16)
	cancelAllBtn:SetPoint("TOPLEFT", 4, -24)
	cancelAllBtn:SetPoint("TOPRIGHT", -4, -24)
	cancelAllBtn:SetHeight(20)
	cancelAllBtn:SetText(L["Cancel All Auctions"])
	cancelAllBtn:SetScript("OnClick", function()
			private.mode = "Cancel"
			private.specialMode = "CancelAll"
			GUI:StartScan(parent)
		end)
	cancelAllBtn.tooltip = L["Will cancel all your auctions, including ones which you didn't post with Auctioning."]
	customScanFrame.cancelAllBtn = cancelAllBtn
	
	TSMAPI.GUI:CreateHorizontalLine(customScanFrame, -48)
	
	local cancelFilterText = TSMAPI.GUI:CreateLabel(customScanFrame, "small")
	cancelFilterText:SetPoint("TOPLEFT", 4, -52)
	cancelFilterText:SetPoint("TOPRIGHT", -4, -52)
	cancelFilterText:SetJustifyH("LEFT")
	cancelFilterText:SetJustifyV("CENTER")
	cancelFilterText:SetText(L["Cancel Filter:"])
	customScanFrame.cancelFilterText = cancelFilterText
	
	local filterEditBox = TSMAPI.GUI:CreateInputBox(customScanFrame, "TSMAuctioningFilterSearchEditbox")
	filterEditBox:SetPoint("TOPLEFT", 4, -72)
	filterEditBox:SetPoint("TOPRIGHT", -4, -72)
	filterEditBox:SetHeight(20)
	customScanFrame.filterEditBox = filterEditBox
	
	local cancelFilterBtn = TSMAPI.GUI:CreateButton(customScanFrame, 16)
	cancelFilterBtn:SetPoint("TOPLEFT", 4, -96)
	cancelFilterBtn:SetPoint("TOPRIGHT", -4, -96)
	cancelFilterBtn:SetHeight(20)
	cancelFilterBtn:SetText("Cancel Items Matching Filter")
	cancelFilterBtn:SetScript("OnClick", function()
			local filter = filterEditBox:GetText():trim()
			if filter == "" then return TSM:Print(L["The filter cannot be empty. If you'd like to cancel all auctions, use the 'Cancel All Auctions' button."]) end
			private.mode = "Cancel"
			private.specialMode = filterEditBox:GetText()
			GUI:StartScan(parent)
		end)
	cancelFilterBtn.tooltip = L["Will cancel all your auctions which match the specified filter, including ones which you didn't post with Auctioning."]
	customScanFrame.cancelFilterBtn = cancelFilterBtn
	
	TSMAPI.GUI:CreateHorizontalLine(customScanFrame, -120)
	
	local durationList = {}
	local durationText = {L["Under 30min"], L["30min to 2hrs"], L["2 to 12 hrs"]}
	for i=1, 3 do -- go up to long duration
		durationList[i] = format("%s (%s)", _G["AUCTION_TIME_LEFT"..i], durationText[i])
	end
	local cancelDurationDropdown = TSMAPI.GUI:CreateDropdown(customScanFrame, durationList, L["Select a duration in this dropdown and click on the button below to cancel all auctions at or below this duration."])
	cancelDurationDropdown:SetPoint("TOPLEFT", 2, -124)
	cancelDurationDropdown:SetPoint("TOPRIGHT", 0, -124)
	cancelDurationDropdown:SetHeight(20)
	cancelDurationDropdown:SetLabel(L["Low Duration"])
	cancelDurationDropdown:SetValue(1)
	
	local cancelDurationBtn = TSMAPI.GUI:CreateButton(customScanFrame, 16)
	cancelDurationBtn:SetPoint("TOPLEFT", 4, -172)
	cancelDurationBtn:SetPoint("TOPRIGHT", -4, -172)
	cancelDurationBtn:SetHeight(20)
	cancelDurationBtn:SetText(L["Cancel Low Duration"])
	cancelDurationBtn:SetScript("OnClick", function()
			private.mode = "Cancel"
			private.specialMode = cancelDurationDropdown:GetValue()
			GUI:StartScan(parent)
		end)
	cancelDurationBtn.tooltip = L["Will cancel all your auctions at or below the specified duration, including ones you didn't post with Auctioning."]
	customScanFrame.cancelDurationBtn = cancelDurationBtn
	
	TSMAPI.GUI:CreateHorizontalLine(customScanFrame, -196)
	
	return frame
end

function GUI:CreateScanFrame(parent)
	local frame = CreateFrame("Frame", nil, parent)
	frame:SetAllPoints()
	local contentFrame = CreateFrame("Frame", nil, frame)
	contentFrame:SetAllPoints(parent.content)
	TSMAPI.Design:SetFrameColor(contentFrame)
	frame.content = contentFrame
	
	local statusBarFrame = CreateFrame("Frame", nil, frame.content)
	statusBarFrame:SetPoint("TOPLEFT", frame.content, "BOTTOMLEFT", 165, -2)
	statusBarFrame:SetWidth(355)
	statusBarFrame:SetHeight(30)
	private.statusBar = TSMAPI.GUI:CreateStatusBar(statusBarFrame, "TSMAuctioningStatusBar")
	
	private.buttons = private:CreateButtons(frame)
	
	private.contentButtons = private.contentButtons or private:CreateContentButtons(frame)
	private.contentButtons:Show()
	private.contentButtons:UpdateMode()
	
	private.infoText = private.infoText or private:CreateInfoText(frame)
	private.infoText:Show()
	
	private.auctionsST = private:CreateAuctionsST(frame.content)
	private.logST = private:CreateLogST(frame.content)
	return frame
end

function GUI:StartScan(frame)
	private.selectionFrame:Hide()
	private.scanFrame = private.scanFrame or GUI:CreateScanFrame(frame)
	private.scanFrame:Show()
	private.statusBar:Show()
	private.buttons:Show()
	private.buttons:UpdateMode()
	private.buttons:Disable()
	private.buttons.stop.isDone = nil
	private.buttons.stop:SetText(L["Stop"])
	private.contentButtons:Show()
	private.contentButtons:UpdateMode()
	private.infoText:Show()
	private.contentButtons.logButton:Click()
	private.auctionsST:SetData({})
	private.logST:SetData({})
	private.logST.cache = {}
	
	if private.mode == "Reset" then
		private.buttons:Hide()
		private.contentButtons:Hide()
		private.auctionsST:Hide()
		private.logST:Hide()
		TSM.Reset:Show(frame)
	end
	
	
	local options = {itemOperations={}}
	if private.specialMode then
		options.specialMode = private.specialMode
	else
		for groupName, data in pairs(private.selectionFrame.groupTree:GetSelectedGroupInfo()) do
			groupName = TSMAPI:FormatGroupPath(groupName, true)
			for _, opName in ipairs(data.operations) do
				TSMAPI:UpdateOperation("Auctioning", opName)
				local opSettings = TSM.operations[opName]
				if not opSettings then
					-- operation doesn't exist anymore in Auctioning
					TSM:Printf(L["'%s' has an Auctioning operation of '%s' which no longer exists. Auctioning will ignore this group until this is fixed."], groupName, opName)
				else
					-- it's a valid operation
					TSM.operationNameLookup[opSettings] = opName
					for itemString in pairs(data.items) do
						options.itemOperations[itemString] = options.itemOperations[itemString] or {}
						tinsert(options.itemOperations[itemString], opSettings)
					end
				end
			end
		end
	end
	
	TSMAPI:CreateTimeDelay("aucStartDelay", 0.1, function() TSM.Manage:StartScan(private, options) end)
end

function GUI:ShowSelectionFrame(frame)
	if private.scanFrame then private.scanFrame:Hide() end
	private.selectionFrame = private.selectionFrame or GUI:CreateSelectionFrame(frame)
	private.selectionFrame:Show()
	TSMAPI.AuctionScan:StopScan()
end

function GUI:HideSelectionFrame()
	private.selectionFrame:Hide()
	if private.scanFrame then private.scanFrame:Hide() end
	TSMAPI.AuctionScan:StopScan()
	TSM.Reset:Hide()
end