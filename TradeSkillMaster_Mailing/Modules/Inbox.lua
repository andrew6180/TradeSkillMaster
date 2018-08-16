-- ------------------------------------------------------------------------------ --
--                            TradeSkillMaster_Mailing                            --
--            http://www.curse.com/addons/wow/tradeskillmaster_mailing            --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

local TSM = select(2, ...)
local Inbox = TSM:NewModule("Inbox", "AceEvent-3.0", "AceHook-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster_Mailing") -- loads the localization table

local private = { recheckTime = 1, allowTimerStart = true, lootIndex = 1, freeSlots = true }


function Inbox:OnEnable()
	Inbox:RegisterEvent("MAIL_SHOW")
	TSMAPI:CreateEventBucket("MAIL_INBOX_UPDATE", private.InboxUpdate, 0.2)
	Inbox:RegisterEvent("MAIL_CLOSED")
end

function Inbox:CreateTab(parent)
	local frame = CreateFrame("Frame", nil, parent)
	frame:Hide()
	frame:SetAllPoints()
	frame:SetScript("OnHide", function() private:StopAutoLooting() end)
	frame:SetScript("OnShow", private.InboxUpdate)

	local label = TSMAPI.GUI:CreateLabel(frame, "small")
	label:SetPoint("TOPLEFT", 5, -5)
	label:SetPoint("TOPRIGHT", -5, -5)
	label:SetHeight(15)
	label:SetJustifyH("CENTER")
	label:SetJustifyV("CENTER")
	frame.topLabel = label

	TSMAPI.GUI:CreateHorizontalLine(frame, -25)

	local stContainer = CreateFrame("Frame", nil, frame)
	stContainer:SetPoint("TOPLEFT", 5, -35)
	stContainer:SetPoint("BOTTOMRIGHT", -5, 55)
	TSMAPI.Design:SetFrameColor(stContainer)

	local handlers = {
		OnClick = function(_, data)
			if IsShiftKeyDown() and select(6, GetInboxHeaderInfo(data.index)) <= 0 then
				if private:CanLootMailIndex(data.index) then
					private:LootMailItem(data.index)
				else
					TSM:Print(L["Could not loot item from mail because your bags are full."])
				end
			end

			if InboxFrame.openMailID ~= data.index then
				InboxFrame.openMailID = data.index
				OpenMailFrame.updateButtonPositions = true
				OpenMail_Update()
				ShowUIPanel(OpenMailFrame)
				OpenMailFrameInset:SetPoint("TOPLEFT", 4, -80)
				PlaySound("igSpellBookOpen")
			else
				InboxFrame.openMailID = 0
				HideUIPanel(OpenMailFrame)
			end
			InboxFrame_Update()
		end,
		OnEnter = function(_, data, self)
		end,
		OnLeave = function()
		end,
	}

	local st = TSMAPI:CreateScrollingTable(stContainer, nil, handlers)
	st:SetData({})
	frame.st = st

	local btn = TSMAPI.GUI:CreateButton(frame, 18)
	btn:SetPoint("BOTTOMLEFT", 5, 30)
	btn:SetPoint("BOTTOMRIGHT", -5, 30)
	btn:SetHeight(20)
	btn:SetText(L["Open All Mail"])
	btn:SetScript("OnClick", function() private:StartAutoLooting("all") end)
	frame.allBtn = btn

	local label = TSMAPI.GUI:CreateLabel(frame, "normal")
	label:SetPoint("BOTTOMLEFT", 5, 5)
	label:SetHeight(20)
	label:SetJustifyH("LEFT")
	label:SetJustifyV("CENTER")
	label:SetText(L["AH Mail:"])

	local btnWidth = (frame:GetWidth() - label:GetWidth() - 25) / 4

	local btn = TSMAPI.GUI:CreateButton(frame, 18)
	btn:SetPoint("BOTTOMLEFT", label, "BOTTOMRIGHT", 5, 0)
	btn:SetWidth(btnWidth)
	btn:SetHeight(20)
	btn:SetText(L["Sales"])
	btn:SetScript("OnClick", function() private:StartAutoLooting("sales") end)
	frame.salesBtn = btn

	local btn = TSMAPI.GUI:CreateButton(frame, 18)
	btn:SetPoint("BOTTOMLEFT", frame.salesBtn, "BOTTOMRIGHT", 5, 0)
	btn:SetWidth(btnWidth)
	btn:SetHeight(20)
	btn:SetText(L["Buys"])
	btn:SetScript("OnClick", function() private:StartAutoLooting("buys") end)
	frame.buysBtn = btn

	local btn = TSMAPI.GUI:CreateButton(frame, 18)
	btn:SetPoint("BOTTOMLEFT", frame.buysBtn, "BOTTOMRIGHT", 5, 0)
	btn:SetWidth(btnWidth)
	btn:SetHeight(20)
	btn:SetText(L["Cancels"])
	btn:SetScript("OnClick", function() private:StartAutoLooting("cancels") end)
	frame.cancelsBtn = btn

	local btn = TSMAPI.GUI:CreateButton(frame, 18)
	btn:SetPoint("BOTTOMLEFT", frame.cancelsBtn, "BOTTOMRIGHT", 5, 0)
	btn:SetPoint("BOTTOMRIGHT", -5, 5)
	btn:SetHeight(20)
	btn:SetText(L["Expires"])
	btn:SetScript("OnClick", function() private:StartAutoLooting("expires") end)
	frame.expiresBtn = btn

	local btn = TSMAPI.GUI:CreateButton(frame, 16)
	btn:SetFrameStrata("HIGH")
	btn:SetPoint("CENTER")
	btn:SetHeight(30)
	btn:SetWidth(150)
	btn:SetText(L["Reload UI"])
	btn:SetScript("OnClick", ReloadUI)
	btn:Hide()
	frame.reloadBtn = btn

	frame.EnableButtons = function(self)
		self.allBtn:Enable()
		self.salesBtn:Enable()
		self.buysBtn:Enable()
		self.cancelsBtn:Enable()
		self.expiresBtn:Enable()
		self.buttonsEnabled = true
	end
	frame.DisableButtons = function(self)
		self.allBtn:Disable()
		self.salesBtn:Disable()
		self.buysBtn:Disable()
		self.cancelsBtn:Disable()
		self.expiresBtn:Disable()
		self.buttonsEnabled = nil
	end
	frame.buttonsEnabled = true

	private.frame = frame
	return frame
