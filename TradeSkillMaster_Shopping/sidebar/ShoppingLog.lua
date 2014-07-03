local TSM = select(2, ...)
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster_Shopping") -- loads the localization table

local private = {}

function private.Create(parent)
	local frame = CreateFrame("Frame", nil, parent)
	frame:Hide()
	frame:SetAllPoints()
	frame:SetScript("OnShow", private.UpdateSTData)
	frame:SetScript("OnUpdate", function(self)
			if #TSM.Util.shoppingLog ~= self.numLogEntries then
				private.UpdateSTData(self)
			end
		end)
	TSMAPI.Design:SetFrameColor(frame)
	
	local stHandlers = {
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
		{name=L["Item"], width=0.40},
		{name=L["Action"], width=0.15, align="CENTER"},
		{name=L["Num"], width=0.13, align="CENTER"},
		{name=L["Buyout"], width=0.25, align="RIGHT"},
	}
	frame.st = TSMAPI:CreateScrollingTable(frame, colInfo, stHandlers, 12)
	frame.st:DisableSelection(true)
	frame.st:DisableHighlight(true)
	
	return frame
end

function private.UpdateSTData(frame)
	local stData = {}
	for i=#TSM.Util.shoppingLog, 1, -1 do
		local entry = TSM.Util.shoppingLog[i]
		local row = {
			cols = {
				{value=entry.link},
				{value=entry.action},
				{value=entry.count},
				{value=TSMAPI:FormatTextMoney(entry.buyout)},
			},
			link = entry.link
		}
		tinsert(stData, row)
	end
	frame.st:SetData(stData)
	frame.numLogEntries = #TSM.Util.shoppingLog
end

do
	TSM:AddSidebarFeature(L["Log"], private.Create)
end