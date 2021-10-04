-- ------------------------------------------------------------------------------ --
--                                TradeSkillMaster                                --
--                http://www.curse.com/addons/wow/tradeskill-master               --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- Much of this code is copied from .../AceGUI-3.0/widgets/AceGUIContainer-Frame.lua
-- This Frame container is modified to fit TSM's theme / needs
local TSM = select(2, ...)
local Type, Version = "TSMMainFrame", 2
local AceGUI = LibStub("AceGUI-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster") -- loads the localization table
if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end

local ICON_TEXT_COLOR = {165/255, 168/255, 188/255, .7}


--[[-----------------------------------------------------------------------------
Scripts
-------------------------------------------------------------------------------]]
local function Frame_OnClose(frame)
	frame.obj:Fire("OnClose")
end

local function CloseButton_OnClick(frame)
	PlaySound("gsTitleOptionExit")
	frame.obj:Hide()
end

local function Frame_OnMouseDown(frame)
	frame.toMove:GetScript("OnMouseDown")(frame.toMove)
	AceGUI:ClearFocus()
end

local function Frame_OnMouseUp(frame)
	frame.toMove:GetScript("OnMouseUp")(frame.toMove)
	AceGUI:ClearFocus()
end

local function Sizer_OnMouseUp(mover)
	local frame = mover:GetParent()
	frame:StopMovingOrSizing()
	frame:SavePositionAndSize()
	local self = frame.obj
	local status = self.status or self.localstatus
	status.width = frame:GetWidth()
	status.height = frame:GetHeight()
	status.top = frame:GetTop()
	status.left = frame:GetLeft()
end

local function Sizer_OnMouseDown(frame)
	frame:GetParent():StartSizing("BOTTOMRIGHT")
	AceGUI:ClearFocus()
end

local function Icon_OnEnter(btn)
	btn.dark:Hide()
	GameTooltip:SetOwner(btn, btn:GetParent().tooltipAnchor)
	GameTooltip:SetText(btn.title)
	GameTooltip:Show()
end

local function Icon_OnLeave(btn)
	if btn.obj.selected ~= btn then
		btn.dark:Show()
	end
	GameTooltip:Hide()
end


