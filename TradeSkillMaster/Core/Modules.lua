-- ------------------------------------------------------------------------------ --
--                                TradeSkillMaster                                --
--                http://www.curse.com/addons/wow/tradeskill-master               --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- This file contains all the code for the new standardized module registration / format

local TSM = select(2, ...)
local Modules = TSM:NewModule("Modules", "AceConsole-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster") -- loads the localization table
local moduleObjects = TSM.moduleObjects
local moduleNames = TSM.moduleNames


-- initialization stuff
function Modules:OnEnable()
	-- register the chat commands (slash commands) - whenver '/tsm' or '/tradeskillmaster' is typed by the user, Modules:ChatCommand() will be called
	Modules:RegisterChatCommand("tsm", "ChatCommand")
	Modules:RegisterChatCommand("tradeskillmaster", "ChatCommand")

	-- tooltip setup
	TSM:SetupTooltips()

	-- no modules popup
	TSMAPI:CreateTimeDelay("noModulesPopup", 3, function()
		if #moduleNames == 1 then
			StaticPopupDialogs["TSMInfoPopup"] = {
				text = L["|cffffff00Important Note:|r You do not currently have any modules installed / enabled for TradeSkillMaster! |cff77ccffYou must download modules for TradeSkillMaster to have some useful functionality!|r\n\nPlease visit http://www.curse.com/addons/wow/tradeskill-master and check the project description for links to download modules."],
				button1 = L["I'll Go There Now!"],
				timeout = 0,
				whileDead = true,
				OnAccept = function() TSM:Print(L["Just incase you didn't read this the first time:"]) TSM:Print(L["|cffffff00Important Note:|r You do not currently have any modules installed / enabled for TradeSkillMaster! |cff77ccffYou must download modules for TradeSkillMaster to have some useful functionality!|r\n\nPlease visit http://www.curse.com/addons/wow/tradeskill-master and check the project description for links to download modules."]) end,
				preferredIndex = 3,
			}
			TSMAPI:ShowStaticPopupDialog("TSMInfoPopup")
		end
	end)
end


-- **************************************************************************
--                             TSMAPI:NewModule API
-- **************************************************************************

-- info on all the possible fields of the module objects which TSM core cares about
local moduleFieldInfo = {
	-- operation fields
	{ key = "operations", type = "table", subFieldInfo = { maxOperations = "number", callbackOptions = "function", callbackInfo = "function" } },
	-- tooltip fields
	{ key = "GetTooltip", type = "function" },
	-- tooltip options
	{ key = "tooltipOptions", type = "table", subFieldInfo = { callback = "function" } },
	-- shared feature fields
	{ key = "slashCommands", type = "table", subTableInfo = { key = "string", label = "string", callback = "function" } },
	{ key = "icons", type = "table", subTableInfo = { side = "string", desc = "string", callback = "function", icon = "string" } },
	{ key = "auctionTab", type = "table", subFieldInfo = { callbackShow = "function", callbackHide = "function" } },
	{ key = "bankUiButton", type = "table", subFieldInfo = { callback = "function" } },
	-- data access fields
	{ key = "priceSources", type = "table", subTableInfo = { key = "string", label = "string", callback = "function" } },
	{ key = "moduleAPIs", type = "table", subTableInfo = { key = "string", callback = "function" } },
	-- multi-account sync fields
	{ key = "sync", type = "table", subFieldInfo = { callback = "function" } },
}

-- if the passed function is a string, will check if it's a method of the object and return a wrapper function
function Modules:GetFunction(obj, func)
	if type(func) == "string" then
		local part1, part2 = (":"):split(func)
		if part2 and obj[part1] and obj[part1][part2] then
			return function(...) return obj[part1][part2](obj[part1], ...) end
		elseif obj[part1] then
			return function(...) return obj[part1](obj, ...) end
		end
	end
	return func
end

