-- ------------------------------------------------------------------------------ --
--                                TradeSkillMaster                                --
--                http://www.curse.com/addons/wow/tradeskill-master               --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- TSM's error handler.

local TSM = select(2, ...)
local AceGUI = LibStub("AceGUI-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster")


local origErrorHandler, ignoreErrors, isErrorFrameVisible, isAssert
TSMERRORLOG = {}
local tsmStack = {}
local stackNameLookup = {}

local addonSuites = {
	{name="ArkInventory"},
	{name="AtlasLoot"},
	{name="Altoholic"},
	{name="Auc-Advanced", commonTerm="Auc-"},
	{name="Bagnon"},
	{name="BigWigs"},
	{name="Broker"},
	{name="ButtonFacade"},
	{name="Carbonite"},
	{name="DataStore"},
	{name="DBM"},
	{name="Dominos"},
	{name="DXE"},
	{name="EveryQuest"},
	{name="Forte"},
	{name="FuBar"},
	{name="GatherMate2"},
	{name="Grid"},
	{name="LightHeaded"},
	{name="LittleWigs"},
	{name="Masque"},
	{name="MogIt"},
	{name="Odyssey"},
	{name="Overachiever"},
	{name="PitBull4"},
	{name="Prat-3.0"},
	{name="RaidAchievement"},
	{name="Skada"},
	{name="SpellFlash"},
	{name="TidyPlates"},
	{name="TipTac"},
	{name="Titan"},
	{name="UnderHood"},
	{name="WowPro"},
	{name="ZOMGBuffs"},
}

local function StrStartCmp(str, startStr)
	local startLen = strlen(startStr)

	if startLen <= strlen(str) then
		return strsub(str, 1, startLen) == startStr
	end
end


local function GetModule(msg)
	if strfind(msg, "TradeSkillMaster_") then
		return strmatch(msg, "TradeSkillMaster_[A-Za-z]+")
	elseif strfind(msg, "TradeSkillMaster\\") then
		return "TradeSkillMaster"
	end
	return "?"
end

local function ExtractErrorMessage(...)
	local msg = ""

	for _, var in ipairs({...}) do
		local varStr
		local varType = type(var)

		if	varType == "boolean" then
			varStr = var and "true" or "false"
		elseif varType == "table" then
			varStr = "<table>"
		elseif varType == "function" then
			varStr = "<function>"
		elseif var == nil then
			varStr = "<nil>"
		else
			varStr = var
		end

		msg = msg.." "..varStr
	end
	
	return msg
end

local function GetDebugStack()
	local stackInfo = {}
	local stackString = ""
	local stack = debugstack(2) or debugstack(1)
	
	if type(stack) == "string" then
		local lines = {("\n"):split(stack)}
		for _, line in ipairs(lines) do
			local strStart = strfind(line, "in function")
			if strStart and not strfind(line, "ErrorHandler.lua") then
				line = gsub(line, "`", "<", 1)
				line = gsub(line, "'", ">", 1)
				local inFunction = strmatch(line, "<[^>]*>", strStart)
				if inFunction then
					inFunction = gsub(gsub(inFunction, ".*\\", ""), "<", "")
					if inFunction ~= "" then
						local str = strsub(line, 1, strStart-2)
						str = strsub(str, strfind(str, "TradeSkillMaster") or 1)
						if strfind(inFunction, "`") then
							inFunction = strsub(inFunction, 2, -2)..">"
						end
						str = gsub(str, "TradeSkillMaster", "TSM")
						tinsert(stackInfo, str.." <"..inFunction)
					end
				end
			end
		end
	end
	
	return table.concat(stackInfo, "\n")
end

local function GetTSMStack()
	local stackInfo = {}
	local index = #tsmStack
	for i=1, 10 do -- only show up to 10 lines
		if not tsmStack[index] then break end
		tinsert(stackInfo, tsmStack[index])
		index = index - 1
	end
	return table.concat(stackInfo, "\n")
end

local function GetEventLog()
	local eventInfo = {}
	local eventLog = TSM:GetEventLog()
	for i, entry in ipairs(eventLog) do
		tinsert(eventInfo, format("%d | %s | %s", i, entry.event, tostring(entry.arg)))
	end
	return table.concat(eventInfo, "\n")
end

