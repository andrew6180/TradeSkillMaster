-- ------------------------------------------------------------------------------ --
--                                TradeSkillMaster                                --
--                http://www.curse.com/addons/wow/tradeskill-master               --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

local TSM = select(2, ...)
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster") -- loads the localization table

TSMAPI.AuctionControl = {}
local private = {}
TSMAPI:RegisterForTracing(private, "TradeSkillMaster.AuctionControl_private")
LibStub("AceEvent-3.0"):Embed(private)
private.matchList = {}
private.currentPage = {}


local function GetNumInBags(baseItemString)
	local num = 0
	for _, _, itemString, quantity in TSMAPI:GetBagIterator() do
		if TSMAPI:GetBaseItemString(itemString) == baseItemString then
			num = num + quantity
		end
	end
	return num
end

local function ValidateAuction(index, list)
	if not private.currentAuction then return end
	local itemString, count, buyout, data, _
	if type(list) == "table" then
		itemString, count, buyout = unpack(list)
	elseif type(list) == "string" then
		itemString = TSMAPI:GetItemString(GetAuctionItemLink(list, index))
		_, _, count, _, _, _, _, _, _, buyout = GetAuctionItemInfo(list, index)
		data = {itemString, count, buyout}
	else
		return
	end
	return count == private.currentAuction.count and buyout == private.currentAuction.buyout and itemString == private.currentAuction.itemString, data
end

local diffFrame = CreateFrame("Frame")
diffFrame:Hide()
diffFrame.num = 0
diffFrame:RegisterEvent("CHAT_MSG_SYSTEM")
diffFrame:RegisterEvent("UI_ERROR_MESSAGE")
diffFrame:SetScript("OnEvent", function(self, event, arg)
	if event == "UI_ERROR_MESSAGE" then
		if arg == ERR_ITEM_NOT_FOUND then
			local auctionExists
			for i=1, GetNumAuctionItems("list") do
				if ValidateAuction(i, "list") then
					auctionExists = true
					break
				end
			end
			if not auctionExists then
				self.num = self.num - 1
			end
		elseif arg == ERR_AUCTION_HIGHER_BID then
			local auctionExists
			for i=1, GetNumAuctionItems("list") do
				if ValidateAuction(i, "list") then
					auctionExists = true
					break
				end
			end
			if not auctionExists then
				self.num = self.num - 1
			end
		end
	elseif event == "CHAT_MSG_SYSTEM" then
		if arg == ERR_AUCTION_BID_PLACED then
			self.num = self.num - 1
		end
	end
end)

local customPriceWarned
function private:SetCurrentAuction(record)
	if not record then
		private.currentAuction = nil
		return
	end
	
	local buyout = record.buyout
	if private.confirmationMode == "Post" and not record:IsPlayer() then
		local undercut = TSMAPI:ParseCustomPrice(private.postUndercut)
		undercut = undercut and undercut(record.parent:GetItemString())
		if not undercut and not customPriceWarned then
			TSM:Print(L["Invalid custom price for undercut amount. Using 1c instead."])
			customPriceWarned = true
			undercut = 1
		end
		buyout = buyout - undercut
	end
	private.currentAuction = {
		link = record.parent.itemLink,
		itemString = record.parent:GetItemString(),
		buyout = buyout,
		count = record.count,
		numAuctions = record.numAuctions,
		seller = record.seller,
		isPlayer = record:IsPlayer(),
		num = 1,
		destroyingNum = record.parent.destroyingNum,
	}
end

local count = 0
function private:FindCurrentAuctionForBuyout(noCache, resetCount)
	if not private.currentAuction then return end
	if diffFrame.num > 0 then
		return TSMAPI:CreateTimeDelay(0.2, private.FindCurrentAuctionForBuyout)
	end
	if resetCount then
		count = 0
	end
	count = count + 1
	
	private:UpdateMatchList(true)
	if #private.matchList > 0 then
		-- the next item is on the current page
		private:UpdateAuctionConfirmation()
		return
	end
	
	private.matchList = {}
	private.currentPage = {}
	
	if count > 3 then
		-- auction no longer exists
		TSM:Print(L["Skipping auction which no longer exists."])
		diffFrame.num = diffFrame.num - 1
		private.justBought = true
		private:AUCTION_ITEM_LIST_UPDATE()
		return
	end
	TSMAPI.AuctionScan:FindAuction(private.OnAuctionFound, {itemString=private.currentAuction.itemString, buyout=private.currentAuction.buyout, count=private.currentAuction.count, seller=private.currentAuction.seller}, not noCache)
	private.isSearching = true
