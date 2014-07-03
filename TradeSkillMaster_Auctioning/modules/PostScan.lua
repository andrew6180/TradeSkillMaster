-- ------------------------------------------------------------------------------ --
--                           TradeSkillMaster_Auctioning                          --
--           http://www.curse.com/addons/wow/tradeskillmaster_auctioning          --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

local TSM = select(2, ...)
local Post = TSM:NewModule("Post", "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster_Auctioning") -- loads the localization table

local bagInfo, bagState = {}, {}
local bagInfoUpdate = 0
local postQueue, currentItem, itemLocations = {}, {}, {}
local totalToPost, totalPosted, count = 0, 0
local isScanning, GUI

function Post:ValidateOperation(itemString, operation)
	local itemLink, salePrice = TSMAPI:Select({2, 11}, TSMAPI:GetSafeItemInfo(itemString))
	local prices = TSM.Util:GetItemPrices(operation, itemString)

	-- don't post this item if their settings are invalid
	if operation.postCap == 0 then
		return -- posting is disabled
	elseif not prices.minPrice then
		if not TSM.db.global.disableInvalidMsg then
			TSM:Printf(L["Did not post %s because your minimum price (%s) is invalid. Check your settings."], itemLink or itemString, operation.minPrice)
		end
		TSM.Log:AddLogRecord(itemString, "post", "Skip", "invalid", operation)
	elseif not prices.maxPrice then
		if not TSM.db.global.disableInvalidMsg then
			TSM:Printf(L["Did not post %s because your maximum price (%s) is invalid. Check your settings."], itemLink or itemString, operation.maxPrice)
		end
		TSM.Log:AddLogRecord(itemString, "post", "Skip", "invalid", operation)
	elseif not prices.normalPrice then
		if not TSM.db.global.disableInvalidMsg then
			TSM:Printf(L["Did not post %s because your normal price (%s) is invalid. Check your settings."], itemLink or itemString, operation.normalPrice)
		end
		TSM.Log:AddLogRecord(itemString, "post", "Skip", "invalid", operation)
	elseif not prices.undercut then
		if not TSM.db.global.disableInvalidMsg then
			TSM:Printf(L["Did not post %s because your undercut (%s) is invalid. Check your settings."], itemLink or itemString, operation.undercut)
		end
		TSM.Log:AddLogRecord(itemString, "post", "Skip", "invalid")
	elseif prices.normalPrice < prices.minPrice then
		if not TSM.db.global.disableInvalidMsg then
			TSM:Printf(L["Did not post %s because your normal price (%s) is lower than your minimum price (%s). Check your settings."], itemLink or itemString, operation.normalPrice, operation.minPrice)
		end
		TSM.Log:AddLogRecord(itemString, "post", "Skip", "invalid", operation)
	elseif prices.maxPrice < prices.minPrice then
		if not TSM.db.global.disableInvalidMsg then
			TSM:Printf(L["Did not post %s because your maximum price (%s) is lower than your minimum price (%s). Check your settings."], itemLink or itemString, operation.maxPrice, operation.minPrice)
		end
		TSM.Log:AddLogRecord(itemString, "post", "Skip", "invalid", operation)
	elseif salePrice > 0 and prices.minPrice <= salePrice*1.05 then
		TSM:Printf(L["WARNING: You minimum price for %s is below its vendorsell price (with AH cut taken into account). Consider raising your minimum price, or vendoring the item."], itemLink or itemString)
		return true -- just a warning, doesn't make this invalid
	else
		return true
	end
end

function Post:UpdateBagState()
	if time() == bagInfoUpdate then return end
	wipe(bagInfo)
	wipe(bagState)
	for bag, slot, itemString, quantity in TSMAPI:GetBagIterator(true) do
		tinsert(bagInfo, {bag, slot, itemString, quantity})
		bagState[itemString] = (bagState[itemString] or 0) + quantity
	end
	bagInfoUpdate = time()
end

