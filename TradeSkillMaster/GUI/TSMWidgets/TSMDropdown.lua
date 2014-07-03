-- ------------------------------------------------------------------------------ --
--                                TradeSkillMaster                                --
--                http://www.curse.com/addons/wow/tradeskill-master               --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- Much of this code is copied from .../AceGUI-3.0/widgets/AceGUIWidget-Dropdown.lua
-- This Dropdown widget is modified to fit TSM's theme / needs
local TSM = select(2, ...)
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)
local Type, Version = "TSMDropdown", 2
if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end

-- Lua APIs
local min, max, floor = math.min, math.max, math.floor
local select, pairs, ipairs, type = select, pairs, ipairs, type
local tsort = table.sort

-- WoW APIs
local PlaySound = PlaySound
local UIParent, CreateFrame = UIParent, CreateFrame
local _G = _G


--[[-----------------------------------------------------------------------------
Support functions
-------------------------------------------------------------------------------]]

local function fixlevels(parent,...)
	local i = 1
	local child = select(i, ...)
	while child do
		child:SetFrameLevel(parent:GetFrameLevel()+1)
		fixlevels(child, child:GetChildren())
		i = i + 1
		child = select(i, ...)
	end
end

local function fixstrata(strata, parent, ...)
	local i = 1
	local child = select(i, ...)
	parent:SetFrameStrata(strata)
	while child do
		fixstrata(strata, child, child:GetChildren())
		i = i + 1
		child = select(i, ...)
	end
end


--[[-----------------------------------------------------------------------------
Scripts
-------------------------------------------------------------------------------]]

local function Control_OnEnter(this)
	this.obj:Fire("OnEnter")
end

local function Control_OnLeave(this)
	this.obj:Fire("OnLeave")
end

local function Dropdown_OnHide(this)
	local self = this.obj
	if self.open then
		self.pullout:Close()
	end
end

local function Dropdown_TogglePullout(this, button)
	local self = this.obj
	if self.disabled then return end
	PlaySound("igMainMenuOptionCheckBoxOn") -- missleading name, but the Blizzard code uses this sound
	if self.open then
		self.open = nil
		self.pullout:Close()
		AceGUI:ClearFocus()
	else
		self.open = true
		self.pullout:SetWidth(self.dropdown:GetWidth())
		self.pullout:Open("TOPLEFT", self.frame, "BOTTOMLEFT", 0, self.label:IsShown() and -2 or 0)
		AceGUI:SetFocus(self)
	end
end

local function OnPulloutOpen(this)
	local self = this.userdata.obj
	local value = self.value
	
	if not self.multiselect then
		for i, item in this:IterateItems() do
			item:SetValue(item.userdata.value == value)
		end
	end
	
	self.open = true
end

local function OnPulloutClose(this)
	local self = this.userdata.obj
	self.open = nil
	self:Fire("OnClosed")
end

local function ShowMultiText(self)
	local text
	for i, widget in self.pullout:IterateItems() do
		if widget.type == "TSMDropdown-Item-Toggle" then
			if widget:GetValue() then
				if text then
					text = text..", "..widget:GetText()
				else
					text = widget:GetText()
				end
			end
		end
	end
	self:SetText(text)
end

local function OnItemValueChanged(this, event, checked)
	local self = this.userdata.obj
	
	if self.multiselect then
		self:Fire("OnValueChanged", this.userdata.value, checked)
		ShowMultiText(self)
	else
		if checked then
			self:SetValue(this.userdata.value)
			self:Fire("OnValueChanged", this.userdata.value)
		else
			this:SetValue(true)
		end
		if self.open then	
			self.pullout:Close()
		end
	end
end


--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]

