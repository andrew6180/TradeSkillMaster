-- ------------------------------------------------------------------------------ --
--                                TradeSkillMaster                                --
--                http://www.curse.com/addons/wow/tradeskill-master               --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- This module holds some GUI helper functions for modules to use.

local TSM = select(2, ...)
local private = {}
TSMAPI:RegisterForTracing(private, "TradeSkillMaster.Gui_private")
private.frames = {}

TSMAPI.GUI = {}


-- Tooltips!
local function ShowTooltip(self)
	if self.link then
		GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT")
		TSMAPI:SafeTooltipLink(self.link)
		GameTooltip:Show()
	elseif type(self.tooltip) == "function" then
		local text = self.tooltip(self)
		if type(text) == "string" then
			GameTooltip:SetOwner(self, "ANCHOR_TOP")
			--GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
			GameTooltip:SetText(text, 1, 1, 1, 1, true)
			GameTooltip:Show()
		end
	elseif self.tooltip then
		GameTooltip:SetOwner(self, "ANCHOR_TOP")
		--GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
		GameTooltip:SetText(self.tooltip, 1, 1, 1, 1, true)
		GameTooltip:Show()
	elseif self.frame.tooltip then
		GameTooltip:SetOwner(self.frame, "ANCHOR_TOP")
		--GameTooltip:SetOwner(self.frame, "ANCHOR_BOTTOMRIGHT")
		GameTooltip:SetText(self.frame.tooltip, 1, 1, 1, 1, true)
		GameTooltip:Show()
	end
end

local function HideTooltip()
	-- BattlePetTooltip:Hide()
	GameTooltip:Hide()
end

function TSMAPI.GUI:CreateButton(parent, textHeight, name, isSecure)
	local btn = CreateFrame("Button", name, parent, isSecure and "SecureActionButtonTemplate")
	TSMAPI.Design:SetContentColor(btn)
	local highlight = btn:CreateTexture(nil, "HIGHLIGHT")
	highlight:SetAllPoints()
	highlight:SetTexture(1, 1, 1, .2)
	highlight:SetBlendMode("BLEND")
	btn.highlight = highlight
	btn:SetScript("OnEnter", function(self) if self.tooltip then ShowTooltip(self) end end)
	btn:SetScript("OnLeave", HideTooltip)
	btn:Show()
	local label = btn:CreateFontString()
	label:SetFont(TSMAPI.Design:GetContentFont(), textHeight)
	label:SetPoint("CENTER")
	label:SetJustifyH("CENTER")
	label:SetJustifyV("CENTER")
	label:SetHeight(textHeight)
	TSMAPI.Design:SetWidgetTextColor(label)
	btn:SetFontString(label)
	TSM:Hook(btn, "Enable", function() TSMAPI.Design:SetWidgetTextColor(label) end, true)
	TSM:Hook(btn, "Disable", function() TSMAPI.Design:SetWidgetTextColor(label, true) end, true)
	return btn
end

function TSMAPI.GUI:CreateHorizontalLine(parent, ofsy, relativeFrame, invertedColor)
	relativeFrame = relativeFrame or parent
	local barTex = parent:CreateTexture()
	barTex:SetPoint("TOPLEFT", relativeFrame, "TOPLEFT", 2, ofsy)
	barTex:SetPoint("TOPRIGHT", relativeFrame, "TOPRIGHT", -2, ofsy)
	barTex:SetHeight(2)
	if invertedColor then
		TSMAPI.Design:SetFrameColor(barTex)
	else
		TSMAPI.Design:SetContentColor(barTex)
	end
	return barTex
end

function TSMAPI.GUI:CreateVerticalLine(parent, ofsx, relativeFrame, invertedColor)
	relativeFrame = relativeFrame or parent
	local barTex = parent:CreateTexture()
	barTex:SetPoint("TOPLEFT", relativeFrame, "TOPLEFT", ofsx, -2)
	barTex:SetPoint("BOTTOMLEFT", relativeFrame, "BOTTOMLEFT", ofsx, 2)
	barTex:SetWidth(2)
	if invertedColor then
		TSMAPI.Design:SetFrameColor(barTex)
	else
		TSMAPI.Design:SetContentColor(barTex)
	end
	return barTex
end

function TSMAPI.GUI:CreateInputBox(parent, name, autoComplete)
	local function OnEscapePressed(self)
		self:ClearFocus()
		self:HighlightText(0, 0)
	end

	local eb = CreateFrame("EditBox", name, parent)
	eb:SetFont(TSMAPI.Design:GetContentFont("normal"))
	eb:SetShadowColor(0, 0, 0, 0)
	TSMAPI.Design:SetContentColor(eb)
	eb:SetAutoFocus(false)
	eb:SetScript("OnEscapePressed", function(self) self:ClearFocus() self:HighlightText(0, 0) end)
	eb:SetScript("OnEnter", function(self) if self.tooltip then ShowTooltip(self) end end)
	eb:SetScript("OnLeave", HideTooltip)
	return eb
