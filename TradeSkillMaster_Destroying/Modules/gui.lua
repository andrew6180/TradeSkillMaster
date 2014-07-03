-- ------------------------------------------------------------------------------ --
--                           TradeSkillMaster_Destroying                          --
--           http://www.curse.com/addons/wow/tradeskillmaster_destroying          --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- load the parent file (TSM) into a local variable and register this file as a module
local TSM = select(2, ...)
local GUI = TSM:NewModule("GUI", "AceEvent-3.0")

-- loads the localization table --
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster_Destroying") 

local private = {data={}, ignore={}}
TSMAPI:RegisterForTracing(private, "TSM_Destroying.GUI_private")


function GUI:OnEnable()
	private.frame = private:CreateDestroyingFrame()
	TSMAPI:CreateEventBucket("BAG_UPDATE", function() private:UpdateST() end, 0.2)
	GUI:RegisterEvent("LOOT_SLOT_CLEARED", private.LootChanged)
	GUI:RegisterEvent("LOOT_OPENED", private.LootOpened)
	GUI:RegisterEvent("LOOT_CLOSED", private.LootChanged)
	GUI:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED")
	GUI:RegisterEvent("UI_ERROR_MESSAGE", function(_, msg) if msg == ERR_INVALID_ITEM_TARGET or msg == SPELL_FAILED_ERROR then private.LootChanged() end end)
	TSMAPI:CreateTimeDelay("destroyingSTUpdate", 1, function() private:UpdateST() end)
end

function GUI:ShowFrame()
	private.hidden = nil
	private:UpdateST(true)
end

function private:CreateDestroyingFrame()
	local frameDefaults = {
		x = 850,
		y = 450,
		width = 200,
		height = 220,
		scale = 1,
	}
	local frame = TSMAPI:CreateMovableFrame("TSMDestroyingFrame", frameDefaults)
	frame:SetFrameStrata("HIGH")
	TSMAPI.Design:SetFrameBackdropColor(frame)
	
	local title = TSMAPI.GUI:CreateLabel(frame)
	title:SetText("TSM_Destroying")
	title:SetPoint("TOPLEFT")
	title:SetPoint("TOPRIGHT")
	title:SetHeight(20)
	
	local line = TSMAPI.GUI:CreateVerticalLine(frame, 0)
	line:ClearAllPoints()
	line:SetPoint("TOPRIGHT", -25, -1)
	line:SetWidth(2)
	line:SetHeight(22)
	
	local closeBtn = TSMAPI.GUI:CreateButton(frame, 18)
	closeBtn:SetPoint("TOPRIGHT", -3, -3)
	closeBtn:SetWidth(19)
	closeBtn:SetHeight(19)
	closeBtn:SetText("X")
	closeBtn:SetScript("OnClick", function()
			if InCombatLockdown() then return end
			TSM:Print(L["Hiding frame for the remainder of this session. Typing '/tsm destroy' will open the frame again."])
			private.hidden = true
			frame:Hide()
		end)
	
	TSMAPI.GUI:CreateHorizontalLine(frame, -23)
	
	local stContainer = CreateFrame("Frame", nil, frame)
	stContainer:SetPoint("TOPLEFT", 0, -25)
	stContainer:SetPoint("BOTTOMRIGHT", 0, 30)
	TSMAPI.Design:SetFrameColor(stContainer)
	
	local stCols = {
		{
			name = L["Item"],
			width = 0.6,
		},
		{
			name = L["Stack Size"],
			width = 0.4,
			align = "CENTER",
		},
	}
	local handlers = {
		OnClick = function(_, data, self, button)
			if not data then return end
			if button == "RightButton" then
				if IsShiftKeyDown() then
					TSM.db.global.ignore[data.itemString] = true
					TSM:Printf(L["Ignoring all %s permanently. You can undo this in the Destroying options."], data.link)
					TSM.Options:UpdateIgnoreST()
				else
					private.ignore[data.itemString] = true
					TSM:Printf(L["Ignoring all %s this session (until your UI is reloaded)."], data.link)
				end
				private:UpdateST()
			end
		end,
		OnEnter = function(_, data, self)
			if not data then return end
			local color = TSMAPI.Design:GetInlineColor("link")
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:AddLine(data.link)
			GameTooltip:AddLine(format(L["%sRight-Click|r to ignore this item for this session. Hold %sshift|r to ignore permanently. You can remove items from permanent ignore in the Destroying options."], color, color), 1, 1, 1, 1, true)
			GameTooltip:Show()
		end,
		OnLeave = function()
			GameTooltip:ClearLines()
			GameTooltip:Hide()
		end
	}
	local st = TSMAPI:CreateScrollingTable(stContainer, stCols, handlers, 12)
	st:SetData({})
	st:DisableSelection(true)
	frame.st = st
	
	local destroyBtn = TSMAPI.GUI:CreateButton(frame, 14, "TSMDestroyButton", true)
	destroyBtn:SetPoint("BOTTOMLEFT", 3, 3)
	destroyBtn:SetPoint("BOTTOMRIGHT",  -3, 3)
	destroyBtn:SetHeight(20)
	destroyBtn:SetText(L["Destroy Next"])
	destroyBtn:SetAttribute("type1", "macro")
	destroyBtn:SetAttribute("macrotext1", "")
	destroyBtn:SetScript("PreClick", function()
			if not destroyBtn:IsVisible() or #private.data == 0 then
				destroyBtn:SetAttribute("macrotext1", "")
			else
				local data = private.data[1]
				private.tempData = data
				destroyBtn:SetAttribute("macrotext1", format("/cast %s;\n/use %d %d", data.spell, data.bag, data.slot))
				destroyBtn:Disable()
				TSMAPI:CancelFrame("destroyEnableDelay")
				TSMAPI:CreateTimeDelay("destroyEnableDelay", 3, function() if not UnitCastingInfo("player") and not LootFrame:IsVisible() then destroyBtn:Enable() end end)
				private.highStack = data.numDestroys > 1
				private.currentSpell = data.spell
			end
		end)
	frame.destroyBtn = destroyBtn
	
	return frame
