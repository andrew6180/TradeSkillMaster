-- ------------------------------------------------------------------------------ --
--                            TradeSkillMaster_Mailing                            --
--            http://www.curse.com/addons/wow/tradeskillmaster_mailing            --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

local TSM = select(2, ...)
local Groups = TSM:NewModule("Groups", "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster_Mailing") -- loads the localization table

local private = {}


function Groups:CreateTab(parent)
	local frame = CreateFrame("Frame", nil, parent)
	frame:Hide()
	frame:SetAllPoints()
	frame:SetScript("OnHide", function()
		TSMAPI:CancelFrame("mailingGroupsRepeat")
	end)

	local stContainer = CreateFrame("Frame", nil, frame)
	stContainer:SetPoint("TOPLEFT", 5, -5)
	stContainer:SetPoint("BOTTOMRIGHT", -5, 35)
	TSMAPI.Design:SetFrameColor(stContainer)
	frame.groupTree = TSMAPI:CreateGroupTree(stContainer, "Mailing", "Mailing_Send")

	local function OnButtonClick(self)
		if IsShiftKeyDown() then
			TSMAPI:CreateTimeDelay("mailingResendDelay", 0.1, private.StartSending, TSM.db.global.resendDelay * 60)
		else
			private:StartSending()
		end
	end
	Groups:RegisterEvent("MAIL_CLOSED", function() TSMAPI:CancelFrame("mailingResendDelay") end)

	local button = TSMAPI.GUI:CreateButton(frame, 15)
	button:SetPoint("BOTTOMLEFT", 5, 5)
	button:SetPoint("BOTTOMRIGHT", -5, 5)
	button:SetHeight(25)
	button:SetText(L["Mail Selected Groups"])
	button:SetScript("OnClick", OnButtonClick)
	button.tooltip = L["Shift-Click to automatically re-send after the amount of time specified in the TSM_Mailing options."]
	frame.button = button

	private.frame = frame
	return frame
end

local badOperations = {}
function private:ValidateOperation(operation, operationName)
	if not operation then return end
	if operation.target == "" then
		-- operation is invalid (no target)
		if not badOperations[operationName] then
			TSM:Printf(L["Skipping operation '%s' because there is no target."], operationName)
			badOperations[operationName] = true
		end
		return
	end
	return true
end

function private:StartSending()
	if private.isSending then return end

	-- get a table of how many of each item we have in our bags
	local inventoryItems = {}
	for bag, slot, itemString, quantity, locked in TSMAPI:GetBagIterator(true) do
		inventoryItems[itemString] = (inventoryItems[itemString] or 0) + quantity
	end

	local badOperations = {}
	local targets = {}
	for _, data in pairs(private.frame.groupTree:GetSelectedGroupInfo()) do
		for _, operationName in ipairs(data.operations) do
			TSMAPI:UpdateOperation("Mailing", operationName)
			local operation = TSM.operations[operationName]
			if private:ValidateOperation(operation, operationName) then
				-- operation is valid
				for itemString in pairs(data.items) do
					local numAvailable = (inventoryItems[itemString] or 0) - operation.keepQty
					if numAvailable > 0 then
						local quantity = 0
						if operation.maxQtyEnabled then
							if TSMAPI:IsPlayer(operation.target) or not operation.restock then
								quantity = min(numAvailable, operation.maxQty)
							else
								local targetQty = private:GetTargetQuantity(operation.target, itemString, operation.restockGBank)
								quantity = min(numAvailable, operation.maxQty - targetQty)
							end
						else
							quantity = numAvailable
						end
						if quantity > 0 then
							inventoryItems[itemString] = inventoryItems[itemString] - quantity
							targets[operation.target] = targets[operation.target] or {}
							targets[operation.target][itemString] = quantity
						end
					end
				end
			end
		end
	end

	for target in pairs(targets) do
		if TSMAPI:IsPlayer(target) then
			targets[target] = nil
		end
	end
	
	private.targets = targets
	private:SendNextTarget()
end

function private:GetTargetQuantity(player, itemString, includeGBank)
	local num = 0
	num = num + ((TSMAPI:ModuleAPI("ItemTracker", "playerbags", player, true) or {})[itemString] or 0)
	num = num + ((TSMAPI:ModuleAPI("ItemTracker", "playerbank", player, true) or {})[itemString] or 0)
	num = num + ((TSMAPI:ModuleAPI("ItemTracker", "playermail", player, true) or {})[itemString] or 0)
	num = num + ((TSMAPI:ModuleAPI("ItemTracker", "playerauctions", player, true) or {})[itemString] or 0)
	if includeGBank then
		num = num + (TSMAPI:ModuleAPI("ItemTracker", "playerguildtotal", itemString, player) or 0)
	end
	return num
end

function private:SendNextTarget()
	local target, items = next(private.targets)
	if not target then
		private.frame.button:SetText(L["Mail Selected Groups"])
		private.frame.button:Enable()
		private.isSending = nil
		TSM:Print(L["Done sending mail."])
		return
	end

	private.isSending = true
	private.targets[target] = nil
	private.frame.button:SetText(L["Sending..."])
	private.frame.button:Disable()
	if not TSM.AutoMail:SendItems(items, target, private.SendNextTarget) then
		private:SendNextTarget()
	end
end
