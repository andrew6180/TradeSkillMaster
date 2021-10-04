-- ------------------------------------------------------------------------------ --
--                                TradeSkillMaster                                --
--                http://www.curse.com/addons/wow/tradeskill-master               --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- This file contains all the code for moving items between bags / bank.

local TSM = select(2, ...)
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster") -- loads the localization table
local AceGUI = LibStub("AceGUI-3.0") -- load the AceGUI libraries
local lib = TSMAPI

local bankType
local fullMoves, splitMoves, bagState = {}, {}, {}
local callbackMsg = {}

-- this is a set of wrapper functions so that I can switch
-- between guildbank and bank function easily (taken from warehousing)

TSM.pickupContainerItemSrc = nil
TSM.getContainerItemIDSrc = nil
TSM.getContainerNumSlotsSrc = nil
TSM.getContainerItemLinkSrc = nil
TSM.getContainerNumFreeSlotsSrc = nil
TSM.splitContainerItemSrc = nil

TSM.pickupContainerItemDest = nil
TSM.getContainerItemIDDest = nil
TSM.getContainerNumSlotsDest = nil
TSM.getContainerItemLinkDest = nil
TSM.getContainerNumFreeSlotsDest = nil


TSM.autoStoreItem = nil
TSM.getContainerItemQty = nil

function TSM:OnEnable()
	local next = next

	TSM:RegisterEvent("GUILDBANKFRAME_OPENED", function(event)
		bankType = "guildbank"
	end)

	TSM:RegisterEvent("BANKFRAME_OPENED", function(event)
		bankType = "bank"
	end)

	TSM:RegisterEvent("GUILDBANKFRAME_CLOSED", function(event, addon)
		bankType = nil
		TSM:UnregisterEvent("GUILDBANKBAGSLOTS_CHANGED")
	end)

	TSM:RegisterEvent("BANKFRAME_CLOSED", function(event)
		bankType = nil
		TSM:UnregisterEvent("BAG_UPDATE")
	end)
end

local function setSrcBagFunctions(bagType)
	if bagType == "guildbank" then
		TSM.autoStoreItem = function(bag, slot) AutoStoreGuildBankItem(bag, slot)
		end
		TSM.getContainerItemQty = function(bag, slot) return select(2, GetGuildBankItemInfo(bag, slot))
		end
		TSM.splitContainerItemSrc = function(bag, slot, need) SplitGuildBankItem(bag, slot, need);
		end
		TSM.pickupContainerItemSrc = function(bag, slot) PickupGuildBankItem(bag, slot)
		end
		TSM.getContainerNumSlotsSrc = function(bag) return MAX_GUILDBANK_SLOTS_PER_TAB or 98
		end
		TSM.getContainerItemLinkSrc = function(bag, slot) return GetGuildBankItemLink(bag, slot)
		end
		TSM.getContainerNumFreeSlotsSrc = function(bag) return MAX_GUILDBANK_SLOTS_PER_TAB or 98
		end --need to change this eventually
		TSM.getContainerItemIDSrc = function(bag, slot)
			local tmpLink = GetGuildBankItemLink(bag, slot)
			local quantity = select(2, GetGuildBankItemInfo(bag, slot))
			if tmpLink then
				return TSMAPI:GetBaseItemString(tmpLink, true), quantity
			else
				return nil
			end
		end
	else
		TSM.autoStoreItem = function(bag, slot) UseContainerItem(bag, slot)
		end
		TSM.getContainerItemQty = function(bag, slot) return select(2, GetContainerItemInfo(bag, slot))
		end
		TSM.splitContainerItemSrc = function(bag, slot, need) SplitContainerItem(bag, slot, need)
		end
		TSM.pickupContainerItemSrc = function(bag, slot) PickupContainerItem(bag, slot)
		end
		TSM.getContainerItemIDSrc = function(bag, slot)
			local tmpLink = GetContainerItemLink(bag, slot)
			local quantity = select(2, GetContainerItemInfo(bag, slot))
			return TSMAPI:GetBaseItemString(tmpLink, true), quantity
		end
		TSM.getContainerNumSlotsSrc = function(bag) return GetContainerNumSlots(bag)
		end
		TSM.getContainerItemLinkSrc = function(bag, slot) return GetContainerItemLink(bag, slot)
		end
		TSM.getContainerNumFreeSlotsSrc = function(bag) return GetContainerNumFreeSlots(bag)
		end
	end
