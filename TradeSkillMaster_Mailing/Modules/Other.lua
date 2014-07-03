-- ------------------------------------------------------------------------------ --
--                            TradeSkillMaster_Mailing                            --
--            http://www.curse.com/addons/wow/tradeskillmaster_mailing            --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

local TSM = select(2, ...)
local Other = TSM:NewModule("Other", "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster_Mailing") -- loads the localization table

local private = {}


function Other:CreateTab(parent)
	local frame = CreateFrame("Frame", nil, parent)
	frame:Hide()
	frame:SetAllPoints()
	
	local deBox = CreateFrame("Frame", nil, frame)
	TSMAPI.Design:SetFrameColor(deBox)
	deBox:SetPoint("TOPLEFT", 5, -5)
	deBox:SetPoint("TOPRIGHT", -5, -5)
	deBox:SetHeight(80)
	private:CreateDisenchantBox(deBox)
	
	TSMAPI.GUI:CreateHorizontalLine(frame, -103)
	
	local sendGoldBox = CreateFrame("Frame", nil, frame)
	TSMAPI.Design:SetFrameColor(sendGoldBox)
	sendGoldBox:SetPoint("TOPLEFT", deBox, "BOTTOMLEFT", 0, -50)
	sendGoldBox:SetPoint("TOPRIGHT", deBox, "BOTTOMRIGHT", 0, -50)
	sendGoldBox:SetHeight(80)
	private:CreateSendGoldBox(sendGoldBox)
	
	return frame
end

function private:CreateDisenchantBox(frame)
	local label = TSMAPI.GUI:CreateLabel(frame, "normal")
	label:SetPoint("TOPLEFT", 5, -5)
	label:SetPoint("TOPRIGHT", -5, -5)
	label:SetHeight(20)
	label:SetJustifyV("TOP")
	label:SetJustifyH("LEFT")
	label:SetText(L["Mail Disenchantables:"])

	local targetBoxLabel = TSMAPI.GUI:CreateLabel(frame, "small")
	targetBoxLabel:SetPoint("TOPLEFT", 5, -30)
	targetBoxLabel:SetHeight(20)
	targetBoxLabel:SetJustifyV("CENTER")
	targetBoxLabel:SetJustifyH("LEFT")
	targetBoxLabel:SetText(L["Target Player:"])
	
	local targetBox = TSMAPI.GUI:CreateInputBox(frame)
	targetBox:SetPoint("TOPLEFT", targetBoxLabel, "TOPRIGHT", 5, 0)
	targetBox:SetPoint("TOPRIGHT", -5, -30)
	targetBox:SetHeight(20)
	targetBox:SetText(TSM.db.factionrealm.deMailTarget)
	targetBox:SetScript("OnEnterPressed", function(self)
			TSM.db.factionrealm.deMailTarget = self:GetText():trim()
			self:ClearFocus()
			frame.btn:Update()
		end)
	targetBox.tooltip = L["Enter name of the character disenchantable greens should be sent to."].."\n\n"..TSM.SPELLING_WARNING
		
	local function OnClick()
		local target = TSM.db.factionrealm.deMailTarget
		if target == "" then return end
		local items = {}
		local hasItems
		for bag, slot, itemString, quantity in TSMAPI:GetBagIterator() do
			if private:IsDisenchantable(itemString) and not TSMAPI:GetGroupPath(TSMAPI:GetBaseItemString(itemString, true)) and not TSMAPI:IsSoulbound(bag, slot) then
				items[itemString] = (items[itemString] or 0) + quantity
				hasItems = true
			end
		end
		if hasItems then
			local function callback()
				TSM:Printf(L["Sent all disenchantable greens to %s."], target)
				frame.btn:Update()
			end
			frame.btn:Disable()
			frame.btn:SetText(L["Sending..."])
			TSM.AutoMail:SendItems(items, target, callback)
		end
	end
	
	local btn = TSMAPI.GUI:CreateButton(frame, 15)
	btn:SetPoint("TOPLEFT", 5, -55)
	btn:SetPoint("TOPRIGHT", -5, -55)
	btn:SetHeight(20)
	btn:SetScript("OnClick", OnClick)
	btn.tooltip = L["Click this button to send all disenchantable greens in your bags to the specified character."]
	btn.Update = function(self)
		if TSM.db.factionrealm.deMailTarget ~= "" then
			self:Enable()
			self:SetText(format(L["Send Disenchantable Greens to %s"], TSM.db.factionrealm.deMailTarget))
		else
			self:Disable()
			self:SetText(L["No Target Player"])
		end
	end
	btn:Update()
	frame.btn = btn
