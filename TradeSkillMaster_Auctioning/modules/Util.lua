-- ------------------------------------------------------------------------------ --
--                           TradeSkillMaster_Auctioning                          --
--           http://www.curse.com/addons/wow/tradeskillmaster_auctioning          --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

local TSM = select(2, ...)
local Util = TSM:NewModule("Util")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster_Auctioning") -- loads the localization table

local currentBank = nil
local bFrame = nil
local buttonFrame = nil
local groupTree = nil

function Util:OnEnable()

	TSM:RegisterEvent("GUILDBANKFRAME_OPENED", function(event)
		currentBank = "guildbank"
	end)

	TSM:RegisterEvent("BANKFRAME_OPENED", function(event)
		currentBank = "bank"
	end)

	TSM:RegisterEvent("GUILDBANKFRAME_CLOSED", function(event, addon)
		currentBank = nil
	end)

	TSM:RegisterEvent("BANKFRAME_CLOSED", function(event)
		currentBank = nil
	end)
end

local function GetItemPrice(operationPrice, itemString)
	local func = TSMAPI:ParseCustomPrice(operationPrice)
	local price = func and func(itemString)
	return price ~= 0 and price or nil
end

function Util:GetItemPrices(operation, itemString, isResetScan)
	local prices = {}
	prices.undercut = GetItemPrice(operation.undercut, itemString)
	prices.minPrice = GetItemPrice(operation.minPrice, itemString)
	prices.maxPrice = GetItemPrice(operation.maxPrice, itemString)
	prices.normalPrice = GetItemPrice(operation.normalPrice, itemString)
	prices.cancelRepostThreshold = GetItemPrice(operation.cancelRepostThreshold, itemString)
	if isResetScan then
		prices.resetMaxCost = GetItemPrice(operation.resetMaxCost, itemString)
		prices.resetMinProfit = GetItemPrice(operation.resetMinProfit, itemString)
		prices.resetResolution = GetItemPrice(operation.resetResolution, itemString)
		prices.resetMaxItemCost = GetItemPrice(operation.resetMaxItemCost, itemString)
	end
	if TSM.db.global.roundNormalPrice and prices.normalPrice then
		prices.normalPrice = ceil(prices.normalPrice / COPPER_PER_GOLD) * COPPER_PER_GOLD
	end
	prices.resetPrice = operation.priceReset ~= "none" and operation.priceReset ~= "ignore" and prices[operation.priceReset]
	prices.aboveMax = operation.aboveMax ~= "none" and prices[operation.aboveMax]
	return prices
end

local function createButton(text, parent, func)
	local btn = TSMAPI.GUI:CreateButton(bFrame, 15, "Button")
	btn:SetText(text)
	btn:SetHeight(17)
	btn:SetWidth(230)
	return btn
end

function Util:createTab(parent)

	bFrame = CreateFrame("Frame", nil, parent)
	--TSMAPI.Design:SetFrameColor(bFrame)
	bFrame:Hide()

	--size--
	bFrame:SetAllPoints()

	--GroupTree--
	local tFrame = CreateFrame("Frame", nil, bFrame)
	tFrame:SetPoint("TOPLEFT", 0, -5)
	tFrame:SetPoint("TOPRIGHT", 0, -5)
	tFrame:SetPoint("BOTTOMLEFT", 0, 120)
	tFrame:SetPoint("BOTTOMRIGHT", 0, 120)

	groupTree = TSMAPI:CreateGroupTree(tFrame, "Auctioning", "Auctioning_Bank")
	groupTree:SetPoint("TOPLEFT", 5, -5)
	groupTree:SetPoint("BOTTOMRIGHT", -5, 5)

	--Buttons--
	buttonFrame = CreateFrame("Frame", nil, bFrame)
	buttonFrame:SetPoint("TOPLEFT", 0, -330)
	buttonFrame:SetPoint("TOPRIGHT", 0, -330)
	buttonFrame:SetPoint("BOTTOMLEFT")
	buttonFrame:SetPoint("BOTTOMRIGHT")

	buttonFrame.btnToBank = createButton(L["Move Group To Bank"], buttonFrame, nil)
	buttonFrame.btnToBank:SetPoint("BOTTOM", buttonFrame, "BOTTOM", 0, 95)

	buttonFrame.btnNonGroup = createButton(L["Move Non Group Items to Bank"], buttonFrame, nil)
	buttonFrame.btnNonGroup:SetPoint("BOTTOM", buttonFrame, "BOTTOM", 0, 75)

	buttonFrame.btnToBags = createButton(L["Move Post Cap To Bags"], buttonFrame, nil)
	buttonFrame.btnToBags:SetPoint("BOTTOM", buttonFrame, "BOTTOM", 0, 45)

	buttonFrame.btnAHToBags = createButton(L["Move AH Shortfall To Bags"], buttonFrame, nil)
	buttonFrame.btnAHToBags:SetPoint("BOTTOM", buttonFrame, "BOTTOM", 0, 25)

	buttonFrame.btnAllToBags = createButton(L["Move Group To Bags"], buttonFrame, nil)
	buttonFrame.btnAllToBags:SetPoint("BOTTOM", buttonFrame, "BOTTOM", 0, 5)

	Util:updateButtons()

	return bFrame
