-- ------------------------------------------------------------------------------ --
--                                TradeSkillMaster                                --
--                http://www.curse.com/addons/wow/tradeskill-master               --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

--[[-----------------------------------------------------------------------------
Group Item List Widget
Provides two scroll lists with buttons to move selected items from one list to the other.
-------------------------------------------------------------------------------]]
local TSM = select(2, ...)
local Type, Version = "TSMGroupItemList", 1
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster") -- loads the localization table
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)
if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end

local ROW_HEIGHT = 16


--[[-----------------------------------------------------------------------------
Scripts
-------------------------------------------------------------------------------]]

local function ShowIcon(row)
	row.iconFrame:Show()
	row.label:SetPoint("TOPLEFT", 20, 0)
	row.label:SetPoint("BOTTOMRIGHT")
end

local function HideIcon(row)
	row.iconFrame:Hide()
	row.label:SetPoint("TOPLEFT", 0, 0)
	row.label:SetPoint("BOTTOMRIGHT")
end

local function UpdateScrollFrame(self)
	local parent = self:GetParent()
	if not parent.obj.GetListCallback then return end
	parent.items = parent.obj.GetListCallback(parent == parent.obj.leftFrame and "left" or "right")
	if not parent.list then
		parent.list = {}
		local usedItems = {}
		for _, itemLink in ipairs(parent.items) do
			local itemString = TSMAPI:GetItemString(itemLink)
			local name, link, _, _, _, _, _, _, _, texture = TSMAPI:GetSafeItemInfo(itemString)
			if itemString and name and texture and not usedItems[itemString] then
				usedItems[itemString] = true
				tinsert(parent.list, {value=itemString, link=link, icon=texture, sortText=strlower(name)})
			end
		end
		sort(parent.list, function(a, b) return a.sortText < b.sortText end)
	end

	local rows = self.rows
	-- clear all the rows
	for _, v in pairs(rows) do
		v.value = nil
		v.label:SetText("")
		v.iconFrame.icon:SetTexture("")
		v:Hide()
	end
	
	local rowData = {}
	for _, data in ipairs(self:GetParent().list) do
		if not data.filtered then
			tinsert(rowData, data)
		end
	end
	
	local maxRows = floor((self.height-5)/(ROW_HEIGHT+2))
	FauxScrollFrame_Update(self, #(rowData), maxRows-1, ROW_HEIGHT)
	local offset = FauxScrollFrame_GetOffset(self)
	local displayIndex = 0
	
	-- make the rows bigger if the scroller isn't showing
	if self:IsVisible() then
		rows[1]:SetPoint("TOPRIGHT", self:GetParent(), -26, 0)
	else
		rows[1]:SetPoint("TOPRIGHT", self:GetParent(), -10, 0)
	end
	
	for index, data in ipairs(rowData) do
		if index >= offset and displayIndex < maxRows then
			displayIndex = displayIndex + 1
			local row = rows[displayIndex]
			
			row.label:SetText(data.link)
			row.value = data.value
			row.data = data
			
			if data.selected then
				row:LockHighlight()
			else
				row:UnlockHighlight()
			end
			
			if data.icon then
				row.iconFrame.icon:SetTexture(data.icon)
				ShowIcon(row)
			else
				HideIcon(row)
			end
			row:Show()
		end
	end
end

local function UpdateRows(parent)
	local numRows = floor((parent.height-5)/(ROW_HEIGHT+2))
	parent.rows = parent.rows or {}
	for i=1, numRows do
		if not parent.rows[i] then
			local row = CreateFrame("Button", parent:GetName().."Row"..i, parent:GetParent())
			row:SetHeight(ROW_HEIGHT)
			row:SetScript("OnClick", function(self)
				self.data.selected = not self.data.selected
				if self.data.selected then
					self:LockHighlight()
				else
					self:UnlockHighlight()
				end
			end)
			row:SetScript("OnEnter", function(self)
				GameTooltip:SetOwner(self, "ANCHOR_NONE")
				GameTooltip:SetPoint("LEFT", parent:GetParent():GetParent(), "RIGHT")
				TSMAPI:SafeTooltipLink(self.data.link)
				GameTooltip:Show()
			end)
			row:SetScript("OnLeave", function() GameTooltip:Hide() BattlePetTooltip:Hide() end)
			
			if i > 1 then
				row:SetPoint("TOPLEFT", parent.rows[i-1], "BOTTOMLEFT", 0, -2)
				row:SetPoint("TOPRIGHT", parent.rows[i-1], "BOTTOMRIGHT", 0, -2)
			else
				row:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0)
				row:SetPoint("TOPRIGHT", parent, "TOPRIGHT", 4, 0)
			end
			
			-- highlight / selection texture for the row
			local highlightTex = row:CreateTexture()
			highlightTex:SetTexture("Interface\\Buttons\\UI-Listbox-Highlight")
			highlightTex:SetPoint("TOPRIGHT", row, "TOPRIGHT", 0, 0)
			highlightTex:SetPoint("BOTTOMLEFT")
			highlightTex:SetAlpha(0.7)
			row:SetHighlightTexture(highlightTex)
			
			-- icon that goes to the left of the text
			local iconFrame = CreateFrame("Frame", nil, row)
			iconFrame:SetHeight(ROW_HEIGHT-2)
			iconFrame:SetWidth(ROW_HEIGHT-2)
			iconFrame:SetPoint("TOPLEFT")
			row.iconFrame = iconFrame
			
			-- texture that goes inside the iconFrame
			local iconTexture = iconFrame:CreateTexture(nil, "BACKGROUND")
			iconTexture:SetAllPoints(iconFrame)
			iconTexture:SetVertexColor(1, 1, 1)
			iconFrame.icon = iconTexture
			
			local label = row:CreateFontString(nil, "OVERLAY")
			label:SetFont(TSMAPI.Design:GetContentFont("normal"))
			label:SetJustifyH("LEFT")
			label:SetJustifyV("CENTER")
			label:SetPoint("TOPLEFT", 20, 0)
			label:SetPoint("BOTTOMRIGHT", 10, 0)
			TSMAPI.Design:SetWidgetTextColor(label)
			row.label = label
			
			parent.rows[i] = row
		end
	end
	UpdateScrollFrame(parent)
