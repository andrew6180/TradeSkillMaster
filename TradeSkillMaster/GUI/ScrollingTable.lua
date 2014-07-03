-- ------------------------------------------------------------------------------ --
--                                TradeSkillMaster                                --
--                http://www.curse.com/addons/wow/tradeskill-master               --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

local TSM = select(2, ...)
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster") -- loads the localization table

local RT_COUNT = 1

local HEAD_HEIGHT = 27
local HEAD_SPACE = 4


local function OnSizeChanged(st, width, height)
	width = width - 14
	if st.headCols then
		-- adjust head col widths
		for i, col in ipairs(st.headCols) do
			col:SetWidth(col.info.width*width)
		end
	end
	
	-- calculate new number of rows
	st.NUM_ROWS = max(floor((height-st.HEAD_HEIGHT-HEAD_SPACE)/st.ROW_HEIGHT), 0)
	
	-- hide all extra rows and clear their data
	for i=st.NUM_ROWS+1, #st.rows do
		st.rows[i]:Hide()
		st.rows[i].data = nil
	end
	
	while #st.rows < st.NUM_ROWS do
		st:AddRow()
	end
	
	-- adjust rows widths
	for _, row in ipairs(st.rows) do
		for i, col in ipairs(row.cols) do
			if st.headCols then
				col:SetWidth(st.headCols[i].info.width*width)
			else
				col:SetWidth(width)
			end
			if col.text.fontHeight < 13 then
				col.text:SetFont(TSMAPI.Design:GetContentFont(), 13)
				col.text.fontHeight = 13
			end
		end
	end
	
	st:RefreshRows()
end

local function GetTableIndex(tbl, value)
	for i, v in pairs(tbl) do
		if value == v then
			return i
		end
	end
end

local function OnColumnClick(self, button, ...)
	if self.st.sortInfo.enabled and button == "LeftButton" then
		if self.st.sortInfo.col == self.colNum then
			self.st.sortInfo.ascending = not self.st.sortInfo.ascending
		else
			self.st.sortInfo.col = self.colNum
			self.st.sortInfo.ascending = true
		end
		self.st.updateSort = true
		self.st:RefreshRows()
	end
	if self.st.handlers.OnColumnClick then
		self.st.handlers.OnColumnClick(self, button, ...)
	end
end


local defaultColScripts = {
	OnEnter = function(self, ...)
		if not self.row.data then return end
		if not self.st.highlightDisabled then
			self.row.highlight:Show()
		end
		
		local handler = self.st.handlers.OnEnter
		if handler then
			handler(self.st, self.row.data, self, ...)
		end
	end,
	
	OnLeave = function(self, ...)
		if not self.row.data then return end
		if self.st.selectionDisabled or not self.st.selected or self.st.selected ~= GetTableIndex(self.st.rowData, self.row.data) then
			self.row.highlight:Hide()
		end
		
		local handler = self.st.handlers.OnLeave
		if handler then
			handler(self.st, self.row.data, self, ...)
		end
	end,
	
	OnClick = function(self, ...)
		if not self.row.data then return end
		self.st:ClearSelection()
		self.st.selected = GetTableIndex(self.st.rowData, self.row.data)
		self.row.highlight:Show()
		
		local handler = self.st.handlers.OnClick
		if handler then
			handler(self.st, self.row.data, self, ...)
		end
	end,
	
	OnDoubleClick = function(self, ...)
		if not self.row.data then return end
		local handler = self.st.handlers.OnDoubleClick
		if handler then
			handler(self.st, self.row.data, self, ...)
		end
	end,
}