end

function private:DoBuyout()
	if private.isSearching or not private.currentAuction or not private.confirmationFrame:IsVisible() then return end

	for i=#private.matchList, 1, -1 do
		local aucIndex = private.matchList[i]
		tremove(private.matchList, i)
		tremove(private.currentPage, aucIndex)
		if ValidateAuction(aucIndex, "list") then
			PlaceAuctionBid("list", aucIndex, private.currentAuction.buyout)
			private.justBought = true
			diffFrame.num = diffFrame.num + 1
			return
		end
	end
	
	private:FindCurrentAuctionForBuyout()
end

function private:DoCancel()
	if private.isSearching or not private.currentAuction or not private.confirmationFrame:IsVisible() then return end
	
	local function OnCancel()
		private.justBought = true
		private:AUCTION_ITEM_LIST_UPDATE()
	end

	for i=GetNumAuctionItems("owner"), 1, -1 do
		if ValidateAuction(i, "owner") then
			CancelAuction(i)
			-- wait for all the events that are triggered by this action
			private:RegisterMessage("TSM_AH_EVENTS", OnCancel)
			TSMAPI:WaitForAuctionEvents("Cancel")
			return
		end
	end
	
	TSM:Print(L["Auction not found. Skipped."])
	private.justBought = true
	private:AUCTION_ITEM_LIST_UPDATE()
end

function private:DoPost(postInfo)
	if private.isSearching or not postInfo or not private.postFrame:IsVisible() then return end
	
	if not AuctionFrameAuctions.duration then
		-- Fix in case Blizzard_AuctionUI hasn't set this value yet (which could cause an error)
		AuctionFrameAuctions.duration = postInfo.duration
	end
	
	local bag, slot
	for b, s, itemString in TSMAPI:GetBagIterator() do
		if postInfo.itemString == itemString then
			bag, slot = b, s
			break
		end
	end
	if not bag then
		TSM:Print(L["Item not found in bags. Skipping"])
		return
	end
	
	local function OnPost()
		private.postFrame:Hide()
		postInfo.duration = postInfo.duration == 1 and 3 or 4
		TSM:AuctionControlCallback("OnPost", postInfo)
		TSMAPI:FireEvent("TSM:AUCTIONCONTROL:ITEMPOSTED", postInfo)
	end
	private:RegisterMessage("TSM_AH_EVENTS", OnPost)
	TSMAPI:WaitForAuctionEvents("Post", postInfo.numAuctions > 1)

	PickupContainerItem(bag, slot)
	ClickAuctionSellItemButton(AuctionsItemButton, "LeftButton")
	StartAuction(postInfo.bid, postInfo.buyout, postInfo.duration, postInfo.stackSize, postInfo.numAuctions)
end

function private:UpdateMatchList(noPageScanning)
	private.matchList = {}
	
	if noPageScanning then
		for i=1, #private.currentPage do
			if ValidateAuction(i, private.currentPage[i]) then
				tinsert(private.matchList, i)
			end
		end
	else
		private.currentPage = {}
		for i=1, GetNumAuctionItems("list") do
			local isValid, data = ValidateAuction(i, "list")
			private.currentPage[i] = data
			if isValid then
				tinsert(private.matchList, i)
			end
		end
	end
end

function private:OnAuctionFound(cacheIndex)
	if not private.isSearching or not private.currentAuction then return end
	private.isSearching = nil
	
	private:UpdateMatchList()
	
	if #private.matchList == 0 then
		private:FindCurrentAuctionForBuyout(true)
	else
		private.currentCacheIndex = cacheIndex
		private:UpdateAuctionConfirmation()
	end
end

function private:AUCTION_ITEM_LIST_UPDATE()
	if not private.currentAuction or not TSMAPI:AHTabIsVisible(private.module) then return end
	
	if private.justBought then
		private.justBought = nil
		private.currentAuction.num = private.currentAuction.num + 1
		local prevAuction = CopyTable(private.currentAuction)
		if private.currentAuction.num > private.currentAuction.numAuctions then
			TSMAPI.AuctionControl:HideConfirmation()
		else
			if #private.matchList > 0 then
				private:UpdateAuctionConfirmation()
			else
				private:FindCurrentAuctionForBuyout(nil, true)
			end
		end
		
		if private.currentCacheIndex then
			TSMAPI.AuctionScan:CacheRemove(prevAuction.itemString, private.currentCacheIndex)
			private.currentCacheIndex = nil
		end
		
		TSM:AuctionControlCallback("OnBuyout", prevAuction)
	end