function Post:GetScanListAndSetup(GUIRef, options)
	-- setup stuff
	GUI = GUIRef
	isScanning = true
	wipe(postQueue)
	wipe(currentItem)
	wipe(itemLocations)
	wipe(TSM.operationLookup)
	totalToPost, totalPosted, count = 0, 0, 0

	local tempList, scanList = {}, {}
	
	Post:UpdateBagState()
	
	local function HasEnoughToPost(operation, itemString)
		local maxStackSize = select(8, TSMAPI:GetSafeItemInfo(itemString)) or 1
		local perAuction = min(maxStackSize, operation.stackSize)
		local perAuctionIsCap = operation.stackSizeIsCap
		local num = (bagState[itemString] or 0) - operation.keepQuantity
		return num >= perAuction or (perAuctionIsCap and num > 0)
	end

	for itemString in pairs(bagState) do
		local operations = options.itemOperations[itemString]
		if not tempList[itemString] and operations then
			for _, operation in ipairs(operations) do
				if operation.postCap > 0 and HasEnoughToPost(operation, itemString) then
					tempList[itemString] = tempList[itemString] or {}
					tinsert(tempList[itemString], operation)
				end
			end
		end
	end

	for itemString, operations in pairs(tempList) do
		TSM.operationLookup[itemString] = operations
		local isValid = true
		for _, operation in ipairs(operations) do
			if not Post:ValidateOperation(itemString, operation) then
				isValid = nil
				break
			end
		end
		if #options.itemOperations[itemString] ~= #operations then
			local j = 1
			for i=1, #options.itemOperations[itemString] do
				if options.itemOperations[itemString][i] ~= operations[j] then
					TSM.Log:AddLogRecord(itemString, "post", "Skip", "notEnough", options.itemOperations[itemString][i])
				else
					j = j + 1
				end
			end
		end
		if isValid then
			tinsert(scanList, itemString)
		end
	end
	
	TSMAPI:FireEvent("AUCTIONING:POST:START", {numItems=#scanList, isGroup=true})
	return scanList
end

function Post:ProcessItem(itemString)
	local operations = TSM.operationLookup[itemString]
	if not operations then return end

	local numInBags = Post:GetNumInBags(itemString)
	for _, operation in ipairs(operations) do
		local toPost, reason, buyout
		numInBags = numInBags - operation.keepQuantity
		toPost, reason, numInBags = Post:ShouldPost(itemString, operation, numInBags)
		numInBags = numInBags + operation.keepQuantity -- restore for the next operation if there are multiple
		local data = {}

		if toPost then
			local bid
			bid, buyout, reason = Post:GetPostPrice(itemString, operation)
			local postTime = (operation.duration == 48 and 3) or (operation.duration == 24 and 2) or 1

			for i = 1, #toPost do
				local stackSize, numStacks = unpack(toPost[i])

				-- Increase the bid/buyout based on how many items we're posting
				local stackBid, stackBuyout = floor(bid * stackSize), floor(buyout * stackSize)
				Post:QueueItemToPost(itemString, numStacks, stackSize, stackBid, stackBuyout, postTime, operation)
				tinsert(data, { numStacks = numStacks, stackSize = stackSize, buyout = buyout, postTime = postTime })
			end
		end

		TSM.Log:AddLogRecord(itemString, "post", (toPost and L["Post"] or L["Skip"]), reason, operation, buyout)
		if #postQueue > 0 and not currentItem.bag then
			Post:SetupForAction()
		end

		if numInBags < 0 then error("less than 0") end
		if numInBags == 0 then break end
	end
end

function Post:ShouldPost(itemString, operation, numInBags)
	local maxStackSize = select(8, TSMAPI:GetSafeItemInfo(itemString))
	local perAuction = min(maxStackSize, operation.stackSize)
	local maxCanPost = floor(numInBags / perAuction)
	local perAuctionIsCap = operation.stackSizeIsCap

	if maxCanPost == 0 then
		if perAuctionIsCap then
			perAuction = numInBags
			maxCanPost = 1
		else
			return nil, "notEnough", numInBags -- not enough for single post
		end
	end

	local activeAuctions = 0
	local extraStack
	local buyout, bid, _, isWhitelist, isPlayer, isInvalidSeller = TSM.Scan:GetLowestAuction(itemString, operation)

	if isInvalidSeller then
		TSM:Printf(L["Seller name of lowest auction for item %s was not returned from server. Skipping this item."], select(2, TSMAPI:GetSafeItemInfo(itemString)))
		return nil, "invalidSeller", numInBags
	end

	local prices = TSM.Util:GetItemPrices(operation, itemString)
	if buyout and buyout <= prices.minPrice then
		-- lowest is below min price
		if not prices.resetPrice then
			-- lowest is below the min price and there's no reset price
			return nil, "belowMinPrice", numInBags
		else
			-- lowest is below the min price, but there is a reset price
			local priceResetBuyout = prices.resetPrice
			local priceResetBid = priceResetBuyout * operation.bidPercent
			activeAuctions = TSM.Scan:GetPlayerAuctionCount(itemString, priceResetBuyout, priceResetBid, perAuction, operation)
		end
	elseif isWhitelist and not isPlayer and not TSM.db.global.matchWhitelist then
		-- lowest is somebody on the whitelist and we aren't price matching
		return nil, "notPostingWhitelist", numInBags
	elseif isPlayer or isWhitelist then
		-- Either the player or a whitelist person is the lowest teir so use this tiers quantity of items
		activeAuctions = TSM.Scan:GetPlayerAuctionCount(itemString, buyout or 0, bid or 0, perAuction, operation)
	end

	-- If we have a post cap of 20, and 10 active auctions, but we can only have 5 of the item then this will only let us create 5 auctions
	-- however, if we have 20 of the item it will let us post another 10
	local auctionsCreated = min(operation.postCap - activeAuctions, maxCanPost)
	if auctionsCreated <= 0 then
		return nil, "tooManyPosted", numInBags
	end

	if (auctionsCreated + activeAuctions) < operation.postCap then
		-- can post at least one more
		local extra = numInBags % perAuction
		if perAuctionIsCap and extra > 0 then
			extraStack = extra
		end
	end

	if Post:FindItemSlot(itemString) then
		local posts = { { perAuction, auctionsCreated } }
		numInBags = numInBags - perAuction * auctionsCreated
		if extraStack then
			numInBags = numInBags - extraStack
			tinsert(posts, { extraStack, 1 })
		end
		-- third return value specifies whether there's extra left over in the player's bags after this operation
		return posts, nil, numInBags
	end
end

function Post:GetPostPrice(itemString, operation)
	local lowestBuyout, lowestBid, lowestOwner, isWhitelist, isPlayer = TSM.Scan:GetLowestAuction(itemString, operation)
	local bid, buyout, info
	local prices = TSM.Util:GetItemPrices(operation, itemString)

	if not lowestOwner then
		-- No other auctions up, default to normalPrice
		info = "postingNormal"
		buyout = prices.normalPrice
	elseif prices.resetPrice and lowestBuyout <= prices.minPrice then
		-- item is below min price and a priceReset is set
		if operation.priceReset == "minPrice" then
			info = "postingResetMin"
		elseif operation.priceReset == "maxPrice" then
			info = "postingResetMax"
		elseif operation.priceReset == "normalPrice" then
			info = "postingResetNormal"
		else
			-- should never happen, but better to throw an error here than cause issues later on
			error("Unknown 'below minimum' price setting.")
		end
		buyout = prices.resetPrice
	elseif isPlayer or (isWhitelist and lowestBuyout - prices.undercut <= prices.maxPrice) then
		-- Either we already have one up or someone on the whitelist does
		bid, buyout = min(lowestBid, lowestBuyout), lowestBuyout
		info = isPlayer and "postingPlayer" or "postingWhitelist"
	else
		-- we've been undercut and we are going to undercut back
		buyout = lowestBuyout - prices.undercut
		-- if the cheapest is above our max price, follow the aboveMax setting
		if buyout > prices.maxPrice then
			if operation.aboveMax == "minPrice" then
				info = "aboveMaxMin"
			elseif operation.aboveMax == "maxPrice" then
				info = "aboveMaxMax"
			elseif operation.aboveMax == "normalPrice" then
				info = "aboveMaxNormal"
			else
				-- should never happen, but better to throw an error here than cause issues later on
				error("Unknown 'above maximum' price setting.")
			end
			buyout = prices.aboveMax
		end
		-- make sure the buyout and bid aren't below the minPrice
		buyout = max(buyout, prices.minPrice)
		-- Check if the bid is too low
		bid = max(buyout * operation.bidPercent, prices.minPrice)
		info = info or "postingUndercut"
	end

	-- set the bid if it hasn't been set
	bid = bid or (buyout * operation.bidPercent)
	return bid, buyout, info
end

function Post:QueueItemToPost(itemString, numStacks, stackSize, bid, buyout, postTime, operation)
	itemLocations[itemString] = itemLocations[itemString] or Post:FindItemSlot(itemString, true)

	for i = 1, numStacks do
		local oBag, oSlot
		for j = 1, #itemLocations[itemString] do
			if itemLocations[itemString][j].quantity >= stackSize then
				oBag, oSlot = itemLocations[itemString][j].bag, itemLocations[itemString][j].slot
				itemLocations[itemString][j].quantity = itemLocations[itemString][j].quantity - stackSize
				break
			end
		end
		if not oBag or not oSlot then
			oBag, oSlot = Post:FindItemSlot(itemString)
			if not (oBag and oSlot) then break end
		end
		tinsert(postQueue, { bag = oBag, slot = oSlot, bid = bid, buyout = buyout, postTime = postTime, stackSize = stackSize, numStacks = (numStacks - i + 1), itemString = itemString, operation = operation })
		totalToPost = totalToPost + 1
	end
	TSM.Manage:UpdateStatus("manage", totalPosted, totalToPost)
end

function Post:FindItemSlot(findItemString, allLocations)
	local locations = {}
	Post:UpdateBagState()
	for _, data in ipairs(bagInfo) do
		local bag, slot, itemString, quantity = unpack(data)
		if findItemString == itemString then
			if not allLocations then
				return bag, slot
			end
			tinsert(locations, { bag = bag, slot = slot, quantity = quantity })
		end
	end
	return allLocations and locations
end

function Post:GetNumInBags(itemString)
	local num = 0
	Post:UpdateBagState()
	return bagState[itemString] or 0
end

local timeout = CreateFrame("Frame")
timeout:Hide()
timeout:SetScript("OnUpdate", function(self, elapsed)
	self.timeLeft = self.timeLeft - elapsed
	if self.timeLeft <= 0 or (postQueue[1] and postQueue[1].bag and postQueue[1].slot and not select(3, GetContainerItemInfo(postQueue[1].bag, postQueue[1].slot)) and not AuctionsCreateAuctionButton:IsEnabled()) then
		tremove(postQueue, 1)
		Post:UpdateItem()
	end
end)

function Post:SetupForAction()
	Post:RegisterEvent("CHAT_MSG_SYSTEM")
	timeout:Hide()
	ClearCursor()
	TSM.Manage:UpdateStatus("manage", totalPosted, totalToPost)
	wipe(currentItem)
	currentItem = postQueue[1]
	TSM.Manage:SetCurrentItem(currentItem)
	GUI.buttons:Enable()
end

-- Check if an auction was posted and move on if so
function Post:CHAT_MSG_SYSTEM(_, msg)
	if msg == ERR_AUCTION_STARTED then
		count = count + 1
		TSM.Manage:UpdateStatus("confirm", count, totalToPost)
	end
end

local countFrame = CreateFrame("Frame")
countFrame:Hide()
countFrame.count = -1
countFrame.timeLeft = 10
countFrame:SetScript("OnUpdate", function(self, elapsed)
	self.timeLeft = self.timeLeft - elapsed
	if count >= totalToPost or self.timeLeft <= 0 then
		self:Hide()
		Post:Stop()
	elseif count ~= self.count then
		self.count = count
		self.timeLeft = (totalToPost - count) * 2
	end
end)

local function DelayFrame()
	if #postQueue > 0 then
		Post:UpdateItem()
		TSMAPI:CancelFrame("postDelayFrame")
	elseif not isScanning then
		TSM.Manage:UpdateStatus("manage", totalPosted, totalToPost)
		Post:Stop()
		TSMAPI:CancelFrame("postDelayFrame")
	end
end

function Post:UpdateItem()
	ClearCursor()
	timeout:Hide()
	if #postQueue == 0 then
		GUI.buttons:Disable()
		if isScanning then
			TSMAPI:CreateFunctionRepeat("postDelayFrame", DelayFrame)
		else
			TSM.Manage:UpdateStatus("manage", totalPosted + 1, totalToPost)
			countFrame:Show()
		end
		return
	end

	totalPosted = totalPosted + 1
	TSM.Manage:UpdateStatus("manage", totalPosted, totalToPost)
	wipe(currentItem)
	currentItem = postQueue[1]
	TSM.Manage:SetCurrentItem(currentItem)
	GUI.buttons:Enable()
end

function Post:DoAction()
	timeout.timeLeft = 5
	timeout:Show()
	if not AuctionFrameAuctions.duration then
		-- Fix in case Blizzard_AuctionUI hasn't set this value yet (which could cause an error)
		AuctionFrameAuctions.duration = 2
	end
	
	if not currentItem.itemString then
		timeout:Hide()
		Post:SkipItem()
		return
	end

	if type(currentItem.bag) ~= "number" or type(currentItem.slot) ~= "number" then
		local bag, slot = Post:FindItemSlot(currentItem.itemString)
		if not bag or not slot then
			local link = select(2, TSMAPI:GetSafeItemInfo(currentItem.itemString)) or currentItem.itemString
			TSM:Printf(L["Auctioning could not find %s in your bags so has skipped posting it. Running the scan again should resolve this issue."], link)
			timeout:Hide()
			Post:SkipItem()
			return
		end
		currentItem.bag = bag
		currentItem.slot = slot
	end
	local itemString = TSMAPI:GetBaseItemString(GetContainerItemLink(currentItem.bag, currentItem.slot), true)
	if itemString ~= currentItem.itemString then
		TSM:Print(L["Please don't move items around in your bags while a post scan is running! The item was skipped to avoid an incorrect item being posted."])
		timeout:Hide()
		Post:SkipItem()
		return
	end

	PickupContainerItem(currentItem.bag, currentItem.slot)
	ClickAuctionSellItemButton(AuctionsItemButton, "LeftButton")
	StartAuction(currentItem.bid, currentItem.buyout, currentItem.postTime, currentItem.stackSize, 1)
	GUI.buttons:Disable()
end

function Post:SkipItem()
	local toSkip = {}
	local skipped = tremove(postQueue, 1)
	count = count + 1
	for i, info in ipairs(postQueue) do
		if info.itemString == skipped.itemString and info.bid == skipped.bid and info.buyout == skipped.buyout then
			tinsert(toSkip, i)
		end
	end
	sort(toSkip, function(a, b) return a > b end)
	for _, index in ipairs(toSkip) do
		tremove(postQueue, index)
		count = count + 1
		totalPosted = totalPosted + 1
	end
	TSM.Manage:UpdateStatus("manage", totalPosted, totalToPost)
	TSM.Manage:UpdateStatus("confirm", count, totalToPost)
	Post:UpdateItem()
end

function Post:Stop()
	GUI:Stopped()
	TSMAPI:CancelFrame("postDelayFrame")
	Post:UnregisterAllEvents()
	TSMAPI:FireEvent("AUCTIONING:POST:STOPPED")

	wipe(currentItem)
	totalToPost, totalPosted = 0, 0
	isScanning = false
end

function Post:GetAHGoldTotal()
	local total = 0
	local incomingTotal = 0
	for i = 1, GetNumAuctionItems("owner") do
		local count, _, _, _, _, _, _, buyoutAmount = select(3, GetAuctionItemInfo("owner", i))
		total = total + buyoutAmount
		if count == 0 then
			incomingTotal = incomingTotal + buyoutAmount
		end
	end
	return TSMAPI:FormatTextMoneyIcon(total), TSMAPI:FormatTextMoneyIcon(incomingTotal)
end

function Post:GetCurrentItem()
	return currentItem
end

function Post:EditPostPrice(itemString, buyout, operation)
	local bid = buyout * operation.bidPercent

	if currentItem.itemString == itemString then
		currentItem.buyout = buyout
		currentItem.bid = bid
	end

	for _, data in ipairs(postQueue) do
		if data.itemString == itemString then
			data.buyout = buyout
			data.bid = bid
		end
	end
	TSM.Manage:SetCurrentItem(currentItem)
end

function Post:DoneScanning()
	isScanning = false
	return totalToPost
end