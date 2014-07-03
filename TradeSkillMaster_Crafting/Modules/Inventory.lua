-- ------------------------------------------------------------------------------ --
--                            TradeSkillMaster_Crafting                           --
--            http://www.curse.com/addons/wow/tradeskillmaster_crafting           --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- load the parent file (TSM) into a local variable and register this file as a module
local TSM = select(2, ...)
local Inventory = TSM:NewModule("Inventory", "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster_Crafting") -- loads the localization table


-- gets the number of an item in the current player's bags
function Inventory:GetPlayerBagNum(itemString)
	if not itemString then return end

	if TSMAPI.SOULBOUND_MATS[itemString] then
		return GetItemCount(itemString)
	else
		local bags = TSMAPI:ModuleAPI("ItemTracker", "playerbags", UnitName("player")) or {}
		return bags and bags[itemString] or 0
	end
end

function Inventory:GetTotals()
	local bagTotal, auctionTotal, otherTotal, total = {}, {}, {}, {}

	for _, player in pairs(TSMAPI:ModuleAPI("ItemTracker", "playerlist") or {}) do
		if player == UnitName("player") or not TSM.db.global.ignoreCharacters[player] then
			local bags = TSMAPI:ModuleAPI("ItemTracker", "playerbags", player) or {}
			local bank = TSMAPI:ModuleAPI("ItemTracker", "playerbank", player) or {}
			local mail = TSMAPI:ModuleAPI("ItemTracker", "playermail", player) or {}
			local auctions = TSMAPI:ModuleAPI("ItemTracker", "playerauctions", player) or {}
			for itemString, quantity in pairs(bags) do
				if player == UnitName("player") then
					bagTotal[itemString] = (bagTotal[itemString] or 0) + quantity
					total[itemString] = (total[itemString] or 0) + quantity
				else
					otherTotal[itemString] = (otherTotal[itemString] or 0) + quantity
					total[itemString] = (total[itemString] or 0) + quantity
				end
			end
			for itemString, quantity in pairs(bank) do
				otherTotal[itemString] = (otherTotal[itemString] or 0) + quantity
				total[itemString] = (total[itemString] or 0) + quantity
			end
			for itemString, quantity in pairs(mail) do
				otherTotal[itemString] = (otherTotal[itemString] or 0) + quantity
				total[itemString] = (total[itemString] or 0) + quantity
			end
			for itemString, quantity in pairs(auctions) do
				auctionTotal[itemString] = (auctionTotal[itemString] or 0) + quantity
				total[itemString] = (total[itemString] or 0) + quantity
			end
		end
	end

	for itemString in pairs(TSMAPI.SOULBOUND_MATS) do
		local bagNum = GetItemCount(itemString)
		local bankNum = GetItemCount(itemString, true) - GetItemCount(itemString)
		bagTotal[itemString] = (bagTotal[itemString] or 0) + bagNum
		otherTotal[itemString] = (otherTotal[itemString] or 0) + bankNum
		total[itemString] = (total[itemString] or 0) + bagNum + bankNum
	end

	-- add gbank counts of all non-ignored guilds
	for _, guild in pairs(TSMAPI:ModuleAPI("ItemTracker", "guildlist") or {}) do
		if not TSM.db.global.ignoreGuilds[guild] then
			local gbank = TSMAPI:ModuleAPI("ItemTracker", "guildbank", guild) or {}
			for itemString, quantity in pairs(gbank) do
				otherTotal[itemString] = (otherTotal[itemString] or 0) + quantity
				total[itemString] = (total[itemString] or 0) + quantity
			end
		end
	end
	return bagTotal, auctionTotal, otherTotal, total
end

-- gets the total number of some item that they have
function Inventory:GetTotalQuantity(itemString)
	if not itemString then return 0 end
	local count = 0

	-- add bags/bank/mail/auction counts of all non-ignored characters (always including current character)
	for _, player in pairs(TSMAPI:ModuleAPI("ItemTracker", "playerlist") or {}) do
		if player == UnitName("player") or not TSM.db.global.ignoreCharacters[player] then
			local bags = TSMAPI:ModuleAPI("ItemTracker", "playerbags", player) or {}
			local bank = TSMAPI:ModuleAPI("ItemTracker", "playerbank", player) or {}
			local mail = TSMAPI:ModuleAPI("ItemTracker", "playermail", player) or {}
			local auctions = TSMAPI:ModuleAPI("ItemTracker", "playerauctions", player) or {}
			count = count + (bags[itemString] or 0)
			count = count + (bank[itemString] or 0)
			count = count + (mail[itemString] or 0)
			count = count + (auctions[itemString] or 0)
		end
	end
	-- add gbank counts of all non-ignored guilds
	for _, guild in pairs(TSMAPI:ModuleAPI("ItemTracker", "guildlist") or {}) do
		if not TSM.db.global.ignoreGuilds[guild] then
			local bank = TSMAPI:ModuleAPI("ItemTracker", "guildbank", guild) or {}
			count = count + (bank[itemString] or 0)
		end
	end

	if TSMAPI.SOULBOUND_MATS[itemString] then
		count = count + GetItemCount(itemString, true)
	end

	return count
