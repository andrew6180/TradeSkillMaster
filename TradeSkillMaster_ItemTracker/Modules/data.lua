-- ------------------------------------------------------------------------------ --
--                          TradeSkillMaster_ItemTracker                          --
--          http://www.curse.com/addons/wow/tradeskillmaster_itemtracker          --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- load the parent file (TSM) into a local variable and register this file as a module
local TSM = select(2, ...)
local Data = TSM:NewModule("Data", "AceEvent-3.0", "AceHook-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster_ItemTracker")

TSM.CURRENT_PLAYER, TSM.CURRENT_GUILD = UnitName("player"), GetGuildInfo("player")
local BUCKET_TIME = 0.2 -- wait at least this amount of time between throttled events firing
local throttleFrames = {}
local isScanning = false

function Data:Initialize()
	Data:RegisterEvent("GUILDBANKFRAME_OPENED", "EventHandler")
	Data:RegisterEvent("GUILDBANKBAGSLOTS_CHANGED", "EventHandler")
	Data:RegisterEvent("AUCTION_OWNED_LIST_UPDATE", "EventHandler")
	TSMAPI:RegisterForBagChange(function(...) Data:GetBagData(...) end)
	TSMAPI:RegisterForBankChange(function(...) Data:GetBankData(...) end)

	TSM.CURRENT_PLAYER, TSM.CURRENT_GUILD = UnitName("player"), GetGuildInfo("player")
	Data:StoreCurrentGuildInfo()
end

local guildThrottle = CreateFrame("frame")
guildThrottle:Hide()
guildThrottle.attemptsLeft = 20
guildThrottle:SetScript("OnUpdate", function(self, elapsed)
	self.timeLeft = self.timeLeft - elapsed
	if self.timeLeft <= 0 then
		self.attemptsLeft = self.attemptsLeft - 1
		Data:StoreCurrentGuildInfo(self.attemptsLeft == 0)
	end
end)

function Data:StoreCurrentGuildInfo(noDelay)
	TSM.CURRENT_GUILD = GetGuildInfo("player")
	if TSM.CURRENT_GUILD then
		TSM.guilds[TSM.CURRENT_GUILD] = TSM.guilds[TSM.CURRENT_GUILD] or { items = {} }
		TSM.guilds[TSM.CURRENT_GUILD].items = TSM.guilds[TSM.CURRENT_GUILD].items or {}
		guildThrottle:Hide()
	elseif not noDelay then
		guildThrottle.timeLeft = 0.5
		guildThrottle:Show()
	else
		guildThrottle:Hide()
	end
	TSM.characters[TSM.CURRENT_PLAYER].guild = TSM.CURRENT_GUILD
	TSM.characters[TSM.CURRENT_PLAYER].lastUpdate.guild = time()
	TSM.Sync:BroadcastUpdateRequest()
end

function Data:ThrottleEvent(event)
	if not throttleFrames[event] then
		local frame = CreateFrame("Frame")
		frame.baseTime = BUCKET_TIME
		frame.event = event
		frame:Hide()
		frame:SetScript("OnShow", function(self) Data:UnregisterEvent(self.event) self.timeLeft = self.baseTime end)
		frame:SetScript("OnUpdate", function(self, elapsed)
			self.timeLeft = self.timeLeft - elapsed
			if self.timeLeft <= 0 then
				Data:EventHandler(self.event, "FIRE")
				self:Hide()
				Data:RegisterEvent(self.event, "EventHandler")
			end
		end)
		throttleFrames[event] = frame
	end

	-- resets the delay time on the frame
	throttleFrames[event]:Hide()
	throttleFrames[event]:Show()
end

function Data:EventHandler(event, fire)
	if isScanning then return end
	if fire ~= "FIRE" then
		Data:ThrottleEvent(event)
	else
		if event == "GUILDBANKFRAME_OPENED" then
			-- Query all tabs of the gbank to ensure all tabs will be scanned.
			local initialTab = GetCurrentGuildBankTab()
			for tab = 1, GetNumGuildBankTabs() do
				if select(5, GetGuildBankTabInfo(tab)) > 0 or IsGuildLeader(UnitName("player")) then
					QueryGuildBankTab(tab)
				end
			end
			QueryGuildBankTab(initialTab)
		elseif event == "GUILDBANKBAGSLOTS_CHANGED" then
			Data:GetGuildBankData()
		elseif event == "AUCTION_OWNED_LIST_UPDATE" then
			Data:ScanPlayerAuctions()
		end
	end
end

