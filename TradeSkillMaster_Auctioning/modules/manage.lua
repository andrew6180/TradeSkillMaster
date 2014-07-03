-- ------------------------------------------------------------------------------ --
--                           TradeSkillMaster_Auctioning                          --
--           http://www.curse.com/addons/wow/tradeskillmaster_auctioning          --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- This file is to contain things that are common between different scan types.

local TSM = select(2, ...)
local Manage = TSM:NewModule("Manage", "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster_Auctioning") -- loads the localization table

local scanStatus = {}
local GUI, Util, mode

function Manage:StartScan(GUIRef, options)
	GUI = GUIRef
	mode = GUI.mode
	Util = TSM[mode]
	GUI.OnAction = Manage.OnGUIEvent
	wipe(scanStatus)
	TSM.Log:Clear()
	
	local scanList = Util:GetScanListAndSetup(GUI, options)
	GUI:UpdateSTData()
	if #scanList == 0 then
		GUI:Stopped()
		return
	end
	
	if options and options.noScan then -- no scanning required
		Manage:StartNoScanScan(GUIRef, scanList)
		return
	end
	
	GUI.statusBar:SetStatusText(L["Starting Scan..."])
	GUI.statusBar:UpdateStatus(0, 0)
	GUI.infoText:SetInfo(L["Running Scan..."])
	TSM.Scan:StartItemScan(scanList)
end

function Manage:StartNoScanScan(GUIRef, scanList)
	GUI.infoText:SetInfo(L["Processing Items..."])
	GUI.statusBar:UpdateStatus(0, 0)
	TSMAPI:CancelFrame("auctioningNoScanProcessing")
	scanStatus.query = {1, 1}
	
	local totalToScan = #scanList
	local function ProcessNoScanItems()
		local numLeft = #scanList
		for i=1, min(numLeft, 10) do
			Manage:ProcessScannedItem(tremove(scanList, 1), (i ~= endNum and i ~= 1))
			Manage:UpdateStatus("scan", totalToScan-#scanList, totalToScan)
		end
		
		if #scanList == 0 then
			TSMAPI:CancelFrame("auctioningNoScanProcessing")
			Manage:ScanComplete()
		end
	end
	TSMAPI:CreateTimeDelay("auctioningNoScanProcessing", 0, ProcessNoScanItems, 0.1)
end

function Manage:OnGUIEvent(event)
	if event == "action" then
		Util:DoAction()
	elseif event == "skip" then
		Util:SkipItem()
	elseif event == "stop" then
		TSMAPI:CancelFrame("auctioningNoScanProcessing")
		TSMAPI.AuctionScan:StopScan()
		Util:Stop()
	end
	TSMAPI:CreateTimeDelay("aucManageSTUpdate", 0.01, GUI.UpdateAuctionsSTData)
end

function Manage:ProcessScannedItem(itemString, noUpdate)
	Util:ProcessItem(itemString)
	if not noUpdate then
		GUI:UpdateSTData()
	end
end

function Manage:ScanComplete(interrupted)
	if interrupted then
		Util:Stop(true)
	else
		local numToManage = Util:DoneScanning()
		TSMAPI:FireEvent("AUCTIONING:SCANDONE", {num=numToManage})
		if numToManage == 0 then
			Util:Stop()
		elseif TSM.db.global.scanCompleteSound ~= 1 then
			PlaySound(TSM.Options:GetScanCompleteSound(TSM.db.global.scanCompleteSound), "Master")
		end
	end
end

-- these functions help display the status text which goes inside the statusbar
local function IsStepStarted(step)
	return scanStatus[step] and scanStatus[step][1] and scanStatus[step][2]
end
local function IsStepDone(step)
	return IsStepStarted(step) and scanStatus[step][1] == scanStatus[step][2]
end
-- update the statusbar
function Manage:UpdateStatus(statusType, current, total)
	scanStatus[statusType] = {current, total}
	if statusType == "query" then
		if total >= 0 then
			GUI.statusBar:SetStatusText(format(L["Preparing Filter %d / %d"], current, total))
		else
			GUI.statusBar:SetStatusText(format(L["Preparing Filters..."], current, total))
		end
	elseif IsStepDone("scan") and IsStepDone("manage") and IsStepDone("confirm") then -- scan complete
		GUI.statusBar:SetStatusText(L["Scan Complete!"])
	else
		local parts = {}
		if IsStepDone("scan") then
			tinsert(parts, L["Done Scanning"])
		elseif IsStepStarted("scan") then
			if IsStepStarted("page") then
				tinsert(parts, format(L["Scanning %d / %d (Page %d / %d)"], scanStatus.scan[1], scanStatus.scan[2], scanStatus.page[1], scanStatus.page[2]))
			else
				tinsert(parts, format(L["Scanning %d / %d"], scanStatus.scan[1], scanStatus.scan[2]))
			end
		end
		if IsStepDone("manage") then
			if mode == "Post" then
				tinsert(parts, L["Done Posting"])
			elseif mode == "Cancel" then
				tinsert(parts, L["Done Canceling"])
			end
			if IsStepStarted("confirm") then
				tinsert(parts, format(L["Confirming %d / %d"], scanStatus.confirm[1]+1, scanStatus.confirm[2]))
			else
				tinsert(parts, format(L["Confirming %d / %d"], 1, scanStatus.manage[2]))
			end
		elseif IsStepDone("scan") and IsStepStarted("manage") then
			if mode == "Post" then
				tinsert(parts, format(L["Posting %d / %d"], scanStatus.manage[1]+1, scanStatus.manage[2]))
			elseif mode == "Cancel" then
				tinsert(parts, format(L["Canceling %d / %d"], scanStatus.manage[1]+1, scanStatus.manage[2]))
			end
			if IsStepStarted("confirm") then
				tinsert(parts, format(L["Confirming %d / %d"], scanStatus.confirm[1]+1, scanStatus.confirm[2]))
			else
				tinsert(parts, format(L["Confirming %d / %d"], 1, scanStatus.manage[2]))
			end
		end
		GUI.statusBar:SetStatusText(table.concat(parts, "  -  "))
	end
	
	if IsStepDone("query") then
		local scanCurrent = scanStatus.scan and scanStatus.scan[1] or 0
		local scanTotal = scanStatus.scan and scanStatus.scan[2] or 1
		local confirmCurrent = scanStatus.confirm and scanStatus.confirm[1] or 0
		local confirmTotal = scanStatus.confirm and scanStatus.confirm[2] or 1
		GUI.statusBar:UpdateStatus(100*confirmCurrent/confirmTotal, 100*scanCurrent/scanTotal)
	end
end

function Manage:SetCurrentItem(currentItem)
	if currentItem and currentItem.itemString then
		GUI.infoText:SetInfo(currentItem)
	end
end

function Manage:GetCurrentItem()
	return currentItem
end

function Manage:SetInfoText(text)
	if type(text) ~= "table" then
		GUI:UpdateLogSTHighlight()
	end
	GUI.infoText:SetInfo(text)
end