end

function TSM:AuctionControlCallback(...)
	if not private.callback then return end
	private.callback(...)
end


-- **************************************************************************
--                          Utility TSMAPI Functions
-- **************************************************************************

function TSMAPI.AuctionControl:IsConfirmationVisible()
	return (private.confirmationFrame and private.confirmationFrame:IsVisible()) or (private.postFrame and private.postFrame:IsVisible())
end

function TSMAPI.AuctionControl:IsBuyingComplete()
	return diffFrame.num <= 0
end


-- **************************************************************************
--                        GUI Show/Hide/Update Functions
-- **************************************************************************

function TSMAPI.AuctionControl:ShowControlButtons(parent, rt, callback, module, postBidPercent, postUndercut)
	private.confirmationFrame = private.confirmationFrame or private:CreateConfirmationFrame(parent)
	private.postFrame = private.postFrame or private:CreatePostFrame(parent)
	private.controlButtons = private.controlButtons or private:CreateControlButtons(parent)
	private.controlButtons:Show()
	private.rt = rt
	private.callback = callback
	private.module = module
	private.postBidPercent = postBidPercent
	private.postUndercut = postUndercut
	return private.controlButtons
end

function TSMAPI.AuctionControl:HideControlButtons()
	private.controlButtons:Hide()
	private.rt = nil
	private.callback = nil
	TSMAPI.AuctionControl:HideConfirmation()
end

function TSMAPI.AuctionControl:SetNoResultItem(itemString, buyout)
	if not itemString or not buyout then return end
	local link = select(2, TSMAPI:GetSafeItemInfo(itemString))
	private.currentAuction = {
		link = link,
		itemString = itemString,
		buyout = buyout,
		count = 1,
		numAuctions = 1,
		num = 1,
		isNoResult = true,
	}
end

function private:ShowConfirmationWindow()
	if private.confirmationFrame:IsVisible() then
		private.confirmationFrame:UpdateStrata()
		return
	elseif private.postFrame:IsVisible() then
		private.postFrame:UpdateStrata()
		return
	end
	private:SetCurrentAuction(private.rt:GetSelectedAuction())
	if not private.currentAuction then return end
	
	private:RegisterEvent("AUCTION_ITEM_LIST_UPDATE")
	diffFrame.num = 0
	diffFrame:Show()
	private.confirmationFrame:Show()
	private.confirmationFrame.proceed:Disable()
	private.confirmationFrame.linkText:SetText("")
	private.confirmationFrame.quantityText:SetText("")
	private.confirmationFrame.buyoutText:SetText("")
	private.confirmationFrame.buyoutText2:SetText("")
	private.confirmationFrame.purchasedText:SetText("")
	private.confirmationFrame.searchingText:SetText(L["Searching for item..."])
	if private.confirmationMode == "Buyout" then
		private:FindCurrentAuctionForBuyout(nil, true)
	else
		private:UpdateAuctionConfirmation()
	end
end

function private:ShowPostWindow()
	if private.confirmationFrame:IsVisible() then
		private.confirmationFrame:UpdateStrata()
		return
	elseif private.postFrame:IsVisible() then
		private.postFrame:UpdateStrata()
		return
	end
	if not private.currentAuction or not private.currentAuction.isNoResult then
		private:SetCurrentAuction(private.rt:GetSelectedAuction())
	end
	if not private.currentAuction then return end
	
	private:RegisterEvent("AUCTION_ITEM_LIST_UPDATE")
	diffFrame.num = 0
	diffFrame:Show()
	private.postFrame:Show()
	private:UpdatePostFrame()
	TSMAPI:FireEvent("TSM:AUCTIONCONTROL:POSTSHOWN")
end

function TSMAPI.AuctionControl:HideConfirmation()
	private:UnregisterEvent("AUCTION_ITEM_LIST_UPDATE")
	if private.confirmationFrame then private.confirmationFrame:Hide() end
	if private.postFrame then private.postFrame:Hide() end
	diffFrame:Hide()
	private.isSearching = nil
	private:SetCurrentAuction()
	TSMAPI.AuctionScan:StopFindScan()
end