end

function TSMAPI.GUI:SetAutoComplete(inputBox, params)
	local autoCompleteHandlers = {"OnTabPressed", "OnEnterPressed", "OnTextChanged", "OnChar", "OnEditFocusLost", "OnEscapePressed"}--, "OnArrowPressed"}
	if params then
		if inputBox._priorTSMHandlers then return end -- already done
		inputBox.autoCompleteParams = params
		inputBox._priorTSMHandlers = {}
		for _, name in ipairs(autoCompleteHandlers) do
			inputBox._priorTSMHandlers[name] = inputBox:GetScript(name)
			inputBox:SetScript(name, function(self, ...) return _G["AutoCompleteEditBox_"..name](self, ...) or (self._priorTSMHandlers[name] and self._priorTSMHandlers[name](self, ...)) end)
		end
	else
		if not inputBox._priorTSMHandlers then return end -- already done
		for _, name in ipairs(autoCompleteHandlers) do
			inputBox:SetScript(name, inputBox._priorTSMHandlers[name])
		end
		inputBox._priorTSMHandlers = nil
	end
end

function TSMAPI.GUI:CreateLabel(parent, size)
	local label = parent:CreateFontString()
	label:SetFont(TSMAPI.Design:GetContentFont(size))
	TSMAPI.Design:SetWidgetLabelColor(label)
	return label
end

function TSMAPI.GUI:CreateTitleLabel(parent, size)
	local label = parent:CreateFontString()
	label:SetFont(TSMAPI.Design:GetBoldFont(), size)
	TSMAPI.Design:SetTitleTextColor(label)
	return label
end

function TSMAPI.GUI:CreateStatusBar(parent, baseName)
	local function UpdateStatus(self, majorStatus, minorStatus)
		if majorStatus then
			self.majorStatusBar:SetValue(majorStatus)
			if majorStatus == 100 then
				self.majorStatusBar.ag:Stop()
			elseif not self.majorStatusBar.ag:IsPlaying() then
				self.majorStatusBar.ag:Play()
			end
		end
		if minorStatus then
			self.minorStatusBar:SetValue(minorStatus)
			if minorStatus == 100 then
				self.minorStatusBar.ag:Stop()
			elseif not self.minorStatusBar.ag:IsPlaying() then
				self.minorStatusBar.ag:Play()
			end
		end
	end
	
	local function SetStatusText(self, text)
		self.text:SetText(text)
	end

	local level = parent:GetFrameLevel()
	local frame = CreateFrame("Frame", nil, parent)
	frame:SetHeight(25)
	frame:SetPoint("TOPLEFT", 2, -3)
	frame:SetPoint("TOPRIGHT", -2, -3)
	frame:SetFrameLevel(level+1)
	frame.UpdateStatus = UpdateStatus
	frame.SetStatusText = SetStatusText
	
	-- minor status bar (gray one)
	local statusBar = CreateFrame("STATUSBAR", baseName.."-Minor", frame, "TextStatusBar")
	statusBar:SetOrientation("HORIZONTAL")
	statusBar:SetMinMaxValues(0, 100)
	statusBar:SetAllPoints()
	statusBar:SetStatusBarTexture("Interface\\Buttons\\WHITE8X8")
	statusBar:SetStatusBarColor(.42, .42, .42, .7)
	statusBar:SetFrameLevel(level+2)
	local ag = statusBar:CreateAnimationGroup()
	local alpha = ag:CreateAnimation("Alpha")
	alpha:SetDuration(1)
	alpha:SetChange(-.5)
	ag:SetLooping("Bounce")
	statusBar.ag = ag
	frame.minorStatusBar = statusBar
	
	-- major status bar (main blue one)
	local statusBar = CreateFrame("STATUSBAR", baseName.."-Major", frame, "TextStatusBar")
	statusBar:SetOrientation("HORIZONTAL")
	statusBar:SetMinMaxValues(0, 100)
	statusBar:SetAllPoints()
	statusBar:SetStatusBarTexture("Interface\\Buttons\\WHITE8X8")
	statusBar:SetStatusBarColor(.19, .22, .33, .9)
	statusBar:SetFrameLevel(level+3)
	local ag = statusBar:CreateAnimationGroup()
	local alpha = ag:CreateAnimation("Alpha")
	alpha:SetDuration(1)
	alpha:SetChange(-.5)
	ag:SetLooping("Bounce")
	statusBar.ag = ag
	frame.majorStatusBar = statusBar
	
	local textFrame = CreateFrame("Frame", nil, frame)
	textFrame:SetFrameLevel(level+4)
	textFrame:SetAllPoints(frame)
	-- Text for the StatusBar
	local text = TSMAPI.GUI:CreateLabel(textFrame)
	TSMAPI.Design:SetWidgetTextColor(text)
	text:SetPoint("CENTER")
	frame.text = text
	
	return frame
