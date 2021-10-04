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
local move = TSM:NewModule("move", "AceEvent-3.0")
local AceGUI = LibStub("AceGUI-3.0") -- load the AceGUI libraries

function move:restockGroup(grpInfo)
	local restockItems, next = TSM.data:unIndexRestockGroupTree(grpInfo), next
	if next(restockItems) == nil then
		TSM:Print(L["Nothing to Restock"])
	else
		TSM:Print(L["Restocking"])
		TSMAPI:MoveItems(restockItems, TSM.PrintMsg)
	end
end

function move:groupTree(grpInfo, src)
	local moveItems, next = TSM.data:unIndexMoveGroupTree(grpInfo, src), next
	if next(moveItems) == nil then
		TSM:Print(L["Nothing to Move"])
	else
		TSM:Print(L["Preparing to Move"])
		TSMAPI:MoveItems(moveItems, TSM.PrintMsg)
	end
end

function move:EmptyRestore(dest, restore)
	local moveItems
	local next = next
	local isGuildBank = false

	if dest == "guildbank" then
		isGuildBank = true
	else
		isGuildBank = false
	end

	if restore then
		moveItems = TSM.db.factionrealm.BagState
	else
		local srcTable = move:getContainerTable("bags")
		moveItems = TSM.data:getEmptyRestoreGroup(srcTable, isGuildBank)
	end

	if next(moveItems) == nil then
		TSM:Print(L["Nothing to Move"])
	else
		TSM:Print(L["Preparing to Move"])
		TSMAPI:MoveItems(moveItems, TSM.PrintMsg, true)
		if restore then
			TSM.db.factionrealm.BagState = {}
		end
	end
end

function move:manualMove(searchString, src, quantity)
	local moveItems = TSM.data:unIndexItem(searchString, src, quantity)
	local next = next
	if next(moveItems) == nil then
		TSM:Print(L["Nothing to Move"])
	else
		TSM:Print(L["Preparing to Move"])
		TSMAPI:MoveItems(moveItems, TSM.PrintMsg)
	end
end

function move:getContainerTable(cnt)
	local t = {}

	if cnt == "bank" then
		local numSlots, _ = GetNumBankSlots()

		for i = 1, numSlots + 1 do
			if i == 1 then
				t[i] = -1
			else
				t[i] = i + 3
			end
		end

		return t

	elseif cnt == "guildbank" then
		for i = 1, GetNumGuildBankTabs() do
			local canView, canDeposit, stacksPerDay = GetGuildBankTabInfo(i);
			if canView and canDeposit and stacksPerDay then
				t[i] = i
			end
		end

		return t
	elseif cnt == "bags" then
		for i = 1, NUM_BAG_SLOTS + 1 do t[i] = i - 1
		end

		return t
	end
end

function move:areBanksVisible()
	if BagnonFrameguildbank and BagnonFrameguildbank:IsVisible() then
		return true
	elseif BagnonFramebank and BagnonFramebank:IsVisible() then
		return true
	elseif GuildBankFrame and GuildBankFrame:IsVisible() then
		return true
	elseif BankFrame and BankFrame:IsVisible() then
		return true
	elseif (ARKINV_Frame4 and ARKINV_Frame4:IsVisible()) or (ARKINV_Frame3 and ARKINV_Frame3:IsVisible()) then
		return true
	elseif (BagginsBag8 and BagginsBag8:IsVisible()) or (BagginsBag9 and BagginsBag9:IsVisible()) or (BagginsBag10 and BagginsBag10:IsVisible()) or (BagginsBag11 and BagginsBag11:IsVisible()) or (BagginsBag12 and BagginsBag12:IsVisible()) then
		return true
	elseif (CombuctorFrame2 and CombuctorFrame2:IsVisible()) then
		return true
	elseif (BaudBagContainer2_1 and BaudBagContainer2_1:IsVisible()) then
		return true
	elseif (AdiBagsContainer2 and AdiBagsContainer2:IsVisible()) then
		return true
	elseif (OneBankFrame and OneBankFrame:IsVisible()) then
		return true
	elseif (EngBank_frame and EngBank_frame:IsVisible()) then
		return true
	elseif (TBnkFrame and TBnkFrame:IsVisible()) then
		return true
	elseif (famBankFrame and famBankFrame:IsVisible()) then
		return true
	elseif (LUIBank and LUIBank:IsVisible()) then
		return true
	elseif (ElvUI_BankContainerFrame and ElvUI_BankContainerFrame:IsVisible()) then
		return true
	elseif (TukuiBank and TukuiBank:IsShown()) then
		return true
	elseif (AdiBagsContainer1 and AdiBagsContainer1.isBank and AdiBagsContainer1:IsVisible()) or (AdiBagsContainer2 and AdiBagsContainer2.isBank and AdiBagsContainer2:IsVisible()) then
		return true
	elseif BagsFrameBank and BagsFrameBank:IsVisible() then
		return true
	elseif AspUIBank and AspUIBank:IsVisible() then
		return true
	elseif NivayacBniv_Bank and NivayacBniv_Bank:IsVisible() then
		return true
	elseif DufUIBank and DufUIBank:IsVisble() then
		return true
	end
	TSM:Print(L["Canceled"])
	return nil
end

function TSM.PrintMsg(message)
	TSM:Print(message)
end