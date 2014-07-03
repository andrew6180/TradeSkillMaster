-- ------------------------------------------------------------------------------ --
--                            TradeSkillMaster_Mailing                            --
--            http://www.curse.com/addons/wow/tradeskillmaster_mailing            --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

local TSM = select(2, ...)
local AutoMail = TSM:NewModule("AutoMail", "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster_Mailing") -- loads the localization table

local private = {}


function AutoMail:OnEnable()
	AutoMail:RegisterEvent("MAIL_CLOSED", private.StopSending)
end

function AutoMail:SendItems(items, target, callback, codPerItem)
	if private.isSending or TSMAPI:IsPlayer(target) or not MailFrame:IsVisible() then return end
	private.isSending = true
	private.items = items
	private.target = target
	private.callback = callback
	private.codPerItem = codPerItem
	private.waitingLocations = {}
	TSMAPI:CreateTimeDelay("mailingSendDelay", 0, private.SendNextMail, TSM.db.global.sendDelay)
	return true
end

-- returns the number of items currently attached to the mail
function private:GetNumPendingAttachments()
	local totalAttached = 0
	for i=1, ATTACHMENTS_MAX_SEND do
		if GetSendMailItem(i) then
			totalAttached = totalAttached + 1
		end
	end
	
	return totalAttached
end

function private:SendNextMail()
	for _, info in ipairs(private.waitingLocations) do
		if not GetContainerItemInfo(info.bag, info.slot) then
			return
		end
	end

	-- send off any pending items
	private:SendOffMail()
	
	-- fill the mail with the next batch of items
	local bagsFull = private:FillMail()
	if #private.waitingLocations > 0 then return end
	
	-- check if anything was actually put in the mail to be sent
	if private:GetNumPendingAttachments() == 0 then
		-- we're done
		if bagsFull then
			TSM:Printf(L["Could not send mail due to not having free bag space available to split a stack of items."])
		end
		private:StopSending()
		return
	end
	
	-- send off this mail
	private:SendOffMail()
end

function private:SendOffMail()
	local attachments = private:GetNumPendingAttachments()
	if attachments == 0 or not private.target then return end
	SendMailNameEditBox:SetText(private.target)
	SetSendMailMoney(0)
	if private.codPerItem then
		local numItems = 0
		for i=1, ATTACHMENTS_MAX_SEND do
			local count = select(3, GetSendMailItem(i))
			numItems = numItems + count
		end
		SetSendMailCOD(private.codPerItem*numItems)
	else
		SetSendMailCOD(0)
	end
	SendMail(private.target, SendMailSubjectEditBox:GetText() or "TSM_Mailing", "")
	if TSM.db.global.sendMessages then
		local items = {}
		for i=1, attachments do
			local num = select(3, GetSendMailItem(i))
			local link = GetSendMailItemLink(i)
			local itemString = TSMAPI:GetItemString(link)
			if itemString then
				items[itemString] = items[itemString] or {num=0, link=link}
				items[itemString].num = items[itemString].num + num
			end
		end
		local temp = {}
		for itemString, info in pairs(items) do
			tinsert(temp, format("%sx%d", info.link, info.num))
		end
		local msg = ""
		local cod = GetSendMailCOD()
		if cod and cod > 0 then
			msg = format(L["Sent %s to %s with a COD of %s."], table.concat(temp, ", "), private.target, TSMAPI:FormatTextMoney(cod))
		else
			msg = format(L["Sent %s to %s."], table.concat(temp, ", "), private.target)
		end
		local function DoPrint()
			if private:GetNumPendingAttachments() > 0 then return end
			TSMAPI:CancelFrame("sendMailPrintDelay")
			TSM:Printf(msg)
		end
		TSMAPI:CreateTimeDelay("sendMailPrintDelay", 0, DoPrint, 0.1)
	end
end