end

function Inventory:GetItemSources(crafter, neededMats)
	if not neededMats then return end
	local sources = {}
	local gbank = {}
	local next = next
	local crafterBags = TSMAPI:ModuleAPI("ItemTracker", "playerbags", crafter) or {}
	local crafterMail = TSMAPI:ModuleAPI("ItemTracker", "playermail", crafter) or {}
	local crafterBank = TSMAPI:ModuleAPI("ItemTracker", "playerbank", crafter) or {}

	-- add vendor items
	local task = {}
	local items = {}
	for itemString, quantity in pairs(neededMats) do
		if TSMAPI:GetVendorCost(itemString) then
			local vendorNeed = quantity - ((crafterBags[itemString] or 0) + (crafterMail[itemString] or 0) + (crafterBank[itemString] or 0))
			if vendorNeed > 0 then
				items[itemString] = vendorNeed
			end
		elseif TSMAPI.Conversions[itemString] and TSMAPI.InkConversions[itemString] then
			local tradeItem, data = next(TSMAPI.Conversions[itemString])
			if data.source == "vendortrade" then
				local num = floor(Inventory:GetTotalQuantity(tradeItem) * data.rate)
				if quantity > Inventory:GetTotalQuantity(itemString) and num >= (quantity - Inventory:GetTotalQuantity(itemString)) then
					items[itemString] = quantity - Inventory:GetTotalQuantity(itemString)
					neededMats[tradeItem] = (neededMats[tradeItem] or 0) + quantity / data.rate -- add the qty of IOD to needed mats
				end
			end
		end
	end
	if next(items) then
		tinsert(task, { taskType = L["Visit Vendor"], items = items })
		tinsert(sources, { sourceName = L["Vendor"], isCrafter = false, isVendor = true, isAH = false, tasks = task })
	end

	-- double check if crafter already has all the items needed
	local shortItems = {}
	for itemString, quantity in pairs(neededMats) do
		local soulboundBagCount
		if TSMAPI.SOULBOUND_MATS[itemString] then
			soulboundBagCount = GetItemCount(itemString)
		end
		local need = max(quantity - (crafterBags[itemString] or soulboundBagCount or 0), 0)
		if need > 0 then
			shortItems[itemString] = need
		end
	end
	if not next(shortItems) then return end

	-- add bags/bank/mail "tasks" for needed items of all non-ignored characters (always include crafter)
	for _, player in pairs(TSMAPI:ModuleAPI("ItemTracker", "playerlist") or {}) do
		if player == crafter or not TSM.db.global.ignoreCharacters[player] then
			local task = {}
			local bags = TSMAPI:ModuleAPI("ItemTracker", "playerbags", player) or {}
			local bank = TSMAPI:ModuleAPI("ItemTracker", "playerbank", player) or {}
			local guild = TSMAPI:ModuleAPI("ItemTracker", "playerguild", player) or {}
			local gbank = {}
			if guild and not TSM.db.global.ignoreGuilds[guild] then
				gbank = TSMAPI:ModuleAPI("ItemTracker", "guildbank", guild) or {}
			end
			local mail = TSMAPI:ModuleAPI("ItemTracker", "playermail", player) or {}
			local bankItems = {}
			local gbankItems = {}
			local mailItems = {}
			local bagItems = {}

			for itemString in pairs(neededMats) do
				local soulboundBagCount, soulboundBankCount
				if TSMAPI.SOULBOUND_MATS[itemString] then
					soulboundBagCount = GetItemCount(itemString)
					soulboundBankCount = GetItemCount(itemString, true) - soulboundBagCount
				end
				if (bank[itemString] or (soulboundBankCount and soulboundBankCount > 0)) and shortItems[itemString] then
					if shortItems[itemString] - (crafterMail[itemString] or 0) - (player ~= crafter and bags[itemString] or 0) > 0 then
						bankItems[itemString] = bank[itemString] or soulboundBankCount
					end
				end
				if gbank[itemString] and shortItems[itemString] then
					if shortItems[itemString] - (crafterMail[itemString] or 0) - (player ~= crafter and bags[itemString] or 0) > 0 then
						gbankItems[itemString] = gbank[itemString]
					end
				end
				if mail[itemString] and shortItems[itemString] then
					mailItems[itemString] = mail[itemString]
				end
				if bags[itemString] and shortItems[itemString] then
					if player ~= crafter then
						if shortItems[itemString] - (crafterMail[itemString] or 0) > 0 then
							bagItems[itemString] = bags[itemString]
						end
					end
				end
			end
			-- add mail tasks for destroyable items bought through shopping search (exclude items already added to mail tasks)
			for itemString, quantity in pairs(TSM.db.factionrealm.gathering.destroyingMats) do
				if mail[itemString] and not shortItems[itemString] then
					mailItems[itemString] = quantity
				end
			end

			if next(bankItems) then
				tinsert(task, { taskType = L["Visit Bank"], items = bankItems })
			end
			if next(gbankItems) then
				tinsert(task, { taskType = L["Visit Guild Bank"], items = gbankItems })
			end
			if next(mailItems) then
				tinsert(task, { taskType = L["Collect Mail"], items = mailItems })
			end
			if next(bagItems) then
				tinsert(task, { taskType = L["Mail Items"], items = bagItems })
			end
			if next(task) then
				tinsert(sources, { sourceName = player, isCrafter = player == crafter, isVendor = false, isAH = false, tasks = task, isCurrent = (player == UnitName("player")) })
			end
		end
	end

	-- add auction house tasks
	local auctionTask = {}
	local auctionItems = {}
	for itemString, quantity in pairs(neededMats) do
		if not TSMAPI.SOULBOUND_MATS[itemString] and not TSMAPI:GetVendorCost(itemString) then
			local need
			if TSM.Inventory.gatherItem == itemString and TSM.Inventory.gatherQuantity then
				need = TSM.Inventory.gatherQuantity
			else
				need = max(quantity - (TSM.Inventory:GetTotalQuantity(itemString) or 0), 0)
			end
			if need > 0 then
				auctionItems[itemString] = need
			end
		end
	end
	if next(auctionItems) then
		tinsert(auctionTask, { taskType = L["Search for Mats"], items = auctionItems })
		tinsert(sources, { sourceName = L["Auction House"], isCrafter = false, isVendor = false, isAH = true, tasks = auctionTask })
	end

	-- add destroying tasks
	local destroyingTask, millItems, prospectItems, transformItems, deItems = {}, {}, {}, {}, {}

	for itemString, quantity in pairs(neededMats) do
		local need = max(quantity - (TSM.Inventory:GetTotalQuantity(itemString) or 0), 0)
		-- conversion items
		for destroyItem, data in pairs(TSMAPI.Conversions[itemString] or {}) do
			if TSM.db.factionrealm.gathering.destroyingMats[destroyItem] then
				if need > 0 then
					local destroyNeed
					if data.source == "mill" then
						destroyNeed = floor(TSM.db.factionrealm.gathering.destroyingMats[destroyItem] / 5)
						if destroyNeed > 0 then
							millItems[destroyItem] = (millItems[destroyItem] or 0) + destroyNeed
						end
					elseif data.source == "prospect" then
						destroyNeed = floor(TSM.db.factionrealm.gathering.destroyingMats[destroyItem] / 5)
						if destroyNeed > 0 then
							prospectItems[destroyItem] = (prospectItems[destroyItem] or 0) + destroyNeed
						end
					elseif data.source == "transform" then
						if data.rate == 1 / 3 then
							destroyNeed = floor(TSM.db.factionrealm.gathering.destroyingMats[destroyItem] / 3)
						elseif data.rate == 1 / 10 then
							destroyNeed = floor(TSM.db.factionrealm.gathering.destroyingMats[destroyItem] / 10)
						else
							destroyNeed = TSM.db.factionrealm.gathering.destroyingMats[destroyItem]
						end
						if destroyNeed > 0 then
							transformItems[destroyItem] = (transformItems[destroyItem] or 0) + destroyNeed
						end
					end
				else
					TSM.db.factionrealm.gathering.destroyingMats[destroyItem] = nil
				end
			end
		end
		-- disenchantable items
		if next(TSM.db.factionrealm.gathering.destroyingMats) then
			for deItemString, quantity in pairs(TSM.db.factionrealm.gathering.destroyingMats) do
				if Inventory:IsDisenchantable(deItemString) then
					if need > 0 then
						deItems[deItemString] = quantity
					else
						TSM.db.factionrealm.gathering.destroyingMats[deItemString] = nil
					end
				end
			end
		end
	end

	if next(millItems) then
		tinsert(destroyingTask, { taskType = L["Milling"], items = millItems })
	end
	if next(prospectItems) then
		tinsert(destroyingTask, { taskType = L["Prospect"], items = prospectItems })
	end
	if next(transformItems) then
		tinsert(destroyingTask, { taskType = L["Transform"], items = transformItems })
	end
	if next(deItems) then
		tinsert(destroyingTask, { taskType = L["Disenchant"], items = deItems })
	end
	if next(destroyingTask) then
		tinsert(sources, { sourceName = L["Destroying"], isCrafter = false, isVendor = false, isAH = true, tasks = destroyingTask })
	end


	sort(sources, function(a, b)
		if a.isCurrent then return true end
		if b.isCurrent then return false end
		if a.isAH then return false end
		if b.isAH then return true end
		if a.isVendor then return false end
		if b.isVendor then return true end
		if a.isCrafter then return false end
		if b.isCrafter then return true end
		return a.sourceName < b.sourceName
	end)
	return sources
end

function Inventory:IsDisenchantable(itemString)
	local _, link, quality, _, _, iType = TSMAPI:GetSafeItemInfo(itemString)
	local WEAPON, ARMOR = GetAuctionItemClasses()
	if itemString and not TSMAPI.DisenchantingData.notDisenchantable[itemString] and (iType == ARMOR or iType == WEAPON) then
		return true
	end
end
