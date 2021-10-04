local TSM = select(2, ...)
local Sidebar = TSM:NewModule("Sidebar", "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster_Shopping") -- loads the localization table

local private = {pages={}, order={}, createFunctions={}, updateFunctions={}, currentPage=nil}


function Sidebar:Show(parent)
	private.frame = private.frame or private:CreateSidebar(parent)
	private.frame:Show()
end

function Sidebar:Hide()
	if not private.frame then return end
	private.frame:Hide()
end

function private:CreateSidebar(parent)
	TSM.Util:ShowSearchFrame(nil, L["% Market Value"])
	local frame = CreateFrame("Frame", nil, parent)
	frame:SetPoint("TOPLEFT", parent, "TOPRIGHT", 2, 0)
	frame:SetPoint("BOTTOMLEFT", parent, "BOTTOMRIGHT", 2, 0)
	frame:SetWidth(300)
	TSMAPI.Design:SetFrameBackdropColor(frame)
	
	local content = CreateFrame("Frame", nil, frame)
	content:SetPoint("TOPLEFT", 5, -5)
	content:SetPoint("BOTTOMRIGHT", -5, 5)
	frame.content = content
	
	for label, func in pairs(private.createFunctions) do
		frame.content[label] = func(content)
		frame.content[label]:Hide()
	end
	private.currentPage = private.currentPage or private.order[1]
	frame.content[private.currentPage]:Show()
	
	return frame
end

function Sidebar:AddSidebarFeature(label, createFunc, updateFunc)
	private.pages[label] = label
	private.createFunctions[label] = createFunc
	private.updateFunctions[label] = updateFunc
	tinsert(private.order, label)
end

function Sidebar:UpdateCurrentFrame()
	if private.currentPage and private.updateFunctions[private.currentPage] then
		private.updateFunctions[private.currentPage]()
	end
end

function Sidebar:GetPages()
	return private.order
end

function Sidebar:ButtonClick(key)
	for i in pairs(private.pages) do
		private.frame.content[i]:Hide()
	end
	private.frame.content[key]:Show()
	private.currentPage = key
end

function Sidebar:GetCurrentPage()
	if not private.frame or not private.frame:IsVisible() then return end
	
	if private.currentPage == L["Saved Searches"] then	
		return "saved"
	elseif private.currentPage == L["TSM Groups"] then	
		return "groups"
	elseif private.currentPage == L["Log"] then	
		return "log"
	elseif private.currentPage == L["Quick Posting"] then	
		return "quick"
	elseif private.currentPage == L["Custom Filter"] then	
		return "custom"
	elseif private.currentPage == OTHER then	
		return "other"
	end
end