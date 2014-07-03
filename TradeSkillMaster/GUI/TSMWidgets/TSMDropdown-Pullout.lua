-- ------------------------------------------------------------------------------ --
--                                TradeSkillMaster                                --
--                http://www.curse.com/addons/wow/tradeskill-master               --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- Much of this code is copied from .../AceGUI-3.0/widgets/AceGUIWidget-Dropdown.lua
-- This Dropdown-Pullout widget is modified to fit TSM's theme / needs
local TSM = select(2, ...)
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)
local Type, Version = "TSMDropdown-Pullout", 2
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
Globals
-------------------------------------------------------------------------------]]

local sliderBackdrop  = {
	bgFile = "Interface\\Buttons\\UI-SliderBar-Background",
	edgeFile = "Interface\\Buttons\\UI-SliderBar-Border",
	tile = true, tileSize = 8, edgeSize = 8,
	insets = { left = 3, right = 3, top = 3, bottom = 3 }
}

local DEFAULT_WIDTH = 200
local DEFAULT_MAX_HEIGHT = 600


--[[-----------------------------------------------------------------------------
Support functions
-------------------------------------------------------------------------------]]

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

local function OnEnter(item)
	local self = item.pullout
	for k, v in ipairs(self.items) do
		if v.CloseMenu and v ~= item then
			v:CloseMenu()
		end
	end
end

-- See the note in Constructor() for each scroll related function
local function OnMouseWheel(this, value)
	this.obj:MoveScroll(value)
end

local function OnScrollValueChanged(this, value)
	this.obj:SetScroll(value)
end

local function OnSizeChanged(this)
	this.obj:FixScroll()
end


--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]

local methods = {
	["OnAcquire"] = function(self)
		self.frame:SetParent(UIParent)
	end,
	
	["OnRelease"] = function(self)
		self:Clear()
		self.frame:ClearAllPoints()
		self.frame:Hide()
	end,

	["SetScroll"] = function(self, value)
		local status = self.scrollStatus
		local frame, child = self.scrollFrame, self.itemFrame
		local height, viewheight = frame:GetHeight(), child:GetHeight()

		local offset
		if height > viewheight then
			offset = 0
		else
			offset = floor((viewheight - height) / 1000 * value)
		end
		child:ClearAllPoints()
		child:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, offset)
		child:SetPoint("TOPRIGHT", frame, "TOPRIGHT", self.slider:IsShown() and -12 or 0, offset)
		status.offset = offset
		status.scrollvalue = value		
	end,

	["MoveScroll"] = function(self, value)
		local status = self.scrollStatus
		local frame, child = self.scrollFrame, self.itemFrame
		local height, viewheight = frame:GetHeight(), child:GetHeight()

		if height > viewheight then
			self.slider:Hide()
		else
			self.slider:Show()
			local diff = height - viewheight
			local delta = 1
			if value < 0 then
				delta = -1
			end
			self.slider:SetValue(min(max(status.scrollvalue + delta*(1000/(diff/45)),0), 1000))
		end
	end,

	["FixScroll"] = function(self)
		local status = self.scrollStatus
		local frame, child = self.scrollFrame, self.itemFrame
		local height, viewheight = frame:GetHeight(), child:GetHeight()
		local offset = status.offset or 0

		if viewheight < height then
			self.slider:Hide()
			child:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, offset)
			self.slider:SetValue(0)
		else
			self.slider:Show()			
			local value = (offset / (viewheight - height) * 1000)
			if value > 1000 then value = 1000 end
			self.slider:SetValue(value)
			self:SetScroll(value)
			if value < 1000 then
				child:ClearAllPoints()
				child:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, offset)
				child:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -12, offset)
				status.offset = offset
			end
		end
	end,

	["AddItem"] = function(self, item)
		self.items[#self.items + 1] = item
		
		local h = #self.items * 16
		self.itemFrame:SetHeight(h)
		self.frame:SetHeight(min(h + 20, self.maxHeight))
		
		item.frame:SetPoint("LEFT", self.itemFrame, "LEFT")
		item.frame:SetPoint("RIGHT", self.itemFrame, "RIGHT")
		
		item:SetPullout(self)
		item:SetOnEnter(OnEnter)
	end,
	
	["Open"] = function(self, point, relFrame, relPoint, x, y)		
		local items = self.items
		local frame = self.frame
		local itemFrame = self.itemFrame
		
		frame:SetPoint(point, relFrame, relPoint, x, y)

		local height = 8
		for i, item in pairs(items) do
			if i == 1 then
				item:SetPoint("TOP", itemFrame, "TOP", 0, -2)
			else
				item:SetPoint("TOP", items[i-1].frame, "BOTTOM", 0, 1)
			end
			
			item:Show()
			
			height = height + 16
		end
		itemFrame:SetHeight(height)
		fixstrata("TOOLTIP", frame, frame:GetChildren())
		frame:Show()
		self:Fire("OnOpen")
	end,

	["Close"] = function(self)
		self.frame:Hide()
		self:Fire("OnClose")
	end,

	["Clear"] = function(self)
		local items = self.items
		for i, item in pairs(items) do
			AceGUI:Release(item)
			items[i] = nil
		end
	end,

	["IterateItems"] = function(self)
		return ipairs(self.items)
	end,

	["SetHideOnLeave"] = function(self, val)
		self.hideOnLeave = val
	end,

	["SetMaxHeight"] = function(self, height)
		self.maxHeight = height or DEFAULT_MAX_HEIGHT
		if self.frame:GetHeight() > height then
			self.frame:SetHeight(height)
		elseif (self.itemFrame:GetHeight()+20) < height then
			self.frame:SetHeight(self.itemFrame:GetHeight()+20) -- see :AddItem
		end
	end,
	
	["GetRightBorderWidth"] = function(self)
		return 6 + (self.slider:IsShown() and 12 or 0)
	end,

	["GetLeftBorderWidth"] = function(self)
		return 6
	end,
}