-- validates a simple list of sub-tables which have the basic key/label/callback fields
function Modules:ValidateList(obj, val, keys)
	for i, v in ipairs(val) do
		if type(v) ~= "table" then
			return "invalid entry in list at index " .. i
		end
		for key, valType in pairs(keys) do
			if valType == "function" then
				v[key] = Modules:GetFunction(obj, v[key])
			end
			if type(v[key]) ~= valType then
				return format("expected %s type for field %s, got %s at index %d", valType, key, type(v[key]), i)
			end
		end
	end
end

function Modules:ValidateModuleObject(obj)
	-- make sure it's a table
	if type(obj) ~= "table" then
		return format("Expected table, got %s.", type(obj))
	end
	-- simple check that it's an AceAddon object which stores the name in .name and implements a .__tostring metamethod.
	if tostring(obj) ~= obj.name then
		return "Passed object is not an AceAddon-3.0 object."
	end

	-- validate all the fields
	for _, fieldInfo in ipairs(moduleFieldInfo) do
		local val = obj[fieldInfo.key]
		if val then
			-- make sure it's of the correct type
			if type(val) ~= fieldInfo.type then
				return format("For field '%s', expected type of %s, got %s.", fieldInfo.key, fieldInfo.type, type(val))
			end
			-- if there's required subfields, check them
			if fieldInfo.subFieldInfo then
				for key, valType in pairs(fieldInfo.subFieldInfo) do
					if valType == "function" then
						val[key] = Modules:GetFunction(obj, val[key])
					end
					if type(val[key]) ~= valType then
						return format("expected %s type for field %s, got %s at index %d", valType, key, type(val[key]), i)
					end
				end
			end
			-- if there's subTableInfo specified, run Modules:ValidateList on this field
			if fieldInfo.subTableInfo then
				local errMsg = Modules:ValidateList(obj, val, fieldInfo.subTableInfo)
				if errMsg then
					return format("Invalid value for '%s': %s.", fieldInfo.key, errMsg)
				end
			end
		end
	end
end

function Modules:GetInfo()
	local info = {}
	for _, name in ipairs(moduleNames) do
		local obj = moduleObjects[name]
		tinsert(info, { name = name, version = obj._version, author = obj._author, desc = obj._desc })
	end
	return info
end

