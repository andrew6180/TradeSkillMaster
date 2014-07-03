-- ------------------------------------------------------------------------------ --
--                                TradeSkillMaster                                --
--                http://www.curse.com/addons/wow/tradeskill-master               --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

local TSM = select(2, ...)
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster") -- loads the localization table

local private = {auctionTabs={}, queuedTabs={}}
TSMAPI:RegisterForTracing(private, "TradeSkillMaster.AuctionFrame_private")
LibStub("AceEvent-3.0"):Embed(private)
LibStub("AceHook-3.0"):Embed(private)

local registeredModules = {}
function TSM:RegisterAuctionFunction(moduleName, callbackShow, callbackHide)
	if registeredModules[moduleName] then return end
	registeredModules[moduleName] = true
	if AuctionFrame then
		private:CreateTSMAHTab(moduleName, callbackShow, callbackHide)
	else
		tinsert(private.queuedTabs, {moduleName, callbackShow, callbackHide})
	end
end

function private:CreateTSMAHTab(moduleName, callbackShow, callbackHide)
	local auctionTab = CreateFrame("Frame", nil, AuctionFrame)
	auctionTab:Hide()
	auctionTab:SetAllPoints()
	auctionTab:EnableMouse(true)
	auctionTab:SetMovable(true)
	auctionTab:SetScript("OnMouseDown", function() if AuctionFrame:IsMovable() then AuctionFrame:StartMoving() end end)
	auctionTab:SetScript("OnMouseUp", function() if AuctionFrame:IsMovable() then AuctionFrame:StopMovingOrSizing() end end)

	TSMAPI:CancelFrame("blizzAHLoadedDelay")
	local n = AuctionFrame.numTabs + 1

	local tab = CreateFrame("Button", "AuctionFrameTab"..n, AuctionFrame, "AuctionTabTemplate")
	tab:Hide()
	tab:SetID(n)
	tab:SetText(TSMAPI.Design:GetInlineColor("link2")..moduleName.."|r")
	tab:SetNormalFontObject(GameFontHighlightSmall)
	tab.isTSMTab = moduleName
	tab:SetPoint("LEFT", _G["AuctionFrameTab"..n-1], "RIGHT", -8, 0)
	tab:Show()
	PanelTemplates_SetNumTabs(AuctionFrame, n)
	PanelTemplates_EnableTab(AuctionFrame, n)
	auctionTab.tab = tab
	
	local closeBtn = TSMAPI.GUI:CreateButton(auctionTab, 18)
	closeBtn:SetPoint("BOTTOMRIGHT", -5, 5)
	closeBtn:SetWidth(75)
	closeBtn:SetHeight(24)
	closeBtn:SetText(CLOSE)
	closeBtn:SetScript("OnClick", CloseAuctionHouse)
	
	local iconFrame = CreateFrame("Frame", nil, auctionTab)
	iconFrame:SetPoint("CENTER", auctionTab, "TOPLEFT", 30, -30)
	iconFrame:SetHeight(100)
	iconFrame:SetWidth(100)
	local icon = iconFrame:CreateTexture(nil, "ARTWORK")
	icon:SetAllPoints()
	icon:SetTexture("Interface\\Addons\\TradeSkillMaster\\Media\\TSM_Icon_Big")
	local textFrame = CreateFrame("Frame", nil, auctionTab)
	local iconText = textFrame:CreateFontString(nil, "OVERLAY")
	iconText:SetPoint("CENTER", iconFrame)
	iconText:SetHeight(15)
	iconText:SetJustifyH("CENTER")
	iconText:SetJustifyV("CENTER")
	iconText:SetFont(TSMAPI.Design:GetContentFont("normal"))
	iconText:SetTextColor(165/255, 168/255, 188/255, .7)
	local version = TSM._version
	iconText:SetText(version)
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
	
	local moneyText = TSMAPI.GUI:CreateTitleLabel(auctionTab, 16)
	moneyText:SetJustifyH("CENTER")
	moneyText:SetJustifyV("CENTER")
	moneyText:SetPoint("CENTER", auctionTab, "BOTTOMLEFT", 85, 17)
	TSMAPI.Design:SetIconRegionColor(moneyText)
	moneyText.SetMoney = function(self, money)
		self:SetText(TSMAPI:FormatTextMoneyIcon(money))
	end
	auctionTab.moneyText = moneyText
	
	local moneyTextFrame = CreateFrame("Frame", nil, auctionTab)
	moneyTextFrame:SetAllPoints(moneyText)
	moneyTextFrame:EnableMouse(true)
	moneyTextFrame:SetScript("OnEnter", function(self)
			local currentTotal = 0
			local incomingTotal = 0
			for i=1, GetNumAuctionItems("owner") do
				local count, _, _, _, _, _, _, buyoutAmount = select(3, GetAuctionItemInfo("owner", i))
				if count == 0 then
					incomingTotal = incomingTotal + buyoutAmount
				else
					currentTotal = currentTotal + buyoutAmount
				end
			end
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:AddLine("Gold Info:")
			GameTooltip:AddDoubleLine("Player Gold", TSMAPI:FormatTextMoneyIcon(GetMoney()), 1, 1, 1, 1, 1, 1)
			GameTooltip:AddDoubleLine("Incoming Auction Sales", TSMAPI:FormatTextMoneyIcon(incomingTotal), 1, 1, 1, 1, 1, 1)
			GameTooltip:AddDoubleLine("Current Auctions Value", TSMAPI:FormatTextMoneyIcon(currentTotal), 1, 1, 1, 1, 1, 1)
			GameTooltip:Show()
		end)
	moneyTextFrame:SetScript("OnLeave", function()
			GameTooltip:ClearLines()
			GameTooltip:Hide()
		end)
	
	auctionTab:SetScript("OnShow", function(self)
			self:SetAllPoints()
			if not self.minimized then
				callbackShow(self)
			end
		end)
	auctionTab:SetScript("OnHide", function(self)
			if not self.minimized then
				callbackHide()
			end
		end)
		
	local contentFrame = CreateFrame("Frame", nil, auctionTab)
	contentFrame:SetPoint("TOPLEFT", 4, -80)
	contentFrame:SetPoint("BOTTOMRIGHT", -4, 35)
	TSMAPI.Design:SetContentColor(contentFrame)
	auctionTab.content = contentFrame

	tinsert(private.auctionTabs, auctionTab)
