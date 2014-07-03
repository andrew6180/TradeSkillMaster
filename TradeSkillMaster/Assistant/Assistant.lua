-- ------------------------------------------------------------------------------ --
--                                TradeSkillMaster                                --
--                http://www.curse.com/addons/wow/tradeskill-master               --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

local TSM = select(2, ...)
local Assistant = TSM:NewModule("Assistant")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster") -- loads the localization table
local private = {}
TSMAPI:RegisterForTracing(private, "TradeSkillMaster.Assistant_private")
local MAX_ASSISTANT_BUTTONS = 6


function Assistant:Open()
	if not private.frame then
		if not private:ValidateQuestions(Assistant.INFO) then
			TSM:Print(L["No Assistant guides available for the modules which you have installed."])
			return
		end
		private.frame = private:CreateAssistantFrame()
	end
	private.frame:Show()
end

-- Removes questions which aren't possible due to missing steps (probably due to missing modules)
function private:ValidateQuestions(questionInfo)
	if not questionInfo.buttons then return false end
	
	for i=#questionInfo.buttons, 1, -1 do
		if questionInfo.buttons[i].guides then
			local hasAllGuides = true
			for _, guide in ipairs(questionInfo.buttons[i].guides) do
				if not Assistant.STEPS[guide] then
					hasAllGuides = false
					break
				end
			end
			if not hasAllGuides then
				tremove(questionInfo.buttons, i)
			end
		elseif questionInfo.buttons[i].children then
			if not private:ValidateQuestions(questionInfo.buttons[i].children) then
				tremove(questionInfo.buttons, i)
			end
		end
	end
	
	return #questionInfo.buttons > 0
end

function private:CreateAssistantFrame()
	local frameDefaults = {
		x = 50,
		y = 300,
		width = 400,
		height = 250,
		scale = 1,
	}
	local frame = TSMAPI:CreateMovableFrame("TSMAssistantFrame", frameDefaults)
	TSMAPI.Design:SetFrameBackdropColor(frame)
	frame:Hide()
	frame:SetScript("OnShow", function(self)
			self.guideFrame:Hide()
			self.questionFrame:Show()
		end)
	frame:SetScript("OnHide", function(self)
			private.currentStep = nil
		end)

	local title = frame:CreateFontString()
	title:SetFont(TSMAPI.Design:GetContentFont(), 18)
	TSMAPI.Design:SetWidgetLabelColor(title)
	title:SetPoint("TOP", frame, 0, -3)
	title:SetText(L["TSM Assistant"])
	
	TSMAPI.GUI:CreateHorizontalLine(frame, -25)

	local closeBtn = TSMAPI.GUI:CreateButton(frame, 18)
	closeBtn:SetPoint("TOPRIGHT", -3, -3)
	closeBtn:SetWidth(19)
	closeBtn:SetHeight(19)
	closeBtn:SetText("X")
	closeBtn:SetScript("OnClick", function() frame:Hide() end)
	
	frame.questionFrame = private:CreateQuestionFrame(frame)
	frame.guideFrame = private:CreateGuideFrame(frame)
	return frame
end

function private:CreateQuestionFrame(parent)
	local frame = CreateFrame("Frame", nil, parent)
	frame:SetAllPoints()
	frame:Hide()
	frame:SetScript("OnShow", function(self)
			private.pageInfo = Assistant.INFO
			self.restartButton:Hide()
			self:Update()
		end)
	
	function frame.Update(self)
		-- update the title question
		self.questionText:SetText(private.pageInfo.title)
		
		-- hide all the buttons
		for _, button in ipairs(self.buttons) do
			button:Hide()
		end
		
		-- update buttons
		for i, buttonInfo in ipairs(private.pageInfo.buttons) do
			self.buttons[i]:Show()
			self.buttons[i]:SetText(buttonInfo.text)
			self.buttons[i].info = buttonInfo
		end
	end
	
	local questionText = TSMAPI.GUI:CreateTitleLabel(frame, 16)
	questionText:SetPoint("TOPLEFT", 5, -30)
	questionText:SetPoint("TOPRIGHT", -5, -30)
	questionText:SetHeight(20)
	questionText:SetJustifyH("LEFT")
	questionText:SetJustifyV("CENTER")
	frame.questionText = questionText
	
	local function OnAnswerButtonClicked(self)
		if self.info.children then
			private.frame.questionFrame.restartButton:Show()
			private.pageInfo = self.info.children
			private.frame.questionFrame:Update()
		elseif self.info.guides then
			private.steps = {}
			for _, guideKey in ipairs(self.info.guides) do
				for _, step in ipairs(Assistant.STEPS[guideKey]) do
					tinsert(private.steps, step)
				end
			end
			private.frame.questionFrame:Hide()
			private.frame.guideFrame:Show()
		end
	end
	
	frame.buttons = {}
	for i=1, MAX_ASSISTANT_BUTTONS do
		local button = TSMAPI.GUI:CreateButton(frame, 14)
		button:SetHeight(20)
		if i == 1 then
			button:SetPoint("TOPLEFT", frame.questionText, "BOTTOMLEFT", 0, -5)
			button:SetPoint("TOPRIGHT", frame.questionText, "BOTTOMRIGHT", 0, -5)
		else
			button:SetPoint("TOPLEFT", frame.buttons[i-1], "BOTTOMLEFT", 0, -5)
			button:SetPoint("TOPRIGHT", frame.buttons[i-1], "BOTTOMRIGHT", 0, -5)
		end
		button:SetScript("OnClick", OnAnswerButtonClicked)
		tinsert(frame.buttons, button)
	end
	
	local restartButton = TSMAPI.GUI:CreateButton(frame, 14)
	restartButton:SetHeight(20)
	restartButton:SetPoint("BOTTOMLEFT", 5, 5)
	restartButton:SetPoint("BOTTOMRIGHT", -5, 5)
	restartButton:SetText(L["Restart Assistant"])
	restartButton:SetScript("OnClick", function(self)
			self:Hide()
			private.pageInfo = Assistant.INFO
			private.frame.questionFrame:Update()
		end)
	frame.restartButton = restartButton
	
	return frame