end


local function CacheFrameOnUpdate(self, elapsed)
	if not private.waitingForData then
		local seconds = self.endTime - GetTime()
		if seconds <= 0 then
			-- Look for new mail
			-- Sometimes it fails and isn't available at exactly 60-61 seconds, and more like 62-64, will keep rechecking every 1 second
			-- until data becomes available
			if TSM.db.global.autoCheck then
				private.waitingForData = true
				self.timeLeft = private.recheckTime
				private.lootIndex = 1
				private.resetIndex = nil
				CheckInbox()
				private.frame.reloadBtn:Hide()
			else
				self:Hide()
			end
			return
		end

		private:UpdateTopLabel()
	else
		self.timeLeft = self.timeLeft - elapsed
		if self.timeLeft <= 0 then
			self.timeLeft = private.recheckTime
			private.lootIndex = 1
			private.resetIndex = nil
			CheckInbox()
			private.frame.reloadBtn:Hide()
		end
	end
end

function Inbox:MAIL_SHOW()
	if not private.cacheFrame then
		-- Timer for mailbox cache updates
		private.cacheFrame = CreateFrame("Frame", nil, MailFrame)
		private.cacheFrame:Hide()
		private.cacheFrame:SetScript("OnUpdate", CacheFrameOnUpdate)
	end
end

