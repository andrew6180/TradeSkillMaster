-- ------------------------------------------------------------------------------ --
--                           TradeSkillMaster_Auctioning                          --
--           http://www.curse.com/addons/wow/tradeskillmaster_auctioning          --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

local TSM = select(2, ...)
local Cancel = TSM:NewModule("Cancel", "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster_Auctioning") -- loads the localization table

local cancelQueue, currentItem, tempIndexList = {}, {}, {}
local totalToCancel, totalCanceled, count = 0, 0, 0
local isScanning, GUI, isCancelAll, specialOptions
local itemsCancelled, itemsMissed = {}, {}


function Cancel:ValidateOperation(itemString, operation)
	local _, itemLink = TSMAPI:GetSafeItemInfo(itemString)
	local prices = TSM.Util:GetItemPrices(operation, itemString)

	-- don't cancel this item if their settings are invalid
	if not prices.minPrice then
		if not TSM.db.global.disableInvalidMsg then
			TSM:Printf(L["Did not cancel %s because your minimum price (%s) is invalid. Check your settings."], itemLink or itemString, operation.minPrice)
		end
		TSM.Log:AddLogRecord(itemString, "cancel", "Skip", "invalid")
	elseif not prices.maxPrice then
		if not TSM.db.global.disableInvalidMsg then
			TSM:Printf(L["Did not cancel %s because your maximum price (%s) is invalid. Check your settings."], itemLink or itemString, operation.maxPrice)
		end
		TSM.Log:AddLogRecord(itemString, "cancel", "Skip", "invalid")
	elseif not prices.normalPrice then
		if not TSM.db.global.disableInvalidMsg then
			TSM:Printf(L["Did not cancel %s because your normal price (%s) is invalid. Check your settings."], itemLink or itemString, operation.normalPrice)
		end
		TSM.Log:AddLogRecord(itemString, "cancel", "Skip", "invalid")
	elseif operation.cancelRepost and not prices.cancelRepostThreshold then
		if not TSM.db.global.disableInvalidMsg then
			TSM:Printf(L["Did not cancel %s because your cancel to repost threshold (%s) is invalid. Check your settings."], itemLink or itemString, operation.cancelRepostThreshold)
		end
		TSM.Log:AddLogRecord(itemString, "cancel", "Skip", "invalid")
	elseif not prices.undercut then
		if not TSM.db.global.disableInvalidMsg then
			TSM:Printf(L["Did not cancel %s because your undercut (%s) is invalid. Check your settings."], itemLink or itemString, operation.undercut)
		end
		TSM.Log:AddLogRecord(itemString, "cancel", "Skip", "invalid")
	elseif prices.maxPrice < prices.minPrice then
		if not TSM.db.global.disableInvalidMsg then
			TSM:Printf(L["Did not cancel %s because your maximum price (%s) is lower than your minimum price (%s). Check your settings."], itemLink or itemString, operation.maxPrice, operation.minPrice)
		end
		TSM.Log:AddLogRecord(itemString, "cancel", "Skip", "invalid")
	elseif prices.normalPrice < prices.minPrice then
		if not TSM.db.global.disableInvalidMsg then
			TSM:Printf(L["Did not cancel %s because your normal price (%s) is lower than your minimum price (%s). Check your settings."], itemLink or itemString, operation.normalPrice, operation.minPrice)
		end
		TSM.Log:AddLogRecord(itemString, "cancel", "Skip", "invalid")
	else
		return true
	end
end