end

function private:CreateGuideFrame(parent)
	local frame = CreateFrame("Frame", nil, parent)
	frame:SetAllPoints()
	frame:Hide()
	frame:SetScript("OnShow", function(self)
			private.currentStep = 1
			private.checkPoint = 1
			Assistant:ClearStepData()
			self:Update()
			private:StartStepWaitThread()
		end)
		
	function frame.Update(self)
		if private.currentStep == -1 then
			self.stepTitle:SetText(L["Done!"])
			self.stepDesc:SetText(L["You have successfully completed this guide. If you require further assistance, visit out our website:"].."\n\n".."http://tradeskillmaster.com")
			self.button:Hide()
			self.restartButton:Show()
		else
			local stepInfo = private.steps[private.currentStep]
			self.stepTitle:SetText(stepInfo.title)
			if stepInfo.getDescArgs then
				self.stepDesc:SetText(format(stepInfo.description, stepInfo.getDescArgs()))
			else
				self.stepDesc:SetText(stepInfo.description)
			end
			if stepInfo.doneButton then
				self.button:Show()
				self.button:SetText(stepInfo.doneButton)
				self.button:SetScript("OnClick", function() stepInfo:onDoneButtonClicked() end)
				self.stepDesc:SetWidth(min(self.stepDesc:GetStringWidth(), self:GetWidth()-10))
			else
				self.button:Hide()
				self.stepDesc:SetWidth(self:GetWidth()-10)
			end
			self.restartButton:Hide()
		end
	end

	local stepTitle = TSMAPI.GUI:CreateTitleLabel(frame, 16)
	stepTitle:SetPoint("TOPLEFT", 5, -30)
	stepTitle:SetPoint("TOPRIGHT", -5, -30)
	stepTitle:SetHeight(20)
	stepTitle:SetJustifyH("LEFT")
	stepTitle:SetJustifyV("CENTER")
	stepTitle:SetText("DEFAULT")
	frame.stepTitle = stepTitle

	local stepDesc = TSMAPI.GUI:CreateLabel(frame, "normal")
	stepDesc:SetPoint("TOPLEFT", 5, -55)
	stepDesc:SetJustifyH("LEFT")
	stepDesc:SetJustifyV("TOP")
	frame.stepDesc = stepDesc
	
	local button = TSMAPI.GUI:CreateButton(frame, 14)
	button:SetHeight(20)
	button:SetPoint("TOPLEFT", frame.stepDesc, "BOTTOMLEFT", 0, -5)
	button:SetPoint("TOPRIGHT", frame.stepDesc, "BOTTOMRIGHT", 0, -5)
	button:SetScript("OnClick", function() end)
	frame.button = button
	
	local restartButton = TSMAPI.GUI:CreateButton(frame, 14)
	restartButton:SetHeight(20)
	restartButton:SetPoint("BOTTOMLEFT", 5, 5)
	restartButton:SetPoint("BOTTOMRIGHT", -5, 5)
	restartButton:SetText(L["Restart Assistant"])
	restartButton:SetScript("OnClick", function(self)
			parent:Hide()
			Assistant:Open()
		end)
	frame.restartButton = restartButton
	
	return frame
end


function private:StartStepWaitThread()
	TSMAPI.Threading:Start(private.GuideThread, 0.1, private.StepComplete)
end

function private:IsStepDone(step)
	if step.isDone and step:isDone() then
		return true
	end
end

function private:GetCurrentStep()
	for i=private.checkPoint, #private.steps do
		if not private:IsStepDone(private.steps[i]) then
			return i
		elseif private.steps[i].isCheckPoint then
			private.checkPoint = i+1
		end
	end
end

function private.GuideThread(self)
	-- loop until the player finishes the step or we abort
	while private.currentStep do
		local stepNum = private:GetCurrentStep()
		if not stepNum then return end
		if stepNum ~= private.currentStep then
			private.currentStep = stepNum
		end
		private.frame.guideFrame:Update()
		self:Sleep(0.1)
	end
end

function private.StepComplete()
	if private.currentStep then
		private.currentStep = -1
		private.frame.guideFrame:Update()
	end
end