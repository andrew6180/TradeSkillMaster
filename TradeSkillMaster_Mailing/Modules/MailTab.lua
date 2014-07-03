-- ------------------------------------------------------------------------------ --
--                            TradeSkillMaster_Mailing                            --
--            http://www.curse.com/addons/wow/tradeskillmaster_mailing            --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

local TSM = select(2, ...)
local MailTab = TSM:NewModule("MailTab", "AceEvent-3.0", "AceHook-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster_Mailing") -- loads the localization table

local private = {tabs = {}}


function MailTab:OnEnable()
	MailTab:RegisterEvent("MAIL_SHOW", function() TSMAPI:CreateTimeDelay("mailShowDelay", 0, private.OnMailShow) end)
end

function private:OnMailShow()
	private.frame = private.frame or private:CreateMailTab()
	if TSM.db.global.defaultMailTab then
		for i=1, MailFrame.numTabs do
			if _G["MailFrameTab"..i].isTSMTab then
				_G["MailFrameTab"..i]:Click()
				break
			end
		end
	end
	
	-- make sure the second tab gets loaded so we can send mail
	local currentTab = PanelTemplates_GetSelectedTab(MailFrame)
	MailFrameTab2:Click()
	_G["MailFrameTab"..currentTab]:Click()
end

function private:CreateMailTab()
	local frame = CreateFrame("Frame", nil, MailFrame)
	TSMAPI.Design:SetFrameBackdropColor(frame)
	frame:Hide()
	frame:SetPoint("TOPLEFT")
	frame:SetPoint("BOTTOMRIGHT", 40, 0)
	frame:EnableMouse(true)
	
	local function OnTabClick(self)
		PanelTemplates_SetTab(MailFrame, self:GetID())
		ButtonFrameTemplate_HideButtonBar(MailFrame)
		InboxFrame:Hide()
		OpenMailFrame:Hide()
		StationeryPopupFrame:Hide()
		SendMailFrame:Hide()
		SetSendMailShowing(false)
		
		MailFrameInset:Hide()
		MailFramePortraitFrame:Hide()
		MailFrameBg:Hide()
		if MailFrameText then MailFrameText:Hide() end
		MailFrameTitleBg:Hide()
		MailFrameTitleText:Hide()
		MailFrameCloseButton:Hide()
		
		MailFrameLeftBorder:Hide()
		MailFrameTopBorder:Hide()
		MailFrameRightBorder:Hide()
		MailFrameBottomBorder:Hide()
		MailFrameTopTileStreaks:Hide()
		MailFrameTopRightCorner:Hide()
		MailFrameBotLeftCorner:Hide()
		MailFrameBotRightCorner:Hide()
		
		private.frame:Show()
		if TSM.db.global.defaultPage == 1 then
			private.frame.inboxBtn:Click()
		elseif TSM.db.global.defaultPage == 2 then
			private.frame.groupsBtn:Click()
		elseif TSM.db.global.defaultPage == 3 then
			private.frame.quickSendBtn:Click()
		elseif TSM.db.global.defaultPage == 4 then
			private.frame.otherBtn:Click()
		end
	end
	
	local function OnOtherTabClick()
		if not private.frame then return end
		private.frame:Hide()
		MailFrameLeftBorder:Show()
		MailFrameTopBorder:Show()
		MailFrameRightBorder:Show()
		MailFrameBottomBorder:Show()
		MailFrameTopTileStreaks:Show()
		MailFrameTopRightCorner:Show()
		MailFrameBotLeftCorner:Show()
		MailFrameBotRightCorner:Show()
		
		MailFrameInset:Show()
		MailFramePortraitFrame:Show()
		MailFrameBg:Show()
		if MailFrameText then MailFrameText:Show() end
		MailFrameTitleBg:Show()
		MailFrameTitleText:Show()
		MailFrameCloseButton:Show()
	end
	
	MailTab:Hook("MailFrameTab_OnClick", OnOtherTabClick, true)

	local n = MailFrame.numTabs + 1
	local tab = CreateFrame("Button", "MailFrameTab"..n, MailFrame, "FriendsFrameTabTemplate")
	tab:Hide()
	tab:SetID(n)
	tab:SetText(TSMAPI.Design:GetInlineColor("link2").."TSM_Mailing|r")
	tab:SetNormalFontObject(GameFontHighlightSmall)
	tab.isTSMTab = true
	tab:SetPoint("LEFT", _G["MailFrameTab"..n-1], "RIGHT", -8, 0)
	tab:Show()
	tab:SetScript("OnClick", OnTabClick)
	PanelTemplates_SetNumTabs(MailFrame, n)
	PanelTemplates_EnableTab(MailFrame, n)
	frame.tab = tab
	
	local iconFrame = CreateFrame("Frame", nil, frame)
	iconFrame:SetPoint("CENTER", frame, "TOPLEFT", 25, -25)
	iconFrame:SetHeight(80)
	iconFrame:SetWidth(80)
	local icon = iconFrame:CreateTexture(nil, "ARTWORK")
	icon:SetAllPoints()
	icon:SetTexture("Interface\\Addons\\TradeSkillMaster\\Media\\TSM_Icon_Big")
	local ag = iconFrame:CreateAnimationGroup()
	local spin = ag:CreateAnimation("Rotation")
	spin:SetOrder(1)
	spin:SetDuration(2)
	spin:SetDegrees(90)
	local spin = ag:CreateAnimation("Rotation")
	spin:SetOrder(2)
	spin:SetDuration(4)
	spin:SetDegrees(-180)
	local spin = ag:CreateAnimation("Rotation")
	spin:SetOrder(3)
	spin:SetDuration(2)
	spin:SetDegrees(90)
	ag:SetLooping("REPEAT")
	iconFrame:SetScript("OnEnter", function() ag:Play() end)
	iconFrame:SetScript("OnLeave", function() ag:Stop() end)
	
	local title = TSMAPI.GUI:CreateLabel(frame)
	title:SetPoint("TOPLEFT", 40, -5)
	title:SetPoint("BOTTOMRIGHT", frame, "TOPRIGHT", -5, -25)
	title:SetJustifyH("CENTER")
	title:SetJustifyV("CENTER")
	title:SetText("TSM_Mailing - "..TSM._version)
	
	local closeBtn = TSMAPI.GUI:CreateButton(frame, 19)
	closeBtn:SetPoint("TOPRIGHT", -5, -5)
	closeBtn:SetWidth(20)
	closeBtn:SetHeight(20)
	closeBtn:SetText("X")
	closeBtn:SetScript("OnClick", CloseMail)
	
	local line = TSMAPI.GUI:CreateVerticalLine(frame, 0)
	line:ClearAllPoints()
	line:SetPoint("TOPRIGHT", -30, -1)
	line:SetWidth(2)
	line:SetHeight(30)
	TSMAPI.GUI:CreateHorizontalLine(frame, -30)
	
	private:CreateTabs(frame)
	return frame