local methods = {
	RefreshRows = function(st)
		if not st.rowData then return end
		FauxScrollFrame_Update(st.scrollFrame, #st.rowData, st.NUM_ROWS, st.ROW_HEIGHT)
		local offset = FauxScrollFrame_GetOffset(st.scrollFrame)
		st.offset = offset
		
		-- hide all rows and clear their data
		for i=1, st.NUM_ROWS do
			st.rows[i]:Hide()
			st.rows[i].data = nil
		end
		
		-- do sorting if enabled
		if st.sortInfo.enabled and st.sortInfo.col and st.updateSort then
			local function SortHelper(rowA, rowB)
				local sortArgA = rowA.cols[st.sortInfo.col].sortArg
				local sortArgB = rowB.cols[st.sortInfo.col].sortArg
				
				if st.sortInfo.ascending then
					return sortArgA < sortArgB
				else
					return sortArgA > sortArgB
				end
			end
			sort(st.rowData, SortHelper)
			st.updateSort = nil
		end
		
		-- set row data
		for i=1, min(st.NUM_ROWS, #st.rowData) do
			st.rows[i]:Show()
			local data = st.rowData[i+offset]
			if not data then break end
			st.rows[i].data = data
			
			if (st.selected == GetTableIndex(st.rowData, data) and not st.selectionDisabled) or st.rows[i]:IsMouseOver() or (st.highlighted and st.highlighted == GetTableIndex(st.rowData, data)) then
				st.rows[i].highlight:Show()
			else
				st.rows[i].highlight:Hide()
			end
			
			for j, col in ipairs(st.rows[i].cols) do
				local colData = data.cols[j]
				if type(colData.value) == "function" then
					col:SetText(colData.value(unpack(colData.args)))
				else
					col:SetText(colData.value)
				end
			end
		end
	end,

	SetData = function(st, rowData)
		st.rowData = rowData
		st.updateSort = true
		st:RefreshRows()
	end,
	
	SetSelection = function(st, rowNum)
		st.selected = rowNum
		st:RefreshRows()
	end,
	
	GetSelection = function(st)
		return st.selected
	end,

	ClearSelection = function(st)
		st.selected = nil
		st:RefreshRows()
	end,
	
	DisableSelection = function(st, value)
		st.selectionDisabled = value
	end,
	
	EnableSorting = function(st, value, defaultCol)
		st.sortInfo.enabled = value
		st.sortInfo.col = abs(defaultCol or 1)
		st.sortInfo.ascending = not defaultCol or defaultCol > 0
		st.updateSort = true
		st:RefreshRows()
	end,
	
	DisableHighlight = function(st, value)
		st.highlightDisabled = value
	end,
	
	SetScrollOffset = function(st, offset)
		local maxOffset = max(#st.rowData - st.NUM_ROWS, 0)
		if not offset or offset < 0 or offset > maxOffset then
			return -- invalid offset
		end
		
		local scrollPercent = offset / maxOffset
		local maxPixelOffset = st.scrollFrame:GetVerticalScrollRange() + st.ROW_HEIGHT * 2
		local pixelOffset = scrollPercent * maxPixelOffset
		FauxScrollFrame_SetOffset(st.scrollFrame, offset)
		st.scrollFrame:SetVerticalScroll(pixelOffset)
	end,
	
	SetHighlighted = function(st, row)
		st.highlighted = row
		st:RefreshRows()
	end,
	
	AddRow = function(st)
		local row = CreateFrame("Frame", nil, st.contentFrame)
		row:SetHeight(st.ROW_HEIGHT)
		if #st.rows == 0 then
			row:SetPoint("TOPLEFT", 0, -(st.HEAD_HEIGHT+HEAD_SPACE))
			row:SetPoint("TOPRIGHT", 0, -(st.HEAD_HEIGHT+HEAD_SPACE))
		else
			row:SetPoint("TOPLEFT", st.rows[#st.rows], "BOTTOMLEFT")
			row:SetPoint("TOPRIGHT", st.rows[#st.rows], "BOTTOMRIGHT")
		end
		local highlight = row:CreateTexture()
		highlight:SetAllPoints()
		highlight:SetTexture(1, .9, 0, .2)
		highlight:Hide()
		row.highlight = highlight
		row.st = st
		
		row.cols = {}
		for j, info in ipairs(st.colInfo or {{}}) do
			local col = CreateFrame("Button", nil, row)
			local text = col:CreateFontString()
			text:SetFont(TSMAPI.Design:GetContentFont(), min(13, st.ROW_HEIGHT))
			text:SetJustifyH(info.align or "LEFT")
			text:SetJustifyV("CENTER")
			text:SetPoint("TOPLEFT", 1, -1)
			text:SetPoint("BOTTOMRIGHT", -1, 1)
			text.fontHeight = min(13, st.ROW_HEIGHT)
			col.text = text
			col:SetFontString(text)
			col:SetHeight(st.ROW_HEIGHT)
			col:RegisterForClicks("AnyUp")
			for name, func in pairs(defaultColScripts) do
				col:SetScript(name, func)
			end
			col.st = st
			col.row = row
			
			if j == 1 then
				col:SetPoint("TOPLEFT")
			else
				col:SetPoint("TOPLEFT", row.cols[j-1], "TOPRIGHT")
			end
			tinsert(row.cols, col)
		end
		
		tinsert(st.rows, row)
	end,
}

function TSMAPI:CreateScrollingTable(parent, colInfo, handlers, headFontSize)
	assert(type(parent) == "table", format("Invalid parent argument. Type is %s.", type(parent)))
	
	local rtName = "TSMScrollingTable"..RT_COUNT
	RT_COUNT = RT_COUNT + 1
	local st = CreateFrame("Frame", rtName, parent)
	if not colInfo then
		st.HEAD_HEIGHT = -HEAD_SPACE
	elseif headFontSize then
		st.HEAD_HEIGHT = headFontSize + 4
	else
		st.HEAD_HEIGHT = HEAD_HEIGHT
	end
	st.ROW_HEIGHT = 15
	st.NUM_ROWS = floor((parent:GetHeight()-st.HEAD_HEIGHT-HEAD_SPACE)/st.ROW_HEIGHT)
	st.colInfo = colInfo
	st:SetScript("OnSizeChanged", OnSizeChanged)
	
	local contentFrame = CreateFrame("Frame", rtName.."Content", st)
	contentFrame:SetPoint("TOPLEFT")
	contentFrame:SetPoint("BOTTOMRIGHT", -15, 0)
	st.contentFrame = contentFrame
	
	-- frame to hold the header columns and the rows
	local scrollFrame = CreateFrame("ScrollFrame", rtName.."ScrollFrame", st, "FauxScrollFrameTemplate")
	scrollFrame:SetScript("OnVerticalScroll", function(self, offset)
		FauxScrollFrame_OnVerticalScroll(self, offset, st.ROW_HEIGHT, function() st:RefreshRows() end) 
	end)
	scrollFrame:SetAllPoints(contentFrame)
	st.scrollFrame = scrollFrame
	
	-- make the scroll bar consistent with the TSM theme
	local scrollBar = _G[scrollFrame:GetName().."ScrollBar"]
	scrollBar:ClearAllPoints()
	scrollBar:SetPoint("BOTTOMRIGHT", st, -1, 1)
	scrollBar:SetPoint("TOPRIGHT", st, -1, -st.HEAD_HEIGHT-HEAD_SPACE)
	scrollBar:SetWidth(12)
	local thumbTex = scrollBar:GetThumbTexture()
	thumbTex:SetPoint("CENTER")
	TSMAPI.Design:SetContentColor(thumbTex)
	thumbTex:SetHeight(50)
	thumbTex:SetWidth(scrollBar:GetWidth())
	_G[scrollBar:GetName().."ScrollUpButton"]:Hide()
	_G[scrollBar:GetName().."ScrollDownButton"]:Hide()
	
	-- create the header columns
	if colInfo then
		st.headCols = {}
		for i, info in ipairs(colInfo) do
			local col = CreateFrame("Button", rtName.."HeadCol"..i, st.contentFrame)
			col:SetHeight(st.HEAD_HEIGHT)
			if i == 1 then
				col:SetPoint("TOPLEFT")
			else
				col:SetPoint("TOPLEFT", st.headCols[i-1], "TOPRIGHT")
			end
			col.info = info
			col.st = st
			col.colNum = i
			col:RegisterForClicks("AnyUp")
			col:SetScript("OnClick", OnColumnClick)
			
			local text = col:CreateFontString()
			text:SetJustifyH(info.headAlign or "CENTER")
			text:SetJustifyV("CENTER")
			if headFontSize then
				text:SetFont(TSMAPI.Design:GetContentFont("normal"), headFontSize)
			else
				text:SetFont(TSMAPI.Design:GetContentFont("normal"))
			end
			TSMAPI.Design:SetWidgetTextColor(text)
			col:SetFontString(text)
			col:SetText(info.name or "")
			text:SetAllPoints()

			local tex = col:CreateTexture()
			tex:SetAllPoints()
			tex:SetTexture("Interface\\Buttons\\UI-Listbox-Highlight")
			tex:SetTexCoord(0.025, 0.957, 0.087, 0.931)
			tex:SetAlpha(0.2)
			col:SetHighlightTexture(tex)
			
			tinsert(st.headCols, col)
		end
		
		TSMAPI.GUI:CreateHorizontalLine(st, -st.HEAD_HEIGHT)
	end
	
	-- set all methods
	for name, func in pairs(methods) do
		st[name] = func
	end
	
	-- create the rows
	st.rows = {}
	for i=1, st.NUM_ROWS do
		st:AddRow()
	end
	
	st:SetAllPoints()
	st.displayRows = {}
	st.handlers = handlers or {}
	st.sortInfo = {enabled=nil}
	
	return st
end