end

local function OnButtonClick(self)
	local selected = {}
	local rows, rowData
	
	if self.type == "Add" then
		rows = self.obj.leftFrame.scrollFrame.rows
		rowData = self.obj.leftFrame.list
	elseif self.type == "Remove" then
		rows = self.obj.rightFrame.scrollFrame.rows
		rowData = self.obj.rightFrame.list
	end
	if not rows then error("Invalid type") end
	
	local temp = {}
	for _, row in pairs(rows) do
		if row.data and row.data.selected and row.value then
			row.data.selected = false
			row:UnlockHighlight()
			temp[row.value] = true
			tinsert(selected, row.value)
		end
	end
	
	for _, data in pairs(rowData) do
		if data.selected and data.value and not temp[data.value] then
			data.selected = false
			tinsert(selected, data.value)
		end
	end

	self.obj:Fire("On"..self.type.."Clicked", selected)
end

local function OnFilterSet(self)
	self:ClearFocus()
	local text = strlower(TSMAPI:StrEscape(self:GetText():trim()))
	
	local filterStr, minLevel, maxLevel, minILevel, maxILevel
	for _, part in ipairs({("/"):split(text)}) do
		part = part:trim()
		if part ~= "" then
			local lvl = tonumber(part)
			local ilvl = gsub(part, "^i", "")
			ilvl = tonumber(ilvl)
			if lvl then
				if not minLevel then
					minLevel = lvl
				elseif not maxLevel then
					maxLevel = lvl
				else
					return TSM:Print(L["Invalid filter."])
				end
			elseif ilvl then
				if not minILevel then
					minILevel = ilvl
				elseif not maxILevel then
					maxILevel = ilvl
				else
					return TSM:Print(L["Invalid filter."])
				end
			else
				if filterStr then
					return TSM:Print(L["Invalid filter."])
				end
				filterStr = part
			end
		end
	end
	filterStr = filterStr or ""
	minLevel = minLevel or 0
	maxLevel = maxLevel or math.huge
	minILevel = minILevel or 0
	maxILevel = maxILevel or math.huge
	
	for _, info in ipairs(self.obj.leftFrame.list) do
		local name, _, _, ilvl, lvl = TSMAPI:GetSafeItemInfo(info.link)
		local selected = (strfind(strlower(name), filterStr) and ilvl >= minILevel and ilvl <= maxILevel and lvl >= minLevel and lvl <= maxLevel)
		info.selected = selected
		info.filtered = not selected
	end
	for _, info in ipairs(self.obj.rightFrame.list) do
		local name, _, _, ilvl, lvl = TSMAPI:GetSafeItemInfo(info.link)
		local selected = (strfind(strlower(name), filterStr) and ilvl >= minILevel and ilvl <= maxILevel and lvl >= minLevel and lvl <= maxLevel)
		info.selected = selected
		info.filtered = not selected
	end
	FauxScrollFrame_SetOffset(self.obj.leftFrame.scrollFrame, 0)
	FauxScrollFrame_SetOffset(self.obj.rightFrame.scrollFrame, 0)
	UpdateScrollFrame(self.obj.leftFrame.scrollFrame)
	UpdateScrollFrame(self.obj.rightFrame.scrollFrame)