--[[-----------------------------------------------------------------------------
Constructor
-------------------------------------------------------------------------------]]

local function Constructor()
	local count = AceGUI:GetNextWidgetNum(Type)
	
	local frame = CreateFrame("Frame", "TSMPullout"..count, UIParent)
	TSMAPI.Design:SetContentColor(frame)
	frame:SetFrameStrata("FULLSCREEN_DIALOG")
	frame:SetClampedToScreen(true)
	frame:SetWidth(DEFAULT_WIDTH)
	frame:SetHeight(DEFAULT_MAX_HEIGHT)

	local scrollFrame = CreateFrame("ScrollFrame", nil, frame)
	local itemFrame = CreateFrame("Frame", nil, scrollFrame)
	
	local slider = CreateFrame("Slider", "TSMPulloutScrollbar"..count, scrollFrame)
	slider:SetOrientation("VERTICAL")
	slider:SetHitRectInsets(0, 0, -10, 0)
	slider:SetBackdrop(sliderBackdrop)
	slider:SetWidth(8)
	slider:SetThumbTexture("Interface\\Buttons\\UI-SliderBar-Button-Vertical")
	slider:SetFrameStrata("FULLSCREEN_DIALOG")

	scrollFrame:SetScrollChild(itemFrame)
	scrollFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", 4, -4)
	scrollFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -4, 4)
	scrollFrame:EnableMouseWheel(true)
	scrollFrame:SetScript("OnMouseWheel", OnMouseWheel)
	scrollFrame:SetScript("OnSizeChanged", OnSizeChanged)
	scrollFrame:SetToplevel(true)
	scrollFrame:SetFrameStrata("FULLSCREEN_DIALOG")
	
	itemFrame:SetPoint("TOPLEFT", scrollFrame, "TOPLEFT", 0, 0)
	itemFrame:SetPoint("TOPRIGHT", scrollFrame, "TOPRIGHT", -12, 0)
	itemFrame:SetHeight(400)
	itemFrame:SetToplevel(true)
	itemFrame:SetFrameStrata("FULLSCREEN_DIALOG")
	
	slider:SetPoint("TOPLEFT", scrollFrame, "TOPRIGHT", -16, 0)
	slider:SetPoint("BOTTOMLEFT", scrollFrame, "BOTTOMRIGHT", -16, 0)
	
	scrollFrame:Show()
	itemFrame:Show()
	slider:Hide()
	
	local widget = {
		frame = frame,
		slider = slider,
		scrollFrame = scrollFrame,
		itemFrame = itemFrame,
		maxHeight = DEFAULT_MAX_HEIGHT,
		scrollStatus = {scrollvalue=0},
		count = count,
		items = {},
		type = Type,
	}
	for method, func in pairs(methods) do
		widget[method] = func
	end
	frame.obj = widget
	scrollFrame.obj = widget
	itemFrame.obj = widget
	slider.obj = widget
	
	slider:SetScript("OnValueChanged", OnScrollValueChanged)
	slider:SetMinMaxValues(0, 1000)
	slider:SetValueStep(1)
	slider:SetValue(0)
	widget:FixScroll()
	
	return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)