function private:UpdateAuctionConfirmation()
	local buyoutText = TSMAPI:FormatTextMoneyIcon(private.currentAuction.buyout, nil, true)
	local itemBuyoutText = TSMAPI:FormatTextMoneyIcon(floor(private.currentAuction.buyout/private.currentAuction.count), nil, true)
	
	private.confirmationFrame.searchingText:SetText("")
	private.confirmationFrame.linkText:SetText(private.currentAuction.link)
	private.confirmationFrame.quantityText:SetText("x"..private.currentAuction.count)
	private.confirmationFrame.buyoutText:SetText(format(L["Item Buyout: %s"], itemBuyoutText))
	private.confirmationFrame.buyoutText2:SetText(format(L["Auction Buyout: %s"], buyoutText))
	if private.confirmationMode == "Buyout" then
		private.confirmationFrame.proceed:SetText(BUYOUT)
		private.confirmationFrame.purchasedText:SetText(format(L["Purchasing Auction: %d/%d"], private.currentAuction.num, private.currentAuction.numAuctions))
	elseif private.confirmationMode == "Cancel" then
		private.confirmationFrame.proceed:SetText(CANCEL)
		private.confirmationFrame.purchasedText:SetText(format(L["Canceling Auction: %d/%d"], private.currentAuction.num, private.currentAuction.numAuctions))
	end
	private.confirmationFrame.proceed:Enable()
end

function private:UpdatePostFrame()
	local maxQuantity = select(8, TSMAPI:GetSafeItemInfo(private.currentAuction.link))
	local numInBags = GetNumInBags(TSMAPI:GetBaseItemString(private.currentAuction.itemString))
	local stackSize = min(private.currentAuction.count, numInBags)
	local currentPerItem = floor(private.currentAuction.buyout/private.currentAuction.count)
	local currentBuyout = stackSize == private.currentAuction.count and private.currentAuction.buyout or (currentPerItem*stackSize)
	
	private.postFrame.numInBags = numInBags
	private.postFrame.linkText:SetText(private.currentAuction.link)
	private.postFrame.proceed:Enable()
	private.postFrame.buyoutInputBox:SetText(TSMAPI:FormatTextMoney(currentBuyout, nil, nil, nil, true))
	private.postFrame.perItemInputBox:SetText(TSMAPI:FormatTextMoney(currentPerItem, nil, nil, nil, true))
	private.postFrame.numAuctionsInputBox.max = numInBags
	private.postFrame.numAuctionsInputBox.btn:SetText(format(L["max %d"], floor(numInBags/stackSize)))
	private.postFrame.numAuctionsInputBox:SetNumber(1)
	private.postFrame.stackSizeInputBox.max = min(numInBags, maxQuantity)
	private.postFrame.stackSizeInputBox.btn:SetText(format(L["max %d"], private.postFrame.stackSizeInputBox.max))
	private.postFrame.stackSizeInputBox:SetNumber(stackSize)
	private.postFrame.durationDropdown:SetValue(TSM.db.profile.postDuration)
end


-- **************************************************************************
--                            GUI Creation Code
-- **************************************************************************