function TSMAPI:NewModule(obj)
	local errMsg
	if obj == TSM then
		local tmp = TSM.operations
		TSM.operations = nil
		errMsg = Modules:ValidateModuleObject(obj)
		TSM.operations = tmp
	else
		errMsg = Modules:ValidateModuleObject(obj)
	end
	if errMsg then
		error(errMsg, 2)
	end
	
	-- register the db callback
	if obj.db and obj.OnTSMDBShutdown then
		obj.appDB = TSM.appDB
		obj.db:RegisterCallback("OnDatabaseShutdown", TSM.ModuleOnDatabaseShutdown)
	end
	
	-- register it for debug tracing
	TSMAPI:RegisterForTracing(obj)
	for _, subModule in pairs(obj.modules or {}) do
		local name = obj.name.."."..subModule.moduleName
		TSMAPI:RegisterForTracing(subModule, name)
	end

	-- sets the _version, _author, and _desc fields
	local fullName = gsub(obj.name, "TSM_", "TradeSkillMaster_")
	obj._version = GetAddOnMetadata(fullName, "X-Curse-Packaged-Version") or GetAddOnMetadata(fullName, "Version")
	if strsub(obj._version, 1, 1) == "@" then
		obj._version = "Dev"
	end
	obj._author = GetAddOnMetadata(fullName, "Author")
	obj._desc = GetAddOnMetadata(fullName, "Notes")

	-- store the object in the local table
	local moduleName = gsub(obj.name, "TradeSkillMaster_", "")
	moduleName = gsub(obj.name, "TSM_", "")
	moduleObjects[moduleName] = obj
	tinsert(moduleNames, moduleName)
	sort(moduleNames, function(a, b)
		if a == "TradeSkillMaster" then
			return true
		elseif b == "TradeSkillMaster" then
			return false
		else
			return a < b
		end
	end)

	-- register icons with main frame code
	if obj.icons then
		for _, info in ipairs(obj.icons) do
			if info.slashCommand then
				obj.slashCommands = obj.slashCommands or {}
				tinsert(obj.slashCommands, {key=info.slashCommand, label=format("Opens the TSM window to the '%s' page", info.desc), callback=function() TSMAPI:OpenFrame() TSMAPI:SelectIcon(obj.name, info.desc) end})
			end
			TSM:RegisterMainFrameIcon(info.desc, info.icon, info.callback, obj.name, info.side)
		end
	end

	-- register auction buttons with auction frame code
	if obj.auctionTab then
		TSM:RegisterAuctionFunction(moduleName, obj.auctionTab.callbackShow, obj.auctionTab.callbackHide)
	end
	if obj ~= TSM and obj.operations then
		-- conversion code from early beta versions
		if obj.db and obj.db.global.operations then
			TSM.operations[moduleName] = CopyTable(obj.db.global.operations)
			obj.db.global.operations = nil
		end
		TSM:RegisterOperationInfo(moduleName, obj.operations)
		TSM.operations[moduleName] = TSM.operations[moduleName] or {}
		obj.operations = TSM.operations[moduleName]
		for _, operation in pairs(obj.operations) do
			operation.ignorePlayer = operation.ignorePlayer or {}
			operation.ignoreFactionrealm = operation.ignoreFactionrealm or {}
			operation.relationships = operation.relationships or {}
		end
		TSM:CheckOperationRelationships(moduleName)
	end
	-- register tooltip options
	if obj.tooltipOptions then
		TSM:RegisterTooltipInfo(moduleName, obj.tooltipOptions)
	end
	-- register bankUi Tabs
	if obj.bankUiButton then
		TSM:RegisterBankUiButton(moduleName, obj.bankUiButton.callback)
	end
	-- register sync callback
	if obj.sync then
		TSM:RegisterSyncCallback(moduleName, obj.sync.callback)
	end
	
	-- replace default Print and Printf functions
	local Print = obj.Print
	obj.Print = function(self, ...) Print(self, TSMAPI:GetChatFrame(), ...) end
	local Printf = obj.Printf
	obj.Printf = function(self, ...) Printf(self, TSMAPI:GetChatFrame(), ...) end
end

function TSM:UpdateModuleProfiles()
	-- set the TradeSkillMasterAppDB profile
	local profile = TSM.db:GetCurrentProfile()
	TradeSkillMasterAppDB.profiles[profile] = TradeSkillMasterAppDB.profiles[profile] or {}
	TSM.appDB.profile = TradeSkillMasterAppDB.profiles[profile]
	TSM.appDB.keys.profile = profile
	
	if TSM.db.global.globalOperations then
		for moduleName, obj in pairs(moduleObjects) do
			if obj.operations then
				TSM.db.global.operations[moduleName] = TSM.db.global.operations[moduleName] or {}
				obj.operations = TSM.db.global.operations[moduleName]
			end
		end
		TSM.operations = TSM.db.global.operations
	else
		for moduleName, obj in pairs(moduleObjects) do
			if obj.operations then
				TSM.db.profile.operations[moduleName] = TSM.db.profile.operations[moduleName] or {}
				obj.operations = TSM.db.profile.operations[moduleName]
			end
		end
		TSM.operations = TSM.db.profile.operations
	end
	for module, operations in pairs(TSM.operations) do
		for _, operation in pairs(operations) do
			operation.ignorePlayer = operation.ignorePlayer or {}
			operation.ignoreFactionrealm = operation.ignoreFactionrealm or {}
			operation.relationships = operation.relationships or {}
		end
		TSM:CheckOperationRelationships(module)
	end
	if not TSM.db.profile.design then
		TSM:LoadDefaultDesign()
	end
