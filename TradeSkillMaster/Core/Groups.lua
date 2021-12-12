-- ------------------------------------------------------------------------------ --
--                                TradeSkillMaster                                --
--                http://www.curse.com/addons/wow/tradeskill-master               --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

local TSM = select(2, ...)
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster") -- loads the localization table
local AceGUI = LibStub("AceGUI-3.0") -- load the AceGUI libraries
local lib = TSMAPI

TSM.GROUP_SEP = "`"

function TSMAPI:FormatGroupPath(path, useColor)
	if not path then return end
	if useColor then
		return TSMAPI.Design:GetInlineColor("link")..gsub(path, TSM.GROUP_SEP, "->").."|r"
	else
		return gsub(path, TSM.GROUP_SEP, "->")
	end
end

local GROUP_LEVEL_COLORS = {
	"FCF141",
	"BDAEC6",
	"06A2CB",
	"FFB85C",
	"51B599",
}
function TSMAPI:ColorGroupName(groupName, level)
	local color = GROUP_LEVEL_COLORS[(level-1) % #GROUP_LEVEL_COLORS + 1]
	return "|cFF"..color..groupName.."|r"
end

function TSMAPI:JoinGroupPath(...)
	return strjoin(TSM.GROUP_SEP, ...)
end


local private = {}
TSMAPI:RegisterForTracing(private, "TradeSkillMaster.Groups_private")
private.operationInfo = {}

function TSM:RegisterOperationInfo(module, info)
	info = CopyTable(info)
	info.module = module
	tinsert(private.operationInfo, info)
end

-- Splits the given group path into the parent path and group name
-- Parent will be nil if there is no parent
local function SplitGroupPath(path)
	local parts = {TSM.GROUP_SEP:split(path)}
	local parent = table.concat(parts, TSM.GROUP_SEP, 1, #parts-1)
	parent = parent ~= "" and parent or nil
	local groupName = parts[#parts]
	return parent, groupName
end

local function GetSubGroups(groupPath)
	local subGroups = {}
	local hasSubGroup
	for group in pairs(TSM.db.profile.groups) do
		local _, _, subGroupName = strfind(group, "^"..TSMAPI:StrEscape(groupPath)..TSM.GROUP_SEP.."([^`]+)$")
		if subGroupName then
			subGroups[group] = subGroupName
			hasSubGroup = true
		end
	end
	if hasSubGroup then
		return subGroups
	end
end

-- Creates a new group with the specified path
local SetOperationOverride
local function CreateGroup(groupPath)
	if TSM.db.profile.groups[groupPath] then return end
	TSM.db.profile.groups[groupPath] = {}
	for _, info in ipairs(private.operationInfo) do
		TSM.db.profile.groups[groupPath][info.module] = TSM.db.profile.groups[groupPath][info.module] or {}
		if SplitGroupPath(groupPath) then
			for _, info in ipairs(private.operationInfo) do
				SetOperationOverride(groupPath, info.module, nil)
			end
		end
	end
end

-- Deletes a group with the specified path and everything (items/subGroups) below it
local function DeleteGroup(groupPath)
	if not TSM.db.profile.groups[groupPath] then return end
	
	-- delete this group and all subgroups
	for path in pairs(TSM.db.profile.groups) do
		if path == groupPath or strfind(path, "^"..TSMAPI:StrEscape(groupPath)..TSM.GROUP_SEP) then
			TSM.db.profile.groups[path] = nil
		end
	end
	
	local parent = SplitGroupPath(groupPath)
	if parent and TSM.db.profile.keepInParent then
		-- move all items in this group its subgroups to the parent
		local changes = {}
		for itemString, path in pairs(TSM.db.profile.items) do
			if path == groupPath or strfind(path, "^"..TSMAPI:StrEscape(groupPath)..TSM.GROUP_SEP) then
				changes[itemString] = parent
			end
		end
		for itemString, newPath in pairs(changes) do
			TSM.db.profile.items[itemString] = newPath
		end
	else
		-- delete all items in this group or subgroup
		for itemString, path in pairs(TSM.db.profile.items) do
			if path == groupPath or strfind(path, "^"..TSMAPI:StrEscape(groupPath)..TSM.GROUP_SEP) then
				TSM.db.profile.items[itemString] = nil
			end
		end
	end
end

-- Moves (renames) a group at the given path to the newPath
local function MoveGroup(groupPath, newPath)
	if not TSM.db.profile.groups[groupPath] then return end
	if TSM.db.profile.groups[newPath] then return end
	
	-- change the path of all subgroups
	local changes = {}
	for path, groupData in pairs(TSM.db.profile.groups) do
		if path == groupPath or strfind(path, "^"..TSMAPI:StrEscape(groupPath)..TSM.GROUP_SEP) then
			changes[path] = gsub(path, "^"..TSMAPI:StrEscape(groupPath), TSMAPI:StrEscape(newPath))
		end
	end
	for oldPath, newPath in pairs(changes) do
		TSM.db.profile.groups[newPath] = TSM.db.profile.groups[oldPath]
		TSM.db.profile.groups[oldPath] = nil
	end
	
	-- change the path for all items in this group (and subgroups)
	changes = {}
	for itemString, path in pairs(TSM.db.profile.items) do
		if path == groupPath or strfind(path, "^"..TSMAPI:StrEscape(groupPath)..TSM.GROUP_SEP) then
			changes[itemString] = gsub(path, "^"..TSMAPI:StrEscape(groupPath), newPath)
		end
	end
	for itemString, newPath in pairs(changes) do
		TSM.db.profile.items[itemString] = newPath
	end
end

-- Adds an item to the group at the specified path.
local function AddItem(itemString, path)
	if not (strfind(path, TSM.GROUP_SEP) or not TSM.db.profile.items[itemString]) then return end
	if not TSM.db.profile.groups[path] then return end
	
	TSM.db.profile.items[itemString] = path
end

-- Deletes an item from the group at the specified path.
local function DeleteItem(itemString)
	if not TSM.db.profile.items[itemString] then return end
	TSM.db.profile.items[itemString] = nil
end

-- Moves an item from an existing group to the group at the specified path.
local function MoveItem(itemString, path)
	if not TSM.db.profile.items[itemString] then return end
	if not TSM.db.profile.groups[path] then return end
	TSM.db.profile.items[itemString] = path
end

local function SetOperationHelper(path, module, origPath)
	if TSM.db.profile.groups[path][module] and TSM.db.profile.groups[path][module].override then return end
	TSM.db.profile.groups[path][module] = CopyTable(TSM.db.profile.groups[origPath][module])
	TSM.db.profile.groups[path][module].override = nil
	local subGroups = GetSubGroups(path)
	if subGroups then
		for subGroupPath in pairs(subGroups) do
			SetOperationHelper(subGroupPath, module, origPath)
		end
	end
end
local function SetOperation(path, module, operation, index)
	if not TSM.db.profile.groups[path] then return end
	if not TSM.db.profile.groups[path][module] then return end
	
	TSM.db.profile.groups[path][module][index] = operation
	local subGroups = GetSubGroups(path)
	if subGroups then
		for subGroupPath in pairs(subGroups) do
			SetOperationHelper(subGroupPath, module, path)
		end
	end
end

local function AddOperation(path, module)
	if not TSM.db.profile.groups[path] then return end
	
	tinsert(TSM.db.profile.groups[path][module], "")
	local subGroups = GetSubGroups(path)
	if subGroups then
		for subGroupPath in pairs(subGroups) do
			SetOperationHelper(subGroupPath, module, path)
		end
	end
end

local function DeleteOperation(path, module, index)
	if not TSM.db.profile.groups[path] then return end
	local numOperations = #TSM.db.profile.groups[path][module]
	for i=index+1, numOperations do
		SetOperation(path, module, TSM.db.profile.groups[path][module][i], i-1)
	end
	SetOperation(path, module, nil, numOperations)
end

function SetOperationOverride(path, module, override)
	if not TSM.db.profile.groups[path] then return end
	
	-- clear all operations for this path/module
	TSM.db.profile.groups[path][module] = {override=(override or nil)}
	-- set this group's (and all applicable subgroups') operation to the parent's
	local parentPath = SplitGroupPath(path)
	if not parentPath then return end
	TSM.db.profile.groups[parentPath][module] = TSM.db.profile.groups[parentPath][module] or {override=(override or nil)}
	for index, operation in ipairs(TSM.db.profile.groups[parentPath][module]) do
		SetOperation(path, module, operation, index)
	end
end


function TSM:GetGroupItems(path)
	local items = {}
	for itemString, groupPath in pairs(TSM.db.profile.items) do
		if groupPath == path then
			items[itemString] = true
		end
	end
	return items
end

function TSM:GetGroupPathList(module)
	local list, disabled = {}, {}
	for groupPath in pairs(TSM.db.profile.groups) do
		if module then
			local operations = TSM:GetGroupOperations(groupPath, module)
			if not operations then
				disabled[groupPath] = true
			end
		end
		tinsert(list, groupPath)
	end
	
	for groupPath in pairs(TSM.db.profile.groups) do
		if not disabled[groupPath] then
			local pathParts = {TSM.GROUP_SEP:split(groupPath)}
			for i=1, #pathParts-1 do
				local path = table.concat(pathParts, TSM.GROUP_SEP, 1, i)
				disabled[path] = nil
			end
		end
	end
	
	sort(list, function(a,b) return strlower(gsub(a, TSM.GROUP_SEP, "\001")) < strlower(gsub(b, TSM.GROUP_SEP, "\001")) end)
	return list, disabled
end

function TSM:GetGroupOperations(path, module)
	if not TSM.db.profile.groups[path] then return end
	
	if module and TSM.db.profile.groups[path][module] then
		local operations = CopyTable(TSM.db.profile.groups[path][module])
		for i=#operations, 1, -1 do
			if operations[i] == "" or TSM:IsOperationIgnored(module, operations[i]) then
				tremove(operations, i)
			end
		end
		if #operations > 0 then
			return operations
		end
	end
end

-- Takes a list of itemString/groupPath k,v pairs and adds them to new groups.
function TSMAPI:CreatePresetGroups(itemList, moduleName, operationInfo)
	for itemString, groupPath in pairs(itemList) do
		if not TSM.db.profile.items[itemString] and not TSMAPI:IsSoulbound(itemString) then
			local pathParts = {TSM.GROUP_SEP:split(groupPath)}
			for i=1, #pathParts do
				local path = table.concat(pathParts, TSM.GROUP_SEP, 1, i)
				if not TSM.db.profile.groups[path] then
					CreateGroup(path)
				end
			end
			AddItem(itemString, groupPath)
			if moduleName and operationInfo and operationInfo[groupPath] then
				if strfind(groupPath, TSM.GROUP_SEP) then
					SetOperationOverride(groupPath, moduleName, true)
				end
				SetOperation(groupPath, moduleName, operationInfo[groupPath], 1)
			end
		end
	end
	
	private:UpdateTree()
end

function TSMAPI:GetItemOperation(itemString, module)
	local groupPath = TSM.db.profile.items[itemString]
	if not groupPath then return end
	local operations = TSM:GetGroupOperations(groupPath, module)
	if not operations then return end
	local result = CopyTable(operations)
	result.override = nil
	return result
end

function TSMAPI:GetGroupPath(itemString)
	return TSM.db.profile.items[itemString]
end

-- gets all items which have an operation for the given module assigned to their groups
function TSMAPI:GetModuleItems(module)
	if not module then return end
	local result = {}
	for itemString in pairs(TSM.db.profile.items) do
		result[itemString] = TSMAPI:GetItemOperation(itemString, module)
	end
	return result
end


local function ShowExportFrame(text)
	local f = AceGUI:Create("TSMWindow")
	f:SetCallback("OnClose", function(self) AceGUI:Release(self) end)
	f:SetTitle("TradeSkillMaster - "..L["Export Group Items"])
	f:SetLayout("Fill")
	f:SetHeight(300)
	
	local eb = AceGUI:Create("TSMMultiLineEditBox")
	eb:SetLabel(L["Group Item Data"])
	eb:SetMaxLetters(0)
	eb:SetText(text)
	f:AddChild(eb)
	
	f.frame:SetFrameStrata("FULLSCREEN_DIALOG")
	f.frame:SetFrameLevel(100)
end

local function ModuleOptionsRefresh(TSMObj, ...)
	TSMObj.Options:UpdateTree()
	TSMObj.Options.treeGroup:SelectByPath(#TSMObj.Options.treeGroup.tree, ...)
	if select('#', ...) > 0 then
		TSMObj.Options.treeGroup.children[1]:SelectTab(#TSMObj.Options.treeGroup.children[1].tablist)
	end
end

function TSMAPI:DrawOperationManagement(TSMObj, container, operationName)
	local moduleName = gsub(TSMObj.name, "TSM_", "")
	local operation = TSMObj.operations[operationName]

	local playerList = {}
	local factionrealmKey = TSM.db.keys.factionrealm
	for playerName in pairs(TSM.db.factionrealm.characters) do
		playerList[playerName.." - "..factionrealmKey] = playerName
	end
	
	local factionrealmList = {}
	for factionrealm in pairs(TSM.db.sv.factionrealm) do
		factionrealmList[factionrealm] = factionrealm
	end
	
	local groupList = {}
	for path, modules in pairs(TSM.db.profile.groups) do
		if modules[moduleName] then
			for i=1, #modules[moduleName] do
				if modules[moduleName][i] == operationName then
					tinsert(groupList, path)
				end
			end
		end
	end
	sort(groupList, function(a,b) return strlower(gsub(a, TSM.GROUP_SEP, "\001")) < strlower(gsub(b, TSM.GROUP_SEP, "\001")) end)
	
	local groupWidgets = {
		{
			type = "Label",
			relativeWidth = 1,
			text = L["Below is a list of groups which this operation is currently applied to. Clicking on the 'Remove' button next to the group name will remove the operation from that group."],
		},
		{
			type = "HeadingLine",
		},
	}
	for _, groupPath in ipairs(groupList) do
		tinsert(groupWidgets, {
				type = "Button",
				relativeWidth = 0.2,
				text = L["Remove"],
				callback = function()
					for i=#TSM.db.profile.groups[groupPath][moduleName], 1, -1 do
						if TSM.db.profile.groups[groupPath][moduleName][i] == operationName then
							DeleteOperation(groupPath, moduleName, i)
						end
					end
					TSM:CheckOperationRelationships(moduleName)
					ModuleOptionsRefresh(TSMObj, operationName)
				end,
				tooltip = L["Click this button to completely remove this operation from the specified group."],
			})
		tinsert(groupWidgets, {
				type = "Label",
				relativeWidth = 0.05,
				text = "",
			})
		tinsert(groupWidgets, {
				type = "Label",
				relativeWidth = 0.75,
				text = TSMAPI:FormatGroupPath(groupPath, true),
			})
	end
	
	local page = {
		{
			type = "ScrollFrame",
			layout = "Flow",
			children = {
				{
					type = "InlineGroup",
					layout = "flow",
					title = L["Operation Management"],
					children = {
						{
							type = "Dropdown",
							label = L["Ignore Operation on Faction-Realms:"],
							list = factionrealmList,
							relativeWidth = 0.5,
							settingInfo = {operation, "ignoreFactionrealm"},
							multiselect = true,
							tooltip = L["This operation will be ignored when you're on any character which is checked in this dropdown."],
						},
						{
							type = "Dropdown",
							label = L["Ignore Operation on Characters:"],
							list = playerList,
							relativeWidth = 0.5,
							settingInfo = {operation, "ignorePlayer"},
							multiselect = true,
							tooltip = L["This operation will be ignored when you're on any character which is checked in this dropdown."],
						},
						{
							type = "HeadingLine"
						},
						{
							type = "EditBox",
							label = L["Rename Operation"],
							value = operationName,
							relativeWidth = 0.5,
							callback = function(self,_,name)
								name = (name or ""):trim()
								if name == "" then return end
								if TSMObj.operations[name] then
									self:SetText("")
									return TSMObj:Printf(L["Error renaming operation. Operation with name '%s' already exists."], name)
								end
								TSMObj.operations[name] = TSMObj.operations[operationName]
								TSMObj.operations[operationName] = nil
								for _, groupPath in ipairs(groupList) do
									for i=1, #TSM.db.profile.groups[groupPath][moduleName] do
										if TSM.db.profile.groups[groupPath][moduleName][i] == operationName then
											TSM.db.profile.groups[groupPath][moduleName][i] = name
										end
									end
								end
								TSM:CheckOperationRelationships(moduleName)
								ModuleOptionsRefresh(TSMObj, name)
							end,
							tooltip = L["Give this operation a new name. A descriptive name will help you find this operation later."],
						},
						{
							type = "EditBox",
							label = L["Duplicate Operation"],
							relativeWidth = 0.5,
							callback = function(self,_,name)
								name = (name or ""):trim()
								if name == "" then return end
								if TSMObj.operations[name] then
									self:SetText("")
									return TSMObj:Printf(L["Error duplicating operation. Operation with name '%s' already exists."], name)
								end
								TSMObj.operations[name] = CopyTable(TSMObj.operations[operationName])
								TSM:CheckOperationRelationships(moduleName)
								ModuleOptionsRefresh(TSMObj, name)
							end,
							tooltip = L["Type in the name of a new operation you wish to create with the same settings as this operation."],
						},
						{
							type = "HeadingLine"
						},
						{
							type = "GroupBox",
							label = L["Apply Operation to Group"],
							relativeWidth = .5,
							callback = function(self, _, path)
								TSM.db.profile.groups[path][moduleName] = TSM.db.profile.groups[path][moduleName] or {}
								local operations = TSM.db.profile.groups[path][moduleName]
								local num = #operations
								if num == 0 then
									SetOperationOverride(path, moduleName, true)
									AddOperation(path, moduleName)
									SetOperation(path, moduleName, operationName, 1)
									TSM:Printf(L["Applied %s to %s."], TSMAPI.Design:GetInlineColor("link")..operationName.."|r", TSMAPI:FormatGroupPath(path, true))
								elseif operations[num] == "" then
									SetOperationOverride(path, moduleName, true)
									SetOperation(path, moduleName, operationName, num)
									TSM:Printf(L["Applied %s to %s."], TSMAPI.Design:GetInlineColor("link")..operationName.."|r", TSMAPI:FormatGroupPath(path, true))
								else
									local canAdd
									for _, info in ipairs(private.operationInfo) do
										if moduleName == info.module then
											canAdd = num < info.maxOperations
											break
										end
									end
									if canAdd then
										StaticPopupDialogs["TSM_APPLY_OPERATION_ADD"] = StaticPopupDialogs["TSM_APPLY_OPERATION_ADD"] or {
											text = L["This group already has operations. Would you like to add another one or replace the last one?"],
											button1 = ADD,
											button2 = L["Replace"],
											button3 = CANCEL,
											timeout = 0,
											OnAccept = function()
												-- the "add" button
												local path, moduleName, operationName, num = unpack(StaticPopupDialogs["TSM_APPLY_OPERATION_ADD"].tsmInfo)
												SetOperationOverride(path, moduleName, true)
												AddOperation(path, moduleName)
												SetOperation(path, moduleName, operationName, num+1)
												TSM:Printf(L["Applied %s to %s."], TSMAPI.Design:GetInlineColor("link")..operationName.."|r", TSMAPI:FormatGroupPath(path, true))
											end,
											OnCancel = function()
												-- the "replace" button
												local path, moduleName, operationName, num = unpack(StaticPopupDialogs["TSM_APPLY_OPERATION_ADD"].tsmInfo)
												SetOperationOverride(path, moduleName, true)
												SetOperation(path, moduleName, operationName, num)
												TSM:Printf(L["Applied %s to %s."], TSMAPI.Design:GetInlineColor("link")..operationName.."|r", TSMAPI:FormatGroupPath(path, true))
											end,
											preferredIndex = 3,
										}
										StaticPopupDialogs["TSM_APPLY_OPERATION_ADD"].tsmInfo = {path, moduleName, operationName, num}
										TSMAPI:ShowStaticPopupDialog("TSM_APPLY_OPERATION_ADD")
									else
										StaticPopupDialogs["TSM_APPLY_OPERATION"] = StaticPopupDialogs["TSM_APPLY_OPERATION"] or {
											text = L["This group already has the max number of operation. Would you like to replace the last one?"],
											button1 = L["Replace"],
											button2 = CANCEL,
											timeout = 0,
											OnAccept = function()
												-- the "replace" button
												local path, moduleName, operationName, num = unpack(StaticPopupDialogs["TSM_APPLY_OPERATION"].tsmInfo)
												SetOperation(path, moduleName, operationName, num)
												TSM:Printf(L["Applied %s to %s."], TSMAPI.Design:GetInlineColor("link")..operationName.."|r", TSMAPI:FormatGroupPath(path, true))
											end,
											preferredIndex = 3,
										}
										StaticPopupDialogs["TSM_APPLY_OPERATION"].tsmInfo = {path, moduleName, operationName, num}
										TSMAPI:ShowStaticPopupDialog("TSM_APPLY_OPERATION")
									end
								end
								self:SetText()
								ModuleOptionsRefresh(TSMObj, operationName)
							end,
						},
						{
							type = "Button",
							text = L["Delete Operation"],
							relativeWidth = 0.5,
							callback = function()
								TSMObj.operations[operationName] = nil
								for _, groupPath in ipairs(groupList) do
									for i=#TSM.db.profile.groups[groupPath][moduleName], 1, -1 do
										if TSM.db.profile.groups[groupPath][moduleName][i] == operationName then
											DeleteOperation(groupPath, moduleName, i)
										end
									end
								end
								TSM:CheckOperationRelationships(moduleName)
								ModuleOptionsRefresh(TSMObj)
							end,
						},
						{
							type = "HeadingLine"
						},
						{
							type = "EditBox",
							label = L["Import Operation Settings"],
							relativeWidth = 1,
							callback = function(self, _, value)
								value = value:trim()
								if value == "" then return end
								local valid, data = LibStub("AceSerializer-3.0"):Deserialize(value)
								if not valid then
									TSM:Print(L["Invalid import string."])
									self:SetFocus()
									return
								elseif data.module ~= moduleName then
									TSM:Print(L["Invalid import string."].." "..L["You appear to be attempting to import an operation from a different module."])
									self:SetText("")
									return
								end
								data.module = nil
								data.ignorePlayer = {}
								data.ignoreFactionrealm = {}
								data.relationships = {}
								TSMObj.operations[operationName] = data
								self:SetText("")
								TSM:Print(L["Successfully imported operation settings."])
								ModuleOptionsRefresh(TSMObj, operationName)
							end,
							tooltip = L["Paste the exported operation settings into this box and hit enter or press the 'Okay' button. Imported settings will irreversibly replace existing settings for this operation."],
						},
						{
							type = "Button",
							text = L["Export Operation"],
							relativeWidth = 1,
							callback = function()
								local data = CopyTable(operation)
								data.module = moduleName
								data.ignorePlayer = nil
								data.ignoreFactionrealm = nil
								data.relationships = nil
								ShowExportFrame(LibStub("AceSerializer-3.0"):Serialize(data))
							end,
						},
					},
				},
				{
					type = "InlineGroup",
					layout = "flow",
					title = L["Groups"],
					children = groupWidgets,
				},
			},
		},
	}
	
	TSMAPI:BuildPage(container, page)
end

function TSMAPI:NewOperationCallback(moduleName, group, operationName)
	if not group then return end
	StaticPopupDialogs["TSM_NEW_OPERATION_ADD"] = StaticPopupDialogs["TSM_NEW_OPERATION_ADD"] or {
		button1 = YES,
		button2 = NO,
		timeout = 0,
		OnAccept = function()
			-- the "add" button
			local group, moduleName, operationName = unpack(StaticPopupDialogs["TSM_NEW_OPERATION_ADD"].tsmInfo)
			SetOperation(group, moduleName, operationName, #TSM.db.profile.groups[group][moduleName])
			TSM:Printf(L["Applied %s to %s."], TSMAPI.Design:GetInlineColor("link")..operationName.."|r", TSMAPI:FormatGroupPath(group, true))
		end,
		preferredIndex = 3,
	}
	StaticPopupDialogs["TSM_NEW_OPERATION_ADD"].text = format(L["Would you like to add this new operation to %s?"], TSMAPI:FormatGroupPath(group, true))
	StaticPopupDialogs["TSM_NEW_OPERATION_ADD"].tsmInfo = {group, moduleName, operationName}
	TSMAPI:ShowStaticPopupDialog("TSM_NEW_OPERATION_ADD")
end

function TSMAPI:UpdateOperation(moduleName, operationName)
	if not TSM.operations[moduleName][operationName] then return end
	for key in pairs(TSM.operations[moduleName][operationName].relationships) do
		local operation = TSM.operations[moduleName][operationName]
		while operation.relationships[key] do
			local newOperation = TSM.operations[moduleName][operation.relationships[key]]
			if not newOperation then break end
			operation = newOperation
		end
		TSM.operations[moduleName][operationName][key] = operation[key]
	end
end

local function IsCircularRelationship(moduleName, operation, key, visited)
	visited = visited or {}
	if visited[operation] then return true end
	visited[operation] = true
	if not operation.relationships[key] then return end
	return IsCircularRelationship(moduleName, TSM.operations[moduleName][operation.relationships[key]], key, visited)
end

function TSMAPI:ShowOperationRelationshipTab(obj, container, operation, settingInfo)
	local moduleName = gsub(obj.name, "TradeSkillMaster_", "")
	moduleName = gsub(obj.name, "TSM_", "")
	local operationList = {[""]=L["<No Relationship>"]}
	local operationListOrder = {""}
	local incomingRelationships = {}
	for name, data in pairs(obj.operations) do
		if data ~= operation then
			operationList[name] = name
			tinsert(operationListOrder, name)
		end
		for key, targetOperation in pairs(data.relationships) do
			if obj.operations[targetOperation] == operation then
				incomingRelationships[key] = name
			end
		end
	end
	sort(operationListOrder)
	
	local target = ""
	local children = {
		{
			type = "InlineGroup",
			layout = "Flow",
			children = {
				{
					type = "Label",
					text = L["Here you can setup relationships between the settings of this operation and other operations for this module. For example, if you have a relationship set to OperationA for the stack size setting below, this operation's stack size setting will always be equal to OperationA's stack size setting."],
					relativeWidth = 1,
				},
				{
					type = "HeadingLine",
				},
				{
					type = "Dropdown",
					label = L["Target Operation"],
					list = operationList,
					order = operationListOrder,
					relativeWidth = 0.5,
					value = target,
					callback = function(self, _, value)
						target = value
					end,
					tooltip = L["Creating a relationship for this setting will cause the setting for this operation to be equal to the equivalent setting of another operation."],
				},
				{
					type = "Button",
					text = L["Set All Relationships to Target"],
					relativeWidth = 0.49,
					callback = function()
						for _, inline in ipairs(settingInfo) do
							for _, widget in ipairs(inline) do
								local prev = operation.relationships[widget.key]
								if target == "" then
									operation.relationships[widget.key] = nil
								else
									operation.relationships[widget.key] = target
									if IsCircularRelationship(moduleName, operation, widget.key) then
										operation.relationships[widget.key] = prev
									end
								end
							end
						end
						container:ReloadTab()
					end,
					tooltip = L["Sets all relationship dropdowns below to the operation selected."],
				},
			},
		},
	}
	for _, inlineData in ipairs(settingInfo) do
		local inlineChildren = {}
		for _, dropdownData in ipairs(inlineData) do
			local dropdown = {
				type = "Dropdown",
				label = dropdownData.label,
				list = operationList,
				order = operationListOrder,
				relativeWidth = 0.5,
				value = operation.relationships[dropdownData.key] or "",
				callback = function(self, _, value)
					local previousValue = operation.relationships[dropdownData.key]
					if value == "" then
						operation.relationships[dropdownData.key] = nil
					else
						operation.relationships[dropdownData.key] = value
					end
					if IsCircularRelationship(moduleName, operation, dropdownData.key) then
						operation.relationships[dropdownData.key] = previousValue
						obj:Print("This relationship cannot be applied because doing so would create a circular relationship.")
						self:SetValue(operation.relationships[dropdownData.key] or "")
					end
				end,
				tooltip = L["Creating a relationship for this setting will cause the setting for this operation to be equal to the equivalent setting of another operation."],
			}
			tinsert(inlineChildren, dropdown)
		end
		local inlineGroup = {
			type = "InlineGroup",
			layout = "flow",
			title = inlineData.label,
			children = inlineChildren,
		}
		tinsert(children, inlineGroup)
	end
	
	
	local page = {
		{
			type = "ScrollFrame",
			layout = "list",
			children = children,
		},
	}
	
	TSMAPI:BuildPage(container, page)
end



-- operation options

function TSM:LoadOperationOptions(parent)
	local tabs = {}
	local next = next

	for _, info in ipairs(private.operationInfo) do
		tinsert(tabs, {text=info.module, value=info.module})
	end

	if next(tabs) then
		sort(tabs, function(a, b)
			return a.text < b.text
		end)
	end

	tinsert(tabs, 1, {text=L["Help"], value="Help"})

	local tabGroup =  AceGUI:Create("TSMTabGroup")
	tabGroup:SetLayout("Fill")
	tabGroup:SetTabs(tabs)
	tabGroup:SetCallback("OnGroupSelected", function(_, _, value)
			tabGroup:ReleaseChildren()
			if value == "Help" then
				private:DrawOperationHelp(tabGroup)
			else
				for _, info in ipairs(private.operationInfo) do
					if info.module == value then
						info.callbackOptions(tabGroup, TSM.loadModuleOptionsTab and TSM.loadModuleOptionsTab.operation, TSM.loadModuleOptionsTab and TSM.loadModuleOptionsTab.group)
					end
				end
			end
		end)
	parent:AddChild(tabGroup)
	
	tabGroup:SelectTab(TSM.loadModuleOptionsTab and TSM.loadModuleOptionsTab.module or "Help")
end

function private:DrawOperationHelp(container)
	local page = {
		{	-- scroll frame to contain everything
			type = "ScrollFrame",
			layout = "List",
			children = {
				{
					type = "InlineGroup",
					layout = "List",
					children = {
						{
							type = "Label",
							relativeWidth = 1,
							text = L["Use the tabs above to select the module for which you'd like to configure operations and general options."],
						},
					},
				},
			},
		},
	}
	
	TSMAPI:BuildPage(container, page)
end



-- group options

local treeGroup
function TSM:LoadGroupOptions(parent)
	treeGroup = AceGUI:Create("TSMTreeGroup")
	treeGroup:SetLayout("Fill")
	treeGroup:SetCallback("OnGroupSelected", function(...) private:SelectTree(...) end)
	treeGroup:SetStatusTable(TSM.db.profile.groupTreeStatus)
	parent:AddChild(treeGroup)
	
	private:UpdateTree()
	treeGroup:SelectByPath(1)
end

local function UpdateTreeHelper(currentPath, groupPathList, index, treeGroupChildren, level)
	for i=index, #groupPathList do
		local groupPath = groupPathList[i]
		-- make sure this group is under the current parent we're interested in
		local parent, groupName = SplitGroupPath(groupPath)
		if parent == currentPath then
			if TSM.db.profile.colorGroupName then
				groupName = TSMAPI:ColorGroupName(groupName, level)
			end
			local row = {value=groupPath, text=groupName}
			if groupPathList[i+1] and (groupPath == groupPathList[i+1] or strfind(groupPathList[i+1], "^"..TSMAPI:StrEscape(groupPath)..TSM.GROUP_SEP)) then
				row.children = {}
				UpdateTreeHelper(groupPath, groupPathList, i+1, row.children, level+1)
			end
			tinsert(treeGroupChildren, row)
		end
	end
	sort(treeGroupChildren, function(a, b) return strlower(a.text) < strlower(b.text) end)
end
function private:UpdateTree()
	if not treeGroup then return end
	
	local groupChildren = {}
	local groupPathList = TSM:GetGroupPathList()
	UpdateTreeHelper(nil, groupPathList, 1, groupChildren, 1)
	local treeGroups = {{value=1, text=L["Groups"], children=groupChildren}}
	treeGroup:SetTree(treeGroups)
end

function private:SelectGroup(name)
	if not treeGroup then return end
	local tmp = {1}
	local groupPathParts = {TSM.GROUP_SEP:split(name)}
	for i=1, #groupPathParts do
		tinsert(tmp, table.concat(groupPathParts, TSM.GROUP_SEP, 1, i))
	end
	treeGroup:SelectByPath(unpack(tmp))
end

local scrollFrameStatus = {}
function private:SelectTree(treeGroup, _, selection)
	treeGroup:ReleaseChildren()
	
	selection = {("\001"):split(selection)}
	if #selection == 1 then
		private:DrawNewGroup(treeGroup)
	else
		local group = selection[#selection]
		local tabGroup =  AceGUI:Create("TSMTabGroup")
		tabGroup:SetLayout("Fill")
		tabGroup:SetTabs({{text=L["Operations"], value=1}, {text=L["Items"], value=2}, {text=L["Import/Export"], value=3}, {text=L["Management"], value=4}})
		tabGroup:SetCallback("OnGroupSelected", function(self, _, value)
				tabGroup:ReleaseChildren()
				if value == 1 then
					-- load operations page
					private:DrawGroupOperationsPage(self, group)
					self.children[1]:SetStatusTable(scrollFrameStatus)
				elseif value == 2 then
					-- load items page
					private:DrawGroupItemsPage(self, group)
				elseif value == 3 then
					-- load import/export page
					private:DrawGroupImportExportPage(self, group)
				elseif value == 4 then
					-- load management page
					private:DrawGroupManagementPage(self, group)
				end
			end)
		tabGroup:SetCallback("OnRelease", function() scrollFrameStatus = {} end)
		treeGroup:AddChild(tabGroup)
		tabGroup:SelectTab(TSM.db.profile.defaultGroupTab)
	end
end

function private:DrawNewGroup(container)
	local page = {
		{	-- scroll frame to contain everything
			type = "ScrollFrame",
			layout = "List",
			children = {
				{
					type = "InlineGroup",
					layout = "flow",
					title = L["New Group"],
					children = {
						{
							type = "Label",
							relativeWidth = 1,
							text = L["A group is a collection of items which will be treated in a similar way by TSM's modules."],
						},
						{
							type = "HeadingLine",
						},
						{
							type = "EditBox",
							label = L["Group Name"],
							relativeWidth = 0.8,
							callback = function(self,_,value)
									value = (value or ""):trim()
									if value == "" then return end
									if strfind(value, TSM.GROUP_SEP) then
										return TSM:Printf(L["Group names cannot contain %s characters."], TSM.GROUP_SEP)
									end
									if TSM.db.profile.groups[value] then
										return TSM:Printf(L["Error creating group. Group with name '%s' already exists."], value)
									end
									CreateGroup(value)
									private:UpdateTree()
									if TSM.db.profile.gotoNewGroup then
										private:SelectGroup(value)
									else
										self:SetText()
										self:SetFocus()
									end
									TSMAPI:FireEvent("TSM:GROUPS:NEWGROUP", value)
								end,
							tooltip = L["Give the new group a name. A descriptive name will help you find this group later."],
						},
						{
							type = "CheckBox",
							label = L["Switch to New Group After Creation"],
							relativeWidth = 1,
							settingInfo = {TSM.db.profile, "gotoNewGroup"},
						},
					},
				},
				{
					type = "Spacer"
				},
				{
					type = "InlineGroup",
					layout = "flow",
					title = L["Settings"],
					children = {
						{
							type = "Dropdown",
							label = L["Default Group Tab"],
							list = {L["Operations"], L["Items"], L["Import/Export"], L["Management"]},
							settingInfo = {TSM.db.profile, "defaultGroupTab"},
							tooltip = L["This dropdown determines the default tab when you visit a group."],
						},
						{
							type = "CheckBox",
							label = L["Show Ungrouped Items for Adding to Subgroups"],
							relativeWidth = 1,
							settingInfo = {TSM.db.profile, "directSubgroupAdd"},
							tooltip = L["If checked, ungrouped items will be displayed in the left list of selection lists used to add items to subgroups. This allows you to add an ungrouped item directly to a subgroup rather than having to add to the parent group(s) first."],
						},
					},
				},
			},
		},
	}
	
	TSMAPI:BuildPage(container, page)
end

function private:DrawGroupOperationsPage(container, groupPath)
	local isSubGroup = strfind(groupPath, TSM.GROUP_SEP)
	local moduleInlines = {}
	local addRef, deleteRef = {}, {}
	for _, info in ipairs(private.operationInfo) do
		local moduleName = info.module
		local ddList = {}
		ddList[""] = L["<No Operation>"]
		for name in pairs(TSM.operations[moduleName] or {}) do
			ddList[name] = name
		end
		
		TSM.db.profile.groups[groupPath][moduleName] = TSM.db.profile.groups[groupPath][moduleName] or {}
		local operations = TSM.db.profile.groups[groupPath][moduleName]
		for i=#operations, 1, -1 do
			if not ddList[operations[i]] then
				DeleteOperation(groupPath, moduleName, i)
			end
		end
		operations[1] = operations[1] or ""
		if #operations > 1 then
			ddList[TSM.GROUP_SEP] = L["<Remove Operation>"]
		end

		local moduleInline = {
			type = "InlineGroup",
			layout = "Flow",
			title = moduleName,
			children = {},
		}
		
		local addOperationWidget
		if #operations < info.maxOperations then
			addOperationWidget = {
				type = "Button",
				text = L["Add Additional Operation"],
				relativeWidth = 1,
				disabled = isSubGroup and not operations.override,
				callback = function()
						AddOperation(groupPath, moduleName)
						container:ReloadTab()
					end,
			}
		else
			addOperationWidget = {type="Label", relativeWidth=1}
		end
		if isSubGroup then
			tinsert(moduleInline.children, {
					type = "CheckBox",
					label = L["Override Module Operations"],
					value = operations.override,
					relativeWidth = 1,
					callback = function(_,_,value)
							SetOperationOverride(groupPath, moduleName, value)
							container:ReloadTab()
						end,
					tooltip = L["Check this box to override this group's operation(s) for this module."],
				})
		else
			tinsert(moduleInline.children, {type="Label", relativeWidth=1})
		end
		
		for i=1, #operations do
			tinsert(moduleInline.children, {
					type = "Dropdown",
					label = format(L["Operation #%d"], i),
					list = ddList,
					value = operations[i],
					relativeWidth = 0.6,
					disabled = isSubGroup and not operations.override,
					callback = function(_,_,value)
						if value == "" then
							SetOperation(groupPath, moduleName, nil, i)
						elseif value == TSM.GROUP_SEP then
							DeleteOperation(groupPath, moduleName, i)
						else
							SetOperation(groupPath, moduleName, value, i)
						end
						container:ReloadTab()
					end,
					tooltip = L["Select an operation to apply to this group."],
				})
			if operations[i] ~= "" then
				tinsert(moduleInline.children, {
						type = "Button",
						text = L["View Operation Options"],
						relativeWidth = 0.39,
						callback = function()
							TSMAPI:ShowOperationOptions(moduleName, operations[i])
						end,
						tooltip = L["Click this button to configure the currently selected operation."],
					})
			elseif not isSubGroup or operations.override then
				tinsert(moduleInline.children, {
						type = "Button",
						text = format(L["Create %s Operation"], moduleName),
						relativeWidth = 0.39,
						callback = function()
							TSMAPI:ShowOperationOptions(moduleName, "", groupPath)
						end,
						tooltip = L["Click this button to create a new operation for this module."],
					})
			end
		end
		tinsert(moduleInline.children, addOperationWidget)
		
		local opStrs = {}
		for _, name in ipairs(operations) do
			if name ~= "" then
				local str = info.callbackInfo(name) or "---"
				tinsert(opStrs, TSMAPI.Design:GetInlineColor("link")..name.."|r: "..str)
			end
		end
		tinsert(moduleInline.children, {type="HeadingLine"})
		tinsert(moduleInline.children, {
				type = "Label",
				text = #opStrs > 0 and table.concat(opStrs, "\n") or format(L["Select a %s operation using the dropdown above."], moduleName),
				relativeWidth = 1,
			})
		
		tinsert(moduleInlines, moduleInline)
	end
	
	sort(moduleInlines, function(a, b) return a.title < b.title end)
	
	local children = {}
	for i, inline in ipairs(moduleInlines) do
		tinsert(children, inline)
		if i ~= #moduleInlines then
			tinsert(children, {type="Spacer"})
		end
	end
	
	local page = {
		{
			type = "ScrollFrame",
			layout = "List",
			children = children,
		},
	}
	
	TSMAPI:BuildPage(container, page)
end

local alreadyLoaded = {}
function private:DrawGroupItemsPage(container, groupPath)
	if not alreadyLoaded[groupPath] then
		alreadyLoaded[groupPath] = true
		TSMAPI:CreateTimeDelay("itemsTabLoad", 0.1, function() container:ReloadTab() end)
	end
	
	local parentPath, groupName = SplitGroupPath(groupPath)
	local function GetItemList(side)
		local list = {}
		if side == "left" then
			if parentPath then
				-- this is a subgroup so add all items from parent group
				for itemString, path in pairs(TSM.db.profile.items) do
					if path == parentPath then
						local link = select(2, TSMAPI:GetSafeItemInfo(itemString))
						if link then
							tinsert(list, link)
						end
					end
				end
			end
			if not parentPath or TSM.db.profile.directSubgroupAdd then
				-- add all items in bags
				local usedLinks = {}
				for bag, slot, itemString in TSMAPI:GetBagIterator() do
					if not usedLinks[itemString] then
						local baseItemString = TSMAPI:GetBaseItemString(itemString)
						local link = GetContainerItemLink(bag, slot)
						if itemString ~= baseItemString and TSM.db.global.ignoreRandomEnchants then -- a random enchant item
							itemString = baseItemString
							link = select(2, TSMAPI:GetSafeItemInfo(itemString))
						end
						if link and not TSM.db.profile.items[itemString] then
							tinsert(list, link)
							usedLinks[itemString] = true
						end
					end
				end
			end
		elseif side == "right" then
			for itemString, path in pairs(TSM.db.profile.items) do
				if path == groupPath or strfind(path, "^"..TSMAPI:StrEscape(groupPath)..TSM.GROUP_SEP) then
					local link = select(2, TSMAPI:GetSafeItemInfo(itemString))
					if link then
						tinsert(list, link)
					end
				end
			end
		end
		return list
	end
	
	local leftTitle, rightTitle
	if parentPath then
		if TSM.db.profile.directSubgroupAdd then
			leftTitle = L["Parent/Ungrouped Items:"]
		else
			leftTitle = L["Parent Group Items:"]
		end
		rightTitle = L["Subgroup Items:"]
	else
		leftTitle = L["Ungrouped Items:"]
		rightTitle = L["Group Items:"]
	end
	
	local page = {
		{	-- scroll frame to contain everything
			type = "SimpleGroup",
			layout = "Fill",
			children = {
				{
					type = "GroupItemList",
					leftTitle = leftTitle,
					rightTitle = rightTitle,
					listCallback = GetItemList,
					showIgnore = not parentPath or TSM.db.profile.directSubgroupAdd,
					onAdd = function(_,_,selected)
							for i=#selected, 1, -1 do
								AddItem(selected[i], groupPath)
							end
							TSMAPI:FireEvent("TSM:GROUPS:ADDITEMS", {num=#selected, group=groupPath})
							container:ReloadTab()
						end,
					onRemove = function(_,_,selected)
							if parentPath and not IsShiftKeyDown() then
								for i=#selected, 1, -1 do
									MoveItem(selected[i], parentPath)
								end
								TSMAPI:FireEvent("TSM:GROUPS:MOVEITEMS", {num=#selected, group=groupPath})
							else
								for i=#selected, 1, -1 do
									DeleteItem(selected[i])
								end
								TSMAPI:FireEvent("TSM:GROUPS:REMOVEITEMS", {num=#selected, group=groupPath})
							end
							container:ReloadTab()
						end,
				},
			},
		},
	}
	TSMAPI:BuildPage(container, page)
end

function TSM:ImportGroup(importStr, groupPath)
	if not importStr then return end
	importStr = importStr:trim()
	if importStr == "" then return end
	local parentPath = strfind(groupPath, TSM.GROUP_SEP) and SplitGroupPath(groupPath)
	
	if strfind(importStr, "^|c") then
		local itemString = TSMAPI:GetItemString(importStr)
		if not itemString then return end
		if parentPath and TSM.db.profile.importParentOnly and TSM.db.profile.items[itemString] ~= parentPath then return 0 end
		if TSM.db.profile.items[itemString] and TSM.db.profile.moveImportedItems then
			MoveItem(itemString, groupPath)
			return 1
		elseif not TSM.db.profile.items[itemString] then
			AddItem(itemString, groupPath)
			return 1
		end
		return 0
	end
	
	local items = {}
	local currentSubPath = ""
	for _, str in ipairs(TSMAPI:SafeStrSplit(importStr, ",")) do
		str = str:trim()
		local noSpaceStr = gsub(str, " ", "") -- forums like to add spaces
		local itemString, subPath
		if tonumber(noSpaceStr) then
			itemString = "item:"..tonumber(noSpaceStr)..":0:0:0:0:0:0"
		elseif strfind(noSpaceStr, "^group:") then
			subPath = strsub(str, strfind(str, ":")+1, -1)
			subPath = gsub(subPath, TSM.GROUP_SEP.."[ ]*"..TSM.GROUP_SEP, ",")
		elseif strfind(noSpaceStr, "p") then
			itemString = gsub(noSpaceStr, "p", "battlepet")
		elseif strfind(noSpaceStr, ":") then
			local itemID, randomEnchant = (":"):split(noSpaceStr)
			if not tonumber(itemID) or not tonumber(randomEnchant) then return end
			itemString = "item:"..tonumber(itemID)..":0:0:0:0:0:"..tonumber(randomEnchant)
		end
		
		if subPath then
			currentSubPath = subPath
		elseif itemString then
			items[itemString] = currentSubPath
		else
			return
		end
	end
	
	local num = 0
	for itemString, subPath in pairs(items) do
		if not (parentPath and TSM.db.profile.moveImportedItems and TSM.db.profile.importParentOnly and TSM.db.profile.items[itemString] ~= parentPath) then
			local path = groupPath
			if subPath ~= "" then
				-- create necessary parent groups
				local subParts = {TSM.GROUP_SEP:split(subPath)}
				for i=1, #subParts-1 do
					CreateGroup(path..TSM.GROUP_SEP..table.concat(subParts, TSM.GROUP_SEP, 1, i))
				end
				path = path..TSM.GROUP_SEP..subPath
			end
			CreateGroup(path)
			if TSM.db.profile.items[itemString] and TSM.db.profile.moveImportedItems then
				MoveItem(itemString, path)
				num = num + 1
			elseif not TSM.db.profile.items[itemString] then
				AddItem(itemString, path)
				num = num + 1
			end
		end
	end
	return num
end

function TSM:ExportGroup(groupPath)
	local temp = {}
	for itemString, group in pairs(TSM.db.profile.items) do
		if group == groupPath or strfind(group, "^"..TSMAPI:StrEscape(groupPath)..TSM.GROUP_SEP) then
			tinsert(temp, itemString)
		end
	end
	sort(temp, function(a, b)
			local groupA = strlower(gsub(TSM.db.profile.items[a], TSM.GROUP_SEP, "\001"))
			local groupB = strlower(gsub(TSM.db.profile.items[b], TSM.GROUP_SEP, "\001"))
			if groupA == groupB then
				return a < b
			end
			return groupA < groupB
		end)

	local items = {}
	local currentPath = ""
	for _, itemString in pairs(temp) do
		if TSM.db.profile.exportSubGroups then
			local path = TSM.db.profile.items[itemString]
			if path == groupPath then
				path = ""
			else
				path = gsub(path, "^"..TSMAPI:StrEscape(groupPath)..TSM.GROUP_SEP, "")
			end
			path = gsub(path, ",", TSM.GROUP_SEP..TSM.GROUP_SEP)
			if path ~= currentPath then
				tinsert(items, "group:"..path)
				currentPath = path
			end
		end
		if strfind(itemString, "^item:") then
			local _, itemID, _, _, _, _, _, randomEnchant = (":"):split(itemString)
			if tonumber(randomEnchant) and tonumber(randomEnchant) > 0 then
				tinsert(items, itemID..":"..randomEnchant)
			else
				tinsert(items, itemID)
			end
		elseif strfind(itemString, "^battlepet:") then
			itemString = gsub(itemString, "battlepet", "p")
			tinsert(items, itemString)
		end
	end
	return table.concat(items, ",")
end

function private:DrawGroupImportExportPage(container, groupPath)
	local page = {
		{	-- scroll frame to contain everything
			type = "ScrollFrame",
			layout = "list",
			children = {
				{
					type = "InlineGroup",
					layout = "flow",
					title = L["Import Items"],
					children = {
						{
							type = "Label",
							relativeWidth = 1,
							text = L["Paste the list of items into the box below and hit enter or click on the 'Okay' button.\n\nYou can also paste an itemLink into the box below to add a specific item to this group."],
						},
						{
							type = "EditBox",
							label = L["Import String"],
							relativeWidth = 1,
							callback = function(self, _, value)
									local num = TSM:ImportGroup(value, groupPath)
									if not num then
										TSM:Print(L["Invalid import string."])
										return self:SetFocus()
									end
									self:SetText("")
									TSM:Printf(L["Successfully imported %d items to %s."], num, TSMAPI:FormatGroupPath(groupPath, true))
									private:UpdateTree()
									private:SelectGroup(groupPath)
									TSMAPI:FireEvent("TSM:GROUPS:ADDITEMS", {num=num, group=groupPath, isImport=true})
								end,
							tooltip = L["Paste the exported items into this box and hit enter or press the 'Okay' button. The recommended format for the list of items is a comma separated list of itemIDs for general items. For battle pets, the entire battlepet string should be used. For randomly enchanted items, the format is <itemID>:<randomEnchant> (ex: 38472:-29)."],
						},
						{
							type = "CheckBox",
							label = L["Move Already Grouped Items"],
							relativeWidth = 0.5,
							settingInfo = {TSM.db.profile, "moveImportedItems"},
							callback = function() container:ReloadTab() end,
							tooltip = L["If checked, any items you import that are already in a group will be moved out of their current group and into this group. Otherwise, they will simply be ignored."],
						},
						{
							type = "CheckBox",
							disabled = not strfind(groupPath, TSM.GROUP_SEP) or not TSM.db.profile.moveImportedItems,
							label = L["Only Import Items from Parent Group"],
							relativeWidth = 0.5,
							settingInfo = {TSM.db.profile, "importParentOnly"},
							tooltip = L["If checked, only items which are in the parent group of this group will be imported."],
						},
					},
				},
				{
					type = "InlineGroup",
					layout = "flow",
					title = L["Export Items in Group"],
					children = {
						{
							type = "Label",
							relativeWidth = 1,
							text = L["Click the button below to open the export frame for this group."],
						},
						{
							type = "Button",
							text = L["Export Group Items"],
							relativeWidth = 1,
							callback = function()
									ShowExportFrame(TSM:ExportGroup(groupPath))
								end,
							tooltip = L["Click this button to show a frame for easily exporting the list of items which are in this group."],
						},
						{
							type = "CheckBox",
							label = L["Include Subgroup Structure in Export"],
							relativeWidth = 0.5,
							settingInfo = {TSM.db.profile, "exportSubGroups"},
							tooltip = L["If checked, the structure of the subgroups will be included in the export. Otherwise, the items in this group (and all subgroups) will be exported as a flat list."],
						},
					},
				},
			},
		},
	}
	TSMAPI:BuildPage(container, page)
end

function private:DrawGroupManagementPage(container, groupPath)
	local page = {
		{	-- scroll frame to contain everything
			type = "ScrollFrame",
			layout = "list",
			children = {
				{
					type = "InlineGroup",
					layout = "flow",
					title = L["Create New Subgroup"],
					children = {
						{
							type = "Label",
							relativeWidth = 1,
							text = L["Subgroups contain a subset of the items in their parent groups and can be used to further refine how different items are treated by TSM's modules."],
						},
						{
							type = "EditBox",
							label = L["New Subgroup Name"],
							relativeWidth = 0.8,
							callback = function(self,_,value)
									value = (value or ""):trim()
									if value == "" then return end
									if strfind(value, TSM.GROUP_SEP) then
										return TSM:Printf(L["Group names cannot contain %s characters."], TSM.GROUP_SEP)
									end
									local newPath = groupPath..TSM.GROUP_SEP..value
									if TSM.db.profile.groups[newPath] then
										return TSM:Printf(L["Error creating subgroup. Subgroup with name '%s' already exists."], value)
									end
									CreateGroup(newPath)
									private:UpdateTree()
									if TSM.db.profile.gotoNewGroup then
										private:SelectGroup(newPath)
									else
										self:SetText()
										self:SetFocus()
									end
								end,
							tooltip = L["Give the group a new name. A descriptive name will help you find this group later."],
						},
						{
							type = "CheckBox",
							label = L["Switch to New Group After Creation"],
							relativeWidth = 1,
							settingInfo = {TSM.db.profile, "gotoNewGroup"},
						},
					},
				},
				{
					type = "InlineGroup",
					layout = "flow",
					title = L["Rename Group"],
					children = {
						{
							type = "Label",
							relativeWidth = 1,
							text = L["Use the editbox below to give this group a new name."],
						},
						{
							type = "EditBox",
							label = L["New Group Name"],
							relativeWidth = 0.8,
							value = select(2, SplitGroupPath(groupPath)),
							callback = function(_,_,value)
									value = (value or ""):trim()
									if value == "" then return end
									if value == select(2, SplitGroupPath(groupPath)) then return end -- same name
									if strfind(value, TSM.GROUP_SEP) then
										return TSM:Printf(L["Group names cannot contain %s characters."], TSM.GROUP_SEP)
									end
									local newPath
									local parent = SplitGroupPath(groupPath)
									if parent then
										newPath = parent..TSM.GROUP_SEP..value
									else
										newPath = value
									end
									if TSM.db.profile.groups[newPath] then
										return TSM:Printf(L["Error renaming group. Group with name '%s' already exists."], value)
									end
									MoveGroup(groupPath, newPath)
									TSMAPI:FireEvent("TSM:GROUPS:MOVEGROUP", {old=groupPath, new=newPath})
									private:UpdateTree()
									private:SelectGroup(newPath)
								end,
							tooltip = L["Give the group a new name. A descriptive name will help you find this group later."],
						},
					},
				},
				{
					type = "InlineGroup",
					layout = "flow",
					title = L["Move Group"],
					children = {
						{
							type = "Label",
							relativeWidth = 1,
							text = L["Use the group box below to move this group and all subgroups of this group. Moving a group will cause all items in the group (and its subgroups) to be removed from its current parent group and added to the new parent group."],
						},
						{
							type = "GroupBox",
							label = L["New Parent Group"],
							relativeWidth = .5,
							callback = function(self, _, value)
								self:SetText()
								if value and value ~= groupPath then
									if strfind(value, "^"..groupPath) then
										return TSM:Printf(L["Error moving group. You cannot move this group to one of its subgroups."])
									end
									local _, groupName = SplitGroupPath(groupPath)
									local newPath = value..TSM.GROUP_SEP..groupName
									if TSM.db.profile.groups[newPath] then
										return TSM:Printf(L["Error moving group. Group '%s' already exists."], TSMAPI:FormatGroupPath(newPath, true))
									end
									
									TSM:Printf(L["Moved %s to %s."], TSMAPI:FormatGroupPath(groupPath, true), TSMAPI:FormatGroupPath(value, true))
									MoveGroup(groupPath, newPath)
									TSMAPI:FireEvent("TSM:GROUPS:MOVEGROUP", {old=groupPath, new=newPath})
									private:UpdateTree()
									private:SelectGroup(newPath)
								end
							end,
						},
						{
							type = "Button",
							text = L["Move to Top Level"],
							relativeWidth = 0.49,
							disabled = groupPath == select(2, SplitGroupPath(groupPath)),
							callback = function()
								local _, groupName = SplitGroupPath(groupPath)
								local newPath = groupName
								if TSM.db.profile.groups[newPath] then
									return TSM:Printf(L["Error moving group. Group '%s' already exists."], TSMAPI:FormatGroupPath(newPath, true))
								end
								
								TSM:Printf(L["Moved %s to %s."], TSMAPI:FormatGroupPath(groupPath, true), TSMAPI:FormatGroupPath(newPath, true))
								MoveGroup(groupPath, newPath)
								TSMAPI:FireEvent("TSM:GROUPS:MOVEGROUP", {old=groupPath, new=newPath})
								private:UpdateTree()
								private:SelectGroup(newPath)
							end,
							tooltip = L["When clicked, makes this group a top-level group with no parent."],
						},
					},
				},
				{
					type = "InlineGroup",
					layout = "flow",
					title = L["Delete Group"],
					children = {
						{
							type = "Label",
							relativeWidth = 1,
							text = L["Use the button below to delete this group. Any subgroups of this group will also be deleted, with all items being returned to the parent of this group or removed completely if this group has no parent."],
						},
						{
							type = "CheckBox",
							label = L["Keep Items in Parent Group"],
							relativeWidth = 1,
							settingInfo = {TSM.db.profile, "keepInParent"},
						},
						{
							type = "Button",
							text = L["Delete Group"],
							relativeWidth = 0.8,
							callback = function()
									DeleteGroup(groupPath)
									TSMAPI:FireEvent("TSM:GROUPS:DELETEGROUP", groupPath)
									private:UpdateTree()
									local parent = SplitGroupPath(groupPath)
									if parent then
										private:SelectGroup(parent)
									else
										treeGroup:SelectByPath(1)
									end
								end,
							tooltip = L["Any subgroups of this group will also be deleted, with all items being returned to the parent of this group or removed completely if this group has no parent."],
						},
					},
				},
			},
		},
	}
	TSMAPI:BuildPage(container, page)
end