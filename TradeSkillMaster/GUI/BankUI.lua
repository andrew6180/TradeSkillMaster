-- ------------------------------------------------------------------------------ --
--                                TradeSkillMaster                                --
--                http://www.curse.com/addons/wow/tradeskill-master               --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- This file contains function for the bank/gbank frame

-- loads the localization table --
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster")

-- load the parent file (TSM) into a local variable and register this file as a module
local TSM = select(2, ...)
local BankUI = TSM:NewModule("BankUI", "AceEvent-3.0")
local AceGUI = LibStub("AceGUI-3.0") -- load the AceGUI librarie

local ui
local bankFrame, bankType
local bFrame = nil
local container = nil
local registeredModules = {}
local private = {}
TSMAPI:RegisterForTracing(private, "TradeSkillMaster.BankUI_private")
private.bankUiButtons = {}

function BankUI:OnEnable()
	BankUI:RegisterEvent("GUILDBANKFRAME_OPENED", function(event)
		bankType = "guild"
		TSMAPI:CreateTimeDelay(0.1, function()
			bankFrame = BankUI:getBankFrame("guildbank")
			if TSM.db.profile.isBankui then
				if #private.bankUiButtons > 0 then
					if ui then
						BankUI:resetPoints(ui)
						ui:Show()
						if TSM.db.global.bankUITab then
							for index, info in ipairs(private.bankUiButtons) do
								if info.moduleName == TSM.db.global.bankUITab then
									ui.buttons[index]:Click()
									break
								end
							end
						else
							ui.buttons[1]:Click()
						end
						return
					end
					ui = BankUI:getFrame(bankFrame)
				end
			end
		end)
	end)

	BankUI:RegisterEvent("BANKFRAME_OPENED", function(event)
		bankType = "bank"
		TSMAPI:CreateTimeDelay(0.1, function()
			bankFrame = BankUI:getBankFrame("bank")
			if TSM.db.profile.isBankui then
				if #private.bankUiButtons > 0 then
					if ui then
						BankUI:resetPoints(ui)
						ui:Show()
						if TSM.db.global.bankUITab then
							for index, info in ipairs(private.bankUiButtons) do
								if info.moduleName == TSM.db.global.bankUITab then
									ui.buttons[index]:Click()
									break
								end
							end
						else
							ui.buttons[1]:Click()
						end
						return
					end
					ui = BankUI:getFrame(bankFrame)
				end
			end
		end)
	end)

	BankUI:RegisterEvent("GUILDBANKFRAME_CLOSED", function(event, addon)
		if ui then ui:Hide() end
		bankType = nil
	end)

	BankUI:RegisterEvent("BANKFRAME_CLOSED", function(event)
		if ui then ui:Hide() end
		bankType = nil
	end)
end

local function createCloseButton(text, parent, func)
	local btn = TSMAPI.GUI:CreateButton(bFrame, 18, "Button")
	btn:SetText(text)
	btn:SetHeight(20)
	btn:SetWidth(20)
	return btn
end

function TSM:RegisterBankUiButton(moduleName, callback)
	if registeredModules[moduleName] then return end
	registeredModules[moduleName] = true
	local info = {}
	info.moduleName = moduleName
	info.callback = callback
	tinsert(private.bankUiButtons, info)
	sort(private.bankUiButtons, function(a, b)
		if a.moduleName == "Warehousing" then
			return true
		elseif b.moduleName == "Warehousing" then
			return false
		else
			return a.moduleName < b.moduleName
		end
	end)
end

function BankUI:getBankFrame(bank)
	if BagnonFrameguildbank and BagnonFrameguildbank:IsVisible() then
		return BagnonFrameguildbank
	elseif BagnonFramebank and BagnonFramebank:IsVisible() then
		return BagnonFramebank
	elseif GuildBankFrame and GuildBankFrame:IsVisible() then
		return GuildBankFrame
	elseif BankFrame and BankFrame:IsVisible() then
		return BankFrame
	elseif (famBankFrame and famBankFrame:IsVisible()) then
		return famBankFrame
	elseif (ARKINV_Frame4 and ARKINV_Frame4:IsVisible()) then
		return ARKINV_Frame4
	elseif (ARKINV_Frame3 and ARKINV_Frame3:IsVisible()) then
		return ARKINV_Frame3
	elseif (OneBankFrame and OneBankFrame:IsVisible()) then
		return OneBankFrame
	elseif (TukuiBank and TukuiBank:IsShown()) then
		return TukuiBank
	elseif (ElvUI_BankContainerFrame and ElvUI_BankContainerFrame:IsVisible()) then
		return ElvUI_BankContainerFrame
	elseif (LUIBank and LUIBank:IsVisible()) then
		return LUIBank
	elseif (AdiBagsContainer1 and AdiBagsContainer1.isBank and AdiBagsContainer1:IsVisible()) then
		return AdiBagsContainer1
	elseif (AdiBagsContainer2 and AdiBagsContainer2.isBank and AdiBagsContainer2:IsVisible()) then
		return AdiBagsContainer2
	elseif (BagsFrameBank and BagsFrameBank:IsVisible()) then
		return BagsFrameBank
	elseif AspUIBank and AspUIBank:IsVisible() then
		return AspUIBank
	elseif NivayacBniv_Bank and NivayacBniv_Bank:IsVisible() then
		return NivayacBniv_Bank
	elseif DufUIBank and DufUIBank:IsVisible() then
		return DufUIBank
	end

	return nil
end

