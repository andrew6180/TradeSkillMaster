-- ------------------------------------------------------------------------------ --
--                                TradeSkillMaster                                --
--                http://www.curse.com/addons/wow/tradeskill-master               --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

local TSM = select(2, ...)
local private = {}
TSMAPI:RegisterForTracing(private, "TradeSkillMaster.AuctionUtil_private")
LibStub("AceEvent-3.0"):Embed(private)


local eventFrame = CreateFrame("Frame")
eventFrame:Hide()
eventFrame.data = {}
eventFrame.callback = function() end
eventFrame:SetScript("OnEvent", function(self, event, ...)
		if self.interrupt and event == self.interrupt.event and self.interrupt.callback() then
			self:UnregisterAllEvents()
			self.data = {}
		end
		for i=1, #self.data do
			if self.data[i].event == event then
				if self.data[i].callback then
					if self.data[i].callback(event, ...) then
						tremove(self.data, i)
						self:UnregisterEvent(event)
					end
				else
					tremove(self.data, i)
					self:UnregisterEvent(event)
				end
				break
			end
		end
		if #self.data == 0 then
			self:Hide()
			self.callback()
		end
	end)
	
local function WaitForEvents(data, callback, interrupt)
	eventFrame.data = data
	eventFrame.callback = callback
	for i=1, #data do
		eventFrame:RegisterEvent(data[i].event)
	end
	if interrupt then
		eventFrame.interrupt = interrupt
		eventFrame:RegisterEvent(interrupt.event)
	end
	eventFrame:Show()
end

function TSMAPI:CreateEventDelay(event, callback, timeout, validator)
	if not event then return end
	local eventName = "eventDelay"..random()
	if timeout then
		TSMAPI:CreateTimeDelay(eventName, timeout, function() eventFrame:Hide() end)
		callback()
	end
	
	WaitForEvents({event=event, callback=validator}, function() callback() TSMAPI:CancelFrame(eventName) end)
end

-- Sends the "TSM_AH_EVENTS" message once the action (buyout/bid/cancel/post)
-- has been acknowledged by the server and the client has been notified
function TSMAPI:WaitForAuctionEvents(mode, isMultiPost)
	local function ValidateEvent(_, msg)
		if mode == "Buyout" then
			return msg:match(gsub(ERR_AUCTION_BID_PLACED, "%%s", ""))
		elseif mode == "Cancel" then
			return msg == ERR_AUCTION_REMOVED
		elseif mode == "Post" then
			return msg == ERR_AUCTION_STARTED
		end
	end
	
	local events, interrupt
	if mode == "Buyout" then
		events = {{event="AUCTION_ITEM_LIST_UPDATE"}, {event="CHAT_MSG_SYSTEM", callback=ValidateEvent}}
		interrupt = {event="UI_ERROR_MESSAGE", callback=function(_,msg) return msg == ERR_AUCTION_HIGHER_BID end}
	elseif mode == "Cancel" then
		events = {{event="CHAT_MSG_SYSTEM", callback=ValidateEvent}, {event="AUCTION_OWNED_LIST_UPDATE"}}
	elseif mode == "Post" then
		if isMultiPost then
			events = {{event="AUCTION_MULTISELL_UPDATE", callback=function(_,arg1,arg2) return arg1 == arg2 end}}
		else
			events = {{event="CHAT_MSG_SYSTEM", callback=ValidateEvent}}
		end
	end
	if events then
		WaitForEvents(events, function() private:SendMessage("TSM_AH_EVENTS", mode) end, interrupt)
	end
end


function TSMAPI:GetAuctionPercentColor(percent)
	local colors = {
		{color="|cff2992ff", value=50}, -- blue
		{color="|cff16ff16", value=80}, -- green
		{color="|cffffff00", value=110}, -- yellow
		{color="|cffff9218", value=135}, -- orange
		{color="|cffff0000", value=math.huge}, -- red
	}
	
	for i=1, #colors do
		if percent < colors[i].value then
			return colors[i].color
		end
	end
	
	return "|cffffffff"
end