local function FormatDaysLeft(daysLeft, index)
	-- code taken from Blizzard MailFrame.lua code
	if daysLeft >= 1 then
		if InboxItemCanDelete(index) then
			daysLeft = YELLOW_FONT_COLOR_CODE .. format(DAYS_ABBR, floor(daysLeft)) .. " " .. FONT_COLOR_CODE_CLOSE;
		else
			daysLeft = GREEN_FONT_COLOR_CODE .. format(DAYS_ABBR, floor(daysLeft)) .. " " .. FONT_COLOR_CODE_CLOSE;
		end
	else
		daysLeft = RED_FONT_COLOR_CODE .. SecondsToTime(floor(daysLeft * 24 * 60 * 60)) .. FONT_COLOR_CODE_CLOSE;
	end
	return daysLeft
end

function private:UpdateTopLabel()
	local parts = {}

	local numMail, totalMail = GetInboxNumItems()
	if totalMail == numMail then
		tinsert(parts, format(L["Showing all %d mail."], numMail))
	else
		tinsert(parts, format(L["Showing %d of %d mail."], numMail, totalMail))
	end

	local collectGold = private.collectGold or 0
	if collectGold > 0 then
		tinsert(parts, format(L["%s to collect."], TSMAPI:FormatTextMoney(collectGold)))
	end

	local nextRefresh = private.cacheFrame:IsVisible() and private.cacheFrame.endTime
	if nextRefresh then
		if numMail == 0 and TSM.db.global.showReloadBtn then
			private.frame.reloadBtn:Show()
		end
		tinsert(parts, format(L["Next inbox update in %d seconds."], max(ceil(nextRefresh - GetTime()), 0)))
	end

	private.frame.topLabel:SetText(table.concat(parts, " "))
end

function private:InboxUpdate()
	if not private.frame or not private.frame:IsVisible() then return end
	TSMAPI:CancelFrame("inboxLootTextDelay")

	local numMail, totalMail = GetInboxNumItems()

	local greenColor, redColor = "|cff00ff00", "|cffff0000"
	local mailInfo = {}
	local collectGold = 0
	for i = 1, numMail do
		mailInfo[i] = ""
		local isInvoice = select(4, GetInboxText(i))
		local _, _, sender, subject, money, cod, daysLeft, hasItem = GetInboxHeaderInfo(i)
		if isInvoice then
			local invoiceType, itemName, playerName, bid, _, _, ahcut, _, _, _, quantity = GetInboxInvoiceInfo(i)
			if invoiceType == "buyer" then
				local itemLink = GetInboxItemLink(i, 1) or itemName
				mailInfo[i] = format(L["Buy: %s (%d) | %s | %s"], itemLink, quantity, TSMAPI:FormatTextMoney(bid, redColor), FormatDaysLeft(daysLeft, i))
			elseif invoiceType == "seller" then
				collectGold = collectGold + bid - ahcut
				mailInfo[i] = format(L["Sale: %s (%d) | %s | %s"], itemName, quantity, TSMAPI:FormatTextMoney(bid - ahcut, greenColor), FormatDaysLeft(daysLeft, i))
			end
		elseif hasItem then
			local itemLink
			local quantity = 0
			for j = 1, hasItem do
				local link = GetInboxItemLink(i, j)
				itemLink = itemLink or link
				quantity = quantity + select(3, GetInboxItem(i, j))
				if TSMAPI:GetItemString(itemLink) ~= TSMAPI:GetItemString(link) then
					itemLink = L["Multiple Items"]
					quantity = -1
					break
				end
			end
			local itemDesc = (quantity > 0 and format("%s (%d)", itemLink, quantity)) or (quantity == -1 and L["Multiple Items"]) or "---"

			if hasItem == 1 and itemLink and strfind(subject, "^" .. TSMAPI:StrEscape(format(AUCTION_EXPIRED_MAIL_SUBJECT, TSMAPI:GetSafeItemInfo(itemLink)))) then
				mailInfo[i] = format(L["Expired: %s | %s"], itemDesc, FormatDaysLeft(daysLeft, i))
			elseif cod > 0 then
				mailInfo[i] = format(L["COD: %s | %s | %s | %s"], itemDesc, TSMAPI:FormatTextMoney(cod, redColor), sender or "---", FormatDaysLeft(daysLeft, i))
			elseif money > 0 then
				collectGold = collectGold + money
				mailInfo[i] = format("%s + %s | %s | %s", itemDesc, TSMAPI:FormatTextMoney(money, greenColor), sender or "---", FormatDaysLeft(daysLeft, i))
			else
				mailInfo[i] = format("%s | %s | %s", itemDesc, sender or "---", FormatDaysLeft(daysLeft, i))
			end
		elseif money > 0 then
			mailInfo[i] = format("%s | %s | %s | %s", subject, TSMAPI:FormatTextMoney(money, greenColor), sender or "---", FormatDaysLeft(daysLeft, i))
		else
			mailInfo[i] = format("%s | %s | %s", subject, sender or "---", FormatDaysLeft(daysLeft, i))
		end
	end
	private.collectGold = collectGold

	local stData = {}
	for i, info in ipairs(mailInfo) do
		tinsert(stData, { cols = { { value = info } }, index = i })
	end
	private.frame.st:SetData(stData)

	private:UpdateTopLabel()

	-- Yay nothing else to loot, so nothing else to update the cache for!
	if private.cacheFrame.endTime and numMail == totalMail and private.lastTotal ~= totalMail then
		private.cacheFrame.endTime = nil
		private.cacheFrame:Hide()
		-- Start a timer since we're over the limit of 50 items before waiting for it to recache
	elseif (private.cacheFrame.endTime and numMail >= 50 and private.lastTotal ~= totalMail) or (numMail >= 50 and private.allowTimerStart) then
		private.resetIndex = nil
		private.allowTimerStart = nil
		private.waitingForData = nil
		private.lastTotal = totalMail
		private.cacheFrame.endTime = GetTime() + 60
		private.cacheFrame:Show()
	end

	-- The last item we setup to auto loot is finished, time for the next one
	if not private.frame.buttonsEnabled then
		if private.autoLootTotal ~= numMail then
			private.autoLootTotal = GetInboxNumItems()

			-- If we're auto checking mail when new data is available, will wait and continue auto looting, otherwise we just stop now
			if numMail == 0 and (not TSM.db.global.autoCheck or totalMail == 0) then
				private:StopAutoLooting()
			else
				private:AutoLoot()
			end
		else
			TSMAPI:CreateTimeDelay("mailSkipDelay", 1, function()
				local money, _, _, hasItem, _, _, _, canReply = select(5, GetInboxHeaderInfo(private.lootIndex))
				if not hasItem and money == 0 then
					private.lootIndex = private.lootIndex + 1
					return private:AutoLoot()
				end
			end)
		end
	end
