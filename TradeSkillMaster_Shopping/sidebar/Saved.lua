local TSM = select(2, ...)
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster_Shopping") -- loads the localization table

local private = {}

StaticPopupDialogs["TSM_SHOPPING_SAVED_EXPORT_POPUP"] = {
	text = L["Press Ctrl-C to copy this saved search."],
	button1 = OKAY,
	OnShow = function(self)
		self.editBox:SetText(private.popupText)
		self.editBox:HighlightText()
		self.editBox:SetFocus()
		self.editBox:SetScript("OnEscapePressed", function() StaticPopup_Hide("TSM_SHOPPING_SAVED_EXPORT_POPUP") end)
		self.editBox:SetScript("OnEnterPressed", function() self.button1:Click() end)
	end,
	hasEditBox = true,
	timeout = 0,
	hideOnEscape = true,
	preferredIndex = 3,
}
StaticPopupDialogs["TSM_SHOPPING_SAVED_IMPORT_POPUP"] = {
	text = L["Paste the search you'd like to import into the box below."],
	button1 = L["Import"],
	button2 = CANCEL,
	OnShow = function(self)
		self.editBox:SetText("")
		self.editBox:HighlightText()
		self.editBox:SetFocus()
		self.editBox:SetScript("OnEscapePressed", function() StaticPopup_Hide("TSM_SHOPPING_SAVED_IMPORT_POPUP") end)
		self.editBox:SetScript("OnEnterPressed", function() self.button1:Click() end)
	end,
	OnAccept = function(self)
		local text = self.editBox:GetText():trim()
		if text ~= "" then
			tinsert(TSM.db.global.favoriteSearches, text)
			TSM:Printf(L["Added '%s' to your favorite searches."], text)
			private.UpdateSTData()
		end
	end,
	hasEditBox = true,
	timeout = 0,
	hideOnEscape = true,
	preferredIndex = 3,
}


function private.Create(parent)
	local frame = CreateFrame("Frame", nil, parent)
	frame:Hide()
	frame:SetAllPoints()
	frame:SetScript("OnShow", private.UpdateSTData)
	private.frame = frame
	
	local stHandlers = {
		OnClick = function(st, data, _, button)
			if not data or not data.search then return end
			if button == "LeftButton" then
				if IsShiftKeyDown() then
					private.popupText = data.search
					TSMAPI:ShowStaticPopupDialog("TSM_SHOPPING_SAVED_EXPORT_POPUP")
				else
					TSM.Search:StartFilterSearch(data.search)
				end
			elseif button == "RightButton" then
				if st == frame.recentST then
					if IsShiftKeyDown() then
						for i=#TSM.db.global.previousSearches, 1, -1 do
							if TSM.db.global.previousSearches[i] == data.search then
								tremove(TSM.db.global.previousSearches, i)
							end
						end
						TSM:Printf(L["Removed '%s' from your recent searches."], data.search)
						private.UpdateSTData()
					else
						tinsert(TSM.db.global.favoriteSearches, data.search)
						TSM:Printf(L["Added '%s' to your favorite searches."], data.search)
						private.UpdateSTData()
					end
				elseif st == frame.favoriteST then
					tremove(TSM.db.global.favoriteSearches, data.index)
					TSM:Printf(L["Removed '%s' from your favorite searches."], data.search)
					private.UpdateSTData()
				end
			end
		end,
		OnEnter = function(st, data, self)
			if not data or not data.search then return end
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:AddLine(data.search, 1, 1, 1, true)
			GameTooltip:AddLine("")
			local color = TSMAPI.Design:GetInlineColor("link")
			if st == frame.recentST then
				GameTooltip:AddLine(color..L["Left-Click to run this search."], 1, 1, 1, true)
				GameTooltip:AddLine(color..L["Shift-Left-Click to export this search."], 1, 1, 1, true)
				GameTooltip:AddLine(color..L["Right-Click to favorite this recent search."], 1, 1, 1, true)
				GameTooltip:AddLine(color..L["Shift-Right-Click to remove this recent search."], 1, 1, 1, true)
			elseif st == frame.favoriteST then
				GameTooltip:AddLine(color..L["Left-Click to run this search."], 1, 1, 1, true)
				GameTooltip:AddLine(color..L["Shift-Left-Click to export this search."], 1, 1, 1, true)
				GameTooltip:AddLine(color..L["Right-Click to remove from favorite searches."], 1, 1, 1, true)
			end
			GameTooltip:Show()
		end,
		OnLeave = function()
			GameTooltip:ClearLines()
			GameTooltip:Hide()
		end
	}
	
	local recentSTParent = CreateFrame("Frame", nil, frame)
	recentSTParent:SetPoint("TOPLEFT")
	recentSTParent:SetPoint("TOPRIGHT")
	recentSTParent:SetPoint("BOTTOM", frame, "CENTER", 0, 4)
	TSMAPI.Design:SetFrameColor(recentSTParent)
	frame.recentST = TSMAPI:CreateScrollingTable(recentSTParent, {{name=L["Recent Searches"], width=1}}, stHandlers, 16)
	frame.recentST:DisableSelection(true)
	
	local favoriteSTParent = CreateFrame("Frame", nil, frame)
	favoriteSTParent:SetPoint("BOTTOMLEFT", 0, 30)
	favoriteSTParent:SetPoint("BOTTOMRIGHT", 0, 30)
	favoriteSTParent:SetPoint("TOP", frame, "CENTER", 0, -4)
	TSMAPI.Design:SetFrameColor(favoriteSTParent)
	frame.favoriteST = TSMAPI:CreateScrollingTable(favoriteSTParent, {{name=L["Favorite Searches"], width=1}}, stHandlers, 16)
	frame.favoriteST:DisableSelection(true)
	
	local importBtn = TSMAPI.GUI:CreateButton(frame, 18)
	importBtn:SetPoint("BOTTOMLEFT", 2, 2)
	importBtn:SetPoint("BOTTOMRIGHT", -2, 2)
	importBtn:SetPoint("TOPLEFT", favoriteSTParent, "BOTTOMLEFT", 2, -2)
	importBtn:SetText(L["Import Favorite Search"])
	importBtn:SetScript("OnClick", function()
			TSMAPI:ShowStaticPopupDialog("TSM_SHOPPING_SAVED_IMPORT_POPUP")
		end)
	
	return frame
end

local function GetSTData(list)
	local stData = {}
	for i, search in ipairs(list) do
		local row = {
			cols = {{value=search}},
			search = search,
			index = i,
		}
		tinsert(stData, row)
	end
	return stData
end

function private.UpdateSTData()
	if not private.frame then return end
	private.frame.recentST:SetData(GetSTData(TSM.db.global.previousSearches))
	private.frame.favoriteST:SetData(GetSTData(TSM.db.global.favoriteSearches))
end

do
	TSM:AddSidebarFeature(L["Saved Searches"], private.Create, private.UpdateSTData)
end