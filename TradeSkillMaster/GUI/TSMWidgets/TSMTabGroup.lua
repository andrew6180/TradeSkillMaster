-- ------------------------------------------------------------------------------ --
--                                TradeSkillMaster                                --
--                http://www.curse.com/addons/wow/tradeskill-master               --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- Much of this code is copied from .../AceGUI-3.0/widgets/AceGUIContainer-TabGroup.lua
-- This TabGroup container is modified to fit TSM's theme / needs
local TSM = select(2, ...)
local Type, Version = "TSMTabGroup", 2
local AceGUI = LibStub("AceGUI-3.0")
if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end


--[[-----------------------------------------------------------------------------
Support functions
-------------------------------------------------------------------------------]]

local function TabResize(tab, padding, width)
	local tabName = tab:GetName()
	
	local sideWidths = 8
	tab:SetWidth(width + padding + sideWidths)
end

local function UpdateTabLook(frame)
	if frame.disabled then
		TSMAPI.Design:SetWidgetLabelColor(frame.text, true)
		frame:Disable()
		frame.text = frame:GetText()
		frame.bottom:Hide()
	elseif frame.selected then
		TSMAPI.Design:SetWidgetLabelColor(frame.text)
		frame:Disable()
		TSMAPI.Design:SetFrameColor(frame.image)
		frame.bottom:Show()
		frame:SetHeight(29)
		
		if GameTooltip:IsOwned(frame) then
			GameTooltip:Hide()
		end
	else
		TSMAPI.Design:SetWidgetTextColor(frame.text)
		frame:Enable()
		TSMAPI.Design:SetContentColor(frame.image)
		frame.bottom:Hide()
		frame:SetHeight(24)
	end
end

local function Tab_SetText(frame, text)
	frame:_SetText(text)
	local width = frame.obj.frame.width or frame.obj.frame:GetWidth() or 0
	TabResize(frame, 0, frame:GetFontString():GetStringWidth())
end

local function Tab_SetSelected(frame, selected)
	frame.selected = selected
	UpdateTabLook(frame)
end

local function Tab_SetDisabled(frame, disabled)
	frame.disabled = disabled
	UpdateTabLook(frame)
end

local function BuildTabsOnUpdate(frame)
	local self = frame.obj
	self:BuildTabs()
	frame:SetScript("OnUpdate", nil)
end


--[[-----------------------------------------------------------------------------
Scripts
-------------------------------------------------------------------------------]]

local function Tab_OnClick(frame)
	if not (frame.selected or frame.disabled) then
		PlaySound("igCharacterInfoTab")
		frame.obj:SelectTab(frame.value)
	end
end

local function Tab_OnEnter(frame)
	local self = frame.obj
	self:Fire("OnTabEnter", self.tabs[frame.id].value, frame)
end

local function Tab_OnLeave(frame)
	local self = frame.obj
	self:Fire("OnTabLeave", self.tabs[frame.id].value, frame)
end


--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]