local methods = {
	["OnAcquire"] = function(self)
		local pullout = AceGUI:Create("TSMDropdown-Pullout")
		self.pullout = pullout
		pullout.userdata.obj = self
		pullout:SetCallback("OnClose", OnPulloutClose)
		pullout:SetCallback("OnOpen", OnPulloutOpen)
		self.pullout.frame:SetFrameLevel(self.frame:GetFrameLevel() + 1)
		fixlevels(self.pullout.frame, self.pullout.frame:GetChildren())
		
		self:SetHeight(44)
		self:SetWidth(200)
		self:SetLabel()
		self:ClearMultiselectChecked()
	end,
	
	["OnRelease"] = function(self)
		if self.open then
			self.pullout:Close()
		end
		AceGUI:Release(self.pullout)
		self.pullout = nil
		
		self:SetText("")
		self:SetDisabled(false)
		self:SetMultiselect(false)
		
		self.value = nil
		self.list = nil
		self.open = nil
		self.hasClose = nil
		
		self.frame:ClearAllPoints()
		self.frame:Hide()
	end,
	
	["SetDisabled"] = function(self, disabled)
		self.disabled = disabled
		TSMAPI.Design:SetWidgetTextColor(self.text, disabled)
		TSMAPI.Design:SetWidgetLabelColor(self.label, disabled)
		if disabled then
			self.button:Disable()
		else
			self.button:Enable()
		end
	end,
	
	["ClearFocus"] = function(self)
		if self.open then
			self.pullout:Close()
		end
	end,
	
	["SetText"] = function(self, text)
		self.text:SetText(text or "")
	end,
	
	["SetLabel"] = function(self, text)
		if text and text ~= "" then
			self.label:SetText(text)
			self.label:Show()
			self.dropdown:SetPoint("TOPLEFT", self.frame, "TOPLEFT", 2, -18)
			self:SetHeight(44)
			self.alignoffset = 30
		else
			self.label:SetText("")
			self.label:Hide()
			self.dropdown:SetPoint("TOPLEFT", self.frame, "TOPLEFT", 2, 0)
			self:SetHeight(26)
			self.alignoffset = 12
		end
	end,
	
	["SetValue"] = function(self, value)
		if self.list then
			self:SetText(self.list[value] or "")
		end
		self.value = value
	end,
	
	["GetValue"] = function(self)
		return self.value
	end,
	
	["SetItemValue"] = function(self, item, value)
		if not self.multiselect then return end
		for i, widget in self.pullout:IterateItems() do
			if widget.userdata.value == item then
				if widget.SetValue then
					widget:SetValue(value)
				end
			end
		end
		ShowMultiText(self)
	end,
	
	["SetItemDisabled"] = function(self, item, disabled)
		for i, widget in self.pullout:IterateItems() do
			if widget.userdata.value == item then
				widget:SetDisabled(disabled)
			end
		end
	end,
	
	["AddListItem"] = function(self, value, text, itemType)
		itemType = itemType or "TSMDropdown-Item-Toggle"
		local exists = AceGUI:GetWidgetVersion(itemType)
		if not exists then error(("The given item type, %q, does not exist within AceGUI-3.0"):format(tostring(itemType)), 2) end

		local item = AceGUI:Create(itemType)
		item:SetText(text)
		item.userdata.obj = self
		item.userdata.value = value
		item:SetValue()
		item:SetCallback("OnValueChanged", OnItemValueChanged)
		self.pullout:AddItem(item)
	end,
	
	["AddCloseButton"] = function(self)
		if not self.hasClose then
			local close = AceGUI:Create("TSMDropdown-Item-Execute")
			close:SetText(CLOSE)
			self.pullout:AddItem(close)
			self.hasClose = true
		end
	end,
	
	["SetList"] = function(self, list, order, itemType)
		self.sortlist = self.sortlist or {}
		self.list = list
		self.pullout:Clear()
		self.hasClose = nil
		if not list then return end
		
		if type(order) ~= "table" then
			for v in pairs(list) do
				self.sortlist[#self.sortlist + 1] = v
			end
			tsort(self.sortlist)
			
			for i, key in ipairs(self.sortlist) do
				self:AddListItem(key, list[key], itemType)
				self.sortlist[i] = nil
			end
		else
			for i, key in ipairs(order) do
				self:AddListItem(key, list[key], itemType)
			end
		end
		if self.multiselect then
			ShowMultiText(self)
			self:AddCloseButton()
		end
	end,
	
	["AddItem"] = function(self, value, text, itemType)
		if self.list then
			self.list[value] = text
			self:AddListItem(value, text, itemType)
		end
	end,
	
	["SetMultiselect"] = function(self, multi)
		self.multiselect = multi
		if multi then
			ShowMultiText(self)
			self:AddCloseButton()
		end
	end,
	
	["GetMultiselect"] = function(self)
		return self.multiselect
	end,

	["ClearMultiselectChecked"] = function(self)
		for i, widget in self.pullout:IterateItems() do
			if widget.type == "TSMDropdown-Item-Toggle" then
				widget:SetValue()
			end
		end
	end,
}


--[[-----------------------------------------------------------------------------
Constructor
-------------------------------------------------------------------------------]]

local function Constructor()
	local count = AceGUI:GetNextWidgetNum(Type)
	
	local frame = CreateFrame("Frame", nil, UIParent)
	local dropdown = CreateFrame("Frame", "TSMDropDown"..count, frame, "UIDropDownMenuTemplate")
	
	frame:SetScript("OnHide", Dropdown_OnHide)

	dropdown:ClearAllPoints()
	dropdown:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -7, 0)
	dropdown:SetScript("OnHide", nil)
	dropdown:SetScript("OnEnter", Control_OnEnter)
	dropdown:SetScript("OnLeave", Control_OnLeave)
	dropdown:SetScript("OnMouseUp", function(self, button) Dropdown_TogglePullout(self.obj.button, button) end)
	TSMAPI.Design:SetContentColor(dropdown)

	local left = _G[dropdown:GetName().."Left"]
	local middle = _G[dropdown:GetName().."Middle"]
	local right = _G[dropdown:GetName().."Right"]
	
	middle:ClearAllPoints()
	right:ClearAllPoints()
	
	middle:SetPoint("LEFT", left, "RIGHT", 0, 0)
	middle:SetPoint("RIGHT", right, "LEFT", 0, 0)
	right:SetPoint("TOPRIGHT", dropdown, "TOPRIGHT", 0, 17)

	local button = _G[dropdown:GetName().."Button"]
	button:RegisterForClicks("AnyUp")
	button:SetScript("OnEnter", Control_OnEnter)
	button:SetScript("OnLeave", Control_OnLeave)
	button:SetScript("OnClick", Dropdown_TogglePullout)
	button:ClearAllPoints()
	button:SetPoint("RIGHT", dropdown, 0, 0)

	local text = _G[dropdown:GetName().."Text"]
	text:ClearAllPoints()
	text:SetPoint("RIGHT", button, "LEFT", -2, 0)
	text:SetPoint("LEFT", dropdown, "LEFT", 8, 0)
	text:SetFont(TSMAPI.Design:GetContentFont("normal"))
	text:SetShadowColor(0, 0, 0, 0)
	
	local label = frame:CreateFontString(nil, "OVERLAY")
	label:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
	label:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 0)
	label:SetJustifyH("LEFT")
	label:SetHeight(18)
	label:SetFont(TSMAPI.Design:GetContentFont("small"))
	label:SetShadowColor(0, 0, 0, 0)
	label:Hide()
	
	left:Hide()
	middle:Hide()
	right:Hide()
	
	local widget = {
		frame = frame,
		label = label,
		dropdown = dropdown,
		text = text,
		button = button,
		count = count,
		alignoffset = 30,
		type = Type,
	}
	for method, func in pairs(methods) do
		widget[method] = func
	end
	frame.obj = widget
	dropdown.obj = widget
	text.obj = widget
	button.obj = widget

	return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)