-- scan the player's bags
function Data:GetBagData(state)
	wipe(TSM.characters[TSM.CURRENT_PLAYER].bags)
	for itemString, quantity in pairs(state) do
		local baseItemString = TSMAPI:GetBaseItemString(itemString)
		TSM.characters[TSM.CURRENT_PLAYER].bags[itemString] = quantity
		if itemString ~= baseItemString then
			TSM.characters[TSM.CURRENT_PLAYER].bags[baseItemString] = (TSM.characters[TSM.CURRENT_PLAYER].bags[baseItemString] or 0) + quantity
		end
	end
	TSM.characters[TSM.CURRENT_PLAYER].lastUpdate.bags = time()
	TSM.Sync:BroadcastUpdateRequest()
end

-- scan the player's bank
function Data:GetBankData(state)
	wipe(TSM.characters[TSM.CURRENT_PLAYER].bank)
	for itemString, quantity in pairs(state) do
		local baseItemString = TSMAPI:GetBaseItemString(itemString)
		TSM.characters[TSM.CURRENT_PLAYER].bank[itemString] = quantity
		if itemString ~= baseItemString then
			TSM.characters[TSM.CURRENT_PLAYER].bank[baseItemString] = (TSM.characters[TSM.CURRENT_PLAYER].bank[baseItemString] or 0) + quantity
		end
	end
	TSM.characters[TSM.CURRENT_PLAYER].lastUpdate.bank = time()
	TSM.Sync:BroadcastUpdateRequest()
end

-- scan the guild bank
function Data:GetGuildBankData()
	if not TSM.CURRENT_GUILD then
		Data:StoreCurrentGuildInfo(true)
		if not TSM.CURRENT_GUILD then return end
	end
	wipe(TSM.guilds[TSM.CURRENT_GUILD].items)

	for tab = 1, GetNumGuildBankTabs() do
		if select(5, GetGuildBankTabInfo(tab)) > 0 or IsGuildLeader(UnitName("player")) then
			for slot = 1, MAX_GUILDBANK_SLOTS_PER_TAB or 98 do
				local itemString = TSMAPI:GetItemString(GetGuildBankItemLink(tab, slot))
				local baseItemString = TSMAPI:GetBaseItemString(GetGuildBankItemLink(tab, slot))
				if itemString then
					local quantity = select(2, GetGuildBankItemInfo(tab, slot))
					TSM.guilds[TSM.CURRENT_GUILD].items[itemString] = (TSM.guilds[TSM.CURRENT_GUILD].items[itemString] or 0) + quantity
					if itemString ~= baseItemString then
						TSM.guilds[TSM.CURRENT_GUILD].items[baseItemString] = (TSM.guilds[TSM.CURRENT_GUILD].items[baseItemString] or 0) + quantity
					end
				end
			end
		end
	end
	if GuildBankFrame and GuildBankFrame:IsVisible() then
		TSM.guilds[TSM.CURRENT_GUILD].lastUpdate = time()
	end
	TSM.Sync:BroadcastUpdateRequest()
end

function Data:ScanPlayerAuctions()
	wipe(TSM.characters[TSM.CURRENT_PLAYER].auctions)
	TSM.characters[TSM.CURRENT_PLAYER].auctions.time = time()

	for i = 1, GetNumAuctionItems("owner") do
		local link = GetAuctionItemLink("owner", i)
		local itemString = TSMAPI:GetItemString(link)
		local baseItemString = TSMAPI:GetBaseItemString(link)
		local name, _, quantity, _, _, _, _, _, _, buyout, _, _, _, wasSold, _, wasSold_54 = GetAuctionItemInfo("owner", i)
		if select(4, GetBuildInfo()) == 50400 then wasSold = wasSold_54 end
		if wasSold == 0 and itemString then
			TSM.characters[TSM.CURRENT_PLAYER].auctions[itemString] = (TSM.characters[TSM.CURRENT_PLAYER].auctions[itemString] or 0) + quantity
			if itemString ~= baseItemString then
				TSM.characters[TSM.CURRENT_PLAYER].auctions[baseItemString] = (TSM.characters[TSM.CURRENT_PLAYER].auctions[baseItemString] or 0) + quantity
			end
		end
	end
	TSM.characters[TSM.CURRENT_PLAYER].lastUpdate.auctions = time()
	TSM.Sync:BroadcastUpdateRequest()
end


-- ***************************************************************************
-- MAIL TRACKING FUNCTIONS
-- ***************************************************************************