end

function private:ShouldOpenMail(index)
	local shouldOpen
	if private.mode == "all" then
		return true
	elseif private.mode == "sales" then
		local money = select(5, GetInboxHeaderInfo(index))
		if money > 0 and GetInboxInvoiceInfo(index) == "seller" then
			return true
		end
	elseif private.mode == "buys" then
		local hasItem = select(8, GetInboxHeaderInfo(index))
		if hasItem and GetInboxInvoiceInfo(index) == "buyer" then
			return true
		end
	elseif private.mode == "cancels" then
		local isInvoice = select(4, GetInboxText(index))
		local subject, _, _, _, hasItem = select(4, GetInboxHeaderInfo(index))
		if not isInvoice and hasItem == 1 then
			local itemLink = GetInboxItemLink(index, 1)
			if itemLink then
				local itemName = TSMAPI:GetSafeItemInfo(itemLink)
				local quantity = select(3, GetInboxItem(index, 1))
				if quantity and quantity > 0 and (subject == format(AUCTION_REMOVED_MAIL_SUBJECT.." (%d)", itemName, quantity) or subject == format(AUCTION_REMOVED_MAIL_SUBJECT, itemName)) then
					return true
				end
			end
		end
	elseif private.mode == "expires" then
		local isInvoice = select(4, GetInboxText(index))
		local subject, _, _, _, hasItem = select(4, GetInboxHeaderInfo(index))
		if not isInvoice and hasItem == 1 then
			local itemLink = GetInboxItemLink(index, 1)
			if itemLink and strfind(subject, "^" .. TSMAPI:StrEscape(format(AUCTION_EXPIRED_MAIL_SUBJECT, TSMAPI:GetSafeItemInfo(itemLink)))) then
				return true
			end
		end
	end