end

function private:CreateTabs(frame)
	local function OnButtonClick(self)
		frame.inboxTab:Hide()
		frame.groupsTab:Hide()
		frame.otherTab:Hide()
		frame.quickSendTab:Hide()
		
		frame.inboxBtn:UnlockHighlight()
		frame.groupsBtn:UnlockHighlight()
		frame.otherBtn:UnlockHighlight()
		frame.quickSendBtn:UnlockHighlight()
		self:LockHighlight()
	
		if self == frame.inboxBtn then
			frame.inboxTab:Show()
		elseif self == frame.groupsBtn then
			frame.groupsTab:Show()
		elseif self == frame.otherBtn then
			frame.otherTab:Show()
		elseif self == frame.quickSendBtn then
			frame.quickSendTab:Show()
		end
	end
	
	local button = TSMAPI.GUI:CreateButton(frame, 15)
	button:SetPoint("TOPLEFT", 70, -40)
	button:SetHeight(20)
	button:SetWidth(55)
	button:SetText(L["Inbox"])
	button:SetScript("OnClick", OnButtonClick)
	frame.inboxBtn = button
	
	local button = TSMAPI.GUI:CreateButton(frame, 15)
	button:SetPoint("TOPLEFT", frame.inboxBtn, "TOPRIGHT", 5, 0)
	button:SetHeight(20)
	button:SetWidth(95)
	button:SetText(L["TSM Groups"])
	button:SetScript("OnClick", OnButtonClick)
	frame.groupsBtn = button
	
	local button = TSMAPI.GUI:CreateButton(frame, 15)
	button:SetPoint("TOPLEFT", frame.groupsBtn, "TOPRIGHT", 5, 0)
	button:SetHeight(20)
	button:SetWidth(85)
	button:SetText(L["Quick Send"])
	button:SetScript("OnClick", OnButtonClick)
	frame.quickSendBtn = button
	
	local button = TSMAPI.GUI:CreateButton(frame, 15)
	button:SetPoint("TOPLEFT", frame.quickSendBtn, "TOPRIGHT", 5, 0)
	button:SetPoint("TOPRIGHT", -5, -40)
	button:SetHeight(20)
	button:SetText(L["Other"])
	button:SetScript("OnClick", OnButtonClick)
	frame.otherBtn = button
	
	TSMAPI.GUI:CreateHorizontalLine(frame, -70)
	
	local content = CreateFrame("Frame", nil, frame)
	content:SetPoint("TOPLEFT", 0, -70)
	content:SetPoint("BOTTOMRIGHT")
	
	frame.inboxTab = TSM.Inbox:CreateTab(content)
	frame.inboxTab:Hide()
	frame.groupsTab = TSM.Groups:CreateTab(content)
	frame.groupsTab:Hide()
	frame.otherTab = TSM.Other:CreateTab(content)
	frame.otherTab:Hide()
	frame.quickSendTab = TSM.QuickSend:CreateTab(content)
	frame.quickSendTab:Hide()
end