local playersToUpdate = {}
local function UpdateMailQuantitiesThread(self)
	-- this runs in the background forever, updating mail quantities as necessary
	while true do
		if #playersToUpdate > 0 then
			local player = tremove(playersToUpdate)
			if TSM.characters[player] then
				local playerMail = TSM.characters[player].mail
				wipe(playerMail)
				for _, data in ipairs(TSM.characters[player].mailInbox) do
					for _, itemData in ipairs(data.items) do
						local itemString = TSMAPI:GetItemString(itemData.link)
						local baseItemString = TSMAPI:GetBaseItemString(itemData.link)
						playerMail[itemString] = (playerMail[itemString] or 0) + itemData.count
						if itemString ~= baseItemString then
							playerMail[baseItemString] = (playerMail[baseItemString] or 0) + itemData.count
						end
					end
					self:Yield()
				end
				TSM.characters[player].lastUpdate.mail = time()
				TSM.Sync:BroadcastUpdateRequest()
			end
		else
			self:Sleep(1)
		end
	end
end

do
	local function InsertInboxMail(player, index, data)
		local playerMail = TSM.characters[player].mail
		for _, itemData in ipairs(data.items) do
			local itemString = TSMAPI:GetItemString(itemData.link)
			local baseItemString = TSMAPI:GetBaseItemString(itemData.link)
			playerMail[itemString] = (playerMail[itemString] or 0) + itemData.count
			if itemString ~= baseItemString then
				playerMail[baseItemString] = (playerMail[baseItemString] or 0) + itemData.count
			end
		end
		tinsert(TSM.characters[player].mailInbox, index, data)
	end
	
	local function RemoveInboxMail(player, index)
		local playerMail = TSM.characters[player].mail
		for _, itemData in ipairs(TSM.characters[player].mailInbox[index].items) do
			local itemString = TSMAPI:GetItemString(itemData.link)
			local baseItemString = TSMAPI:GetBaseItemString(itemData.link)
			if playerMail[itemString] then
				playerMail[itemString] = max(playerMail[itemString] - itemData.count, 0)
				if playerMail[itemString] == 0 then
					playerMail[itemString] = nil
				end
			end
			if itemString ~= baseItemString and playerMail[baseItemString] then
				playerMail[baseItemString] = max(playerMail[baseItemString] - itemData.count, 0)
				if playerMail[baseItemString] == 0 then
					playerMail[baseItemString] = nil
				end
			end
		end
		tremove(TSM.characters[player].mailInbox, index)
	end
	
	local function RemoveInboxMailItem(player, index, itemIndex)
		local playerMail = TSM.characters[player].mail
		local itemData = TSM.characters[player].mailInbox[index].items[itemIndex]
		local itemString = TSMAPI:GetItemString(itemData.link)
		local baseItemString = TSMAPI:GetBaseItemString(itemData.link)
		if playerMail[itemString] then
			playerMail[itemString] = max(playerMail[itemString] - itemData.count, 0)
			if playerMail[itemString] == 0 then
				playerMail[itemString] = nil
			end
		end
		if itemString ~= baseItemString and playerMail[baseItemString] then
			playerMail[baseItemString] = max(playerMail[baseItemString] - itemData.count, 0)
			if playerMail[baseItemString] == 0 then
				playerMail[baseItemString] = nil
			end
		end
		tremove(TSM.characters[player].mailInbox[index].items, itemIndex)
	end

	local function AddIncomingMail(player, ...)
		if not TSM.characters[player] then return end
		TSM.characters[player].mailInbox = TSM.characters[player].mailInbox or {}
		local items
		if select('#', ...) == 1 then
			items = ...
		else
			local link, count = ...
			items = {{link=link, count=count}}
		end
		if not items then error() end
		InsertInboxMail(player, 1, {items=items, index=nil})
	end
	
	local function RemoveMailItem(index, itemIndex)
		local link = GetInboxItemLink(index, itemIndex)
		if not link then return end
		local count = select(3, GetInboxItem(index, itemIndex))
		for i, data in ipairs(TSM.characters[TSM.CURRENT_PLAYER].mailInbox) do
			if data.index == index then
				for j, itemData in ipairs(data.items) do
					if itemData.link == link and itemData.count == count then
						RemoveInboxMailItem(TSM.CURRENT_PLAYER, i, j)
						break
					end
				end
				if #data.items == 0 then
					RemoveInboxMail(TSM.CURRENT_PLAYER, i)
				end
				break
			end
		end
	end
	
	
	local tmpBuyouts = {}
	local function OnAuctionBid(listType, index, bidPlaced)
		local link = GetAuctionItemLink(listType, index)
		local name, _, count, _, _, _, _, _, _, buyout = GetAuctionItemInfo(listType, index)
		if bidPlaced == buyout then
			tinsert(tmpBuyouts, { name = name, link = link, count = count })
		end
	end
	local function OnChatMsg(_, msg)
		if msg:match(gsub(ERR_AUCTION_WON_S, "%%s", "")) then
			while #tmpBuyouts > 0 do
				local info = tremove(tmpBuyouts, 1)
				if msg == format(ERR_AUCTION_WON_S, info.name) then
					AddIncomingMail(TSM.CURRENT_PLAYER, info.link, info.count)
					tinsert(playersToUpdate, TSM.CURRENT_PLAYER)
					break
				end
			end
		end
	end
	
	local function OnAuctionCanceled(index)
		local link = GetAuctionItemLink("owner", index)
		local count = select(3, GetAuctionItemInfo("owner", index))
		AddIncomingMail(TSM.CURRENT_PLAYER, link, count)
		tinsert(playersToUpdate, TSM.CURRENT_PLAYER)
	end

	local function OnSendMail(target)
		local altName
		for name in pairs(TSM.characters) do
			if strlower(name) == strlower(target) then
				altName = name
				break
			end
		end
		if not altName then return end
		local items = {}
		for i = 1, ATTACHMENTS_MAX_SEND do
			local link = GetSendMailItemLink(i)
			if link then
				local count = select(3, GetSendMailItem(i))
				tinsert(items, {link=link, count=count})
			end
		end
		AddIncomingMail(altName, items)
		tinsert(playersToUpdate, altName)
	end
	
	local function OnTakeInboxItem(index, itemIndex)
		for i = (itemIndex or 1), (itemIndex or ATTACHMENTS_MAX_RECEIVE) do
			local link = GetInboxItemLink(index, i)
			if link then
				RemoveMailItem(index, i)
			end
		end
	end
	
	local function OnReturnMail(index)
		local sender = select(3, GetInboxHeaderInfo(index))
		local items = {}
		for itemIndex = 1, ATTACHMENTS_MAX_RECEIVE do
			local link = GetInboxItemLink(index, itemIndex)
			if link then
				local count = select(3, GetInboxItem(index, itemIndex))
				tinsert(items, {link=link, count=count})
				RemoveMailItem(index, itemIndex)
			end
		end
		AddIncomingMail(sender, items)
		tinsert(playersToUpdate, sender)
		tinsert(playersToUpdate, TSM.CURRENT_PLAYER)
	end

	local function OnInboxUpdate()
		local player = TSM.characters[TSM.CURRENT_PLAYER]
		player.mailInbox = player.mailInbox or {}
		local numItems, totalItems = GetInboxNumItems()
		if numItems == totalItems then
			wipe(player.mailInbox)
		end
		
		local index = 1
		for i=1, numItems do
			local items = {}
			if select(8, GetInboxHeaderInfo(i)) then
				for j=1, ATTACHMENTS_MAX_RECEIVE do
					local link = GetInboxItemLink(i, j)
					if link then
						tinsert(items, {link=link, count=select(3, GetInboxItem(i, j))})
					end
				end
				local matchIndex
				for k=index, #player.mailInbox do
					if #player.mailInbox[k].items == #items then
						local temp = {}
						for _, data in ipairs(player.mailInbox[k].items) do
							temp[data.link] = (temp[data.link] or 0) + data.count
						end
						for _, data in ipairs(items) do
							if not temp[data.link] then break end
							temp[data.link] = temp[data.link] - data.count
							if temp[data.link] == 0 then temp[data.link] = nil end
						end
						
						if not next(temp) then
							matchIndex = k
							break
						end
					end
				end
				if matchIndex then
					if index == matchIndex then
						player.mailInbox[matchIndex].index = i
						index = index + 1
					elseif matchIndex > index then
						for k=1, matchIndex-index do
							RemoveInboxMail(TSM.CURRENT_PLAYER, index)
						end
					end
				else
					InsertInboxMail(TSM.CURRENT_PLAYER, index, {items=items, index=i})
					index = index + 1
				end
			end
		end
		tinsert(playersToUpdate, TSM.CURRENT_PLAYER)
	end

	Data:RegisterEvent("CHAT_MSG_SYSTEM", OnChatMsg)
	TSMAPI:CreateEventBucket("MAIL_INBOX_UPDATE", OnInboxUpdate, 0)
	Data:Hook("PlaceAuctionBid", OnAuctionBid, true)
	Data:Hook("CancelAuction", OnAuctionCanceled, true)
	Data:Hook("TakeInboxItem", OnTakeInboxItem, true)
	Data:Hook("AutoLootMailItem", OnTakeInboxItem, true)
	Data:Hook("SendMail", OnSendMail, true)
	Data:Hook("ReturnInboxItem", OnReturnMail, true)
	TSMAPI.Threading:Start(UpdateMailQuantitiesThread, 0.1)
end