--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
local methods = {
	["OnAcquire"] = function(self)
		self.frame:RefreshPosition()
		self.frame:SetFrameStrata("MEDIUM")
		self:SetTitle()
		self:ApplyStatus()
		self:Show()
	end,

	["OnRelease"] = function(self)
		self.status = nil
		wipe(self.localstatus)
	end,
	
	["LayoutIcons"] = function(self)
		for _, container in ipairs({self.topLeftIcons, self.topRightIcons}) do
			if type(container.icons) == "table" and container.icons[1] then
				local numIcons = #container.icons
				local iconSize = container.icons[1]:GetHeight()
				local spacing = (container:GetWidth() - numIcons * iconSize) / (numIcons + 1)
				local width = iconSize
				if spacing < 1 then
					spacing = 1
					width = (container:GetWidth() - (numIcons - 1) * spacing) / numIcons
				end
				for i, icon in ipairs(container.icons) do
					icon:SetPoint("TOPLEFT", spacing+(i-1)*(width+spacing), 0)
					icon:SetWidth(width)
				end
			end
		end
	end,

	["OnWidthSet"] = function(self, width)
		self.content.width = self.content:GetWidth()
		
		self.topLeftIcons:ClearAllPoints()
		self.topLeftIcons:SetPoint("TOPLEFT", 5, 20)
		self.topLeftIcons:SetPoint("TOPRIGHT", self.frame, "TOP", -115, 20)
		self.topLeftIcons:SetHeight(51)
		
		self.topRightIcons:ClearAllPoints()
		self.topRightIcons:SetPoint("TOPRIGHT", -5, 20)
		self.topRightIcons:SetPoint("TOPLEFT", self.frame, "TOP", 115, 20)
		self.topRightIcons:SetHeight(51)
		
		self:LayoutIcons()
	end,

	["OnHeightSet"] = function(self, height)
		self.content.height = self.content:GetHeight()
	end,

	["SetTitle"] = function(self, title)
		self.titletext:SetText(title)
	end,
	
	["SetIconText"] = function(self, title)
		self.icontext:SetText(title)
	end,
	
	["SetIconLabels"] = function(self, topLeft, topRight)
		self.topLeftIcons.label = topLeft
		self.topRightIcons.label = topRight
	end,

	["Hide"] = function(self)
		self.frame:Hide()
	end,

	["Show"] = function(self)
		self.frame:Show()
	end,
	
	["UpdateSelected"] = function(self)
		for _, container in ipairs({self.topLeftIcons, self.topRightIcons}) do
			if type(container.icons) == "table" then
				for _, icon in ipairs(container.icons) do
					icon.dark:Show()
				end
			end
		end
		self.selected.dark:Hide()
	end,
	
	["AddIcon"] = function(self, info)
		local container = self[info.where.."Icons"]
		assert(container, "Invalid icon container.")
		
		local size = 51
		
		local btn = CreateFrame("Button", nil, container)
		btn:SetBackdrop({edgeFile="Interface\\Buttons\\WHITE8X8", edgeSize=2})
		btn:SetBackdropBorderColor(0, 0, 0, 0.5)
		btn:SetHeight(size)
		btn:SetWidth(size)
		btn.title = info.name
		btn.info = info
		btn.obj = self
		info.frame = btn
		
		local image = btn:CreateTexture(nil, "BACKGROUND")
		image:SetAllPoints()
		image:SetTexture(info.texture)
		image:SetTexCoord(0.08, 0.922, 0.09, 0.918)
		image:SetVertexColor(1, 1, 1)
		btn.image = image
		
		local dark = btn:CreateTexture(nil, "OVERLAY")
		dark:SetAllPoints(image)
		dark:SetTexture(0, 0, 0, .3)
		dark:SetBlendMode("BLEND")
		btn.dark = dark
		btn:SetScript("OnEnter", Icon_OnEnter)
		btn:SetScript("OnLeave", Icon_OnLeave)
		btn:SetScript("OnClick", function(btn)
				if #self.children > 0 then
					self:ReleaseChildren()
				end
				self:SetTitle(btn.title)
				btn.info.loadGUI(self)
				self.selected = btn
				self:UpdateSelected()
			end)
		
		local highlight = btn:CreateTexture(nil, "HIGHLIGHT")
		highlight:SetAllPoints(image)
		highlight:SetTexture(1, 1, 1, .2)
		highlight:SetBlendMode("ADD")
		btn.highlight = highlight
		
		container.icons = container.icons or {}
		tinsert(container.icons, btn)
		
		self:LayoutIcons()
		
		if not container.textLabel then
			local label = container:CreateFontString()
			label:SetHeight(12)
			label:SetJustifyH("CENTER")
			label:SetJustifyV("CENTER")
			label:SetFont(TSMAPI.Design:GetContentFont("small"))
			TSMAPI.Design:SetIconRegionColor(label)
			label:SetText(container.label)
			label:SetPoint("TOP", 0, -53)
			container.tooltipAnchor = "ANCHOR_TOP"
			container.textLabel = label
			
			-- make the lines that extend the width of the container out from the label
			local leftHLine = container:CreateTexture()
			leftHLine:SetPoint("TOPRIGHT", label, "TOPLEFT", -2, -6)
			leftHLine:SetHeight(1)
			TSMAPI.Design:SetIconRegionColor(leftHLine)
			local rightHLine = container:CreateTexture()
			rightHLine:SetPoint("TOPLEFT", label, "TOPRIGHT", 2, -6)
			rightHLine:SetHeight(1)
			TSMAPI.Design:SetIconRegionColor(rightHLine)
			leftHLine:SetPoint("TOPLEFT", 20, -59)
			rightHLine:SetPoint("TOPRIGHT", -20, -59)
		end
	end,

	-- called to set an external table to store status in
	["SetStatusTable"] = function(self, status)
		assert(type(status) == "table")
		self.status = status
		self:ApplyStatus()
	end,

	["ApplyStatus"] = function(self)
		local status = self.status or self.localstatus
		local frame = self.frame
		self:SetWidth(status.width or self.frame:GetWidth())
		self:SetHeight(status.height or self.frame:GetHeight())
		frame:ClearAllPoints()
		if status.top and status.left then
			frame:SetPoint("TOP", UIParent, "BOTTOM", 0, status.top)
			frame:SetPoint("LEFT", UIParent, "LEFT", status.left, 0)
		else
			frame:SetPoint("CENTER")
		end
	end,
}