function private:CreateConfirmationFrame(parent)
	local frame = CreateFrame("Frame", nil, parent)
	TSMAPI.Design:SetFrameBackdropColor(frame)
	frame:Hide()
	frame:SetPoint("CENTER")
	frame:SetFrameStrata("DIALOG")
	frame:SetWidth(300)
	frame:SetHeight(150)
	frame.UpdateStrata = function()
		frame:SetFrameStrata("DIALOG")
		frame.bg:SetFrameStrata("HIGH")
	end
	frame:SetScript("OnShow", frame.UpdateStrata)
	frame:SetScript("OnUpdate", function()
			if not TSMAPI:AHTabIsVisible(private.module) then
				TSMAPI.AuctionControl:HideConfirmation()
			end
		end)
	
	local bg = CreateFrame("Frame", nil, frame)
	bg:SetFrameStrata("HIGH")
	bg:SetPoint("TOPLEFT", parent.content)
	bg:SetPoint("BOTTOMRIGHT", parent.content)
	bg:EnableMouse(true)
	TSMAPI.Design:SetFrameBackdropColor(bg)
	bg:SetAlpha(.2)
	frame.bg = bg
	
	local btn = TSMAPI.GUI:CreateButton(frame, 18, "TSMAHConfirmationActionButton")
	btn:SetPoint("BOTTOMLEFT", 10, 10)
	btn:SetPoint("BOTTOMRIGHT", frame, "BOTTOM", -2, 10)
	btn:SetHeight(25)
	btn:SetText("")
	btn:SetScript("OnClick", function(self)
			if not TSMAPI:AHTabIsVisible(private.module) then return end
			self:Disable()
			if private.confirmationMode == "Buyout" then
				private:DoBuyout()
			elseif private.confirmationMode == "Cancel" then
				private:DoCancel()
			end
		end)
	frame.proceed = btn
	
	local btn = TSMAPI.GUI:CreateButton(frame, 18)
	btn:SetPoint("BOTTOMLEFT", frame, "BOTTOM", 2, 10)
	btn:SetPoint("BOTTOMRIGHT", -10, 10)
	btn:SetHeight(25)
	btn:SetText(CLOSE)
	btn:SetScript("OnClick", function() frame:Hide() end)
	frame.close = btn
	
	local linkText = TSMAPI.GUI:CreateLabel(frame)
	linkText:SetFontObject(GameFontNormal)
	linkText:SetPoint("TOP", -10, -10)
	frame.linkText = linkText
	
	local bg = frame:CreateTexture(nil, "BACKGROUND")
	bg:SetPoint("TOPLEFT", linkText, -2, 2)
	bg:SetPoint("BOTTOMRIGHT", linkText, 2, -2)
	TSMAPI.Design:SetContentColor(bg)
	linkText.bg = bg
	bg:Show()
	
	local quantityText = TSMAPI.GUI:CreateLabel(frame)
	quantityText:SetPoint("LEFT", linkText, "RIGHT")
	frame.quantityText = quantityText
	
	local buyoutText = TSMAPI.GUI:CreateLabel(frame)
	buyoutText:SetPoint("TOPLEFT", 10, -41)
	buyoutText:SetJustifyH("LEFT")
	frame.buyoutText = buyoutText
	
	local buyoutText2 = TSMAPI.GUI:CreateLabel(frame)
	buyoutText2:SetPoint("TOPLEFT", buyoutText, "BOTTOMLEFT")
	buyoutText2:SetJustifyH("LEFT")
	frame.buyoutText2 = buyoutText2
	
	local purchasedText = TSMAPI.GUI:CreateLabel(frame)
	purchasedText:SetPoint("TOPLEFT", 10, -70)
	frame.purchasedText = purchasedText
	
	local searchingText = TSMAPI.GUI:CreateLabel(frame)
	searchingText:SetPoint("CENTER")
	frame.searchingText = searchingText
	
	return frame
end