-- fills the current mail with items to be sent to the target
function private:FillMail()
	if private:GetNumPendingAttachments() ~= 0 then return end
	
	local locationInfo = {}
	for bag, slot, itemString, quantity, locked in TSMAPI:GetBagIterator(true) do
		if not locked then
			locationInfo[itemString] = locationInfo[itemString] or {}
			tinsert(locationInfo[itemString], {bag=bag, slot=slot, quantity=quantity})
		end
	end
	
	local emptySlots = {}
	for bag=0, NUM_BAG_SLOTS do
		for slot=1, GetContainerNumSlots(bag) do
			if not GetContainerItemInfo(bag, slot) then
				local family = bag == 0 and 0 or GetItemFamily(GetInventoryItemLink("player", ContainerIDToInventoryID(bag)))
				tinsert(emptySlots, {bag=bag, slot=slot, family=family})
			end
		end
	end
	private.waitingLocations = {}
	
	for itemString, quantity in pairs(private.items) do
		if locationInfo[itemString] and quantity > 0 then
			-- use stack sizes which match exactly first, followed by the smallest stacks
			local sameSize = {}
			for i=#locationInfo[itemString], 1, -1 do
				if locationInfo[itemString][i].quantity == quantity then
					tinsert(sameSize, locationInfo[itemString][i])
					tremove(locationInfo[itemString], i)
				end
			end
			sort(locationInfo[itemString], function(a,b) return a.quantity < b.quantity end)
			for _, info in ipairs(sameSize) do
				tinsert(locationInfo[itemString], 1, info)
			end
			for _, info in ipairs(locationInfo[itemString]) do
				if quantity == 0 then break end
				if quantity >= info.quantity then
					PickupContainerItem(info.bag, info.slot)
					quantity = quantity - info.quantity
					private.items[itemString] = quantity
					
					ClickSendMailItemButton()
					if private:GetNumPendingAttachments() == ATTACHMENTS_MAX_SEND then
						return
					end
				else
					-- sort the empty slots such that we'll use special bags first if possible
					local family = GetItemFamily(itemString)
					local splitTarget
					if family > 0 then
						local specialBags = {}
						for bag=1, NUM_BAG_SLOTS do
							local bagFamily = GetItemFamily(GetInventoryItemLink("player", ContainerIDToInventoryID(bag)))
							if bagFamily and bagFamily > 0 and bit.band(family, bagFamily) > 0 then
								specialBags[bag] = true
							end
						end
						sort(emptySlots, function(a, b)
								if specialBags[a.bag] and specialBags[b.bag] then
									if a.bag == b.bag then
										return a.slot < b.slot
									end
									return a.bag < b.bag
								end
								if a.bag == b.bag then
									return a.slot < b.slot
								end
								if specialBags[a.bag] then return true end
								if specialBags[b.bag] then return false end
								return a.bag < b.bag
							end)
					else
						sort(emptySlots, function(a, b)
								if a.bag == b.bag then
									return a.slot < b.slot
								end
								return a.bag < b.bag
							end)
					end
					for i=1, #emptySlots do
						if emptySlots[i].family == 0 or bit.band(family, emptySlots[i].family) > 0 then
							splitTarget = emptySlots[i]
							tremove(emptySlots, i)
							break
						end
					end
					
					if not splitTarget then return true end
					SplitContainerItem(info.bag, info.slot, quantity)
					PickupContainerItem(splitTarget.bag, splitTarget.slot)
					tinsert(private.waitingLocations, splitTarget)
					break
				end
			end
			
			-- check if we want to send only one type of item per mail
			if TSM.db.global.sendItemsIndividually then
				return
			end
		end
	end
end

-- stops sending mail and calls the callback
function private:StopSending()
	if not private.isSending then return end
	TSMAPI:CancelFrame("mailingSendDelay")
	private.isSending = nil
	private.items = nil
	private.target = nil
	private.waitingLocations = {}
	private.callback()
end