end

function private:CreateSendGoldBox(frame)
	local label = TSMAPI.GUI:CreateLabel(frame, "normal")
	label:SetPoint("TOPLEFT", 5, -5)
	label:SetPoint("TOPRIGHT", -5, -5)
	label:SetHeight(20)
	label:SetJustifyV("TOP")
	label:SetJustifyH("LEFT")
	label:SetText(L["Send Excess Gold to Banker:"])
	
	local targetBoxLabel = TSMAPI.GUI:CreateLabel(frame, "small")
	targetBoxLabel:SetPoint("TOPLEFT", 5, -30)
	targetBoxLabel:SetHeight(20)
	targetBoxLabel:SetJustifyV("CENTER")
	targetBoxLabel:SetJustifyH("LEFT")
	targetBoxLabel:SetText(L["Target Player:"])
	
	local targetBox = TSMAPI.GUI:CreateInputBox(frame)
	targetBox:SetPoint("TOPLEFT", targetBoxLabel, "TOPRIGHT", 5, 0)
	targetBox:SetWidth(80)
	targetBox:SetHeight(20)
	targetBox:SetText(TSM.db.char.goldMailTarget)
	targetBox:SetScript("OnEnterPressed", function(self)
			TSM.db.char.goldMailTarget = self:GetText():trim()
			self:ClearFocus()
			frame.btn:Update()
		end)
	targetBox.tooltip = L["Enter the name of the player you want to send excess gold to."].."\n\n"..TSM.SPELLING_WARNING
	
	
	local goldBoxLabel = TSMAPI.GUI:CreateLabel(frame, "small")
	goldBoxLabel:SetPoint("TOPLEFT", targetBox, "TOPRIGHT", 15, 0)
	goldBoxLabel:SetHeight(20)
	goldBoxLabel:SetJustifyV("CENTER")
	goldBoxLabel:SetJustifyH("LEFT")
	goldBoxLabel:SetText(L["Limit (In Gold):"])
	
	local goldBox = TSMAPI.GUI:CreateInputBox(frame)
	goldBox:SetPoint("TOPLEFT", goldBoxLabel, "TOPRIGHT", 5, 0)
	goldBox:SetPoint("TOPRIGHT", -5, -30)
	goldBox:SetHeight(20)
	goldBox:SetNumeric(true)
	goldBox:SetNumber(TSM.db.char.goldKeepAmount)
	goldBox:SetScript("OnTextChanged", function(self)
			TSM.db.char.goldKeepAmount = self:GetNumber()
			frame.btn:Update()
		end)
	goldBox:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)
	goldBox.tooltip = L["This is maximum amount of gold you want to keep on the current player. Any amount over this limit will be send to the specified character."]

	
	local function OnClick()
		local extra = (GetMoney() - 30) - (TSM.db.char.goldKeepAmount * COPPER_PER_GOLD)
		if extra <= 0 then
			TSM:Print(L["Not sending any gold as you have less than the specified limit."])
			return
		end
		SetSendMailMoney(extra)
		SendMail(TSM.db.char.goldMailTarget, L["TSM_Mailing Excess Gold"], "")
		TSM:Printf(L["Sent %s to %s."], TSMAPI:FormatTextMoney(extra), TSM.db.char.goldMailTarget)
	end
	
	local btn = TSMAPI.GUI:CreateButton(frame, 15)
	btn:SetPoint("TOPLEFT", 5, -55)
	btn:SetPoint("TOPRIGHT", -5, -55)
	btn:SetHeight(20)
	btn:SetScript("OnClick", OnClick)
	btn.tooltip = L["Click this button to send excess gold to the specified character."]
	btn.Update = function(self)
		if TSM.db.char.goldMailTarget == "" then
			self:Disable()
			self:SetText(L["Not Target Specified"])
		elseif TSMAPI:IsPlayer(TSM.db.char.goldMailTarget) then
			self:Disable()
			self:SetText(L["Target is Current Player"])
		else
			self:Enable()
			self:SetText(format(L["Send Excess Gold to %s"], TSM.db.char.goldMailTarget))
		end
	end
	btn:Update()
	frame.btn = btn
end

function private:IsDisenchantable(itemString)
	local _, link, quality, _, _, iType = TSMAPI:GetSafeItemInfo(itemString)
	local WEAPON, ARMOR = GetAuctionItemClasses()
	if itemString and not TSMAPI.DisenchantingData.notDisenchantable[itemString] and (iType == ARMOR or iType == WEAPON) and quality == ITEM_QUALITY_UNCOMMON then
		return true
	end
end