function private:CreatePostFrame(parent)
	local frame = CreateFrame("Frame", nil, parent)
	TSMAPI.Design:SetFrameBackdropColor(frame)
	frame:Hide()
	frame:SetPoint("CENTER")
	frame:SetFrameStrata("DIALOG")
	frame:SetWidth(250)
	frame:SetHeight(245)
	frame.UpdateStrata = function()
		frame:SetFrameStrata("DIALOG")
		frame.bg:SetFrameStrata("HIGH")
	end
	frame:SetScript("OnShow", frame.UpdateStrata)
	frame:SetScript("OnUpdate", function()
			if not TSMAPI:AHTabIsVisible(private.module) then
				TSMAPI.AuctionControl:HideConfirmation()
			end
		end)
	
	local bg = CreateFrame("Frame", nil, frame)
	bg:SetFrameStrata("HIGH")
	bg:SetPoint("TOPLEFT", parent.content)
	bg:SetPoint("BOTTOMRIGHT", parent.content)
	bg:EnableMouse(true)
	TSMAPI.Design:SetFrameBackdropColor(bg)
	bg:SetAlpha(0.2)
	frame.bg = bg
	
	local btn = TSMAPI.GUI:CreateButton(frame, 18, "TSMAHConfirmationPostButton")
	btn:SetPoint("BOTTOMLEFT", 10, 10)
	btn:SetPoint("BOTTOMRIGHT", frame, "BOTTOM", -2, 10)
	btn:SetHeight(25)
	btn:SetText(L["Post"])
	btn:SetScript("OnClick", function(self)
			if not TSMAPI:AHTabIsVisible(private.module) then return end
			self:Disable()
			local postInfo = {}
			postInfo.itemString = private.currentAuction.itemString
			postInfo.buyout = TSMAPI:UnformatTextMoney(frame.buyoutInputBox:GetText())
			postInfo.bid = max(floor(postInfo.buyout*private.postBidPercent), 1)
			postInfo.stackSize = frame.stackSizeInputBox:GetNumber()
			postInfo.numAuctions = frame.numAuctionsInputBox:GetNumber()
			postInfo.duration = TSM.db.profile.postDuration
			
			private:DoPost(postInfo)
		end)
	frame.proceed = btn
	
	local btn = TSMAPI.GUI:CreateButton(frame, 18)
	btn:SetPoint("BOTTOMLEFT", frame, "BOTTOM", 2, 10)
	btn:SetPoint("BOTTOMRIGHT", -10, 10)
	btn:SetHeight(25)
	btn:SetText(CLOSE)
	btn:SetScript("OnClick", function() frame:Hide() end)
	frame.close = btn
	
	local linkText = TSMAPI.GUI:CreateLabel(frame)
	linkText:SetFontObject(GameFontNormal)
	linkText:SetPoint("TOP", -10, -10)
	frame.linkText = linkText
	
	local bg = frame:CreateTexture(nil, "BACKGROUND")
	bg:SetPoint("TOPLEFT", linkText, -2, 2)
	bg:SetPoint("BOTTOMRIGHT", linkText, 2, -2)
	TSMAPI.Design:SetContentColor(bg)
	linkText.bg = bg
	bg:Show()
	
	
	local function OnPriceInputBoxTextChanged()
		local buyout = TSMAPI:UnformatTextMoney(frame.buyoutInputBox:GetText())
		local perItem = TSMAPI:UnformatTextMoney(frame.perItemInputBox:GetText())
		if not buyout or not perItem or buyout == 0 then
			frame.proceed:Disable()
		else
			frame.proceed:Enable()
		end
	end
	
	local function OnPriceInputBoxEditFocusLost(self)
		local copper = TSMAPI:UnformatTextMoney(self:GetText())
		if copper then
			local stackSize = frame.stackSizeInputBox:GetNumber()
			if self == frame.buyoutInputBox then
				frame.perItemInputBox:SetText(TSMAPI:FormatTextMoney(floor(copper/stackSize), nil, nil, nil, true))
			elseif self == frame.perItemInputBox then
				frame.buyoutInputBox:SetText(TSMAPI:FormatTextMoney(copper*stackSize, nil, nil, nil, true))
			end
			self:SetText(TSMAPI:FormatTextMoney(copper, nil, nil, nil, true))
			self:ClearFocus()
		else
			self:SetFocus()
		end
	end
	
	local function OnInputBoxTabPressed(self)
		local boxes = {"buyoutInputBox", "perItemInputBox", "numAuctionsInputBox", "stackSizeInputBox"}
		self:ClearFocus()
		for i=1, #boxes-1 do
			if self == frame[boxes[i]] then
				frame[boxes[i+1]]:SetFocus()
			end
		end
	end
	
	local buyoutLabel = TSMAPI.GUI:CreateLabel(frame)
	buyoutLabel:SetPoint("TOPLEFT", 10, -40)
	buyoutLabel:SetHeight(20)
	buyoutLabel:SetJustifyH("LEFT")
	buyoutLabel:SetText(L["Auction Buyout:"])
	
	local buyoutInputBox = TSMAPI.GUI:CreateInputBox(frame)
	buyoutInputBox:SetJustifyH("RIGHT")
	buyoutInputBox:SetPoint("TOPRIGHT", -10, -40)
	buyoutInputBox:SetPoint("TOPLEFT", buyoutLabel, "TOPRIGHT", 10, 0)
	buyoutInputBox:SetHeight(20)
	buyoutInputBox:SetScript("OnEnterPressed", buyoutInputBox.ClearFocus)
	buyoutInputBox:SetScript("OnEscapePressed", buyoutInputBox.ClearFocus)
	buyoutInputBox:SetScript("OnEditFocusLost", OnPriceInputBoxEditFocusLost)
	buyoutInputBox:SetScript("OnTextChanged", OnPriceInputBoxTextChanged)
	buyoutInputBox:SetScript("OnTabPressed", OnInputBoxTabPressed)
	frame.buyoutInputBox = buyoutInputBox
	
	local perItemLabel = TSMAPI.GUI:CreateLabel(frame)
	perItemLabel:SetPoint("TOPLEFT", 10, -65)
	perItemLabel:SetHeight(20)
	perItemLabel:SetJustifyH("LEFT")
	perItemLabel:SetText(L["Per Item:"])
	
	local perItemInputBox = TSMAPI.GUI:CreateInputBox(frame)
	perItemInputBox:SetJustifyH("RIGHT")
	perItemInputBox:SetPoint("TOPRIGHT", -10, -65)
	perItemInputBox:SetPoint("TOPLEFT", perItemLabel, "TOPRIGHT", 10, 0)
	perItemInputBox:SetHeight(20)
	perItemInputBox:SetScript("OnEnterPressed", perItemInputBox.ClearFocus)
	perItemInputBox:SetScript("OnEscapePressed", perItemInputBox.ClearFocus)
	perItemInputBox:SetScript("OnEditFocusLost", OnPriceInputBoxEditFocusLost)
	perItemInputBox:SetScript("OnTextChanged", OnPriceInputBoxTextChanged)
	perItemInputBox:SetScript("OnTabPressed", OnInputBoxTabPressed)
	frame.perItemInputBox = perItemInputBox
	
	
	local function OnCountInputBoxEditFocusLost(self)
		local numAuctions = max(1, min(frame.numAuctionsInputBox:GetNumber(), frame.numAuctionsInputBox.max))
		local stackSize = max(1, min(frame.stackSizeInputBox:GetNumber(), frame.stackSizeInputBox.max))
		
		if self == frame.stackSizeInputBox then
			numAuctions = min(numAuctions, floor(frame.numInBags/stackSize))
		elseif self == frame.numAuctionsInputBox then
			stackSize = min(stackSize, floor(frame.numInBags/numAuctions))
		end
		frame.numAuctionsInputBox:SetNumber(numAuctions)
		frame.stackSizeInputBox:SetNumber(stackSize)
		frame.numAuctionsInputBox.btn:SetText(format(L["max %d"], floor(frame.numInBags/stackSize)))
		frame.stackSizeInputBox.btn:SetText(format(L["max %d"], min(frame.stackSizeInputBox.max, floor(frame.numInBags/numAuctions))))
		local perItem = TSMAPI:UnformatTextMoney(frame.perItemInputBox:GetText())
		frame.buyoutInputBox:SetText(TSMAPI:FormatTextMoney(perItem*stackSize, nil, nil, nil, true))
	end
	
	local function OnCountInputBoxTextChanged(self)
		local numAuctions = frame.numAuctionsInputBox:GetNumber()
		local stackSize = frame.stackSizeInputBox:GetNumber()
		if numAuctions <= 0 or stackSize <= 0 or numAuctions*stackSize > frame.numInBags then
			frame.proceed:Disable()
		else
			frame.proceed:Enable()
		end
	end
	
	local function OnMaxButtonClicked(self)
		self.inputBox:SetNumber(self.inputBox.max)
		self.inputBox:SetFocus()
		self.inputBox:ClearFocus()
	end
	
	local numAuctionsInputBox = TSMAPI.GUI:CreateInputBox(frame)
	numAuctionsInputBox:SetJustifyH("CENTER")
	numAuctionsInputBox:SetNumeric(true)
	numAuctionsInputBox:SetPoint("TOPLEFT", 10, -110)
	numAuctionsInputBox:SetHeight(20)
	numAuctionsInputBox:SetScript("OnEnterPressed", numAuctionsInputBox.ClearFocus)
	numAuctionsInputBox:SetScript("OnEscapePressed", numAuctionsInputBox.ClearFocus)
	numAuctionsInputBox:SetScript("OnEditFocusLost", OnCountInputBoxEditFocusLost)
	numAuctionsInputBox:SetScript("OnTextChanged", OnCountInputBoxTextChanged)
	numAuctionsInputBox:SetScript("OnTabPressed", OnInputBoxTabPressed)
	frame.numAuctionsInputBox = numAuctionsInputBox
	
	local stackSizeInputBox = TSMAPI.GUI:CreateInputBox(frame)
	stackSizeInputBox:SetJustifyH("CENTER")
	stackSizeInputBox:SetNumeric(true)
	stackSizeInputBox:SetPoint("TOPRIGHT", -10, -110)
	stackSizeInputBox:SetHeight(20)
	stackSizeInputBox:SetScript("OnEnterPressed", stackSizeInputBox.ClearFocus)
	stackSizeInputBox:SetScript("OnEscapePressed", stackSizeInputBox.ClearFocus)
	stackSizeInputBox:SetScript("OnEditFocusLost", OnCountInputBoxEditFocusLost)
	stackSizeInputBox:SetScript("OnTextChanged", OnCountInputBoxTextChanged)
	stackSizeInputBox:SetScript("OnTabPressed", OnInputBoxTabPressed)
	frame.stackSizeInputBox = stackSizeInputBox
	
	local countLabel = TSMAPI.GUI:CreateLabel(frame)
	countLabel:SetPoint("TOPLEFT", numAuctionsInputBox, "TOPRIGHT", 10, 0)
	countLabel:SetPoint("TOPRIGHT", stackSizeInputBox, "TOPLEFT", -10, 0)
	countLabel:SetHeight(20)
	countLabel:SetJustifyH("CENTER")
	countLabel:SetText(L["stacks of"])
	
	local editboxWidth = (frame:GetWidth() - 40 - countLabel:GetStringWidth()) / 2
	numAuctionsInputBox:SetWidth(editboxWidth)
	stackSizeInputBox:SetWidth(editboxWidth)
	
	local maxStackSizeBtn = TSMAPI.GUI:CreateButton(frame, 12)
	maxStackSizeBtn:SetPoint("TOPLEFT", stackSizeInputBox, "BOTTOMLEFT", 5, -3)
	maxStackSizeBtn:SetPoint("TOPRIGHT", stackSizeInputBox, "BOTTOMRIGHT", -5, -3)
	maxStackSizeBtn:SetHeight(14)
	maxStackSizeBtn:SetText("")
	maxStackSizeBtn:SetScript("OnClick", OnMaxButtonClicked)
	maxStackSizeBtn.inputBox = stackSizeInputBox
	stackSizeInputBox.btn = maxStackSizeBtn
	
	local maxNumAuctionsBtn = TSMAPI.GUI:CreateButton(frame, 12)
	maxNumAuctionsBtn:SetPoint("TOPLEFT", numAuctionsInputBox, "BOTTOMLEFT", 5, -3)
	maxNumAuctionsBtn:SetPoint("TOPRIGHT", numAuctionsInputBox, "BOTTOMRIGHT", -5, -3)
	maxNumAuctionsBtn:SetHeight(14)
	maxNumAuctionsBtn:SetText("")
	maxNumAuctionsBtn:SetScript("OnClick", OnMaxButtonClicked)
	maxNumAuctionsBtn.inputBox = numAuctionsInputBox
	numAuctionsInputBox.btn = maxNumAuctionsBtn
	
	local durationLabel = TSMAPI.GUI:CreateLabel(frame)
	durationLabel:SetPoint("TOPLEFT", 10, -165)
	durationLabel:SetHeight(20)
	durationLabel:SetJustifyH("LEFT")
	durationLabel:SetText(L["Duration:"])
	
	local list = {AUCTION_DURATION_ONE, AUCTION_DURATION_TWO, AUCTION_DURATION_THREE}
	local durationDropdown = TSMAPI.GUI:CreateDropdown(frame, list)
	durationDropdown:SetPoint("TOPLEFT", durationLabel, "TOPRIGHT", 10, 0)
	durationDropdown:SetPoint("TOPRIGHT", 0, -165)
	durationDropdown:SetHeight(20)
	durationDropdown:SetCallback("OnValueChanged", function(self, _, value) TSM.db.profile.postDuration = value end)
	frame.durationDropdown = durationDropdown
	
	return frame