end



-- Deals with auto looting of mail!
function private:StartAutoLooting(mode)
	private.mode = mode
	local canCollectMail
	if private.mode == "all" then
		local total
		private.autoLootTotal, total = GetInboxNumItems()
		canCollectMail = not (private.autoLootTotal == 0 and total == 0)
	else
		for i = 1, GetInboxNumItems() do
			if private:ShouldOpenMail(i) then
				canCollectMail = true
				break
			end
		end
	end
	if not canCollectMail then
		private.mode = nil
		return
	end

	Inbox:RegisterEvent("UI_ERROR_MESSAGE")
	private.frame:DisableButtons()
	private.moneyCollected = 0
	private.mode = mode
	private.lootIndex = 1
	private:AutoLoot()
end

function private:AutoLoot()
	TSMAPI:CancelFrame("mailSkipDelay")

	-- Already looted everything after the invalid indexes we had, so fail it
	if private.lootIndex > 1 and private.lootIndex > GetInboxNumItems() then
		if private.resetIndex then
			private:StopAutoLooting()
		else
			private.resetIndex = true
			private.lootIndex = 1
			private:AutoLoot()
		end
		return
	end

	local money, cod, _, items, _, _, _, _, isGM = select(5, GetInboxHeaderInfo(private.lootIndex))
	if not isGM and (not cod or cod <= 0) and ((money and money > 0) or (items and items > 0)) then
		TSMAPI:CancelFrame("mailWaitDelay")
		if private.mode == "all" then
			if money > 0 then
				if TSM.db.global.openAllLeaveGold then
					private.lootIndex = private.lootIndex + 1
					return private:AutoLoot()
				end
			end
			if private:CanLootMailIndex(private.lootIndex) then
				if money > 0 then
					private.moneyCollected = private.moneyCollected + money
				end
				private:LootMailItem(private.lootIndex)
			else
				private.lootIndex = private.lootIndex + 1
				return private:AutoLoot()
			end
		else
			if private:CanLootMailIndex(private.lootIndex) and private:ShouldOpenMail(private.lootIndex) then
				if money > 0 then
					private.moneyCollected = private.moneyCollected + money
				end
				private:LootMailItem(private.lootIndex)
			else
				private.lootIndex = private.lootIndex + 1
				return private:AutoLoot()
			end
		end
		-- Can't grab the first mail, so increase it and try again
	elseif GetInboxNumItems() >= private.lootIndex then
		private.lootIndex = private.lootIndex + 1
		private:AutoLoot()
	end
end

function private:LootMailItem(index)
	if TSM.db.global.inboxMessages then
		local _, _, sender, subject, money, cod, _, hasItem = GetInboxHeaderInfo(index)
		sender = sender or "?"
		if select(4, GetInboxText(index)) then
			-- it's an invoice
			local invoiceType, itemName, playerName, bid, _, _, ahcut, _, _, _, quantity = GetInboxInvoiceInfo(index)
			if invoiceType == "buyer" then
				local itemLink = GetInboxItemLink(index, 1) or itemName
				TSM:Printf(L["Collected purchase of %s (%d) for %s."], itemLink, quantity, TSMAPI:FormatTextMoney(bid, redColor))
			elseif invoiceType == "seller" then
				TSM:Printf(L["Collected sale of %s (%d) for %s."], itemName, quantity, TSMAPI:FormatTextMoney(bid - ahcut, greenColor))
			end
		elseif hasItem then
			local itemLink
			local quantity = 0
			for i = 1, hasItem do
				local link = GetInboxItemLink(index, i)
				itemLink = itemLink or link
				quantity = quantity + select(3, GetInboxItem(index, i))
				if TSMAPI:GetItemString(itemLink) ~= TSMAPI:GetItemString(link) then
					itemLink = L["Multiple Items"]
					quantity = -1
					break
				end
			end
			local itemDesc = (quantity > 0 and format("%s (%d)", itemLink, quantity)) or (quantity == -1 and "Multiple Items") or "?"
			if hasItem == 1 and itemLink and strfind(subject, "^" .. TSMAPI:StrEscape(format(AUCTION_EXPIRED_MAIL_SUBJECT, TSMAPI:GetSafeItemInfo(itemLink)))) then
				TSM:Printf(L["Collected expired auction of %s"], itemDesc)
			elseif cod > 0 then
				TSM:Printf(L["Collected COD of %s from %s for %s."], itemDesc, sender, TSMAPI:FormatTextMoney(cod, redColor))
			elseif money > 0 then
				TSM:Printf(L["Collected %s and %s from %s."], itemDesc, TSMAPI:FormatTextMoney(money, greenColor), sender)
			else
				TSM:Printf(L["Collected %s from %s."], itemDesc, sender)
			end
		elseif money > 0 then
			TSM:Printf(L["Collected %s from %s."], TSMAPI:FormatTextMoney(money, greenColor), sender)
		else
			TSM:Printf(L["Collected mail from %s with a subject of '%s'."], sender, subject)
		end
	end
	AutoLootMailItem(index)