function BankUI:getFrame(frameType)
	bFrame = CreateFrame("Frame", nil, UIParent)
	bFrame:Hide()
	--size--
	bFrame:SetWidth(275)
	bFrame:SetHeight(470)
	bFrame:SetPoint("CENTER", UIParent)

	--for moving--
	bFrame:SetScript("OnMouseDown", bFrame.StartMoving)
	bFrame:SetScript("OnMouseUp", function(...) bFrame.StopMovingOrSizing(...)
	if bankType == "guild" then
		TSM.db.factionrealm.bankUIGBankFramePosition = { bFrame:GetLeft(), bFrame:GetBottom() }
	else
		TSM.db.factionrealm.bankUIBankFramePosition = { bFrame:GetLeft(), bFrame:GetBottom() }
	end
	end)
	bFrame:SetMovable(true)
	bFrame:EnableMouse(true)

	bFrame:SetPoint("CENTER", UIParent)

	local function OnFrameShow(self)
		self:SetFrameLevel(0)
		self:ClearAllPoints()
		if bankType == "guild" then
			self:SetPoint("BOTTOMLEFT", UIParent, unpack(TSM.db.factionrealm.bankUIGBankFramePosition))
		else
			self:SetPoint("BOTTOMLEFT", UIParent, unpack(TSM.db.factionrealm.bankUIBankFramePosition))
		end
	end

	TSMAPI.Design:SetFrameBackdropColor(bFrame)
	bFrame:SetScript("OnShow", OnFrameShow)
	bFrame:Show()

	local title = TSMAPI.GUI:CreateLabel(bFrame)
	title:SetPoint("TOPLEFT", 40, -3)
	title:SetPoint("BOTTOMRIGHT", bFrame, "TOPRIGHT", -5, -23)
	title:SetJustifyH("CENTER")
	title:SetJustifyV("CENTER")
	title:SetText("TradeSkillMaster - " .. TSM._version)
	TSMAPI.Design:SetTitleTextColor(title)

	local title2 = TSMAPI.GUI:CreateLabel(bFrame)
	title2:SetPoint("TOPLEFT", title, "BOTTOMLEFT")
	title2:SetPoint("TOPRIGHT", title, "BOTTOMRIGHT")
	title2:SetJustifyH("CENTER")
	title2:SetJustifyV("CENTER")
	title2:SetText(L["BankUI"])
	TSMAPI.Design:SetTitleTextColor(title2)


	bFrame.btnClose = createCloseButton("X", bFrame, nil)
	bFrame.btnClose:SetPoint("TOPRIGHT", bFrame, "TOPRIGHT")
	bFrame.btnClose:SetScript("OnClick", function(self)
		if bFrame then bFrame:Hide() end
		TSM.db.profile.isBankui = false
		TSM:Print(L["You have closed the bankui. Use '/tsm bankui' to view again."])
	end)

	-- module buttons
	bFrame.buttons = {}

	local iconFrame = CreateFrame("Frame", nil, bFrame)
	iconFrame:SetPoint("CENTER", bFrame, "TOPLEFT", 25, -25)
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

	container = CreateFrame("Frame", nil, bFrame)
	container:SetPoint("TOPLEFT", 5, -60)
	container:SetPoint("BOTTOMRIGHT", -5, 5)
	TSMAPI.Design:SetFrameColor(container)

	for _, info in ipairs(private.bankUiButtons) do
		info.bankTab = info.callback(container)
		private:CreateBankButton(info.moduleName)
	end

	if TSM.db.global.bankUITab then
		for index, info in ipairs(private.bankUiButtons) do
			if info.moduleName == TSM.db.global.bankUITab then
				bFrame.buttons[index]:Click()
				break
			end
		end
	else
		bFrame.buttons[1]:Click()
	end
	return bFrame
end

function BankUI:resetPoints(container)
	if bankType == "guild" then
		container:SetPoint("BOTTOMLEFT", UIParent, unpack(TSM.db.factionrealm.bankUIGBankFramePosition))
	else
		container:SetPoint("BOTTOMLEFT", UIParent, unpack(TSM.db.factionrealm.bankUIBankFramePosition))
	end
end

function private:CreateBankButton(module)
	local buttonIndex
	for record, info in ipairs(private.bankUiButtons) do
		if info.moduleName == module then
			buttonIndex = record
		end
	end

	local function OnButtonClick(self)
		for _, info in ipairs(private.bankUiButtons) do
			info.bankTab:Hide()
		end

		for index, button in ipairs(bFrame.buttons) do
			button:UnlockHighlight()
			if self == button then
				private.bankUiButtons[index].bankTab:Show()
			end
		end
		self:LockHighlight()
	end

	local button = TSMAPI.GUI:CreateButton(bFrame, 12)
	if buttonIndex == 1 then
		button:SetPoint("TOPLEFT", 70, -40)
	else
		button:SetPoint("TOPLEFT", bFrame.buttons[buttonIndex - 1], "TOPRIGHT", 5, 0)
	end
	button:SetHeight(20)
	button:SetWidth(70)
	button:SetText(module)
	button:SetScript("OnClick", OnButtonClick)
	tinsert(bFrame.buttons, button)
end

function TSM:toggleBankUI()
	if TSM:areBanksVisible() then
		if ui then
			if ui:IsShown() then
				ui:Hide()
			else
				ui:Show()
			end
		else
			ui = BankUI:getFrame(bankFrame)
			TSM.db.profile.isBankui = true
		end
	else
		TSM:Print(L["There are no visible banks."])
	end
end

function TSM:getBankTabs()
	local tabs = {}
	for record, info in ipairs(private.bankUiButtons) do
		tabs[info.moduleName] = info.moduleName
	end
	return tabs
end

function TSM:ResetBankUIFramePosition()
	TSM.db.factionrealm.bankUIGBankFramePosition = { 100, 300 }
	TSM.db.factionrealm.bankUIBankFramePosition = { 100, 300 }
	if ui then
		ui:Hide()
		ui:Show()
	end
end