end

local function OnClearButtonClicked(self)
	for _, info in ipairs(self.obj.leftFrame.list) do
		info.selected = false
	end
	for _, info in ipairs(self.obj.rightFrame.list) do
		info.selected = false
	end
	UpdateScrollFrame(self.obj.leftFrame.scrollFrame)
	UpdateScrollFrame(self.obj.rightFrame.scrollFrame)
end

local function OnIgnoreChanged(self, _, value)
	TSM.db.global.ignoreRandomEnchants = value
	self.obj.leftFrame.list = nil
	UpdateScrollFrame(self.obj.leftFrame.scrollFrame)
end


--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]

local methods = {
	["OnAcquire"] = function(self)
		-- restore default values
		self:SetHeight(550)
		TSMAPI:CreateTimeDelay(0.05, function() self.parent:DoLayout() end)
		self.filter:SetText("")
		self.ignoreCheckBox:SetValue(TSM.db.global.ignoreRandomEnchants)
	end,

	["OnRelease"] = function(self)
		-- clear any points / other values
		wipe(self.leftFrame.list)
		wipe(self.rightFrame.list)
		self.frame.leftTitle:SetText("")
		self.frame.rightTitle:SetText("")
	end,
	
	["OnHeightSet"] = function(self, height)
		if height == 100 then return end
		self.leftScrollFrame.height = self.frame:GetHeight() - 85
		self.rightScrollFrame.height = self.frame:GetHeight() - 85
		UpdateRows(self.leftScrollFrame)
		UpdateRows(self.rightScrollFrame)
	end,
	
	["SetListCallback"] = function(self, callback)
		self.GetListCallback = callback
		self.leftFrame.list = nil
		self.rightFrame.list = nil
		UpdateScrollFrame(self.leftScrollFrame)
		UpdateScrollFrame(self.rightScrollFrame)
	end,
	
	["SetTitle"] = function(self, side, title)
		if strlower(side) == "left" then
			self.frame.leftTitle:SetText(title)
		elseif strlower(side) == "right" then
			self.frame.rightTitle:SetText(title)
		elseif title then
			error("Invalid side passed. Expected 'left' or 'right'")
		end
	end,
	
	["SetIgnoreVisible"] = function(self, shown)
		if shown then
			self.ignoreCheckBox.frame:Show()
		else
			self.ignoreCheckBox.frame:Hide()
		end
	end,
}


--[[-----------------------------------------------------------------------------
Constructor
-------------------------------------------------------------------------------]]

