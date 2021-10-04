local TSM = select(2, ...)
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster_Shopping") -- loads the localization table

local private = {}

function private.Create(parent)
	local frame = CreateFrame("Frame", nil, parent)
	frame:Hide()
	frame:SetAllPoints()

	-- row 1 - filter
	local y = 5
	local filterText = TSMAPI.GUI:CreateLabel(frame)
	filterText:SetPoint("TOPLEFT", 5, -y)
	filterText:SetHeight(20)
	filterText:SetText(L["Search Filter:"])
	
	local filterInputBox = TSMAPI.GUI:CreateInputBox(frame)
	filterInputBox:SetPoint("TOPLEFT", filterText, "TOPRIGHT", 5, 0)
	filterInputBox:SetPoint("TOPRIGHT", -5, -y)
	filterInputBox:SetHeight(20)
	filterInputBox:SetScript("OnShow", filterInputBox.SetFocus)
	frame.filterInputBox = filterInputBox
	
	TSMAPI.GUI:CreateHorizontalLine(frame, -(y+27))
	
	-- row 2 - required level range
	y = y + 35
	local levelText = TSMAPI.GUI:CreateLabel(frame)
	levelText:SetPoint("TOPLEFT", 5, -y)
	levelText:SetHeight(20)
	levelText:SetText(L["Required Level Range:"])
	
	local levelMinBox = TSMAPI.GUI:CreateInputBox(frame)
	levelMinBox:SetPoint("TOPLEFT", levelText, "TOPRIGHT", 5, 0)
	levelMinBox:SetHeight(20)
	levelMinBox:SetWidth(60)
	levelMinBox:SetNumeric(true)
	frame.levelMinBox = levelMinBox
	
	local label = TSMAPI.GUI:CreateLabel(frame)
	label:SetPoint("TOPLEFT", levelMinBox, "TOPRIGHT", 5, 0)
	label:SetHeight(20)
	label:SetText("-")
	
	local levelMaxBox = TSMAPI.GUI:CreateInputBox(frame)
	levelMaxBox:SetPoint("TOPLEFT", label, "TOPRIGHT", 5, 0)
	levelMaxBox:SetPoint("TOPRIGHT", -5, -y)
	levelMaxBox:SetHeight(20)
	levelMaxBox:SetNumeric(true)
	frame.levelMaxBox = levelMaxBox
	
	-- row 3 - item level range
	y = y + 30
	local levelText = TSMAPI.GUI:CreateLabel(frame)
	levelText:SetPoint("TOPLEFT", 5, -y)
	levelText:SetHeight(20)
	levelText:SetText(L["Item Level Range:"])
	
	local itemLevelMinBox = TSMAPI.GUI:CreateInputBox(frame)
	itemLevelMinBox:SetPoint("TOPLEFT", levelText, "TOPRIGHT", 5, 0)
	itemLevelMinBox:SetHeight(20)
	itemLevelMinBox:SetWidth(70)
	itemLevelMinBox:SetNumeric(true)
	frame.itemLevelMinBox = itemLevelMinBox
	
	local label = TSMAPI.GUI:CreateLabel(frame)
	label:SetPoint("TOPLEFT", itemLevelMinBox, "TOPRIGHT", 5, 0)
	label:SetHeight(20)
	label:SetText("-")
	
	local itemLevelMaxBox = TSMAPI.GUI:CreateInputBox(frame)
	itemLevelMaxBox:SetPoint("TOPLEFT", label, "TOPRIGHT", 5, 0)
	itemLevelMaxBox:SetPoint("TOPRIGHT", -5, -y)
	itemLevelMaxBox:SetHeight(20)
	itemLevelMaxBox:SetNumeric(true)
	frame.itemLevelMaxBox = itemLevelMaxBox
	
	TSMAPI.GUI:CreateHorizontalLine(frame, -(y+25))
	
	-- row 4 - class
	y = y + 30
	local list = {GetAuctionItemClasses()}
	local classDropdown = TSMAPI.GUI:CreateDropdown(frame, list, "")
	classDropdown:SetLabel(L["Item Class"])
	classDropdown:SetPoint("TOPLEFT", 5, -y)
	classDropdown:SetPoint("TOPRIGHT", 0, -y)
	classDropdown:SetCallback("OnValueChanged", function(_,_,value)
			frame.subClassDropdown:SetValue()
			frame.subClassDropdown:SetList({GetAuctionItemSubClasses(value)})
			frame.subClassDropdown:SetDisabled(false)
		end)
	frame.classDropdown = classDropdown
	
	-- row 5 - subclass
	y = y + 50
	local subClassDropdown = TSMAPI.GUI:CreateDropdown(frame, {}, "")
	subClassDropdown:SetLabel(L["Item SubClass"])
	subClassDropdown:SetPoint("TOPLEFT", 5, -y)
	subClassDropdown:SetPoint("TOPRIGHT", 0, -y)
	subClassDropdown:SetDisabled(true)
	frame.subClassDropdown = subClassDropdown
	
	TSMAPI.GUI:CreateHorizontalLine(frame, -(y+55))
	
	-- row 6 - rarity
	y = y + 60
	local rarityList = {}
	for i = 1, 4 do tinsert(rarityList, _G["ITEM_QUALITY"..i.."_DESC"]) end
	local rarityDropdown = TSMAPI.GUI:CreateDropdown(frame, rarityList, "")
	rarityDropdown:SetLabel(L["Minimum Rarity"])
	rarityDropdown:SetPoint("TOPLEFT", 5, -y)
	rarityDropdown:SetPoint("TOPRIGHT", 0, -y)
	frame.rarityDropdown = rarityDropdown
	
	TSMAPI.GUI:CreateHorizontalLine(frame, -(y+55))
	
	-- row 7 - usable / exact
	y = y + 60
	local usableCheckBox = TSMAPI.GUI:CreateCheckBox(frame, L["If set, only items which are usable by your character will be included in the results."])
	usableCheckBox:SetLabel("Usable")
	usableCheckBox:SetPoint("TOPLEFT", 5, -y)
	usableCheckBox:SetWidth((frame:GetWidth()/2)-5)
	frame.usableCheckBox = usableCheckBox
	
	local exactCheckBox = TSMAPI.GUI:CreateCheckBox(frame, L["If set, only items which exactly match the search filter you have set will be included in the results."])
	exactCheckBox:SetLabel("Exact")
	exactCheckBox:SetPoint("TOPRIGHT", 5, -y)
	exactCheckBox:SetWidth((frame:GetWidth()/2)-5)
	frame.exactCheckBox = exactCheckBox
	
	TSMAPI.GUI:CreateHorizontalLine(frame, -(y+30))
	
	-- row 8 - maximum quantity
	y = y + 35
	local maxQtyText = TSMAPI.GUI:CreateLabel(frame)
	maxQtyText:SetPoint("TOPLEFT", 5, -y)
	maxQtyText:SetHeight(20)
	maxQtyText:SetText(L["Maximum Quantity to Buy:"])
	
	local maxQtyBox = TSMAPI.GUI:CreateInputBox(frame)
	maxQtyBox:SetPoint("TOPLEFT", maxQtyText, "TOPRIGHT", 5, 0)
	maxQtyBox:SetPoint("TOPRIGHT", -5, -y)
	maxQtyBox:SetHeight(20)
	maxQtyBox:SetNumeric(true)
	frame.maxQtyBox = maxQtyBox
	
	TSMAPI.GUI:CreateHorizontalLine(frame, -(y+35))
	
	-- row 9 - clear / search buttons
	local clearBtn = TSMAPI.GUI:CreateButton(frame, 20)
	clearBtn:SetPoint("BOTTOMLEFT", 5, 5)
	clearBtn:SetWidth((frame:GetWidth()/2)-7.5)
	clearBtn:SetHeight(25)
	clearBtn:SetText(L["Reset Filters"])
	clearBtn:SetScript("OnClick", function() private:ResetFilters(frame) end)
	frame.clearBtn = clearBtn
	
	local startBtn = TSMAPI.GUI:CreateButton(frame, 20)
	startBtn:SetPoint("TOPLEFT", clearBtn, "TOPRIGHT", 5, 0)
	startBtn:SetPoint("BOTTOMRIGHT", -5, 5)
	startBtn:SetHeight(25)
	startBtn:SetText(L["Start Search"])
	startBtn:SetScript("OnClick", function() private:StartSearch(frame) end)
	frame.startBtn = startBtn
	
	private:ResetFilters(frame)
	return frame