end

function private:CreateControlButtons(parent)
	local frame = CreateFrame("Frame", nil, parent)
	frame:SetHeight(24)
	frame:SetWidth(390)
	frame:SetPoint("BOTTOMRIGHT", -20, 6)
	
	local function OnClick(self)
		if not private.rt or not private.callback then return end
		private.confirmationMode = self.which
		if self.which == "Post" then
			private:ShowPostWindow()
		else
			private:ShowConfirmationWindow()
		end
	end
	
	local button = TSMAPI.GUI:CreateButton(frame, 18, "TSMAHTabCancelButton")
	button:SetPoint("TOPLEFT", 0, 0)
	button:SetWidth(100)
	button:SetHeight(24)
	button:SetText(CANCEL)
	button.which = "Cancel"
	button:SetScript("OnClick", OnClick)
	frame.cancel = button
	
	local button = TSMAPI.GUI:CreateButton(frame, 18, "TSMAHTabPostButton")
	button:SetPoint("TOPLEFT", 104, 0)
	button:SetWidth(100)
	button:SetHeight(24)
	button:SetText(L["Post"])
	button.which = "Post"
	button:SetScript("OnClick", OnClick)
	frame.post = button
	
	local button = TSMAPI.GUI:CreateButton(frame, 18, "TSMAHTabBuyoutButton")
	button:SetPoint("TOPLEFT", 208, 0)
	button:SetWidth(100)
	button:SetHeight(24)
	button:SetText(BUYOUT)
	button.which = "Buyout"
	button:SetScript("OnClick", OnClick)
	frame.buyout = button
	
	return frame
end