end

local function setDestBagFunctions(bagType)
	if bagType == "guildbank" then
		TSM.pickupContainerItemDest = function(bag, slot) PickupGuildBankItem(bag, slot)
		end
		TSM.getContainerNumSlotsDest = function(bag) return MAX_GUILDBANK_SLOTS_PER_TAB or 98
		end
		TSM.getContainerNumFreeSlotsDest = function(bag) return GetEmptySlotCount(bag)
		end --need to change this eventually
		TSM.getContainerItemLinkDest = function(bag, slot) return GetGuildBankItemLink(bag, slot)
		end
		TSM.getContainerItemIDDest = function(bag, slot)
			local tmpLink = GetGuildBankItemLink(bag, slot)
			local quantity = select(2, GetGuildBankItemInfo(bag, slot))
			if tmpLink then
				return TSMAPI:GetBaseItemString(tmpLink, true), quantity
			else
				return nil
			end
		end
	else
		TSM.pickupContainerItemDest = function(bag, slot) PickupContainerItem(bag, slot)
		end
		TSM.getContainerItemIDDest = function(bag, slot)
			local tmpLink = GetContainerItemLink(bag, slot)
			local quantity = select(2, GetContainerItemInfo(bag, slot))
			return TSMAPI:GetBaseItemString(tmpLink, true), quantity
		end
		TSM.getContainerNumSlotsDest = function(bag) return GetContainerNumSlots(bag)
		end
		TSM.getContainerItemLinkDest = function(bag, slot) return GetContainerItemLink(bag, slot)
		end
		TSM.getContainerNumFreeSlotsDest = function(bag) return GetContainerNumFreeSlots(bag)
		end
	end
end

local function getContainerTable(cnt)
	local t = {}

	if cnt == "bank" then
		local numSlots, _ = GetNumBankSlots()

		for i = 1, numSlots + 1 do
			if i == 1 then
				t[i] = -1
			else
				t[i] = i + 3
			end
		end

		return t

	elseif cnt == "guildbank" then
		for i = 1, GetNumGuildBankTabs() do
			local canView, canDeposit, stacksPerDay = GetGuildBankTabInfo(i);
			if canView and canDeposit and stacksPerDay then
				t[i] = i
			end
		end

		return t
	elseif cnt == "bags" then
		for i = 1, NUM_BAG_SLOTS + 1 do t[i] = i - 1
		end
		return t
	end
end

local function GetEmptySlots(container)
	local emptySlots = {}
	for i, bag in ipairs(getContainerTable(container)) do
		if TSM.getContainerNumSlotsDest(bag) > 0 then
			for slot = 1, TSM.getContainerNumSlotsDest(bag) do
				if not TSM.getContainerItemIDDest(bag, slot) then
					if not emptySlots[bag] then emptySlots[bag] = {}
					end
					table.insert(emptySlots[bag], slot)
				end
			end
		end
	end
	return emptySlots
end

local function GetEmptySlotCount(bag)
	local count = 0
	for slot = 1, TSM.getContainerNumSlotsDest(bag) do
		if not TSM.getContainerItemLinkDest(bag, slot) then
			count = count + 1
		end
	end
	if count ~= 0 then
		return count
	else
		return false
	end
end

