-- ------------------------------------------------------------------------------ --
--                          TradeSkillMaster_Warehousing                          --
--          http://www.curse.com/addons/wow/tradeskillmaster_warehousing          --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- loads the localization table --
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster_Warehousing")

-- load the parent file (TSM) into a local variable and register this file as a module
local TSM = select(2, ...)
local data = TSM:NewModule("data", "AceEvent-3.0")
local AceGUI = LibStub("AceGUI-3.0") -- load the AceGUI librarie

----------------------------------
-- Generates the Bagstate table --
----------------------------------
function data:getEmptyRestoreGroup(container, isGuildBank)
	TSM.util:setSrcBagFunctions("bags")
	local tmp = {}
	local grp = {}
	local restore = {}

	for i, bagid in ipairs(container) do
		for slotid = 1, TSM.util.getContainerNumSlotsSrc(bagid) do
			local id, quan = TSM.util.getContainerItemIDSrc(bagid, slotid)
			if id then
				if not isGuildBank or not TSMAPI:IsSoulbound(bagid, slotid) then
					if not tmp[id] then tmp[id] = 0 end
					tmp[id] = tmp[id] + quan
				end --end if
			end --end if id
		end --end for slots
	end --end for bags

	for i, q in pairs(tmp) do
		grp[i] = q * -1 -- convert to negative number for TSMAPI:MoveItems
		restore[i] = q -- for the restore bagstate
	end
	TSM.db.factionrealm.BagState = restore
	return grp
end

function data:unIndexMoveGroupTree(grpInfo, src)
	local newgrp = {}
	local totalItems = data:getTotalItems(src)
	for groupName, info in pairs(grpInfo) do
		groupName = TSMAPI:FormatGroupPath(groupName, true)
		for _, opName in ipairs(info.operations) do
			TSMAPI:UpdateOperation("Warehousing", opName)
			local opSettings = TSM.operations[opName]
			if not opSettings then
				-- operation doesn't exist anymore in Crafting
				TSM:Printf(L["'%s' has a Warehousing operation of '%s' which no longer exists."], groupName, opName)
			else
				-- it's a valid operation
				for itemString in pairs(info.items) do
					itemString = TSMAPI:GetItemString(itemString)
					local totalq = 0
					if totalItems then
						totalq = totalItems[itemString] or 0
					end

					if src == "bags" then -- if moving from bags to bank/gbank
						if opSettings.moveQtyEnabled and opSettings.keepBagQtyEnabled then -- move specified quantity but keep x in bags
							local q = (totalq - opSettings.keepBagQuantity)
							if q > 0 then
								--newgrp[itemString] = min(tonumber(q), tonumber(opSettings.moveQuantity))
								newgrp[itemString] = max(tonumber(q * -1), tonumber(opSettings.moveQuantity * -1))
							end
						elseif opSettings.moveQtyEnabled then -- move specified quantity
							newgrp[itemString] = tonumber(opSettings.moveQuantity * -1)
						elseif opSettings.keepBagQtyEnabled then -- move all but keep x in bags
							local q = totalq - opSettings.keepBagQuantity
							if q > 0 then
								newgrp[itemString] = tonumber(q * -1)
							end
						else -- move everything
							if totalq > 0 then
								newgrp[itemString] = tonumber(totalq * -1)
							end
						end
					else -- move from bank/gbank to bags
						local stacksize = 1
						if opSettings.stackSizeEnabled and opSettings.stackSize then -- only move in multiples of the stack size set
							stacksize = opSettings.stackSize
							end
						if opSettings.moveQtyEnabled and opSettings.keepBankQtyEnabled then -- move specified quantity but keep x in bank
							local q = (totalq - opSettings.keepBankQuantity)
							if q > 0 then
								newgrp[itemString] = floor(min(tonumber(q), tonumber(opSettings.moveQuantity)) / tonumber(stacksize)) * tonumber(stacksize)
							end
						elseif opSettings.moveQtyEnabled then -- move specified quantity
							newgrp[itemString] = floor(tonumber(opSettings.moveQuantity) / tonumber(stacksize)) * tonumber(stacksize)
						elseif opSettings.keepBankQtyEnabled then -- move all but keep x in bank
							local q = totalq - opSettings.keepBankQuantity
							if q > 0 then
								newgrp[itemString] = floor(tonumber(q) / tonumber(stacksize)) * tonumber(stacksize)
							end
						else -- move everything
							if totalq > 0 then
								newgrp[itemString] = floor(tonumber(totalq) / tonumber(stacksize)) * tonumber(stacksize)
							end
						end
					end
				end
			end
		end
	end
	return newgrp
end

function data:unIndexRestockGroupTree(grpInfo)
	local newgrp = {}
	local totalItems = data:getTotalItems("bags")
	for groupName, info in pairs(grpInfo) do
		groupName = TSMAPI:FormatGroupPath(groupName, true)
		for _, opName in ipairs(info.operations) do
			TSMAPI:UpdateOperation("Warehousing", opName)
			local opSettings = TSM.operations[opName]
			if not opSettings then
				-- operation doesn't exist anymore in Crafting
				TSM:Printf(L["'%s' has a Warehousing operation of '%s' which no longer exists."], groupName, opName)
			else
				-- it's a valid operation
				for itemString in pairs(info.items) do
					local totalq = 0
					if totalItems then
						totalq = totalItems[itemString] or 0
					end
					if opSettings.restockQtyEnabled then -- work out qty to add or remove from bags
						local q = opSettings.restockQuantity - totalq
						if q ~= 0 then
							newgrp[itemString] = tonumber(q)
						end
					end
				end
			end
		end
	end
	return newgrp
end

function data:unIndexItem(searchString, src, quantity)
	local newgrp = {}
	local totalItems = data:getTotalItems(src) -- table of itemstrings and total qty in source

	if totalItems then
		local matchedString = TSMAPI:GetBaseItemString(TSMAPI:GetItemString(searchString))
		if matchedString then
			for itemString, totalQty in pairs(totalItems) do
				if TSMAPI:GetBaseItemString(itemString) == matchedString then
					if quantity then
						if src == "bags" then
							newgrp[itemString] = tonumber(quantity * -1)
						else
							newgrp[itemString] = tonumber(quantity)
						end
					else
						if src == "bags" then
							newgrp[itemString] = tonumber(totalQty * -1)
						else
							newgrp[itemString] = tonumber(totalQty)
						end
					end
				end
			end
		else
			for itemString, totalQty in pairs(totalItems) do
				local name = strlower(TSMAPI:GetSafeItemInfo(itemString))
				if strfind(name, strlower(searchString)) then
					if quantity then
						if src == "bags" then
							newgrp[itemString] = tonumber(quantity * -1)
						else
							newgrp[itemString] = tonumber(quantity)
						end
					else
						if src == "bags" then
							newgrp[itemString] = tonumber(totalQty * -1)
						else
							newgrp[itemString] = tonumber(totalQty)
						end
					end
				end
			end
		end
	end
	return newgrp
end

function data:getTotalItems(src)
	local results = {}
	if src == "bank" then
		local function ScanBankBag(bag)
			for slot = 1, GetContainerNumSlots(bag) do
				local itemString = TSMAPI:GetBaseItemString(GetContainerItemLink(bag, slot), true)
				if itemString then
					local quantity = select(2, GetContainerItemInfo(bag, slot))
					if not results[itemString] then results[itemString] = 0 end
					results[itemString] = results[itemString] + quantity
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
		for _, _, itemString, quantity in TSMAPI:GetBagIterator(true) do
			results[itemString] = (results[itemString] or 0) + quantity
		end

		return results
	end
end