--[[-----------------------------------------------------------------------------
Constructor
-------------------------------------------------------------------------------]]
local function Constructor()
	local frameName = Type..AceGUI:GetNextWidgetNum(Type)

	local frameDefaults = {
		x = UIParent:GetWidth()/2,
		y = UIParent:GetHeight()/2,
		width = 823,
		height = 686,
		scale = 1,
	}
	local frame = TSMAPI:CreateMovableFrame(frameName, frameDefaults)
	frame:SetFrameStrata("MEDIUM")
	TSMAPI.Design:SetFrameBackdropColor(frame)
	frame:SetResizable(true)
	frame:SetMinResize(600, 400)
	frame:SetScript("OnHide", Frame_OnClose)
	frame.toMove = frame
	tinsert(UISpecialFrames, frameName)
	
	local closebutton = CreateFrame("Button", nil, frame)
	TSMAPI.Design:SetContentColor(closebutton)
	local highlight = closebutton:CreateTexture(nil, "HIGHLIGHT")
	highlight:SetAllPoints()
	highlight:SetTexture(1, 1, 1, .2)
	highlight:SetBlendMode("BLEND")
	closebutton.highlight = highlight
	closebutton:SetPoint("BOTTOMRIGHT", -29, -14)
	closebutton:SetHeight(29)
	closebutton:SetWidth(86)
	closebutton:SetScript("OnClick", CloseButton_OnClick)
	closebutton:Show()
	local label = closebutton:CreateFontString()
	label:SetPoint("TOP")
	label:SetJustifyH("CENTER")
	label:SetJustifyV("CENTER")
	label:SetHeight(28)
	label:SetFont(TSMAPI.Design:GetContentFont(), 28)
	TSMAPI.Design:SetWidgetTextColor(label)
	label:SetText(CLOSE)
	closebutton:SetFontString(label)
	
	local iconBtn = CreateFrame("Button", nil, frame)
	iconBtn:SetWidth(286)
	iconBtn:SetHeight(286)
	iconBtn:SetPoint("TOP", 0, 174)
	iconBtn:SetScript("OnMouseDown", Frame_OnMouseDown)
	iconBtn:SetScript("OnMouseUp", Frame_OnMouseUp)
	iconBtn.toMove = frame
	local icon = iconBtn:CreateTexture()
	icon:SetAllPoints()
	icon:SetTexture("Interface\\Addons\\TradeSkillMaster\\Media\\TSM_Icon_Pocket")
	frame.icon = icon

	local sizer = CreateFrame("Frame", nil, frame)
	sizer:SetPoint("BOTTOMRIGHT", -2, 2)
	sizer:SetWidth(20)
	sizer:SetHeight(20)
	sizer:EnableMouse()
	sizer:SetScript("OnMouseDown",Sizer_OnMouseDown)
	sizer:SetScript("OnMouseUp", Sizer_OnMouseUp)
	local image = sizer:CreateTexture(nil, "BACKGROUND")
	image:SetAllPoints()
	image:SetTexture("Interface\\Addons\\TradeSkillMaster\\Media\\Sizer")
	
	local content = CreateFrame("Frame", nil, frame)
	content:SetPoint("TOPLEFT", 11, -62)
	content:SetPoint("BOTTOMRIGHT", -11, 20)
	
	local titletext = frame:CreateFontString()
	titletext:SetPoint("TOP", 0, -32)
	titletext:SetHeight(22)
	titletext:SetJustifyH("CENTER")
	titletext:SetJustifyV("CENTER")
	titletext:SetFont(TSMAPI.Design:GetContentFont(), 22)
	TSMAPI.Design:SetTitleTextColor(titletext)
	
	local icontext = iconBtn:CreateFontString(nil, "OVERLAY")
	icontext:SetPoint("TOP", frame, "TOP", 0, 14)
	icontext:SetHeight(29)
	icontext:SetJustifyH("CENTER")
	icontext:SetJustifyV("CENTER")
	icontext:SetFont(TSMAPI.Design:GetContentFont(), 27)
	icontext:SetTextColor(unpack(ICON_TEXT_COLOR))
	
	-- local helpButton = CreateFrame("Button", nil, frame, "MainHelpPlateButton")
	local helpButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
	helpButton:SetPoint("BOTTOMLEFT", -10, -30)
	helpButton:SetScript("OnEnter", function(self)
		HelpPlateTooltip.ArrowRIGHT:Show()
		HelpPlateTooltip.ArrowGlowRIGHT:Show()
		HelpPlateTooltip:SetPoint("LEFT", self, "RIGHT", 10, 0)
		HelpPlateTooltip.Text:SetText(L["Click this to open TSM Assistant."])
		HelpPlateTooltip:Show()
	end)
	helpButton:SetScript("OnLeave", function(self)
		HelpPlateTooltip.ArrowRIGHT:Hide()
		HelpPlateTooltip.ArrowGlowRIGHT:Hide()
		HelpPlateTooltip:ClearAllPoints()
		HelpPlateTooltip:Hide()
	end)
	helpButton:SetScript("OnClick", TSM.Assistant.Open)

	local widget = {
		type = Type,
		localstatus = {},
		frame = frame,
		-- container for children
		content = content,
		-- changable labels
		titletext = titletext,
		icontext = icontext,
		-- containers for the icons - size/pos set by OnWidthSet
		topLeftIcons = CreateFrame("Frame", nil, frame),
		topRightIcons = CreateFrame("Frame", nil, frame),
	}
	for method, func in pairs(methods) do
		widget[method] = func
	end
	closebutton.obj = widget

	return AceGUI:RegisterAsContainer(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)