local function GetAddonList()
	local hasAddonSuite = {}
	local addons = {}
	local addonString = ""
	
	for i = 1, GetNumAddOns() do
		local name, _, _, enabled = GetAddOnInfo(i)
		local version = GetAddOnMetadata(name, "X-Curse-Packaged-Version") or GetAddOnMetadata(name, "Version") or ""
		if enabled then
			local isSuite
		
			for _, addonSuite in ipairs(addonSuites) do
				local commonTerm = addonSuite.commonTerm or addonSuite.name
				
				if StrStartCmp(name, commonTerm) then
					isSuite = commonTerm
					break
				end
			end
			
			if isSuite then
				if not hasAddonSuite[isSuite] then
					tinsert(addons, {name=name, version=version})
					hasAddonSuite[isSuite] = true
				end
			elseif StrStartCmp(name, "TradeSkillMaster") then
				tinsert(addons, {name=gsub(name, "TradeSkillMaster", "TSM"), version=version})
			else
				tinsert(addons, {name=name, version=version})
			end
		end
	end
	
	for i, addonInfo in ipairs(addons) do
		local info = addonInfo.name .. " (" .. addonInfo.version .. ")"
		if i == #addons then
			addonString = addonString .. "    " .. info
		else
			addonString = addonString .. "    " .. info .. "\n"
		end
	end
	
	return addonString
end

local function ShowError(msg, isVerify)
	if not AceGUI then
		TSMAPI:CreateTimeDelay("errHandlerShowDelay", 0.1, function()
				if AceGUI and UIParent then
					CancelFrame("errHandlerShowDelay")
					ShowError(msg, isVerify)
				end
			end, 0.1)
		return
	end

	local f = AceGUI:Create("TSMWindow")
	f:SetCallback("OnClose", function(self) isErrorFrameVisible = false AceGUI:Release(self) end)
	f:SetTitle(L["TradeSkillMaster Error Window"])
	f:SetLayout("Flow")
	f:SetWidth(500)
	f:SetHeight(400)
	
	local l = AceGUI:Create("Label")
	l:SetFullWidth(true)
	l:SetFontObject(GameFontNormal)
	if isVerify then
		l:SetText(L["Looks like TradeSkillMaster has detected an error with your configuration. Please address this in order to ensure TSM remains functional."].."\n"..L["|cffffff00DO NOT report this as an error to the developers.|r If you require assistance with this, make a post on the TSM forums instead."].."|r")
	else
		l:SetText(L["Looks like TradeSkillMaster has encountered an error. Please help the author fix this error by copying the entire error below and following the instructions for reporting bugs listed here (unless told elsewhere by the author):"].." |cffffff00http://tradeskillmaster.com/wiki|r")
	end
	f:AddChild(l)
	
	local heading = AceGUI:Create("Heading")
	heading:SetText("")
	heading:SetFullWidth(true)
	f:AddChild(heading)
	
	local eb = AceGUI:Create("MultiLineEditBox")
	eb:SetLabel(L["Error Info:"])
	eb:SetMaxLetters(0)
	eb:SetFullWidth(true)
	eb:SetText(msg)
	eb:DisableButton(true)
	eb:SetFullHeight(true)
	f:AddChild(eb)
	
	f.frame:SetFrameStrata("FULLSCREEN_DIALOG")
	f.frame:SetFrameLevel(100)
	isErrorFrameVisible = true
end

function TSM:IsValidError(...)
	if ignoreErrors then return end
	ignoreErrors = true
	local msg = ExtractErrorMessage(...)
	ignoreErrors = false
	if not strfind(msg, "TradeSkillMaster") then return end
	if strfind(msg, "auc%-stat%-wowuction") then return end
	return msg
end

function TSMAPI:Verify(cond, err)
	if cond then return end
	
	ignoreErrors = true
	
	tinsert(TSMERRORLOG, err)
	if not isErrorFrameVisible then
		TSM:Print(L["Looks like TradeSkillMaster has detected an error with your configuration. Please address this in order to ensure TSM remains functional."])
		ShowError(err, true)
	elseif isErrorFrameVisible == true then
		TSM:Print(L["Additional error suppressed"])
		isErrorFrameVisible = 1
	end
	
	ignoreErrors = false
end

local function TSMErrorHandler(msg)
	-- ignore errors while we are handling this error
	ignoreErrors = true
	TSMERRORTEMP = msg
	
	local color = TSMAPI.Design and TSMAPI.Design:GetInlineColor("link2") or ""
	local color2 = TSMAPI.Design and TSMAPI.Design:GetInlineColor("advanced") or ""
	local errorMessage = ""
	errorMessage = errorMessage..color.."Addon:|r "..color2..GetModule(msg).."|r\n"
	errorMessage = errorMessage..color.."Message:|r "..msg.."\n"
	errorMessage = errorMessage..color.."Date:|r "..date("%m/%d/%y %H:%M:%S").."\n"
	errorMessage = errorMessage..color.."Client:|r "..GetBuildInfo().."\n"
	errorMessage = errorMessage..color.."Locale:|r "..GetLocale().."\n"
	errorMessage = errorMessage..color.."Stack:|r\n"..GetDebugStack().."\n"
	errorMessage = errorMessage..color.."TSM Stack:|r\n"..GetTSMStack().."\n"
	errorMessage = errorMessage..color.."Local Variables:|r\n"..(debuglocals(isAssert and 5 or 4) or "").."\n"
	errorMessage = errorMessage..color.."TSM Event Log:|r\n"..GetEventLog().."\n"
	errorMessage = errorMessage..color.."Addons:|r\n"..GetAddonList().."\n"
	tinsert(TSMERRORLOG, errorMessage)
	if not isErrorFrameVisible then
		TSM:Print(L["Looks like TradeSkillMaster has encountered an error. Please help the author fix this error by following the instructions shown."])
		ShowError(errorMessage)
	elseif isErrorFrameVisible == true then
		TSM:Print(L["Additional error suppressed"])
		isErrorFrameVisible = 1
	end

	-- need to clear the stack
	tsmStack = {}
	ignoreErrors = false