local methods = {
	["OnAcquire"] = function(self) end,

	["OnRelease"] = function(self)
		self.status = nil
		for k in pairs(self.localstatus) do
			self.localstatus[k] = nil
		end
		self.tablist = nil
		for _, tab in pairs(self.tabs) do
			tab:Hide()
		end
	end,

	["CreateTab"] = function(self, id)
		local tabname = ("TSMTabGroup%dTab%d"):format(self.num, id)
		local tab = CreateFrame("Button", tabname, self.border)
		tab.obj = self
		tab.id = id
		tab:SetHeight(24)
		TSMAPI.Design:SetFrameColor(tab)
		tab:SetBackdropColor(0, 0, 0, 0)
		local image = tab:CreateTexture(nil, "BACKGROUND")
		image:SetAllPoints()
		TSMAPI.Design:SetContentColor(image)
		tab.image = image
		local bottom = tab:CreateTexture(nil, "OVERLAY")
		bottom:SetHeight(2)
		bottom:SetPoint("BOTTOMLEFT", 1, -1)
		bottom:SetPoint("BOTTOMRIGHT", -1, -1)
		TSMAPI.Design:SetFrameColor(bottom)
		tab.bottom = bottom
		local highlight = tab:CreateTexture(nil, "HIGHLIGHT")
		highlight:SetAllPoints()
		highlight:SetTexture(1, 1, 1, .2)
		highlight:SetBlendMode("BLEND")
		tab.highlight = highlight

		tab.text = tab:CreateFontString()
		tab.text:SetPoint("LEFT", 3, -1)
		tab.text:SetPoint("RIGHT", -3, -1)
		tab.text:SetJustifyH("CENTER")
		tab.text:SetJustifyV("CENTER")
		tab.text:SetFont(TSMAPI.Design:GetContentFont(), 18)
		tab:SetFontString(tab.text)

		tab:SetScript("OnClick", Tab_OnClick)
		tab:SetScript("OnEnter", Tab_OnEnter)
		tab:SetScript("OnLeave", Tab_OnLeave)

		tab._SetText = tab.SetText
		tab.SetText = Tab_SetText
		tab.SetSelected = Tab_SetSelected
		tab.SetDisabled = Tab_SetDisabled

		return tab
	end,

	["SetStatusTable"] = function(self, status)
		assert(type(status) == "table")
		self.status = status
	end,

	["SelectTab"] = function(self, value)
		local status = self.status or self.localstatus
		local found
		for i, v in ipairs(self.tabs) do
			if v.value == value then
				v:SetSelected(true)
				found = true
			else
				v:SetSelected(false)
			end
		end
		status.selected = value
		if found then
			self:Fire("OnGroupSelected", value)
		end
	end,

	["SetTabs"] = function(self, tabs)
		self.tablist = tabs
		self:BuildTabs()
	end,
	
	["ReloadTab"] = function(self)
		local status = self.status or self.localstatus
		if status and status.selected then
			self:Fire("OnGroupSelected", status.selected)
		end
	end,

	["BuildTabs"] = function(self)
		local status = self.status or self.localstatus
		local tablist = self.tablist
		local tabs = self.tabs
		
		if not tablist then return end
		
		local numTabs = #tablist
		local width = self.frame.width or self.frame:GetWidth() or 0
		
		-- Show tabs and set text.
		for i, v in ipairs(tablist) do
			local tab = tabs[i]
			if not tab then
				tab = self:CreateTab(i)
				tabs[i] = tab
			end
			
			tab:Show()
			tab:SetText(v.text)
			tab:SetDisabled(v.disabled)
			tab.value = v.value
		end
		
		-- hide tabs which aren't in use
		for i=numTabs+1, #tabs do
			tabs[i]:Hide()
		end

		--anchor the rows as defined and resize tabs
		for i=1, numTabs do
			local tab = tabs[i]
			tab:ClearAllPoints()
			if i == 1 then
				tab:SetPoint("BOTTOMLEFT", self.frame, "TOPLEFT", 5, -31)
			else
				tab:SetPoint("BOTTOMLEFT", tabs[i-1], "BOTTOMRIGHT", 4, 0)
			end
		end
		
		for i=1, numTabs do
			TabResize(tabs[i], 4, tabs[i]:GetFontString():GetStringWidth())
		end
	end,

	["OnWidthSet"] = function(self, width)
		local content = self.content
		local contentwidth = width - 60
		if contentwidth < 0 then
			contentwidth = 0
		end
		content:SetWidth(contentwidth)
		content.width = contentwidth
		self:BuildTabs(self)
		self.frame:SetScript("OnUpdate", BuildTabsOnUpdate)
	end,

	["OnHeightSet"] = function(self, height)
		local content = self.content
		local contentheight = height - 30
		if contentheight < 0 then
			contentheight = 0
		end
		content:SetHeight(contentheight)
		content.height = contentheight
	end,
	
	["LayoutFinished"] = function(self, width, height)
		if self.noAutoHeight then return end
		self:SetHeight((height or 0) + 30)
	end
}


--[[-----------------------------------------------------------------------------
Constructor
-------------------------------------------------------------------------------]]

local PaneBackdrop  = {
	bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
	tile = true, tileSize = 16, edgeSize = 16,
	insets = { left = 3, right = 3, top = 5, bottom = 3 }
}

local function Constructor()
	local num = AceGUI:GetNextWidgetNum(Type)
	local frame = CreateFrame("Frame",nil,UIParent)
	frame:SetHeight(100)
	frame:SetWidth(100)
	frame:SetFrameStrata("FULLSCREEN_DIALOG")

	local border = CreateFrame("Frame", nil, frame)
	border:SetPoint("TOPLEFT", 1, -30)
	border:SetPoint("BOTTOMRIGHT", -1, 3)
	TSMAPI.Design:SetFrameColor(border)

	local content = CreateFrame("Frame", nil, border)
	content:SetPoint("TOPLEFT", 8, -8)
	content:SetPoint("BOTTOMRIGHT", -8, 8)

	local widget = {
		num          = num,
		frame        = frame,
		localstatus  = {},
		border       = border,
		tabs         = {},
		content      = content,
		type         = Type
	}
	for method, func in pairs(methods) do
		widget[method] = func
	end
	
	widget.Add = TSMAPI.AddGUIElement
	return AceGUI:RegisterAsContainer(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)