end

function private:InitializeAuctionFrame(auctionTab)
	-- make the AH movable if this option is enabled
	AuctionFrame:SetMovable(TSM.db.profile.auctionFrameMovable)
	AuctionFrame:EnableMouse(true)
	AuctionFrame:SetScript("OnMouseDown", function(self) if self:IsMovable() then self:StartMoving() end end)
	AuctionFrame:SetScript("OnMouseUp", function(self) if self:IsMovable() then self:StopMovingOrSizing() end end)
	
	-- scale the auction frame according to the TSM option
	if AuctionFrame:GetScale() ~= 1 and TSM.db.profile.auctionFrameScale == 1 then TSM.db.profile.auctionFrameScale = AuctionFrame:GetScale() end
	AuctionFrame:SetScale(TSM.db.profile.auctionFrameScale)
	
	local prevTab
	local function TabChangeHook(self)
		if self.isTSMTab then
			for _, tabFrame in ipairs(private.auctionTabs) do
				if tabFrame.minimized and tabFrame.tab ~= self then
					tabFrame:Show()
					tabFrame.minimized = nil
					tabFrame:Hide()
				elseif tabFrame:IsShown() then
					tabFrame:Hide()
				end
			end
			local tabAuctionFrame = private:GetAuctionFrame(self)
			private:OnTabClick(tabAuctionFrame)
			AuctionFrame:SetFrameLevel(1)
			tabAuctionFrame:SetFrameStrata(AuctionFrame:GetFrameStrata())
			tabAuctionFrame:SetFrameLevel(AuctionFrame:GetFrameLevel() + 1)
		elseif prevTab and prevTab.isTSMTab then
			local prevTabAuctionFrame = private:GetAuctionFrame(prevTab)
			prevTabAuctionFrame.minimized = true
			prevTabAuctionFrame:Hide()
			private:TabHidden()
		end
		prevTab = self
	
	end
	private:Hook("AuctionFrameTab_OnClick", TabChangeHook, true)
	
	-- Makes sure the TSM tab hides correctly when used with addons that hook this function to change tabs (ie Auctionator)
	-- This probably doesn't have to be a SecureHook, but does need to be a Post-Hook.
	private:SecureHook("ContainerFrameItemButton_OnModifiedClick", function()
			if _G["AuctionFrameTab"..PanelTemplates_GetSelectedTab(AuctionFrame)].isTSMTab then return end
			TabChangeHook(_G["AuctionFrameTab"..PanelTemplates_GetSelectedTab(AuctionFrame)])
		end)