local function canGoInBag(itemString, destTable)
	local itemFamily = GetItemFamily(itemString)
	local default
	for _, bag in pairs(destTable) do
		local bagFamily = GetItemFamily(GetBagName(bag)) or 0
		if itemFamily and bagFamily and bagFamily > 0 and bit.band(itemFamily, bagFamily) > 0 then
			if GetEmptySlotCount(bag) then
				return bag
			end
		elseif bagFamily == 0 then
			if GetEmptySlotCount(bag) then
				if not default then
					default = bag
				end
			end
		end
	end
	return default
end

local function findExistingStack(itemLink, dest, quantity, gbank)
	for i, bag in ipairs(getContainerTable(dest)) do
		if gbank then
			if bag == GetCurrentGuildBankTab() then
				for slot = 1, TSM.getContainerNumSlotsDest(bag) do
					if TSM.getContainerItemIDDest(bag, slot) == TSMAPI:GetBaseItemString(itemLink, true) then
						local maxStack = select(8, TSMAPI:GetSafeItemInfo(itemLink))
						local _, currentQuantity = TSM.getContainerItemIDDest(bag, slot)
						if currentQuantity and (currentQuantity + quantity) <= maxStack then
							return bag, slot
						end
					end
				end
			end
		else
			for slot = 1, TSM.getContainerNumSlotsDest(bag) do
				if TSM.getContainerItemIDDest(bag, slot) == TSMAPI:GetBaseItemString(itemLink, true) then
					local maxStack = select(8, TSMAPI:GetSafeItemInfo(itemLink))
					local _, currentQuantity = TSM.getContainerItemIDDest(bag, slot)
					if currentQuantity and (currentQuantity + quantity) <= maxStack then
						return bag, slot
					end
				end
			end
		end
	end
end

local function getTotalItems(src)
	local results = {}
	if src == "bank" then
		for _, _, itemString, quantity in TSMAPI:GetBankIterator(true, true) do
			results[itemString] = (results[itemString] or 0) + quantity
		end

		return results
	elseif src == "guildbank" then
		for bag = 1, GetNumGuildBankTabs() do
			for slot = 1, MAX_GUILDBANK_SLOTS_PER_TAB or 98 do
				local link = GetGuildBankItemLink(bag, slot)
				local itemString = TSMAPI:GetBaseItemString(link, true)
				if itemString then
					local quantity = select(2, GetGuildBankItemInfo(bag, slot))
					results[itemString] = (results[itemString] or 0) + quantity
				end
			end
		end

		return results
	elseif src == "bags" then
		for _, _, itemString, quantity in TSMAPI:GetBagIterator(true, true) do
			results[itemString] = (results[itemString] or 0) + quantity
		end

		return results
	end
end

