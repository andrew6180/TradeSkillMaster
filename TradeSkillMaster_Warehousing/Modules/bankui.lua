-- ------------------------------------------------------------------------------ --
--                          TradeSkillMaster_Warehousing                          --
--          http://www.curse.com/addons/wow/tradeskillmaster_warehousing          --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- loads the localization table --
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster_Warehousing")

-- load the parent file (TSM) into a local variable and register this file as a module
local TSM = select(2, ...)
local bankui = TSM:NewModule("bankui", "AceEvent-3.0")
local AceGUI = LibStub("AceGUI-3.0") -- load the AceGUI librarie

local currentBank = nil
local bFrame = nil
local buttonFrame = nil
local groupTree = nil

function bankui:OnEnable()

	bankui:RegisterEvent("GUILDBANKFRAME_OPENED", function(event)
		currentBank = "guildbank"
	end)

	bankui:RegisterEvent("BANKFRAME_OPENED", function(event)
		currentBank = "bank"
	end)

	bankui:RegisterEvent("GUILDBANKFRAME_CLOSED", function(event, addon)
		currentBank = nil
	end)

	bankui:RegisterEvent("BANKFRAME_CLOSED", function(event)
		currentBank = nil
	end)
end

local function createButton(text, small)
	local btn = TSMAPI.GUI:CreateButton(bFrame, 15, "Button")
	btn:SetText(text)
	btn:SetHeight(17)
	if small then
		btn:SetWidth(110)
	else
		btn:SetWidth(230)
	end
	return btn
end

function bankui:createTab(parent)

	bFrame = CreateFrame("Frame", nil, parent)
	--TSMAPI.Design:SetFrameColor(bFrame)
	bFrame:Hide()

	--size--
	bFrame:SetAllPoints()

	--GroupTree--
	local tFrame = CreateFrame("Frame", nil, bFrame)
	tFrame:SetPoint("TOPLEFT", 0, -5)
	tFrame:SetPoint("TOPRIGHT", 0, -5)
	tFrame:SetPoint("BOTTOMLEFT", 0, 120)
	tFrame:SetPoint("BOTTOMRIGHT", 0, 120)

	groupTree = TSMAPI:CreateGroupTree(tFrame, "Warehousing", "Warehousing_Bank")
	groupTree:SetPoint("TOPLEFT", 5, -5)
	groupTree:SetPoint("BOTTOMRIGHT", -5, 5)

	--Buttons--
	buttonFrame = CreateFrame("Frame", nil, bFrame)
	buttonFrame:SetPoint("TOPLEFT", 0, -330)
	buttonFrame:SetPoint("TOPRIGHT", 0, -330)
	buttonFrame:SetPoint("BOTTOMLEFT")
	buttonFrame:SetPoint("BOTTOMRIGHT")

	buttonFrame.btnToBank = createButton(L["Move Group To Bank"], nil)
	buttonFrame.btnToBank:SetPoint("BOTTOM", buttonFrame, "BOTTOM", 0, 99)

	buttonFrame.btnToBags = createButton(L["Move Group To Bags"], nil)
	buttonFrame.btnToBags:SetPoint("BOTTOM", buttonFrame, "BOTTOM", 0, 77)

	buttonFrame.btnRestock = createButton(L["Restock Bags"], nil)
	buttonFrame.btnRestock:SetPoint("BOTTOM", buttonFrame, "BOTTOM", 0, 50)

	buttonFrame.btnReagents = createButton(L["Deposit Reagents"], nil)
	buttonFrame.btnReagents:SetPoint("BOTTOM", buttonFrame, "BOTTOM", 0, 28)

	buttonFrame.btnEmpty = createButton(L["Empty Bags"], buttonFrame, true)
	buttonFrame.btnEmpty:SetPoint("BOTTOM", buttonFrame, "BOTTOM", -60, 5)

	buttonFrame.btnRestore = createButton(L["Restore Bags"], buttonFrame, true)
	buttonFrame.btnRestore:SetPoint("BOTTOM", buttonFrame, "BOTTOM", 60, 5)

	bankui:updateButtons()

	return bFrame
end

function bankui:updateButtons()
	------------------
	-- Move to Bank --
	------------------
	buttonFrame.btnToBank:SetScript("OnClick", function(self)
		TSM.move:groupTree(groupTree:GetSelectedGroupInfo(), "bags")
	end)

	--------------------------
	-- Empty / Restore Bags --
	--------------------------
	buttonFrame.btnEmpty:SetScript("OnClick", function(self) TSM.move:EmptyRestore(currentBank) end)

	buttonFrame.btnRestore:SetScript("OnClick", function(self)
		TSM.move:EmptyRestore(currentBank, true)
	end)

	------------------
	-- Move to Bags --
	------------------
	buttonFrame.btnToBags:SetScript("OnClick", function(self)
		TSM.move:groupTree(groupTree:GetSelectedGroupInfo(), currentBank)
	end)

	-------------
	-- Restock --
	-------------
	buttonFrame.btnRestock:SetScript("OnClick", function(self)
		TSM.move:restockGroup(groupTree:GetSelectedGroupInfo())
	end)

	----------------------
	-- Deposit Reagents --
	----------------------
	buttonFrame.btnReagents:SetScript("OnClick", function(self)
		if currentBank == "bank" then
			if IsReagentBankUnlocked() then
				DepositReagentBank()
			else
				TSMAPI:ShowStaticPopupDialog("CONFIRM_BUY_REAGENTBANK_TAB");
			end
		end
	end)
end