end

function Util:updateButtons()
	------------------
	-- Move to Bank --
	------------------
	buttonFrame.btnToBank:SetScript("OnClick", function(self)
		Util:groupTree(groupTree:GetSelectedGroupInfo(), "bags")
	end)

	-----------------------------------
	-- Move Non Group Items to Bank  --
	-----------------------------------
	buttonFrame.btnNonGroup:SetScript("OnClick", function(self)
		Util:nonGroupTree(groupTree:GetSelectedGroupInfo(), "bags")
	end)

	----------------------------
	-- Move Post Cap to Bags  --
	----------------------------
	buttonFrame.btnToBags:SetScript("OnClick", function(self)
		Util:groupTree(groupTree:GetSelectedGroupInfo(), currentBank)
	end)

	--------------------------------
	-- Move AH Shortfall to Bags  --
	--------------------------------
	buttonFrame.btnAHToBags:SetScript("OnClick", function(self)
		Util:groupTree(groupTree:GetSelectedGroupInfo(), currentBank, false, true)
	end)


	----------------------------
	-- Move All to Bags  --
	----------------------------
	buttonFrame.btnAllToBags:SetScript("OnClick", function(self)
		Util:groupTree(groupTree:GetSelectedGroupInfo(), currentBank, true)
	end)
end

function Util:groupTree(grpInfo, src, all, ah)
	local next = next
	local newgrp = {}
	local totalItems = Util:getTotalItems(src)
	local bagItems = Util:getTotalItems("bags") or {}
	for groupName, data in pairs(grpInfo) do
		groupName = TSMAPI:FormatGroupPath(groupName, true)
		for _, opName in ipairs(data.operations) do
			TSMAPI:UpdateOperation("Auctioning", opName)
			local opSettings = TSM.operations[opName]

			if not opSettings then
				-- operation doesn't exist anymore in Auctioning
				TSM:Printf(L["'%s' has an Auctioning operation of '%s' which no longer exists."], groupName, opName)
			else
				--it's a valid operation
				for itemString in pairs(data.items) do
					local totalq = 0
					local usedq = 0
					local maxPost = opSettings.stackSize * opSettings.postCap

					if totalItems then
						totalq = totalItems[itemString] or 0
					end

					if src == "bags" then -- move them all back to bank/gbank
						if totalq > 0 then
							newgrp[itemString] = totalq * -1
							totalItems[itemString] = nil -- remove the current bag count in case we loop round for another operation
						end
					else -- move from bank/gbank to bags
						if totalq > 0 then
							if all then
								newgrp[itemString] = totalq
								totalq = 0
							else
								local quantity = maxPost - (bagItems[itemString] or 0)
								newgrp[itemString] = (newgrp[itemString] or 0) + quantity
								totalq = totalq - quantity -- remove this operations qty to move from source quantity in case we loop again for another operation
								if bagItems[itemString] then --remove this operations maxPost quantity from the bag total in case we loop again for another operation
									bagItems[itemString] = bagItems[itemString] - maxPost
									if bagItems[itemString] <= 0 then
										bagItems[itemString] = nil
									end
								end
							end
						end
					end
				end
			end
		end
	end

	if src ~= "bags" and ah then -- remove ah/mail quantities from the total to move
		local playermail = TSMAPI:ModuleAPI("ItemTracker", "playermail")
		local playerauctions = TSMAPI:ModuleAPI("ItemTracker", "playerauctions")
		for itemString in pairs(newgrp) do
			if playerauctions then
				newgrp[itemString] = newgrp[itemString] - (playerauctions[itemString] or 0)
			end
			if playermail then
				newgrp[itemString] = newgrp[itemString] - (playermail[itemString] or 0)
			end
			if newgrp[itemString] < 0 then
				newgrp[itemString] = nil
			end
		end
	end

	if next(newgrp) == nil then
		TSM:Print(L["Nothing to Move"])
	else
		TSM:Print(L["Preparing to Move"])
		TSMAPI:MoveItems(newgrp, TSM.PrintMsg)
	end