function TSM.generateMoves(includeSoulbound)
	if not TSM:areBanksVisible() then
		wipe(splitMoves)
		wipe(fullMoves)
		for _, callback in ipairs(callbackMsg) do
			callback(L["Cancelled - You must be at a bank or guildbank"])
		end
		wipe(callbackMsg)
		return
	end

	local next = next
	local bagsFull, bankFull = false, false
	local bagMoves, bankMoves = {}, {}
	wipe(splitMoves)
	wipe(fullMoves)

	local currentBagState = getTotalItems("bags")

	for itemString, quantity in pairs(bagState) do
		local currentQty = currentBagState[itemString] or 0
		if quantity < currentQty then
			bagMoves[itemString] = currentQty - quantity
		elseif quantity > currentQty then
			bankMoves[itemString] = quantity - currentQty
		end
	end

	if next(bagMoves) ~= nil then -- generate moves from bags to bank
		setSrcBagFunctions("bags")
		setDestBagFunctions(bankType)
		for item, _ in pairs(bagMoves) do
			for i, bag in ipairs(getContainerTable("bags")) do
				for slot = 1, TSM.getContainerNumSlotsSrc(bag) do
					local itemLink = TSM.getContainerItemLinkSrc(bag, slot)
					local itemString = TSMAPI:GetBaseItemString(itemLink, true)
					if itemString and itemString == item then
						if not TSMAPI:IsSoulbound(bag, slot) or includeSoulbound then
							local have = TSM.getContainerItemQty(bag, slot)
							local need = bagMoves[itemString]
							if have and need then
								-- check if the source item stack can fit into a destination bag
								local destBag
								if bankType == "guildbank" then
									destBag = findExistingStack(itemLink, bankType, min(have, need), true)
									if not destBag then
										if GetEmptySlotCount(GetCurrentGuildBankTab()) ~= false then
											destBag = GetCurrentGuildBankTab()
										end
									end
								else
									destBag = findExistingStack(itemLink, bankType, min(have, need))
									if not destBag then
										if next(GetEmptySlots(bankType)) ~= nil then
											destBag = canGoInBag(itemString, getContainerTable(bankType))
										end
									end
								end
								if destBag then
									if have > need then
										tinsert(splitMoves, { src = "bags", bag = bag, slot = slot, quantity = need })
										bagMoves[itemString] = nil
									else
										tinsert(fullMoves, { src = "bags", bag = bag, slot = slot, quantity = have })
										bagMoves[itemString] = bagMoves[itemString] - have
										if bagMoves[itemString] <= 0 then
											bagMoves[itemString] = nil
										end
									end
								else
									bankFull = true
								end
							end
						end
					end
				end
			end
		end
	end


	if next(bankMoves) ~= nil then -- generate moves from bank to bags
		setSrcBagFunctions(bankType)
		setDestBagFunctions("bags")
		for item, _ in pairs(bankMoves) do
			for i, bag in ipairs(getContainerTable(bankType)) do
				for slot = 1, TSM.getContainerNumSlotsSrc(bag) do
					local itemLink = TSM.getContainerItemLinkSrc(bag, slot)
					local itemString = TSMAPI:GetBaseItemString(itemLink, true)
					if itemString and itemString == item then
						local have = TSM.getContainerItemQty(bag, slot)
						local need = bankMoves[itemString]
						if have and need then
							if not TSMAPI:IsSoulbound(bag, slot) or includeSoulbound then
								local destBag = findExistingStack(itemLink, "bags", min(have, need)) or canGoInBag(itemString, getContainerTable("bags"))
								if destBag then
									if have > need then
										tinsert(splitMoves, { src = bankType, bag = bag, slot = slot, quantity = need })
										bankMoves[itemString] = nil
									else
										tinsert(fullMoves, { src = bankType, bag = bag, slot = slot, quantity = have })
										bankMoves[itemString] = bankMoves[itemString] - have
										if bankMoves[itemString] <= 0 then
											bankMoves[itemString] = nil
										end
									end
								else
									bagsFull = true
								end
							end
						end
					end
				end
			end
		end
	end

	if next(fullMoves) ~= nil then
		if bankType == "guildbank" then
			TSMAPI:CreateTimeDelay("moveItem", 0.05, TSM.moveItem, 0.35)
		else
			TSMAPI:CreateTimeDelay("moveItem", 0.05, TSM.moveItem, 0.05)
		end
	elseif next(splitMoves) ~= nil then
		if bankType == "guildbank" then
			TSMAPI:CreateTimeDelay("moveSplitItem", 0.05, TSM.moveSplitItem, 0.75)
		else
			TSMAPI:CreateTimeDelay("moveSplitItem", 0.05, TSM.moveSplitItem, 0.4)
		end
	else
		if bagsFull and not bankFull then
			for _, callback in ipairs(callbackMsg) do
				callback(L["Cancelled - Bags are full"])
			end
		elseif bankFull and not bagsFull then
			for _, callback in ipairs(callbackMsg) do
				if bankType == "guildbank" then
					callback(L["Cancelled - Guildbank is full"])
				elseif bankType == "bank" then
					callback(L["Cancelled - Bank is full"])
				else
					callback("Cancelled - " .. bankType .. " is full")
				end
			end
		elseif bagsFull and bankFull then
			for _, callback in ipairs(callbackMsg) do
				if bankType == "guildbank" then
					callback(L["Cancelled - Bags and guildbank are full"])
				elseif bankType == "bank" then
					callback(L["Cancelled - Bags and bank are full"])
				else
					callback("Cancelled - Bags and " .. bankType .. " are full")
				end
			end
		else
			for _, callback in ipairs(callbackMsg) do
				callback(L["Done"])
			end
		end
		wipe(callbackMsg)
	end