end

-- combine partial stacks
function private:Stack()
	local partialStacks = {}
	for bag, slot, itemString, quantity in TSMAPI:GetBagIterator(nil, TSM.db.global.includeSoulbound) do
		local spell, perDestroy = TSM:IsDestroyable(bag, slot, itemString)
		if spell and quantity % perDestroy ~= 0 and not private.ignore[itemString] and not TSM.db.global.ignore[itemString] then
			partialStacks[itemString] = partialStacks[itemString] or {}
			tinsert(partialStacks[itemString], {bag, slot})
		end
	end
	
	for itemString, locations in pairs(partialStacks) do
		for i=#locations, 2, -1 do
			local quantity = select(2, GetContainerItemInfo(unpack(locations[i])))
			local maxStack = select(8, GetItemInfo(itemString))
			if quantity == 0 or quantity == maxStack then break end
			
			for j=1, i-1 do
				local targetQuantity = select(2, GetContainerItemInfo(unpack(locations[j])))
				if targetQuantity ~= maxStack then
					PickupContainerItem(unpack(locations[i]))
					PickupContainerItem(unpack(locations[j]))
				end
			end
		end
	end
end

local isDelayed
function private:UpdateST(forceShow)
	if private.hidden then return end
	if (not private.frame or not private.frame:IsVisible()) and not forceShow and not isDelayed then
		TSMAPI:CreateTimeDelay("destroyBagUpdateDelay2", 1, function() isDelayed = true private:UpdateST() isDelayed = nil end)
		return
	end
	if InCombatLockdown() then return end
	
	if TSM.db.global.autoStack then
		private:Stack()
	end
	
	local stData = {}
	for bag, slot, itemString, quantity in TSMAPI:GetBagIterator(nil, TSM.db.global.includeSoulbound) do
		if not private.ignore[itemString] and not TSM.db.global.ignore[itemString] then
			local spell, perDestroy = TSM:IsDestroyable(bag, slot, itemString)
			local link = GetContainerItemLink(bag, slot)
			if spell and quantity >= perDestroy then
				local row = {
					cols = {
						{
							value = link,
						},
						{
							value = quantity
						},
					},
					itemString = itemString,
					link = link,
					quantity = quantity,
					bag = bag,
					slot = slot,
					spell = spell,
					perDestroy = perDestroy,
					numDestroys = floor(quantity/perDestroy),
				}
				tinsert(stData, row)
			end
		end
	end
	
	if #stData == 0 then
		if forceShow then
			TSM:Print(L["Nothing to destroy in your bags."])
		end
		private.frame.destroyBtn:Disable()
		private.frame:Hide()
	elseif (TSM.db.global.autoShow or forceShow) and not private.frame:IsVisible() then
		TSMAPI:CancelFrame("destroyEnableDelay")
		private.frame.destroyBtn:Enable()
		private.frame:Show()
	end
	private.data = CopyTable(stData)
	private.frame.st:SetData(stData)
end

function GUI:UNIT_SPELLCAST_INTERRUPTED(_, unit)
	if unit == "player" and private.frame and private.frame:IsVisible() then
		TSMAPI:CancelFrame("destroyEnableDelay")
		private.frame.destroyBtn:Enable()
	end
end

function private:LootOpened()
	if not private.currentSpell then return end
	local temp = {result={}, time=time()}
	for bag, slot, itemString, quantity, locked in TSMAPI:GetBagIterator(nil, TSM.db.global.includeSoulbound) do
		if locked and TSM:IsDestroyable(bag, slot, itemString) then
			temp.item = itemString
			break
		end
	end
	if temp.item and GetNumLootItems() > 0 then
		for i=1, GetNumLootItems() do
			local itemString = TSMAPI:GetItemString(GetLootSlotLink(i))
			local quantity = select(3, GetLootSlotInfo(i)) or 0
			if itemString and quantity > 0 then
				temp.result[itemString] = quantity
			end
		end
		TSM.db.global.history[private.currentSpell] = TSM.db.global.history[private.currentSpell] or {}
		tinsert(TSM.db.global.history[private.currentSpell], temp)
		TSM.Options:UpdateLogST()
	end
	private.currentSpell = nil
end

function private:LootChanged()
	if not private.tempData then return end
	if not LootFrame:IsVisible() then
		if private.frame and private.frame:IsVisible() then
			local quantity = select(2, GetContainerItemInfo(private.tempData.bag, private.tempData.slot))
			if quantity ~= private.tempData.quantity or quantity ~= private.tempData.perDestroy then
				TSMAPI:CancelFrame("destroyEnableDelay")
				private.frame.destroyBtn:Enable()
			end
		end
	elseif private.highStack and GetNumLootItems() <= 1 then
		if private.frame and private.frame:IsVisible() then
			TSMAPI:CancelFrame("destroyEnableDelay")
			private.frame.destroyBtn:Enable()
		end
	end
end