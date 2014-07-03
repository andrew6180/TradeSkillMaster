local TSM = select(2, ...)
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster_Shopping") -- loads the localization table

local private = {}

function private.Create(parent)
	local frame = CreateFrame("Frame", nil, parent)
	frame:Hide()
	frame:SetAllPoints()
	frame:SetScript("OnShow", private.UpdateSTData)
	frame:RegisterEvent("BAG_UPDATE")
	frame:SetScript("OnEvent", function() TSMAPI:CreateTimeDelay("quickPostingBagUpdate", 0.1, function() private.UpdateSTData(frame) end) end)
	
	local label = TSMAPI.GUI:CreateLabel(frame, "small")
	label:SetPoint("TOPLEFT")
	label:SetPoint("TOPRIGHT")
	label:SetJustifyH("CENTER")
	label:SetJustifyV("TOP")
	label:SetText(L["Click to search for an item.\nShift-Click to post at market value."])
	
	TSMAPI.GUI:CreateHorizontalLine(frame, -(label:GetHeight()+5))
	
	local stFrame = CreateFrame("Frame", nil, frame)
	stFrame:SetPoint("TOPLEFT", label, "BOTTOMLEFT", 0, -10)
	stFrame:SetPoint("BOTTOMRIGHT", 0, 30)
	TSMAPI.Design:SetFrameColor(stFrame)
	
	local stHandlers = {
		OnClick = function(_, data)
			if IsShiftKeyDown() then
				if type(data.buyout) ~= "number" or data.buyout <= 0 then return end
				local bag, slot
				for b, s, itemString in TSMAPI:GetBagIterator() do
					if itemString == data.itemString then
						bag = b
						slot = s
						break
					end
				end
				if not bag or not slot then return end
				if not AuctionFrameAuctions.duration then
					-- Fix in case Blizzard_AuctionUI hasn't set this value yet (which could cause an error)
					AuctionFrameAuctions.duration = TSM.db.global.quickPostingDuration
				end
				PickupContainerItem(bag, slot)
				ClickAuctionSellItemButton(AuctionsItemButton, "LeftButton")
				StartAuction(data.buyout*TSM.db.global.postBidPercent, data.buyout, TSM.db.global.quickPostingDuration, 1, 1)
				TSM:Printf(L["Posted a %s with a buyout of %s."], data.link, TSMAPI:FormatTextMoney(data.buyout))
				
				TSM:RegisterMessage("TSM_AH_EVENTS", function() TSMAPI:FireEvent("SHOPPING:QUICKPOST:POSTEDITEM", data) private.UpdateSTData(frame) end)
				TSMAPI:WaitForAuctionEvents("Post")
			else
				TSM.Search:StartFilterSearch(data.name.."/exact")
			end
		end,
		OnEnter = function(_, data, self)
			if not data then return end
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			TSMAPI:SafeTooltipLink(data.link)
			GameTooltip:Show()
		end,
		OnLeave = function()
			GameTooltip:ClearLines()
			GameTooltip:Hide()
		end
	}
	local colInfo = {
		{name=L["Item"], width=0.56},
		{name=L["Num"], width=0.14, align="CENTER"},
		{name=L["Price"], width=0.3, align="RIGHT"},
	}
	frame.st = TSMAPI:CreateScrollingTable(stFrame, colInfo, stHandlers, 12)
	frame.st:DisableSelection(true)
	frame.st:DisableHighlight(true)
	
	local checkBox = TSMAPI.GUI:CreateCheckBox(frame)
	checkBox:SetPoint("BOTTOMLEFT")
	checkBox:SetPoint("BOTTOMRIGHT")
	checkBox:SetHeight(30)
	checkBox:SetLabel(L["Hide Grouped Items"])
	checkBox:SetValue(TSM.db.global.quickPostingHideGrouped)
	checkBox:SetCallback("OnValueChanged", function(_, _, value)
			TSM.db.global.quickPostingHideGrouped = value
			private.UpdateSTData(frame)
		end)
	
	return frame
end

function private.UpdateSTData(frame)
	local items = {}
	for bag, slot, itemString, quantity in TSMAPI:GetBagIterator() do
		if not TSM.db.global.quickPostingHideGrouped or not TSMAPI:GetGroupPath(itemString) then
			items[itemString] = (items[itemString] or 0) + quantity
		end
	end

	local stData = {}
	for itemString, quantity in pairs(items) do
		local name, link = TSMAPI:GetSafeItemInfo(itemString)
		if name then
			local buyout = TSM:GetMaxPrice(TSM.db.global.quickPostingPrice, itemString)
			local row = {
				cols = {
					{value=link},
					{value=quantity},
					{value=TSMAPI:FormatTextMoney(buyout) or "---"},
				},
				itemString = itemString,
				link = link,
				name = name,
				buyout = buyout,
			}
			tinsert(stData, row)
		end
	end
	sort(stData, function(a, b) return a.name < b.name end)
	frame.st:SetData(stData)
end

do
	TSM:AddSidebarFeature(L["Quick Posting"], private.Create)
end