end

function TSM.moveItem()
	if not TSM:areBanksVisible() then
		wipe(fullMoves)
		wipe(splitMoves)
		TSMAPI:CancelFrame("moveItem")
		for _, callback in ipairs(callbackMsg) do
			callback(L["Cancelled - You must be at a bank or guildbank"])
		end
		wipe(callbackMsg)
		return
	end

	local next = next
	if #fullMoves > 0 then
		local i = next(fullMoves)
		if fullMoves[i].src == "bags" then
			setSrcBagFunctions("bags")
			setDestBagFunctions(bankType)
			local itemString = TSMAPI:GetBaseItemString(TSM.getContainerItemLinkSrc(fullMoves[i].bag, fullMoves[i].slot), true)
			local itemLink = TSM.getContainerItemLinkSrc(fullMoves[i].bag, fullMoves[i].slot)
			local have = TSM.getContainerItemQty(fullMoves[i].bag, fullMoves[i].slot)
			local need = fullMoves[i].quantity
			if have and need then
				if bankType == "guildbank" then
					if findExistingStack(itemLink, bankType, need, true) then
						TSM.autoStoreItem(fullMoves[i].bag, fullMoves[i].slot)
					elseif GetEmptySlotCount(GetCurrentGuildBankTab()) then
						TSM.autoStoreItem(fullMoves[i].bag, fullMoves[i].slot)
					else
						TSMAPI:CancelFrame("moveItem")
						TSMAPI:CreateTimeDelay("generateMoves", 0.4, TSM.generateMoves)
					end
				else
					if findExistingStack(itemLink, bankType, need) then
						TSM.autoStoreItem(fullMoves[i].bag, fullMoves[i].slot)
					elseif next(GetEmptySlots(bankType)) ~= nil and canGoInBag(itemString, getContainerTable(bankType)) then
						TSM.autoStoreItem(fullMoves[i].bag, fullMoves[i].slot)
					else
						TSMAPI:CancelFrame("moveItem")
						TSMAPI:CreateTimeDelay("generateMoves", 0.4, TSM.generateMoves)
					end
				end
			end
		else
			setSrcBagFunctions(bankType)
			setDestBagFunctions("bags")
			local itemString = TSMAPI:GetBaseItemString(TSM.getContainerItemLinkSrc(fullMoves[i].bag, fullMoves[i].slot), true)
			local itemLink = TSM.getContainerItemLinkSrc(fullMoves[i].bag, fullMoves[i].slot)
			local have = TSM.getContainerItemQty(fullMoves[i].bag, fullMoves[i].slot)
			local need = fullMoves[i].quantity
			if have and need then
				if findExistingStack(itemLink, "bags", need) then
					if bankType == "guildbank" then
						if GetCurrentGuildBankTab() ~= fullMoves[i].bag then
							SetCurrentGuildBankTab(fullMoves[i].bag)
						end
					end
					TSM.autoStoreItem(fullMoves[i].bag, fullMoves[i].slot)
				elseif next(GetEmptySlots("bags")) ~= nil and canGoInBag(itemString, getContainerTable("bags")) then
					if bankType == "guildbank" then
						if GetCurrentGuildBankTab() ~= fullMoves[i].bag then
							SetCurrentGuildBankTab(fullMoves[i].bag)
						end
					end
					TSM.autoStoreItem(fullMoves[i].bag, fullMoves[i].slot)
				else
					TSMAPI:CancelFrame("moveItem")
					TSMAPI:CreateTimeDelay("generateMoves", 0.4, TSM.generateMoves)
				end
			end
		end
		tremove(fullMoves, i)
	else
		TSMAPI:CancelFrame("moveItem")
		TSMAPI:CreateTimeDelay("generateMoves", 0.4, TSM.generateMoves)
	end