end

function private:CanLootMailIndex(index)
	local hasItem = select(8, GetInboxHeaderInfo(index))
	if not hasItem or hasItem == 0 then return true end

	if not TSM.db.global.keepMailSpace or TSM.db.global.keepMailSpace == 0 then
		for j = 1, ATTACHMENTS_MAX_RECEIVE do
			local itemString = TSMAPI:GetItemString(GetInboxItemLink(index, j))
			local quantity = select(3, GetInboxItem(index, j))
			local space = 0
			if itemString then
				for bag = 0, NUM_BAG_SLOTS do
					if TSMAPI:ItemWillGoInBag(itemString, bag) then
						for slot = 1, GetContainerNumSlots(bag) do
							local iString = TSMAPI:GetItemString(GetContainerItemLink(bag, slot))
							if iString == itemString then
								local stackSize = select(2, GetContainerItemInfo(bag, slot))
								local maxStackSize = select(8, TSMAPI:GetSafeItemInfo(itemString))
								if (maxStackSize - stackSize) >= quantity then
									return true
								end
							elseif not iString then
								return true
							end
						end
					end
				end
			end
		end
	else
		-- get number of free slots per generic / special bags and partial slots by bag
		local genericSpace, uniqueSpace, partSlots = private:GetBagSlots()
		local usedSlots = {}
		for j = 1, ATTACHMENTS_MAX_RECEIVE do
			local itemString = TSMAPI:GetItemString(GetInboxItemLink(index, j))
			local quantity = select(3, GetInboxItem(index, j))
			local isDone = false
			if itemString then
				for bag = 0, NUM_BAG_SLOTS do
					if TSMAPI:ItemWillGoInBag(itemString, bag) then
						for slot = 1, GetContainerNumSlots(bag) do
							local iString = TSMAPI:GetItemString(GetContainerItemLink(bag, slot))
							if iString == itemString and (partSlots[bag] and partSlots[bag][slot]) then
								local stackSize = select(2, GetContainerItemInfo(bag, slot))
								local maxStackSize = select(8, TSMAPI:GetSafeItemInfo(itemString))
								if (maxStackSize - stackSize - (usedSlots[bag] and usedSlots[bag][slot] or 0)) >= quantity then
									if stackSize + quantity == maxStackSize then
										if partSlots[bag] and partSlots[bag][slot] then
											partSlots[bag][slot] = nil -- this partial slot would be filled so remove it from available part slots
										end
									else
										if not usedSlots[bag] then
											usedSlots[bag] = {}
										end
										usedSlots[bag][slot] = (usedSlots[bag][slot] or 0) + stackSize -- store the stacksize for this slot after adding this item
									end
									isDone = true
									break
								end
							else
								local itemFamily = GetItemFamily(itemString)
								local bagFamily = GetItemFamily(GetBagName(bag)) or 0
								if itemFamily and bagFamily and bagFamily > 0 and bit.band(itemFamily, bagFamily) > 0 and (uniqueSpace[bag] and uniqueSpace[bag] > 0) then
									uniqueSpace[bag] = uniqueSpace[bag] - 1 -- remove one empty slot from the bag
									isDone = true
									break
								else
									if genericSpace[bag] and genericSpace[bag] > 0 then
										genericSpace[bag] = genericSpace[bag] - 1 -- remove one empty slot from the bag
										if genericSpace[bag] <= 0 then
											genericSpace[bag] = nil
										end
										isDone = true
										break
									end
								end
							end
						end
						if isDone then break end
					end
				end
			end
		end

		--calculate the total remaining empty slots in generic bags after looting this mail
		local remainingSpace = 0
		for bag, space in pairs(genericSpace) do
			remainingSpace = remainingSpace + space
		end
		if remainingSpace >= TSM.db.global.keepMailSpace then
			return true -- either not using keepMailSpace option or we can loot all of this mail
		else
			private.keepFreeSlots = true -- can't loot the whole of this mail and leave enough free slots so set the flag that displays the chat message
		end
	end
