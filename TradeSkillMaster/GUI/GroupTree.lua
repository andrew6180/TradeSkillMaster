-- ------------------------------------------------------------------------------ --
--                                TradeSkillMaster                                --
--                http://www.curse.com/addons/wow/tradeskill-master               --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

local TSM = select(2, ...)
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster") -- loads the localization table

local COUNT = 1
local ROW_HEIGHT = 14


local function UpdateTree(self)
	self.statusText:SetText("")
	local rowData = {}
	local groupPathList, disabledGroupPaths = TSM:GetGroupPathList(self.module)

	for i, groupPath in ipairs(groupPathList) do
		if not disabledGroupPaths[groupPath] then
			local pathParts = { TSM.GROUP_SEP:split(groupPath) }
			local leader = ""
			for i = 1, #pathParts - 1 do
				leader = leader .. "    "
			end
			local hasSubGroups = (groupPathList[i + 1] and (groupPathList[i + 1] == groupPath or strfind(groupPathList[i + 1], "^" .. TSMAPI:StrEscape(groupPath) .. TSM.GROUP_SEP)))
			local parent = #pathParts > 1 and table.concat(pathParts, TSM.GROUP_SEP, 1, #pathParts - 1) or nil
			local index = #rowData + 1
			if self.selectedGroups[groupPath] == nil then
				-- select group by default
				self.selectedGroups[groupPath] = true
			end
			local groupNameText = pathParts[#pathParts]
			if TSM.db.profile.colorGroupName then
				groupNameText = TSMAPI:ColorGroupName(groupNameText, #pathParts)
			end
			rowData[index] = {
				value = leader .. format("%s %s%s|r", groupNameText, TSMAPI.Design:GetInlineColor("link"), hasSubGroups and (self.collapsed[groupPath] and "[+]" or "[-]") or ""),
				groupName = pathParts[#pathParts],
				parent = parent,
				groupPath = groupPath,
				hasSubGroups = hasSubGroups,
				index = index,
				isSelected = not self.isGroupBox and self.selectedGroups[groupPath], -- select all rows by default (unless it's for a GroupBox)
			}
		end
	end

	if #rowData == 0 then
		if #groupPathList == 0 then
			self.statusText:SetText(L["You currently don't have any groups setup. Type '/tsm' and click on the 'TradeSkillMaster Groups' button to setup TSM groups."])
		else
			self.statusText:SetText(format(L["None of your groups have %s operations assigned. Type '/tsm' and click on the 'TradeSkillMaster Groups' button to assign operations to your TSM groups."], self.module))
		end
	else
		self.statusText:SetText("")
	end

	self.rowData = rowData
	self:RefreshRows()
end

local function SelectAll(self)
	for i = 1, #self.st.rowData do
		self.st.selectedGroups[self.st.rowData[i].groupPath] = true
		self.st.rowData[i].isSelected = true
	end
	self.st:RefreshRows()
	for _, row in ipairs(self.st.rows) do
		row.highlight:Show()
	end
end

local function DeselectAll(self)
	for i = 1, #self.st.rowData do
		self.st.selectedGroups[self.st.rowData[i].groupPath] = false
		self.st.rowData[i].isSelected = nil
	end
	self.st:RefreshRows()
	for _, row in ipairs(self.st.rows) do
		row.highlight:Hide()
	end
end

local methods = {
	GetRowIndex = function(self, value)
		for i, v in pairs(self.rowData) do
			if v.groupPath == value then
				return i
			end
		end
	end,
	RefreshRows = function(self)
		local offset = FauxScrollFrame_GetOffset(self.scrollFrame)
		self.offset = offset

		for i = #self.rowData, 1, -1 do
			local data = self.rowData[i]
			if not self.isGroupBox and not data.isSelected and data.parent then
				local index = self:GetRowIndex(data.parent)
				if index then
					self.rowData[index].isSelected = self.selectedGroups[self.rowData[index].groupPath]
				end
			end
		end

		local displayRows = {}
		for i = 1, #self.rowData do
			local pathParts = { TSM.GROUP_SEP:split(self.rowData[i].groupPath) }
			local isCollapsed = false
			for i = 1, #pathParts - 1 do
				local path = table.concat(pathParts, TSM.GROUP_SEP, 1, i)
				if self.collapsed[path] then
					isCollapsed = true
					break
				end
			end
			if not isCollapsed then
				if self.collapsed[self.rowData[i].groupPath] then
					self.rowData[i].value = gsub(self.rowData[i].value, TSMAPI:StrEscape("[-]"), "[+]")
				else
					self.rowData[i].value = gsub(self.rowData[i].value, TSMAPI:StrEscape("[+]"), "[-]")
				end
				tinsert(displayRows, self.rowData[i])
			end
		end
		FauxScrollFrame_Update(self.scrollFrame, #displayRows, self.NUM_ROWS, ROW_HEIGHT)

		for i = 1, self.NUM_ROWS do
			if i > #displayRows then
				self.rows[i]:Hide()
				self.rows[i].data = nil
			else
				self.rows[i]:Show()
				local data = displayRows[i + offset]
				if not data then return end
				self.rows[i].data = data

				if data.isSelected or self.rows[i]:IsMouseOver() then
					self.rows[i].highlight:Show()
				else
					self.rows[i].highlight:Hide()
				end
				self.rows[i]:SetText(data.value)
			end
		end
	end,
	SetSelection = function(self, rowNum, isSelected)
		self.selectedGroups[self.rowData[rowNum].groupPath] = isSelected or false
		self.rowData[rowNum].isSelected = isSelected
		self:RefreshRows()
	end,
	GetSelectedGroupInfo = function(self, rowNum)
		local groupInfo = {}
		for _, data in ipairs(self.rowData) do
			if data.isSelected then
				groupInfo[data.groupPath] = { operations = TSM:GetGroupOperations(data.groupPath, self.module), items = TSM:GetGroupItems(data.groupPath) }
				if self.module and not groupInfo[data.groupPath].operations then
					groupInfo[data.groupPath] = nil
				end
			end
		end
		return groupInfo
	end,
	ClearSelection = function(self)
		for i = 1, #self.rowData do
			self.selectedGroups[self.rowData[i].groupPath] = false
			self.rowData[i].isSelected = nil
		end
		self.groupBoxSelection = nil
		self:RefreshRows()
	end,
	SetGropBoxSelection = function(self, groupPath)
		if self.groupBoxSelection then
			self.groupBoxSelection.isSelected = nil
			self.groupBoxSelection = nil
		end
		for i = 1, #self.rowData do
			if self.rowData[i].groupPath == groupPath then
				self.rowData[i].isSelected = true
				self.groupBoxSelection = self.rowData[i]
				break
			end
		end
	end,
	GetGroupBoxSelection = function(self)
		return self.groupBoxSelection and self.groupBoxSelection.groupPath
	end,
}

local defaultColScripts = {
	OnEnter = function(self)
		local tooltipLines = {}
		tinsert(tooltipLines, format(L["%sLeft-Click|r to select / deselect this group."], TSMAPI.Design:GetInlineColor("link")))
		if self.data.hasSubGroups then
			tinsert(tooltipLines, format(L["%sRight-Click|r to collapse / expand this group."], TSMAPI.Design:GetInlineColor("link")))
		end

		local operations = TSM:GetGroupOperations(self.data.groupPath, self.st.module)
		local operationLine = operations and table.concat(operations, ", ") or L["<No Operation>"]
		tinsert(tooltipLines, "")
		tinsert(tooltipLines, format(L["Operations: %s"], operationLine))

		GameTooltip:SetOwner(self, "ANCHOR_TOP")
		GameTooltip:AddLine(table.concat(tooltipLines, "\n"), 1, 1, 1)
		GameTooltip:Show()

		self.highlight:Show()
	end,
	OnLeave = function(self)
		GameTooltip:Hide()
		if not self.data.isSelected then
			self.highlight:Hide()
		end
	end,
	OnClick = function(self, button)
		if button == "RightButton" then
			self.st.collapsed[self.data.groupPath] = not self.st.collapsed[self.data.groupPath]
			self.st:RefreshRows()
			return
		end
		if self.st.isGroupBox then
			if self.data ~= self.st.groupBoxSelection then
				if self.st.groupBoxSelection then
					self.st.groupBoxSelection.isSelected = false
				end
				self.st.groupBoxSelection = self.data
			end
			self.data.isSelected = true
		else
			self.data.isSelected = not self.data.isSelected
			self.st.selectedGroups[self.data.groupPath] = self.data.isSelected or false
			if self.data.hasSubGroups then
				for i = 1, #self.st.rowData do
					if self.st.rowData[i].groupPath == self.data.groupPath or strfind(self.st.rowData[i].groupPath, "^" .. TSMAPI:StrEscape(self.data.groupPath) .. TSM.GROUP_SEP) then
						self.st.selectedGroups[self.st.rowData[i].groupPath] = self.data.isSelected or false
						self.st.rowData[i].isSelected = self.data.isSelected
					end
				end
			end
		end
		self.st:RefreshRows()
		if self.data.isSelected then
			self.highlight:Show()
		else
			self.highlight:Hide()
		end
	end,
}

function TSMAPI:CreateGroupTree(parent, module, label, isGroupBox)
	assert(type(parent) == "table", format(L["Invalid parent argument type. Expected table, got %s."], type(parent)))

	local name = "TSMGroupTree" .. COUNT
	COUNT = COUNT + 1
	local st = CreateFrame("Frame", name, parent)
	st:SetAllPoints()
	st:SetScript("OnShow", UpdateTree)
	st.NUM_ROWS = floor((parent:GetHeight() - (isGroupBox and 0 or 20)) / ROW_HEIGHT)
	st.isGroupBox = isGroupBox
	st.groupBoxSelection = nil
	st.module = module
	if label or module then
		label = label or module
		if not TSM.db.profile.groupTreeSelectedGroupStatus[label] then
			TSMAPI:CreateTimeDelay(0, function() SelectAll({st=st}) end)
		end
		TSM.db.profile.groupTreeCollapsedStatus[label] = TSM.db.profile.groupTreeCollapsedStatus[label] or {}
		TSM.db.profile.groupTreeSelectedGroupStatus[label] = TSM.db.profile.groupTreeSelectedGroupStatus[label] or {}
		st.collapsed = TSM.db.profile.groupTreeCollapsedStatus[label]
		st.selectedGroups = TSM.db.profile.groupTreeSelectedGroupStatus[label]
	else
		st.collapsed = {}
		st.selectedGroups = {}
	end

	local contentFrame = CreateFrame("Frame", name .. "Content", st)
	contentFrame:SetPoint("TOPLEFT")
	contentFrame:SetPoint("BOTTOMRIGHT", -15, isGroupBox and 0 or 18)
	st.contentFrame = contentFrame

	if not isGroupBox then
		local btn = TSMAPI.GUI:CreateButton(st, 14)
		btn:SetPoint("BOTTOMLEFT", 0, 2)
		btn:SetPoint("BOTTOMRIGHT", st, "BOTTOM", -2, 2)
		btn:SetHeight(16)
		btn:SetText(L["Select All Groups"])
		btn:SetScript("OnClick", SelectAll)
		btn.st = st

		local btn = TSMAPI.GUI:CreateButton(st, 14)
		btn:SetPoint("BOTTOMLEFT", st, "BOTTOM", 2, 2)
		btn:SetPoint("BOTTOMRIGHT", 0, 2)
		btn:SetHeight(16)
		btn:SetText(L["Deselect All Groups"])
		btn:SetScript("OnClick", DeselectAll)
		btn.st = st
	end

	-- frame to hold the rows
	local scrollFrame = CreateFrame("ScrollFrame", name .. "ScrollFrame", st, "FauxScrollFrameTemplate")
	scrollFrame:SetScript("OnVerticalScroll", function(self, offset)
		FauxScrollFrame_OnVerticalScroll(self, offset, ROW_HEIGHT, function() st:RefreshRows() end)
	end)
	scrollFrame:SetAllPoints(contentFrame)
	st.scrollFrame = scrollFrame

	-- make the scroll bar consistent with the TSM theme
	local scrollBar = _G[scrollFrame:GetName() .. "ScrollBar"]
	scrollBar:ClearAllPoints()
	scrollBar:SetPoint("BOTTOMRIGHT", st, -1, isGroupBox and 1 or 19)
	scrollBar:SetPoint("TOPRIGHT", st, -1, -1)
	scrollBar:SetWidth(12)
	local thumbTex = scrollBar:GetThumbTexture()
	thumbTex:SetPoint("CENTER")
	TSMAPI.Design:SetContentColor(thumbTex)
	thumbTex:SetHeight(50)
	thumbTex:SetWidth(scrollBar:GetWidth())
	_G[scrollBar:GetName() .. "ScrollUpButton"]:Hide()
	_G[scrollBar:GetName() .. "ScrollDownButton"]:Hide()

	local text = st:CreateFontString()
	text:SetFont(TSMAPI.Design:GetContentFont("normal"))
	text:SetJustifyH("CENTER")
	text:SetJustifyV("CENTER")
	text:SetPoint("LEFT", 5, 0)
	text:SetPoint("RIGHT", -5, 0)
	text:SetHeight(100)
	text:SetNonSpaceWrap(true)
	st.statusText = text

	-- create the rows
	st.rows = {}
	for i = 1, st.NUM_ROWS do
		local row = CreateFrame("Button", name .. "Row" .. i, st.contentFrame)
		row:SetHeight(ROW_HEIGHT)
		row:RegisterForClicks("AnyUp")
		if i == 1 then
			row:SetPoint("TOPLEFT")
			row:SetPoint("TOPRIGHT")
		else
			row:SetPoint("TOPLEFT", st.rows[i - 1], "BOTTOMLEFT")
			row:SetPoint("TOPRIGHT", st.rows[i - 1], "BOTTOMRIGHT")
		end
		local highlight = row:CreateTexture()
		highlight:SetAllPoints()
		highlight:SetTexture(1, .9, 0, .2)
		highlight:Hide()
		row.highlight = highlight
		local text = row:CreateFontString()
		text:SetFont(TSMAPI.Design:GetContentFont("medium"))
		text:SetJustifyH("LEFT")
		text:SetJustifyV("CENTER")
		text:SetPoint("TOPLEFT", 1, -1)
		text:SetPoint("BOTTOMRIGHT", -1, 1)
		row:SetFontString(text)
		for name, func in pairs(defaultColScripts) do
			row:SetScript(name, func)
		end
		row.st = st
		tinsert(st.rows, row)
	end

	for name, func in pairs(methods) do
		st[name] = func
	end

	UpdateTree(st)

	return st
end