end

function private:ResetFilters(frame)
	frame.filterInputBox:SetText("")
	frame.levelMinBox:SetText("")
	frame.levelMaxBox:SetText("")
	frame.itemLevelMinBox:SetText("")
	frame.itemLevelMaxBox:SetText("")
	frame.classDropdown:SetValue()
	frame.subClassDropdown:SetValue()
	frame.subClassDropdown:SetDisabled(true)
	frame.rarityDropdown:SetValue()
	frame.usableCheckBox:SetValue(false)
	frame.exactCheckBox:SetValue(false)
	frame.maxQtyBox:SetText("")
end

function private:StartSearch(frame)
	local filter = frame.filterInputBox:GetText()

	local minLevel = frame.levelMinBox:GetNumber()
	local maxLevel = frame.levelMaxBox:GetNumber()
	if maxLevel > 0 then
		filter = format("%s/%d/%d", filter, minLevel, maxLevel)
	elseif minLevel > 0 then
		filter = format("%s/%d", filter, minLevel)
	end
	
	local minItemLevel = frame.itemLevelMinBox:GetNumber()
	local maxItemLevel = frame.itemLevelMaxBox:GetNumber()
	if maxItemLevel > 0 then
		filter = format("%s/i%d/i%d", filter, minItemLevel, maxItemLevel)
	elseif minItemLevel > 0 then
		filter = format("%s/i%d", filter, minItemLevel)
	end
	
	local class = frame.classDropdown:GetValue()
	if class then
		local classes = {GetAuctionItemClasses()}
		filter = format("%s/%s", filter, classes[class])
		local subClass = frame.subClassDropdown:GetValue()
		if subClass then
			local subClasses = {GetAuctionItemSubClasses(class)}
			filter = format("%s/%s", filter, subClasses[subClass])
		end
	end
	
	local rarity = frame.rarityDropdown:GetValue()
	if rarity then
		filter = format("%s/%s", filter,  _G["ITEM_QUALITY"..rarity.."_DESC"])
	end
	
	if frame.usableCheckBox:GetValue() then
		filter = format("%s/usable", filter)
	end
	
	if frame.exactCheckBox:GetValue() then
		filter = format("%s/exact", filter)
	end
	
	local maxQty = frame.maxQtyBox:GetNumber()
	if maxQty > 0 then
		filter = format("%s/x%d", filter, maxQty)
	end
	
	TSM.Search:StartFilterSearch(filter)
end

do
	TSM:AddSidebarFeature(L["Custom Filter"], private.Create)
end