end

function private:StopAutoLooting(failed)
	if failed and (not private.frame or not private.frame:IsVisible()) then
		TSM:Print(L["Cannot finish auto looting, inventory is full or too many unique items."])
	end

	if private.keepFreeSlots then
		TSM:Printf(L["Cannot finish auto looting, keeping %s slots free."], TSM.db.global.keepMailSpace)
		private.keepFreeSlots = false
	end

	private.mode = nil
	private.resetIndex = nil
	private.autoLootTotal = nil
	if not private.frame then return end
	private.frame:EnableButtons()

	--Tell user how much money has been collected if they don't have it turned off in TradeSkillMaster_Mailing options
	if private.moneyCollected and private.moneyCollected > 0 and TSM.db.global.displayMoneyCollected then
		TSM:Printf(L["%s total gold collected!"], TSMAPI:FormatTextMoney(private.moneyCollected))
		private.moneyCollected = 0
	end
end

function private:GetBagSlots()
	local genericSpace, uniqueSpace, partSlots = {}, {}, {}
	for bag = 0, NUM_BAG_SLOTS do
		if (GetItemFamily(GetBagName(bag)) or 0) > 0 then
			uniqueSpace[bag] = GetContainerNumFreeSlots(bag) or 0
		else
			genericSpace[bag] = GetContainerNumFreeSlots(bag) or 0
		end
		for slot = 1, GetContainerNumSlots(bag) do
			local iLink = GetContainerItemLink(bag, slot)
			if iLink then
				if not partSlots[bag] then
					partSlots[bag] = {}
				end
				table.insert(partSlots[bag], slot)
			end
		end
	end
	return genericSpace, uniqueSpace, partSlots
end

function Inbox:UI_ERROR_MESSAGE(event, msg)
	if msg == ERR_MAIL_DATABASE_ERROR then
		-- recover from internal mail error
		TSMAPI:CreateTimeDelay("mailWaitDelay", 1, private.AutoLoot)
	elseif msg == ERR_INV_FULL or msg == ERR_ITEM_MAX_COUNT then
		-- Try the next index in case we can still loot more such as in the case of glyphs
		private.lootIndex = private.lootIndex + 1

		-- If we've exhausted all slots, but we still have <50 and more mail pending, wait until new data comes and keep looting it
		local current, total = GetInboxNumItems()
		if private.lootIndex > current then
			if private.lootIndex > total and total <= 50 then
				private:StopAutoLooting(true)
			end
			return
		end

		TSMAPI:CreateTimeDelay("mailWaitDelay", 0.3, private.AutoLoot)
	end
end

function Inbox:MAIL_CLOSED()
	private.resetIndex = nil
	private.allowTimerStart = true
	private.waitingForData = nil
	private:StopAutoLooting()
	TSMAPI:CancelFrame("inboxLootTextDelay")
	TSMAPI:CancelFrame("mailSkipDelay")
end