end

function Util:nonGroupTree(grpInfo, src)
	local next = next
	local newgrp = {}
	local bagItems = Util:getTotalItems("bags")
	for groupName, data in pairs(grpInfo) do
		groupName = TSMAPI:FormatGroupPath(groupName, true)
		for _, opName in ipairs(data.operations) do
			TSMAPI:UpdateOperation("Auctioning", opName)
			local opSettings = TSM.operations[opName]

			if not opSettings then
				-- operation doesn't exist anymore in Auctioning
				TSM:Printf(L["'%s' has an Auctioning operation of '%s' which no longer exists."], groupName, opName)
			else
				-- it's a valid operation so remove all the items from bagItems so we are left with non group items to move
				for itemString in pairs(data.items) do
					if bagItems then
						if bagItems[itemString] then
							bagItems[itemString] = nil
						end
					end
				end
			end
		end
	end


	for itemString, quantity in pairs(bagItems) do
		quantity = quantity * -1
		if newgrp[itemString] then
			newgrp[itemString] = newgrp[itemString] + quantity
		else
			newgrp[itemString] = quantity
		end
	end

	if next(newgrp) == nil then
		TSM:Print(L["Nothing to Move"])
	else
		TSM:Print(L["Preparing to Move"])
		TSMAPI:MoveItems(newgrp, TSM.PrintMsg)
	end
end

function TSM.PrintMsg(message)
	TSM:Print(message)
end

function Util:getTotalItems(src)
	local results = {}
	if src == "bank" then
		local function ScanBankBag(bag)
			for slot = 1, GetContainerNumSlots(bag) do
				if not TSMAPI:IsSoulbound(bag, slot) then
					local itemString = TSMAPI:GetBaseItemString(GetContainerItemLink(bag, slot), true)
					if itemString then
						local quantity = select(2, GetContainerItemInfo(bag, slot))
						if not results[itemString] then results[itemString] = 0 end
						results[itemString] = results[itemString] + quantity
					end
				end
			end
		end

		for bag = NUM_BAG_SLOTS + 1, NUM_BAG_SLOTS + NUM_BANKBAGSLOTS do
			ScanBankBag(bag)
		end
		ScanBankBag(-1)

		return results
	elseif src == "guildbank" then
		for bag = 1, GetNumGuildBankTabs() do
			for slot = 1, MAX_GUILDBANK_SLOTS_PER_TAB or 98 do
				local link = GetGuildBankItemLink(bag, slot)
				local itemString = TSMAPI:GetBaseItemString(link, true)
				if itemString then
					local quantity = select(2, GetGuildBankItemInfo(bag, slot))
					if not results[itemString] then results[itemString] = 0 end
					results[itemString] = results[itemString] + quantity
				end
			end
		end

		return results
	elseif src == "bags" then
		for bag, slot, itemString, quantity, locked in TSMAPI:GetBagIterator(true) do
			if currentBank == "guildbank" then
				if not TSMAPI:IsSoulbound(bag, slot) then
					results[itemString] = (results[itemString] or 0) + quantity
				end
			else
				results[itemString] = (results[itemString] or 0) + quantity
			end
		end
	end
	return results
end