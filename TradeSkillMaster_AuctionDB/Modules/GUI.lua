-- ------------------------------------------------------------------------------ --
--                           TradeSkillMaster_AuctionDB                           --
--           http://www.curse.com/addons/wow/tradeskillmaster_auctiondb           --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- load the parent file (TSM) into a local variable and register this file as a module
local TSM = select(2, ...)
local GUI = TSM:NewModule("GUI")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster_AuctionDB") -- loads the localization table
	
local private = {}

function GUI:Show(frame)
	private.statusBar = private.statusBar or private:CreateStatusBar(frame.content)
	private.statusBar:Show()
	GUI:UpdateStatus("", 0, 0)
	
	private.startScanContent = private.startScanContent or private:CreateStartScanContent(frame)
	private.startScanContent:Show()
end

function GUI:Hide()
	private.statusBar:Hide()
	private.startScanContent:Hide()
	
	TSM.Scan:DoneScanning()
	TSMAPI.AuctionScan:StopScan()
end

function GUI:UpdateStatus(text, major, minor)
	if text then
		private.statusBar:SetStatusText(text)
	end
	if major or minor then
		private.statusBar:UpdateStatus(major, minor)
	end
end

function private:CreateStatusBar(parent)
	local frame = TSMAPI.GUI:CreateStatusBar(parent, "TSMAuctionDBStatusBar")
	TSMAPI.GUI:CreateHorizontalLine(frame, -30, parent)
	
	return frame
end

function private:CreateStartScanContent(parent)
	local frame = CreateFrame("Frame", nil, parent)
	frame:SetAllPoints(parent)
	frame:Hide()

	local function UpdateGetAllButton()
		if TSM.Scan.isScanning then
			frame:Disable()
		elseif not select(2, CanSendAuctionQuery()) then
			local previous = TSM.db.profile.lastGetAll or time()
			if previous > (time() - 15*60) then
				local diff = previous + 15*60 - time()
				local diffMin = math.floor(diff/60)
				local diffSec = diff - diffMin*60
				frame.getAllStatusText:SetText("|cff990000"..format(L["Ready in %s min and %s sec"], diffMin, diffSec))
			else
				frame.getAllStatusText:SetText("|cff990000"..L["Not Ready"])
			end
			frame:Enable()
			frame.startGetAllButton:Disable()
		else
			frame:Enable()
			frame.getAllStatusText:SetText("|cff009900"..L["Ready"])
			frame.startGetAllButton:Enable()
		end
	end
	
	frame:SetScript("OnShow", function(self)
			TSMAPI:CreateTimeDelay("auctionDBGetAllStatus", 0, UpdateGetAllButton, 0.2)
		end)
	
	frame:SetScript("OnHide", function(self)
			TSMAPI:CancelFrame("auctionDBGetAllStatus")
		end)
		
	frame.Enable = function(self)
		self.startGetAllButton:Enable()
		self.startFullScanButton:Enable()
		self.startGroupScanButton:Enable()
	end

	frame.Disable = function(self)
		self.startGetAllButton:Disable()
		self.startFullScanButton:Disable()
		self.startGroupScanButton:Disable()
	end
	
	-- top row (auto updater)
	local text = TSMAPI.GUI:CreateLabel(frame)
	text:SetFont(TSMAPI.Design:GetContentFont(), 24)
	text:SetPoint("TOP", 0, -24)
	text:SetHeight(24)
	text:SetJustifyH("CENTER")
	text:SetJustifyV("CENTER")
	text:SetText(TSMAPI.Design:GetInlineColor("link").."TSM_AuctionDB")
	local ag = text:CreateAnimationGroup()
	local a1 = ag:CreateAnimation("Alpha")
	a1:SetChange(-.5)
	a1:SetDuration(.5)
	ag:SetLooping("BOUNCE")
	ag:Play()
	
	local content = CreateFrame("Frame", nil, frame)
	content:SetAllPoints(parent.content)
	TSMAPI.Design:SetFrameBackdropColor(content)
	
	-- group tree
	local container = CreateFrame("Frame", nil, content)
	container:SetPoint("TOPLEFT", 5, -35)
	container:SetPoint("BOTTOMRIGHT", -205, 5)
	TSMAPI.Design:SetFrameColor(container)
	frame.groupTree = TSMAPI:CreateGroupTree(container, nil, "AuctionDB")
	
	local bar = TSMAPI.GUI:CreateVerticalLine(content, 0)
	bar:ClearAllPoints()
	bar:SetPoint("TOPRIGHT", -200, -30)
	bar:SetPoint("BOTTOMRIGHT", -200, 0)
	
	local buttonFrame = CreateFrame("Frame", nil, content)
	buttonFrame:SetPoint("TOPLEFT", content, "TOPRIGHT", -200, 0)
	buttonFrame:SetPoint("BOTTOMRIGHT")
	
	-- first row (getall scan)
	local btn = TSMAPI.GUI:CreateButton(buttonFrame, 18)
	btn:SetPoint("TOPLEFT", 6, -50)
	btn:SetPoint("TOPRIGHT", -6, -50)
	btn:SetHeight(22)
	btn:SetScript("OnClick", TSM.Scan.StartGetAllScan)
	btn:SetText(L["Run GetAll Scan"])
	btn.tooltip = L["A GetAll scan is the fastest in-game method for scanning every item on the auction house. However, there are many possible bugs on Blizzard's end with it including the chance for it to disconnect you from the game. Also, it has a 15 minute cooldown."]
	frame.startGetAllButton = btn
	
	local text = TSMAPI.GUI:CreateLabel(buttonFrame)
	text:SetPoint("TOPLEFT", btn, "BOTTOMLEFT", 0, -3)
	text:SetPoint("TOPRIGHT", btn, "BOTTOMRIGHT", 0, -3)
	text:SetHeight(16)
	text:SetJustifyH("CENTER")
	text:SetJustifyV("CENTER")
	frame.getAllStatusText = text
	
	TSMAPI.GUI:CreateHorizontalLine(buttonFrame, -110)
	
	-- second row (full scan)
	local btn = TSMAPI.GUI:CreateButton(buttonFrame, 18)
	btn:SetPoint("TOPLEFT", 6, -150)
	btn:SetPoint("TOPRIGHT", -6, -150)
	btn:SetHeight(22)
	btn:SetScript("OnClick", TSM.Scan.StartFullScan)
	btn:SetText(L["Run Full Scan"])
	btn.tooltip = L["A full auction house scan will scan every item on the auction house but is far slower than a GetAll scan. Expect this scan to take several minutes or longer."]
	frame.startFullScanButton = btn
	
	TSMAPI.GUI:CreateHorizontalLine(buttonFrame, -200)
	
	-- third row (group scan)
	local btn = TSMAPI.GUI:CreateButton(buttonFrame, 18)
	btn:SetPoint("TOPLEFT", 6, -225)
	btn:SetPoint("TOPRIGHT", -6, -225)
	btn:SetHeight(22)
	btn:SetScript("OnClick", GUI.StartGroupScan)
	btn:SetText(L["Scan Selected Groups"])
	btn.tooltip = L["This will do a slow auction house scan of every item in the selected groups and update their AuctionDB prices. This may take several minutes."]
	frame.startGroupScanButton = btn
	
	return frame
end

function GUI:StartGroupScan()
	local items = {}
	for groupName, data in pairs(private.startScanContent.groupTree:GetSelectedGroupInfo()) do
		groupName = TSMAPI:FormatGroupPath(groupName, true)
		for itemString in pairs(data.items) do
			tinsert(items, itemString)
		end
	end
	TSM.Scan:StartGroupScan(items)
end