function Cancel:GetScanListAndSetup(GUIRef, options)
	-- setup stuff
	GUI = GUIRef
	options = options or {}
	isScanning = true
	options.noScan = options.specialMode
	isCancelAll = options.specialMode
	wipe(cancelQueue)
	wipe(currentItem)
	wipe(itemsCancelled)
	wipe(itemsMissed)
	wipe(TSM.operationLookup)
	totalToCancel, totalCanceled, count = 0, 0, 0
	
	local tempList, scanList, groupTemp = {}, {}, {}
	
	specialOptions = specialOptions or {}
	wipe(specialOptions)
	if type(options.specialMode) == "string" then
		if strsub(options.specialMode, 1, 1) == "<" then
			specialOptions.specialPriceMax = TSMAPI:UnformatTextMoney(strsub(options.specialMode, 2))
			isCancelAll = "price"
		elseif strsub(options.specialMode, 1, 1) == ">" then
			specialOptions.specialPriceMin = TSMAPI:UnformatTextMoney(strsub(options.specialMode, 2))
			isCancelAll = "price"
		end
	end
	
	for i=GetNumAuctionItems("owner"), 1, -1 do
		-- ignore sold auctions
		if select(13, GetAuctionItemInfo("owner", i)) == 0 then
			local itemString = TSMAPI:GetBaseItemString(GetAuctionItemLink("owner", i), true)
			if not TSM.db.global.cancelWithBid and select(10, GetAuctionItemInfo("owner", i)) > 0 then
				-- we aren't canceling auctions with bids
				TSM.Log:AddLogRecord(itemString, "cancel", "Skip", "bid")
			else
				if specialOptions.specialPriceMin then
					-- cancel auctions above some min price
					local buyout = select(9, GetAuctionItemInfo("owner", i))
					if buyout > 0 and buyout > specialOptions.specialPriceMin then
						tempList[itemString] = true
					end
				elseif specialOptions.specialPriceMax then
					-- cancel auctions below some max price
					local buyout = select(9, GetAuctionItemInfo("owner", i))
					if buyout > 0 and buyout < specialOptions.specialPriceMax then
						tempList[itemString] = true
					end
				elseif options.specialMode == "CancelAll" then
					-- cancel all auctions
					tempList[itemString] = true
				elseif type(options.specialMode) == "number" then
					-- cancel low duration auctions
					local timeLeft = GetAuctionItemTimeLeft("owner", i)
					if timeLeft <= options.specialMode then
						tempList[itemString] = true
					end
				elseif options.specialMode then
					-- cancel all items matching filter
					local itemName = GetAuctionItemInfo("owner", i)
					if strfind(strlower(itemName), strlower(options.specialMode)) then
						tempList[itemString] = true
					end
				elseif options.itemOperations[itemString] then
					-- normal cancel scan
					local operations = {}
					for _, operation in pairs(options.itemOperations[itemString]) do
						if operation.cancelUndercut or operation.cancelRepost then
							tinsert(operations, operation)
						end
					end
					tempList[itemString] = operations
				end
			end
		end
	end
	
	if options.specialMode then
		for itemString in pairs(tempList) do
			tinsert(scanList, itemString)
		end
	else
		for itemString, operations in pairs(tempList) do
			TSM.operationLookup[itemString] = operations
			local isValid
			for _, operation in pairs(operations) do
				if operation.cancelUndercut or operation.cancelRepost then
					isValid = true
					if not Cancel:ValidateOperation(itemString, operation) then
						isValid = nil
						break
					end
				end
			end
			if isValid then
				tinsert(scanList, itemString)
			end
		end
		TSMAPI:FireEvent("AUCTIONING:CANCEL:START", {num=#scanList})
	end
	
	return scanList
end

function Cancel:ProcessItem(itemString, noLog)
	if isCancelAll then
		return Cancel:SpecialScanProcessItem(itemString, noLog)
	end

	local operations = TSM.operationLookup[itemString]
	if not operations then return end
	for _, operation in pairs(operations) do
		local toCancel, reasonToCancel, reasonNotToCancel, buyout
		local cancelAuctions = {}
		for i=GetNumAuctionItems("owner"), 1, -1 do
			if select(13, GetAuctionItemInfo("owner", i)) == 0 and itemString == TSMAPI:GetBaseItemString(GetAuctionItemLink("owner", i), true) then
				local shouldCancel, reason = Cancel:ShouldCancel(i, operation)
				if shouldCancel then
					shouldCancel.reason = reason
					tinsert(cancelAuctions, shouldCancel)
					buyout = select(9, GetAuctionItemInfo("owner", i))
				else
					reasonNotToCancel = reasonNotToCancel or reason
					buyout = buyout or select(9, GetAuctionItemInfo("owner", i))
				end
			end
		end
		
		local numKept = 0
		sort(cancelAuctions, function(a, b) return a.buyout < b.buyout end) --keepPosted
		for i=#cancelAuctions, 1, -1 do
			local auction = cancelAuctions[i]
			if (auction.reason == "whitelistUndercut" or auction.reason == "undercut" or auction.reason == "notLowest") and numKept < operation.keepPosted then
				numKept = numKept + 1
				reasonNotToCancel = "keepPosted"
			else
				toCancel = true
				reasonToCancel = auction.reason
				totalToCancel = totalToCancel + 1
				tinsert(cancelQueue, auction)
			end
		end
		if totalToCancel > 0 then
			TSM.Manage:UpdateStatus("manage", totalCanceled, totalToCancel)
		end
		
		if not noLog then
			if toCancel then
				TSM.Log:AddLogRecord(itemString, "cancel", "Cancel", reasonToCancel, operation, buyout)
			elseif reasonNotToCancel then
				TSM.Log:AddLogRecord(itemString, "cancel", "Skip", reasonNotToCancel, operation, buyout)
			end
		end
		
		if #cancelQueue > 0 and not currentItem.buyout then
			Cancel:SetupForAction()
		end
	end
end

function Cancel:SpecialScanProcessItem(itemString, noLog)
	local toCancel, reasonToCancel, reasonNotToCancel
	local cancelAuctions = {}
	for i=GetNumAuctionItems("owner"), 1, -1 do
		if select(13, GetAuctionItemInfo("owner", i)) == 0 and itemString == TSMAPI:GetBaseItemString(GetAuctionItemLink("owner", i), true) then
			local _, _, quantity, _, _, _, bid, _, buyout, activeBid, _, _, wasSold = GetAuctionItemInfo("owner", i)
			local cancelData = {itemString=itemString, stackSize=quantity, buyout=buyout, bid=bid, index=i, numStacks=1}
			if specialOptions.specialPriceMin then
				if buyout > specialOptions.specialPriceMin then
					cancelData.reason = "cancelAll"
					tinsert(cancelAuctions, cancelData)
				else
					reasonNotToCancel = reasonNotToCancel or "cancelAll"
				end
			elseif specialOptions.specialPriceMax then
				if buyout < specialOptions.specialPriceMax then
					cancelData.reason = "cancelAll"
					tinsert(cancelAuctions, cancelData)
				else
					reasonNotToCancel = reasonNotToCancel or "cancelAll"
				end
			elseif type(isCancelAll) ~= "number" or GetAuctionItemTimeLeft("owner", i) <= isCancelAll then
				cancelData.reason = "cancelAll"
				tinsert(cancelAuctions, cancelData)
			else
				reasonNotToCancel = reasonNotToCancel or "cancelAll"
			end
		end
	end
	
	local numKept = 0
	sort(cancelAuctions, function(a, b) return a.buyout < b.buyout end) --keepPosted
	for i=#cancelAuctions, 1, -1 do
		local auction = cancelAuctions[i]
		toCancel = true
		reasonToCancel = auction.reason
		totalToCancel = totalToCancel + 1
		tinsert(cancelQueue, auction)
	end
	if totalToCancel > 0 then
		TSM.Manage:UpdateStatus("manage", totalCanceled, totalToCancel)
	end
	
	if not noLog then
		if toCancel then
			TSM.Log:AddLogRecord(itemString, "cancel", "Cancel", reasonToCancel)
		elseif reasonNotToCancel then
			TSM.Log:AddLogRecord(itemString, "cancel", "Skip", reasonNotToCancel)
		end
	end
	
	if #cancelQueue > 0 and not currentItem.buyout then
		Cancel:SetupForAction()
	end
end

function Cancel:ShouldCancel(index, operation)
	local _, _, quantity, _, _, _, bid, _, buyout, activeBid, _, _, wasSold = GetAuctionItemInfo("owner", index)
	local buyoutPerItem = floor(buyout / quantity)
	local bidPerItem = floor(bid / quantity)
	if operation.matchStackSize and quantity ~= operation.stackSize then return end
	
	local itemString = TSMAPI:GetBaseItemString(GetAuctionItemLink("owner", index), true)
	local cancelData = {itemString=itemString, stackSize=quantity, buyout=buyout, bid=bid, index=index, numStacks=1, operation=operation}
	
	local auctionItem = TSM.Scan.auctionData[itemString]
	local lowestBuyout, lowestBid, lowestOwner, isWhitelist, isPlayer, isInvalidSeller = TSM.Scan:GetLowestAuction(itemString, operation)
	local secondLowest = TSM.Scan:GetSecondLowest(itemString, lowestBuyout, operation) or 0
	
	if wasSold == 1 or not lowestOwner then
		-- if this auction was sold or we don't have any data on it then this request is invalid
		return
	elseif isInvalidSeller or not lowestBuyout then
		if isInvalidSeller then
			TSM:Printf(L["Seller name of lowest auction for item %s was not returned from server. Skipping this item."], GetAuctionItemLink("owner", index))
		else
			TSM:Printf(L["Invalid scan data for item %s. Skipping this item."], GetAuctionItemLink("owner", index))
		end
		return false, "invalidSeller"
	end
	
	if not TSM.db.global.cancelWithBid and activeBid > 0 then
		-- Don't cancel an auction if it has a bid and we're set to not cancel those
		return false, "bid"
	end
	
	local prices = TSM.Util:GetItemPrices(operation, itemString)
	if buyoutPerItem < prices.minPrice then
		-- this auction is below min price
		if operation.cancelRepost and prices.resetPrice and buyoutPerItem < (prices.resetPrice - prices.cancelRepostThreshold) then
			-- canceling to post at reset price
			return cancelData, "reset"
		end
		return false, "belowMinPrice"
	elseif lowestBuyout < prices.minPrice then
		-- lowest buyout is below min price, so do nothing
		return false, "belowMinPrice"
	else
		-- lowest buyout is above the min price
		if operation.cancelUndercut and (buyoutPerItem - prices.undercut) > (TSM.Scan:GetPlayerLowestBuyout(auctionItem, operation) or math.huge) then
			-- this is not our lowest auction
			return cancelData, "notLowest"
		elseif auctionItem:IsPlayerOnly() then
			-- we are posted at the aboveMax price with no competition under our max price
			-- check if we can repost higher
			if operation.cancelRepost and prices.normalPrice - buyoutPerItem > prices.cancelRepostThreshold then
				-- we can repost higher
				return cancelData, "repost"
			end
			return false, "atNormal"
		elseif isPlayer and (secondLowest > prices.maxPrice) then
			-- we are posted at the aboveMax price with no competition under our max price
			-- check if we can repost higher
			if operation.cancelRepost and prices.aboveMax - buyoutPerItem > prices.cancelRepostThreshold then
				-- we can repost higher
				return cancelData, "repost"
			end
			return false, "atAboveMax"
		elseif isPlayer then
			-- we are the loewst auction
			-- check if we can repost higher
			if operation.cancelRepost and ((secondLowest - prices.undercut) - lowestBuyout) > prices.cancelRepostThreshold then
				-- we can repost higher
				return cancelData, "repost"
			end
			return false, "notUndercut"
		elseif not operation.cancelUndercut then
			return -- we're undercut but not canceling undercut auctions
		elseif isWhitelist and buyoutPerItem == lowestBuyout then
			-- at whitelisted player price
			return false, "atWhitelist"
		elseif not isWhitelist then
			-- we've been undercut by somebody not on our whitelist
			return cancelData, "undercut"
		elseif buyoutPerItem ~= lowestBuyout or bidPerItem ~= lowestBid then
			-- somebody on our whitelist undercut us (or their bid is lower)
			return cancelData, "whitelistUndercut"
		end
	end
	
	error("unexpectedly reached end", buyoutPerItem, lowestBuyout, isWhitelist, isPlayer, prices.minPrice)
end

-- register events and queue up the first item to cancel
function Cancel:SetupForAction()
	Cancel:RegisterEvent("CHAT_MSG_SYSTEM")
	Cancel:RegisterEvent("UI_ERROR_MESSAGE")
	TSM.Manage:UpdateStatus("manage", totalCanceled, totalToCancel)
	wipe(currentItem)
	currentItem = cancelQueue[1]
	TSM.Manage:SetCurrentItem(currentItem)
	GUI.buttons:Enable()
end

-- Check if an auction was canceled and move on if so
function Cancel:CHAT_MSG_SYSTEM(_, msg)
	if msg == ERR_AUCTION_REMOVED then
		count = count + 1
		TSM.Manage:UpdateStatus("confirm", count, totalToCancel)
	end
end

-- "Item Not Found" error
function Cancel:UI_ERROR_MESSAGE(event, msg)
	if msg == ERR_ITEM_NOT_FOUND then
		count = count + 1
		TSM.Manage:UpdateStatus("confirm", count, totalToCancel)
		tinsert(itemsMissed, itemsCancelled[count])
	end
end

local function CountFrame()
	if count == totalToCancel then
		TSMAPI:CancelFrame("cancelCountFrame")
		Cancel:Stop()
	end
end

local function DelayFrame()
	if not isScanning and #(cancelQueue) == 0 then
		TSMAPI:CreateFunctionRepeat("cancelCountFrame", CountFrame)
		TSMAPI:CancelFrame("cancelDelayFrame")
	elseif #(cancelQueue) > 0 then
		Cancel:UpdateItem()
		TSMAPI:CancelFrame("cancelDelayFrame")
	end
end

-- updates the current item to the first one in the list
function Cancel:UpdateItem()
	if #(cancelQueue) == 0 then
		GUI.buttons:Disable()
		if isScanning then
			TSMAPI:CreateFunctionRepeat("cancelDelayFrame", DelayFrame)
		else
			TSMAPI:CreateFunctionRepeat("cancelCountFrame", CountFrame)
		end
		return
	end
	
	sort(cancelQueue, function(a, b) return (a.index or 0)>(b.index or 0) end)

	totalCanceled = totalCanceled + 1
	TSM.Manage:UpdateStatus("manage", totalCanceled, totalToCancel)
	wipe(currentItem)
	currentItem = cancelQueue[1]
	TSM.Manage:SetCurrentItem(currentItem)
	GUI.buttons:Enable()
end

-- cancel the current item (gets called when the button is pressed
function Cancel:DoAction()
	local index, backupIndex
	-- make sure the currentItem is accurate
	if cancelQueue[1].itemString ~= currentItem.itemString then
		Cancel:UpdateItem()
	end
	
	-- figure out which index the item goes to
	for i=GetNumAuctionItems("owner"), 1, -1 do
		local _, _, quantity, _, _, _, bid, _, buyout, activeBid = GetAuctionItemInfo("owner", i)
		local itemString = TSMAPI:GetBaseItemString(GetAuctionItemLink("owner", i), true)
		if itemString == currentItem.itemString and abs((buyout or 0) - (currentItem.buyout or 0)) < quantity and abs((bid or 0) - (currentItem.bid or 0)) < quantity and (not TSM.db.global.cancelWithBid and activeBid == 0 or TSM.db.global.cancelWithBid) then
			if not tempIndexList[itemString..buyout..bid..i] then
				tempIndexList[itemString..buyout..bid..i] = true
				index = i
				break
			else
				backupIndex = i
			end
		end
	end
	
	-- if we found an index then cancel the item
	if index then
		CancelAuction(index)
	elseif backupIndex then
		CancelAuction(backupIndex)
	end
	
	-- disable the button and move onto the next item
	GUI.buttons:Disable()
	tinsert(itemsCancelled, CopyTable(cancelQueue[1]))
	tremove(cancelQueue, 1)
	Cancel:UpdateItem()
end

-- gets called when the "Skip Item" button is pressed
function Cancel:SkipItem()
	tremove(cancelQueue, 1)
	count = count + 1
	TSM.Manage:UpdateStatus("confirm", count, totalToCancel)
	Cancel:UpdateItem()
end

-- we are done canceling (maybe)
function Cancel:Stop(interrupted)
	wipe(tempIndexList)
	if #itemsMissed == 0 or interrupted then
		-- didn't get "item not found" for any cancels or we were interrupted so we are done
		TSMAPI:CancelFrame("cancelCountFrame")
		TSMAPI:CancelFrame("cancelDelayFrame")
		TSMAPI:CancelFrame("updateCancelStatus")
		GUI:Stopped()
	
		Cancel:UnregisterAllEvents()
		wipe(currentItem)
		totalToCancel, totalCanceled = 0, 0
		isScanning = false
	else -- got an "item not found" so requeue ones that we missed
		count = totalToCancel
		for _, info in ipairs(itemsMissed) do
			Cancel:ProcessItem(info.itemString, true)
		end
		wipe(itemsMissed)
		isScanning = false
		Cancel:UpdateItem()
	end
end

function Cancel:DoneScanning()
	isScanning = false
	return totalToCancel
end

function Cancel:GetCurrentItem()
	return currentItem
end