end

function TSM.moveSplitItem()
	if not TSM:areBanksVisible() then
		wipe(fullMoves)
		wipe(splitMoves)
		TSMAPI:CancelFrame("moveSplitItem")
		for _, callback in ipairs(callbackMsg) do
			callback(L["Cancelled - You must be at a bank or guildbank"])
		end
		wipe(callbackMsg)
		return
	end
	local next = next
	--if next(moves) ~= nil then
	if #splitMoves > 0 then
		local i = next(splitMoves)
		if splitMoves[i].src == "bags" then
			setSrcBagFunctions("bags")
			setDestBagFunctions(bankType)
			local itemLink = TSM.getContainerItemLinkSrc(splitMoves[i].bag, splitMoves[i].slot)
			local itemString = TSMAPI:GetBaseItemString(itemLink, true)
			local have = TSM.getContainerItemQty(splitMoves[i].bag, splitMoves[i].slot)
			local need = splitMoves[i].quantity
			if have and need then
				local destBag, destSlot
				destBag, destSlot = findExistingStack(itemLink, bankType, need)
				if destBag and destSlot then
					TSM.splitContainerItemSrc(splitMoves[i].bag, splitMoves[i].slot, need)
					TSM.pickupContainerItemDest(destBag, destSlot)
				else
					local emptyBankSlots = GetEmptySlots(bankType)
					destBag = canGoInBag(itemString, getContainerTable(bankType))
					if emptyBankSlots[destBag] then
						destSlot = emptyBankSlots[destBag][1]
					end
					if destBag and destSlot then
						if bankType == "guildbank" then
							if GetCurrentGuildBankTab() ~= destBag then
								SetCurrentGuildBankTab(destBag)
							end
						end
						if GetEmptySlotCount(destBag) then
							TSM.splitContainerItemSrc(splitMoves[i].bag, splitMoves[i].slot, need)
							TSM.pickupContainerItemDest(destBag, destSlot)
						else
							TSMAPI:CancelFrame("moveSplitItem")
							TSMAPI:CreateTimeDelay("generateMoves", 0.4, TSM.generateMoves)
						end
					else
						if next(GetEmptySlots(bankType)) ~= nil then
							TSM.splitContainerItemSrc(splitMoves[i].bag, splitMoves[i].slot, need)
							TSM.pickupContainerItemDest(destBag, destSlot)
						else
							TSMAPI:CancelFrame("moveSplitItem")
							TSMAPI:CreateTimeDelay("generateMoves", 0.4, TSM.generateMoves)
						end
					end
				end
			else
				TSMAPI:CancelFrame("moveSplitItem")
				TSMAPI:CreateTimeDelay("generateMoves", 0.2, TSM.generateMoves)
			end
		else
			setSrcBagFunctions(bankType)
			setDestBagFunctions("bags")
			local itemLink = TSM.getContainerItemLinkSrc(splitMoves[i].bag, splitMoves[i].slot)
			local itemString = TSMAPI:GetBaseItemString(itemLink, true)
			local have = TSM.getContainerItemQty(splitMoves[i].bag, splitMoves[i].slot)
			local need = splitMoves[i].quantity
			if have and need then
				local destBag, destSlot
				destBag, destSlot = findExistingStack(itemLink, "bags", need)
				if destBag and destSlot then
					TSM.splitContainerItemSrc(splitMoves[i].bag, splitMoves[i].slot, need)
					TSM.pickupContainerItemDest(destBag, destSlot)
				else
					local emptyBagSlots = GetEmptySlots("bags")
					destBag = canGoInBag(itemString, getContainerTable("bags"))
					if emptyBagSlots[destBag] then
						destSlot = emptyBagSlots[destBag][1]
					end
					if destBag and destSlot then
						if bankType == "guildbank" then
							if GetCurrentGuildBankTab() ~= splitMoves[i].bag then
								SetCurrentGuildBankTab(splitMoves[i].bag)
							end
						end
						TSM.splitContainerItemSrc(splitMoves[i].bag, splitMoves[i].slot, need)
						TSM.pickupContainerItemDest(destBag, destSlot)
					end
				end
			else
				TSMAPI:CancelFrame("moveSplitItem")
				TSMAPI:CreateTimeDelay("generateMoves", 0.2, TSM.generateMoves)
			end
		end
		tremove(splitMoves, i)
	else
		TSMAPI:CancelFrame("moveSplitItem")
		TSMAPI:CreateTimeDelay("generateMoves", 0.2, TSM.generateMoves)
	end
