-- ------------------------------------------------------------------------------ --
--                                TradeSkillMaster                                --
--          http://www.curse.com/addons/wow/tradeskillmaster_warehousing          --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- This file contains APIs related to inventory information (bags/bank)

local TSM = select(2, ...)
local private = {}
TSMAPI:RegisterForTracing(private, "TradeSkillMaster.Util_private")
private.bagUpdateCallbacks = {}
private.bankUpdateCallbacks = {}
private.bagState = {}
private.bankState = {}


function private:OnBagUpdate()
	local newState = {}
	local didChange
	for bag, slot, itemString, quantity in TSMAPI:GetBagIterator() do
		newState[itemString] = (newState[itemString] or 0) + quantity
		if not private.bagState[itemString] then
			didChange = true
		elseif private.bagState[itemString] then
			if private.bagState[itemString] ~= quantity then
				didChange = true
			end
			private.bagState[itemString] = nil
		end
	end
	didChange = didChange or (next(private.bagState) and true)
	private.bagState = newState

	if didChange then
		for _, callback in ipairs(private.bagUpdateCallbacks) do
			callback(private.bagState)
		end
	end
end

function private:OnBankUpdate()
	if not private.bankOpened then return end
	local newState = {}
	local didChange
	for bag, slot, itemString, quantity in TSMAPI:GetBankIterator() do
		newState[itemString] = (newState[itemString] or 0) + quantity
		if not private.bankState[itemString] then
			didChange = true
		elseif private.bankState[itemString] then
			if private.bankState[itemString] ~= quantity then
				didChange = true
			end
			private.bankState[itemString] = nil
		end
	end
	didChange = didChange or (next(private.bankState) and true)
	private.bankState = newState

	if didChange then
		for _, callback in ipairs(private.bankUpdateCallbacks) do
			callback(private.bankState)
		end
	end
end

function TSMAPI:RegisterForBagChange(callback)
	assert(type(callback) == "function", format("Expected function, got %s.", type(callback)))
	tinsert(private.bagUpdateCallbacks, callback)
end

function TSMAPI:RegisterForBankChange(callback)
	assert(type(callback) == "function", format("Expected function, got %s.", type(callback)))
	tinsert(private.bankUpdateCallbacks, callback)
end


-- Makes sure this bag is an actual bag and not an ammo, soul shard, etc bag
function private:IsValidBag(bag)
	if bag == 0 then return true end
	
	-- family 0 = bag with no type, family 1/2/4 are special bags that can only hold certain types of items
	local itemFamily = GetItemFamily(GetInventoryItemLink("player", ContainerIDToInventoryID(bag)))
	return itemFamily and (itemFamily == 0 or itemFamily > 4)
end

function TSMAPI:GetBagIterator(autoBaseItems, includeSoulbound)
	local bags, b, s = {}, 1, 0
	for bag=0, NUM_BAG_SLOTS do
		if private:IsValidBag(bag) then
			tinsert(bags, bag)
		end
	end

	local iter
	iter = function()
		if bags[b] then
			if s < GetContainerNumSlots(bags[b]) then
				s = s + 1
			else
				s = 1
				b = b + 1
				if not bags[b] then return end
			end
			
			local link = GetContainerItemLink(bags[b], s)
			if not link then
				-- no item here, try the next slot
				return iter()
			end
			local itemString
			if autoBaseItems then
				itemString = TSMAPI:GetBaseItemString(link, true)
			else
				itemString = TSMAPI:GetItemString(link)
			end
			
			if not itemString then
				-- ignore invalid item
				return iter()
			end
			
			if not includeSoulbound and TSMAPI:IsSoulbound(bags[b], s) then
				-- ignore soulbound item
				return iter()
			end
			
			local _, quantity, locked = GetContainerItemInfo(bags[b], s)
			return bags[b], s, itemString, quantity, locked
		end
	end
	
	return iter
end

function TSMAPI:GetBankIterator(autoBaseItems, includeSoulbound)
	local bags, b, s = {}, 1, 0
	tinsert(bags, -1)
	for bag=NUM_BAG_SLOTS+1, NUM_BAG_SLOTS+NUM_BANKBAGSLOTS do
		if private:IsValidBag(bag) then
			tinsert(bags, bag)
		end
	end

	local iter
	iter = function()
		if bags[b] then
			if s < GetContainerNumSlots(bags[b]) then
				s = s + 1
			else
				s = 1
				b = b + 1
				if not bags[b] then return end
			end
			local link = GetContainerItemLink(bags[b], s)
			local itemString
			if autoBaseItems then
				itemString = TSMAPI:GetBaseItemString(link, true)
			else
				itemString = TSMAPI:GetItemString(link)
			end
			if not itemString or (not includeSoulbound and TSMAPI:IsSoulbound(bags[b], s)) then
				return iter()
			else
				local _, quantity, locked = GetContainerItemInfo(bags[b], s)
				return bags[b], s, itemString, quantity, locked
			end
		end
	end
	
	return iter
end

function TSMAPI:ItemWillGoInBag(link, bag)
	if not link or not bag then return end
	if bag == 0 then return true end
	local itemFamily = GetItemFamily(link)
	local bagFamily = GetItemFamily(GetBagName(bag))
	if not bagFamily then return end
	return bagFamily == 0 or bit.band(itemFamily, bagFamily) > 0
end



do
	local BUCKET_TIME = 0.5
	local function EventHandler(event, bag)
		if event == "BANKFRAME_OPENED" then
			private.bankOpened = true
		elseif event == "BANKFRAME_CLOSED" then
			private.bankOpened = nil
		end
		if event == "BAG_UPDATE" then
			if bag > NUM_BAG_SLOTS then
				TSMAPI:CreateTimeDelay("bankStateUpdate", BUCKET_TIME, private.OnBankUpdate)
			else
				TSMAPI:CreateTimeDelay("bagStateUpdate", BUCKET_TIME, private.OnBagUpdate)
			end
		elseif event == "PLAYER_ENTERING_WORLD" then
			TSMAPI:CreateTimeDelay("bagStateUpdate", BUCKET_TIME, private.OnBagUpdate)
			TSMAPI:CreateTimeDelay("bankStateUpdate", BUCKET_TIME, private.OnBankUpdate)
		elseif event == "BANKFRAME_OPENED" or event == "PLAYERBANKSLOTS_CHANGED" then
			TSMAPI:CreateTimeDelay("bankStateUpdate", BUCKET_TIME, private.OnBankUpdate)
		end
	end

	TSM.RegisterEvent(private, "BAG_UPDATE", EventHandler)
	TSM.RegisterEvent(private, "BANKFRAME_OPENED", EventHandler)
	TSM.RegisterEvent(private, "BANKFRAME_CLOSED", EventHandler)
	TSM.RegisterEvent(private, "PLAYER_ENTERING_WORLD", EventHandler)
	TSM.RegisterEvent(private, "PLAYERBANKSLOTS_CHANGED", EventHandler)
end