end

function TSMAPI:Assert(cond, err)
	if cond then return end
	isAssert = true
	TSMErrorHandler(err)
	isAssert = false
end

do
	origErrorHandler = geterrorhandler()
	local errHandlerFrame = CreateFrame("Frame", nil, nil, "TSMErrorHandlerTemplate")
	errHandlerFrame.errorHandler = TSMErrorHandler
	errHandlerFrame.origErrorHandler = origErrorHandler
	seterrorhandler(errHandlerFrame.handler)
end

--[===[@debug@ 
--- Disables TSM's error handler until the game is reloaded.
-- This is mainly used for debugging errors with TSM's error handler and should not be used in actual code.
function TSMAPI:DisableErrorHandler()
	seterrorhandler(origErrorHandler)
end
--@end-debug@]===]



-- other debug functions
TSMAPI.Debug = {}

local dumpDefaults = {
	DEVTOOLS_MAX_ENTRY_CUTOFF = 30,    -- Maximum table entries shown
	DEVTOOLS_LONG_STRING_CUTOFF = 200, -- Maximum string size shown
	DEVTOOLS_DEPTH_CUTOFF = 10,        -- Maximum table depth
}

function TSMAPI.Debug:DumpTable(tbl, maxDepth, maxItems, maxStr)
	DEVTOOLS_DEPTH_CUTOFF = maxDepth or dumpDefaults.DEVTOOLS_DEPTH_CUTOFF
	DEVTOOLS_MAX_ENTRY_CUTOFF = maxItems or dumpDefaults.DEVTOOLS_MAX_ENTRY_CUTOFF
	DEVTOOLS_DEPTH_CUTOFF = maxStr or dumpDefaults.DEVTOOLS_DEPTH_CUTOFF
	
	if not IsAddOnLoaded("Blizzard_DebugTools") then
		LoadAddOn("Blizzard_DebugTools")
	end
	
	DevTools_Dump(tbl)
	
	for i, v in pairs(dumpDefaults) do
		_G[i] = v
	end
end


-- stack tracing functions
local function FormatTSMStack(obj, name, ...)
	local args
	for i=2, select('#', ...) do
		local arg = select(i, ...)
		local str
		if stackNameLookup[arg] then
			str = "<"..stackNameLookup[arg]..">"
		elseif type(arg) == "table" then
			if getmetatable(arg) and getmetatable(arg).__tostring then
				str = "<"..tostring(arg)..">"
			else
				local _, addr = (":"):split(tostring(arg))
				str = "table:"..tonumber(addr, 16)
			end
		elseif type(arg) == "string" then
			str = '"'..tostring(arg)..'"'
		elseif type(arg) == "function" then
			local _, addr = (":"):split(tostring(arg))
			str = "function:"..tonumber(addr, 16)
		else
			str = tostring(arg)
		end
		
		if args then
			args = args..", "..str
		else
			args = str
		end
	end
	
	local funcCall = "?"
	if obj == select(1, ...) and args then
		funcCall = (stackNameLookup[obj] or tostring(obj))..":"..name.."("..args..")"
	end
	return funcCall
end

-- this must be a separate function so we can return the ... after popping off the stack
local function TrackPopStack(...)	
	tremove(tsmStack, #tsmStack)
	return ...
end

local function RegisterForTracing(obj, name)
	stackNameLookup[obj] = name
	for name, v in pairs(obj) do
		if type(v) == "function" then
			TSM:RawHook(obj, name, function(...)
					tinsert(tsmStack, FormatTSMStack(obj, name, ...))
					return TrackPopStack(v(...))
				end)
		end
	end
end

function TSMAPI:RegisterForTracing(obj, name)
	-- wait one frame to ensure all functions are declared
	TSMAPI:CreateTimeDelay(0, function() RegisterForTracing(obj, name) end)
end