end

function TSMAPI:MoveItems(requestedItems, callback, includeSoulbound)
	wipe(bagState)

	if callback then
		assert(type(callback) == "function", format("Expected function, got %s.", type(callback)))
		tinsert(callbackMsg, callback)
	end


	bagState = getTotalItems("bags") -- create initial bagstate

	-- iterates over the requested items and adjusts bagState quantities , negative removes from bagState, positive adds to bagState
	-- this gives the final states to generate the moves from
	for itemString, qty in pairs(requestedItems) do
		if not bagState[itemString] then bagState[itemString] = 0
		end
		bagState[itemString] = bagState[itemString] + qty
		if bagState[itemString] < 0 then
			bagState[itemString] = 0
		end
	end

	TSMAPI:CreateTimeDelay("generateMoves", 0.2, TSM.generateMoves(includeSoulbound))
end

function TSM:areBanksVisible()
	if BagnonFrameguildbank and BagnonFrameguildbank:IsVisible() then
		return true
	elseif BagnonFramebank and BagnonFramebank:IsVisible() then
		return true
	elseif GuildBankFrame and GuildBankFrame:IsVisible() then
		return true
	elseif BankFrame and BankFrame:IsVisible() then
		return true
	elseif (ARKINV_Frame4 and ARKINV_Frame4:IsVisible()) or (ARKINV_Frame3 and ARKINV_Frame3:IsVisible()) then
		return true
	elseif (BagginsBag8 and BagginsBag8:IsVisible()) or (BagginsBag9 and BagginsBag9:IsVisible()) or (BagginsBag10 and BagginsBag10:IsVisible()) or (BagginsBag11 and BagginsBag11:IsVisible()) or (BagginsBag12 and BagginsBag12:IsVisible()) then
		return true
	elseif (CombuctorFrame2 and CombuctorFrame2:IsVisible()) then
		return true
	elseif (BaudBagContainer2_1 and BaudBagContainer2_1:IsVisible()) then
		return true
	elseif (AdiBagsContainer2 and AdiBagsContainer2:IsVisible()) then
		return true
	elseif (OneBankFrame and OneBankFrame:IsVisible()) then
		return true
	elseif (EngBank_frame and EngBank_frame:IsVisible()) then
		return true
	elseif (TBnkFrame and TBnkFrame:IsVisible()) then
		return true
	elseif (famBankFrame and famBankFrame:IsVisible()) then
		return true
	elseif (LUIBank and LUIBank:IsVisible()) then
		return true
	elseif (ElvUI_BankContainerFrame and ElvUI_BankContainerFrame:IsVisible()) then
		return true
	elseif (TukuiBank and TukuiBank:IsShown()) then
		return true
	elseif (AdiBagsContainer1 and AdiBagsContainer1.isBank and AdiBagsContainer1:IsVisible()) or (AdiBagsContainer2 and AdiBagsContainer2.isBank and AdiBagsContainer2:IsVisible()) then
		return true
	elseif BagsFrameBank and BagsFrameBank:IsVisible() then
		return true
	elseif AspUIBank and AspUIBank:IsVisible() then
		return true
	elseif NivayacBniv_Bank and NivayacBniv_Bank:IsVisible() then
		return true
	elseif DufUIBank and DufUIBank:IsVisible() then
		return true
	end
	return nil
end