end

function private:GetAuctionFrame(targetTab)
	for _, tabFrame in ipairs(private.auctionTabs) do
		if tabFrame.tab == targetTab then
			return tabFrame
		end
	end
end

function private:InitializeAHTab()
	for _, info in ipairs(private.queuedTabs) do
		private:CreateTSMAHTab(unpack(info))
	end
	private.queuedTabs = {}
	private:InitializeAuctionFrame()
	private.isInitialized = true
	if AuctionHouse and AuctionHouse:IsVisible() then
		private:AUCTION_HOUSE_SHOW()
	end
end

function TSMAPI:AHTabIsVisible(module)
	return module and _G["AuctionFrameTab"..AuctionFrame.selectedTab].isTSMTab == module
end

function private:AUCTION_HOUSE_SHOW()
	if private.isInitialized then
		for i = AuctionFrame.numTabs, 1, -1 do
			local text = gsub(_G["AuctionFrameTab"..i]:GetText(), "|r", "")
			text = gsub(text, "|c[0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f]", "")
			if text == TSM.db.profile.defaultAuctionTab then
				_G["AuctionFrameTab"..i]:Click()
				return
			end
		end
		_G["AuctionFrameTab1"]:Click()
	end
end

function private:OnTabClick(tab)
	AuctionFrameTopLeft:Hide()
	AuctionFrameTop:Hide()
	AuctionFrameTopRight:Hide()
	AuctionFrameBotLeft:Hide()
	AuctionFrameBot:Hide()
	AuctionFrameBotRight:Hide()
	AuctionFrameMoneyFrame:Hide()
	AuctionFrameCloseButton:Hide()
	private:RegisterEvent("PLAYER_MONEY")
	
	if TSM.db.profile.openAllBags then
		OpenAllBags()
	end
	TSMAPI:CreateTimeDelay("hideAHMoneyFrame", 0.1, function() AuctionFrameMoneyFrame:Hide() end)
	
	TSMAPI.Design:SetFrameBackdropColor(tab)
	AuctionFrameTab1:SetPoint("TOPLEFT", AuctionFrame, "BOTTOMLEFT", 15, 1)
	
	tab:Show()
	tab.minimized = nil
	tab.moneyText:SetMoney(GetMoney())
end

function private:TabHidden()
	AuctionFrameTopLeft:Show()
	AuctionFrameTop:Show()
	AuctionFrameTopRight:Show()
	AuctionFrameBotLeft:Show()
	AuctionFrameBot:Show()
	AuctionFrameBotRight:Show()
	AuctionFrameMoneyFrame:Show()
	AuctionFrameCloseButton:Show()
	AuctionFrameTab1:SetPoint("TOPLEFT", AuctionFrame, "BOTTOMLEFT", 15, 12)
end

function private:PLAYER_MONEY()
	for _, tab in ipairs(private.auctionTabs) do
		if tab:IsVisible() then
			tab.moneyText:SetMoney(GetMoney())
		end
	end
end

function private:ADDON_LOADED(event, addonName)
	if addonName == "Blizzard_AuctionUI" then
		private:UnregisterEvent("ADDON_LOADED")
		if TSM.db then
			private:InitializeAHTab()
		else
			TSMAPI:CreateTimeDelay("blizzAHLoadedDelay", 0.2, private.InitializeAHTab, 0.2)
		end
	end
end

do
	private:RegisterEvent("AUCTION_HOUSE_SHOW")
	if IsAddOnLoaded("Blizzard_AuctionUI") then
		private:InitializeAHTab()
	else
		private:RegisterEvent("ADDON_LOADED")
	end
end