local function Constructor()
	local borderColor = TSM.db.profile.frameBackdropColor
	local name = "TSMGroupItemList" .. AceGUI:GetNextWidgetNum(Type)
	local frame = CreateFrame("Frame", name, UIParent)
	frame:Hide()
	
	local leftFrame = CreateFrame("Frame", name.."LeftFrame", frame)
	leftFrame:SetPoint("TOPLEFT", 0, -80)
	leftFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOM", -7, 0)
	TSMAPI.Design:SetContentColor(leftFrame)
	leftFrame.list = {}
	frame.leftFrame = leftFrame
	
	local leftTitle = frame:CreateFontString(nil, "OVERLAY")
	leftTitle:SetFont(TSMAPI.Design:GetContentFont("normal"))
	TSMAPI.Design:SetTitleTextColor(leftTitle)
	leftTitle:SetJustifyH("LEFT")
	leftTitle:SetJustifyV("BOTTOM")
	leftTitle:SetHeight(15)
	leftTitle:SetPoint("BOTTOMLEFT", leftFrame, "TOPLEFT", 8, 0)
	leftTitle:SetPoint("BOTTOMRIGHT", leftFrame, "TOPRIGHT", -8, 0)
	frame.leftTitle = leftTitle
	
	local leftSF = CreateFrame("ScrollFrame", name.."LeftFrameScrollFrame", leftFrame, "FauxScrollFrameTemplate")
	leftSF:SetPoint("TOPLEFT", 5, -5)
	leftSF:SetPoint("BOTTOMRIGHT", -5, 5)
	leftSF:SetScript("OnVerticalScroll", function(self, offset)
		FauxScrollFrame_OnVerticalScroll(self, offset, ROW_HEIGHT, function() UpdateScrollFrame(self) end) 
	end)
	leftFrame.scrollFrame = leftSF
	
	local leftScrollBar = _G[leftSF:GetName().."ScrollBar"]
	leftScrollBar:ClearAllPoints()
	leftScrollBar:SetPoint("BOTTOMRIGHT")
	leftScrollBar:SetPoint("TOPRIGHT")
	leftScrollBar:SetWidth(12)
	
	local thumbTex = leftScrollBar:GetThumbTexture()
	thumbTex:SetPoint("CENTER")
	TSMAPI.Design:SetFrameColor(thumbTex)
	thumbTex:SetHeight(150)
	thumbTex:SetWidth(leftScrollBar:GetWidth())
	_G[leftScrollBar:GetName().."ScrollUpButton"]:Hide()
	_G[leftScrollBar:GetName().."ScrollDownButton"]:Hide()
	
	local rightFrame = CreateFrame("Frame", name.."RightFrame", frame)
	rightFrame:SetPoint("TOPLEFT", frame, "TOP", 7, -80)
	rightFrame:SetPoint("BOTTOMRIGHT", 0, 0)
	TSMAPI.Design:SetContentColor(rightFrame)
	rightFrame.list = {}
	frame.rightFrame = rightFrame
	
	local rightTitle = frame:CreateFontString(nil, "OVERLAY")
	rightTitle:SetFont(TSMAPI.Design:GetContentFont("normal"))
	TSMAPI.Design:SetTitleTextColor(rightTitle)
	rightTitle:SetJustifyH("LEFT")
	rightTitle:SetJustifyV("BOTTOM")
	rightTitle:SetHeight(15)
	rightTitle:SetPoint("BOTTOMLEFT", rightFrame, "TOPLEFT", 8, 0)
	rightTitle:SetPoint("BOTTOMRIGHT", rightFrame, "TOPRIGHT", -8, 0)
	frame.rightTitle = rightTitle
	
	local rightSF = CreateFrame("ScrollFrame", name.."RightFrameScrollFrame", rightFrame, "FauxScrollFrameTemplate")
	rightSF:SetPoint("TOPLEFT", 5, -5)
	rightSF:SetPoint("BOTTOMRIGHT", -5, 5)
	rightSF:SetScript("OnVerticalScroll", function(self, offset)
		FauxScrollFrame_OnVerticalScroll(self, offset, ROW_HEIGHT, function() UpdateScrollFrame(self) end) 
	end)
	rightFrame.scrollFrame = rightSF
	
	local rightScrollBar = _G[rightSF:GetName().."ScrollBar"]
	rightScrollBar:ClearAllPoints()
	rightScrollBar:SetPoint("BOTTOMRIGHT")
	rightScrollBar:SetPoint("TOPRIGHT")
	rightScrollBar:SetWidth(12)
	
	local thumbTex = rightScrollBar:GetThumbTexture()
	thumbTex:SetPoint("CENTER")
	TSMAPI.Design:SetFrameColor(thumbTex)
	thumbTex:SetHeight(150)
	thumbTex:SetWidth(rightScrollBar:GetWidth())
	_G[rightScrollBar:GetName().."ScrollUpButton"]:Hide()
	_G[rightScrollBar:GetName().."ScrollDownButton"]:Hide()
	
	
	
	local label = TSMAPI.GUI:CreateLabel(frame, "normal")
	label:SetText("Filter:")
	label:SetPoint("TOPLEFT", 0, -5)
	label:SetHeight(20)
	label:SetJustifyV("CENTER")
	
	local filter = TSMAPI.GUI:CreateInputBox(frame)
	filter:SetPoint("BOTTOMLEFT", label, "BOTTOMRIGHT", 2, 0)
	filter:SetHeight(20)
	filter:SetWidth(150)
	filter:SetScript("OnEnterPressed", OnFilterSet)
	filter.tooltip = L["All items with names containing the specified filter will be selected. This makes it easier to add/remove multiple items at a time."]
	
	local line = TSMAPI.GUI:CreateHorizontalLine(frame, 0)
	line:SetPoint("TOPLEFT", 0, -58)
	line:SetPoint("TOPRIGHT", 0, -58)
	local line = TSMAPI.GUI:CreateVerticalLine(frame, 0)
	line:ClearAllPoints()
	line:SetPoint("TOP", 0, -60)
	line:SetPoint("BOTTOM")

	local ignoreCheckBox = TSMAPI.GUI:CreateCheckBox(frame, L["When checked, random enchants will be ignored for ungrouped items.\n\nNB: This will not affect parent group items that were already added with random enchants\n\nIf you have this checked when adding an ungrouped randomly enchanted item, it will act as all possible random enchants of that item."])
	ignoreCheckBox:SetLabel(L["Ignore Random Enchants on Ungrouped Items"])
	ignoreCheckBox:SetPoint("BOTTOMLEFT", filter, "BOTTOMRIGHT", 20, 5)
	ignoreCheckBox:SetPoint("TOPRIGHT", 0, -2)
	ignoreCheckBox:SetCallback("OnValueChanged", OnIgnoreChanged)
	
	local addBtn = TSMAPI.GUI:CreateButton(frame, 18)
	addBtn:SetPoint("TOPLEFT", 0, -33)
	addBtn:SetWidth(170)
	addBtn:SetHeight(20)
	addBtn:SetText(L["Add >>>"])
	addBtn.type = "Add"
	addBtn:SetScript("OnClick", OnButtonClick)
	
	local removeBtn = TSMAPI.GUI:CreateButton(frame, 18)
	removeBtn:SetPoint("TOPRIGHT", 0, -33)
	removeBtn:SetWidth(170)
	removeBtn:SetHeight(20)
	removeBtn:SetText(L["<<< Remove"])
	removeBtn.type = "Remove"
	removeBtn:SetScript("OnClick", OnButtonClick)
	removeBtn.tooltip = L["You can hold shift while clicking this button to remove the items from ALL groups rather than keeping them in the parent group (if one exists)."]
	
	local clearBtn = TSMAPI.GUI:CreateButton(frame, 16)
	clearBtn:SetPoint("BOTTOMLEFT", addBtn, "BOTTOMRIGHT", 15, 0)
	clearBtn:SetPoint("BOTTOMRIGHT", removeBtn, "BOTTOMLEFT", -15, 0)
	clearBtn:SetHeight(20)
	clearBtn:SetText(L["Clear Selection"])
	clearBtn:SetScript("OnClick", OnClearButtonClicked)
	clearBtn.tooltip = L["Deselects all items in both columns."]
	

	local widget = {
		leftFrame = leftFrame,
		leftScrollFrame = leftSF,
		rightFrame = rightFrame,
		rightScrollFrame = rightSF,
		ignoreCheckBox = ignoreCheckBox,
		filter = filter,
		clearBtn = clearBtn,
		frame = frame,
		type  = Type
	}
	for method, func in pairs(methods) do
		widget[method] = func
	end
	
	addBtn.obj = widget
	removeBtn.obj = widget
	widget.ignoreCheckBox.obj = widget
	widget.filter.obj = widget
	widget.clearBtn.obj = widget
	widget.leftFrame.obj = widget
	widget.rightFrame.obj = widget
	widget.frame.obj = widget

	return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)