end

function TSMAPI.GUI:CreateDropdown(parent, list, tooltip)
	local dd = LibStub("AceGUI-3.0"):Create("TSMDropdown")
	dd:SetDisabled()
	dd:SetMultiselect(false)
	dd:SetList(list)
	dd.frame:SetParent(parent)
	dd.frame:Show()
	dd.frame.tooltip = tooltip
	dd:SetCallback("OnEnter", ShowTooltip)
	dd:SetCallback("OnLeave", HideTooltip)
	return dd
end

function TSMAPI.GUI:CreateCheckBox(parent, tooltip)
	local cb = LibStub("AceGUI-3.0"):Create("TSMCheckBox")
	cb.frame:SetParent(parent)
	cb.frame:Show()
	cb.frame.tooltip = tooltip
	cb:SetCallback("OnEnter", ShowTooltip)
	cb:SetCallback("OnLeave", HideTooltip)
	return cb
end

function TSMAPI.GUI:CreateItemLinkLabel(parent, textHeight)
	local btn = CreateFrame("Button", nil, parent)
	btn:SetScript("OnEnter", function(self) if self.link then ShowTooltip(self) end end)
	btn:SetScript("OnLeave", HideTooltip)
	btn:SetScript("OnClick", function(self) if self.link then HandleModifiedItemClick(self.link) end end)
	btn:SetHeight(textHeight)
	btn:Show()
	local text = btn:CreateFontString()
	text:SetFont(TSMAPI.Design:GetContentFont(), textHeight)
	text:SetPoint("TOPLEFT")
	text:SetPoint("BOTTOMLEFT")
	text:SetJustifyH("LEFT")
	text:SetJustifyV("CENTER")
	btn:SetFontString(text)
	return btn
end



-- Registers a movable/resizable frame which TSM will keep track of and persistently store its position / size.
-- The frame must be named for this function to work.
-- Required defaults
--          x  -  x position
--          y  -  y position
--      width  -  width
--     height  -  height
--      scale  -  scale
function TSMAPI:CreateMovableFrame(name, defaults, parent)
	local options = TSM.db.global.frameStatus[name] or CopyTable(defaults)
	options.defaults = defaults
	TSM.db.global.frameStatus[name] = options
	options.hasLoaded = nil
	
	local frame = CreateFrame("Frame", name, parent)
	frame:Hide()
	frame:SetHeight(options.height)
	frame:SetWidth(options.width)
	frame:SetScale(UIParent:GetScale()*options.scale)
	frame:SetPoint("CENTER", frame:GetParent())
	frame:SetToplevel(true)
	frame:EnableMouse(true)
	frame:SetMovable(true)
	frame:SetClampedToScreen(true)
	frame:SetClampRectInsets(options.width-50, -(options.width-50), -(options.height-50), options.height-50)
	frame.SavePositionAndSize = function(self)
		if not options.hasLoaded then return end
		options.width = self:GetWidth()
		options.height = self:GetHeight()
		options.x = self:GetLeft()
		options.y = self:GetBottom()
		self:SetClampRectInsets(options.width-50, -(options.width-50), -(options.height-50), options.height-50)
	end
	frame:SetScript("OnMouseDown", frame.StartMoving)
	frame:SetScript("OnMouseUp", function(self) self:StopMovingOrSizing() self:SavePositionAndSize() end)
	frame:SetScript("OnSizeChanged", frame.SavePositionAndSize)
	frame.RefreshPosition = function(self)
		options.hasLoaded = true
		self:SetScale(UIParent:GetScale()*options.scale)
		self:SetFrameLevel(0)
		self:ClearAllPoints()
		self:SetPoint("BOTTOMLEFT", UIParent, options.x, options.y)
		self:SetWidth(options.width)
		self:SetHeight(options.height)
	end
	frame:SetScript("OnShow", frame.RefreshPosition)
	frame.options = options
	tinsert(private.frames, frame)
	
	return frame
end

function TSM:ResetFrames()
	for _, frame in ipairs(private.frames) do
		-- reset all fields to the default values without breaking any table references
		local options = TSM.db.global.frameStatus[frame:GetName()]
		options.hasLoaded = true
		local defaults = options.defaults
		for i, v in pairs(defaults) do options[i] = v end
		if frame and frame:IsVisible() then
			frame:RefreshPosition()
		end
	end
	
	-- explicitly reset bankui since it can't easily use TSMAPI:CreateMovableFrame
	TSM:ResetBankUIFramePosition()
end