end

local didDBShutdown = false
function TSM:ModuleOnDatabaseShutdown()
	if didDBShutdown then return end
	didDBShutdown = true
	local originalProfile = TSM.db:GetCurrentProfile()
	for _, obj in pairs(moduleObjects) do
		-- erroring here would cause the profile to be reset, so use pcall
		if obj.OnTSMDBShutdown and not pcall(obj.OnTSMDBShutdown) then
			-- the callback hit an error, so ensure the correct profile is restored
			TSM.db:SetProfile(originalProfile)
		end
	end
	-- ensure we're back on the correct profile
	TSM.db:SetProfile(originalProfile)
	
	-- general cleanup of TradeSkillMasterAppDB
	for name, data in pairs(TradeSkillMasterAppDB.profiles) do
		if not next(data) then
			TradeSkillMasterAppDB.profiles[name] = nil
		end
	end
	for name, data in pairs(TradeSkillMasterAppDB.factionrealm) do
		if not next(data) then
			TradeSkillMasterAppDB.factionrealm[name] = nil
		end
	end
	
	TradeSkillMasterAppDB.version = max(TradeSkillMasterAppDB.version, 1)
	TradeSkillMasterAppDB = LibStub("LibParse"):JSONEncode(TradeSkillMasterAppDB)
end

function TSM:IsOperationIgnored(module, operationName)
	local obj = moduleObjects[module]
	local operation = obj.operations[operationName]
	if not operation then return end
	local factionrealm = TSM.db.keys.factionrealm
	local playerKey = UnitName("player").." - "..factionrealm
	return operation.ignorePlayer[playerKey] or operation.ignoreFactionrealm[factionrealm]
end

function TSM:CheckOperationRelationships(moduleName)
	for _, operation in pairs(TSM.operations[moduleName]) do
		for key, target in pairs(operation.relationships or {}) do
			if not TSM.operations[moduleName][target] then
				operation.relationships[key] = nil
			end
		end
	end
end


-- **************************************************************************
--                               Module APIs
-- **************************************************************************

function TSMAPI:ModuleAPI(moduleName, key, ...)
	if type(moduleName) ~= "string" or type(key) ~= "string" then return nil, "Invalid args" end
	if not moduleObjects[moduleName] then return nil, "Invalid module" end

	for _, info in ipairs(moduleObjects[moduleName].moduleAPIs or {}) do
		if info.key == key then
			return info.callback(...)
		end
	end
	return nil, "Key not found"
end


-- **************************************************************************
--                              Slash Commands
-- **************************************************************************

function Modules:ChatCommand(input)
	local parts = { (" "):split(input) }
	local cmd, args = strlower(parts[1] or ""), table.concat(parts, " ", 2)

	if cmd == "" then
		TSMAPI:OpenFrame()
		TSMAPI:SelectIcon("TradeSkillMaster", L["TSM Status / Options"])
	else
		local foundCmd
		for _, obj in pairs(moduleObjects) do
			if obj.slashCommands then
				for _, info in ipairs(obj.slashCommands) do
					if strlower(info.key) == cmd then
						info.callback(args)
						foundCmd = true
					end
				end
			end
		end
		-- If not a registered command, print out slash command help
		if not foundCmd then
			local chatFrame = TSMAPI:GetChatFrame()
			TSM:Print(L["Slash Commands:"])
			chatFrame:AddMessage("|cffffaa00" .. L["/tsm|r - opens the main TSM window."])
			chatFrame:AddMessage("|cffffaa00" .. L["/tsm help|r - Shows this help listing"])
			for _, name in ipairs(moduleNames) do
				for _, info in ipairs(moduleObjects[name].slashCommands or {}) do
					chatFrame:AddMessage("|cffffaa00/tsm " .. info.key .. "|r - " .. info.label)
				end
			end
		end
	end
end