-- ------------------------------------------------------------------------------ --
--                            TradeSkillMaster_Crafting                           --
--            http://www.curse.com/addons/wow/tradeskillmaster_crafting           --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- load the parent file (TSM) into a local variable and register this file as a module
local TSM = select(2, ...)
local Util = TSM:NewModule("Util")
-- local VELLUM_ID = "item:38682:0:0:0:0:0:0"

local scanTooltip
function GetTradeSkillReagentItemLink(skillIndex, reagentLink)
	if not scanTooltip then
		scanTooltip = CreateFrame("GameTooltip", "TSMCraftingScanTooltip", UIParent, "GameTooltipTemplate")
		scanTooltip:SetOwner(UIParent, "ANCHOR_NONE")
	end
	scanTooltip:ClearLines()
	scanTooltip:SetTradeSkillItem(skillIndex, reagentLink)
	return select(2, scanTooltip:GetItem())
end

function Util:IsProfessionReady()
	if GetTradeSkillLine() == "UNKNOWN" or not GetNumTradeSkills() or GetNumTradeSkills() <= 0 or InCombatLockdown() then
		return
	end
	
	for index=1, GetNumTradeSkills() do
		local itemLink = GetTradeSkillItemLink(index)
		local spellLink = GetTradeSkillRecipeLink(index)
		if itemLink and spellLink and strfind(spellLink, "enchant:") then
			local spellID, itemID, craftName
			if strfind(itemLink, "enchant:") then
				-- result of craft is enchant
				spellID = Util:GetSpellID(index)
				itemID = TSM.enchantingItemIDs[spellID] and "item:"..TSM.enchantingItemIDs[spellID]..":0:0:0:0:0:0"
			elseif strfind(itemLink, "item:") then
				-- result of craft is item
				itemID = TSMAPI:GetItemString(itemLink)
				spellID = Util:GetSpellID(index)
			else
				return
			end
			
			if itemID and spellID then
				for i=1, GetTradeSkillNumReagents(index) do
					local link = GetTradeSkillReagentItemLink(index, i)
					local name, _, quantity = GetTradeSkillReagentInfo(index, i)
					if not name or not link then
						return
					end
				end
			end
		end
	end
	
	return true
end

function Util:ScanCurrentProfession()
	if not Util:IsProfessionReady() then return TSMAPI:CreateTimeDelay("craftingScanDelay", 0.1, Util.ScanCurrentProfession) end
	
	local newCrafts = {}
	local playerName = UnitName("player")
	local currentTradeSkill = GetTradeSkillLine()
	local subClasses = {GetTradeSkillSubClasses()}
	local currentSubClass = 0

	local usedItems = {}
	local presetGroupInfo = {}
	local reagentLinkCache = {}
	for index=1, GetNumTradeSkills() do
		local itemLink = GetTradeSkillItemLink(index)
		local spellLink = GetTradeSkillRecipeLink(index)
		if not itemLink then
			local skillName, skillType = GetTradeSkillInfo(index)
			if skillType == "header" then
				for j=1, #subClasses do
					if skillName == subClasses[j] then
						currentSubClass = j
						break
					end
				end
			end
		elseif spellLink and strfind(spellLink, "enchant:") then
			local spellID, itemID, craftName
			
			if strfind(itemLink, "enchant:") then
				-- result of craft is enchant
				spellID = Util:GetSpellID(index)
				itemID = TSM.enchantingItemIDs[spellID] and "item:"..TSM.enchantingItemIDs[spellID]..":0:0:0:0:0:0"
				craftName = GetSpellInfo(spellID)
			elseif strfind(itemLink, "item:") then
				-- result of craft is item
				itemID = TSMAPI:GetItemString(itemLink)
				craftName = TSMAPI:GetSafeItemInfo(itemLink)
				spellID = Util:GetSpellID(index)
			end
			
			if itemID and spellID then
				local lNum, hNum = GetTradeSkillNumMade(index)
				local numMade = floor(((lNum or 1) + (hNum or 1))/2)
				local hasCD = select(2, GetTradeSkillCooldown(index)) and true or nil
				local mats = {}
				if currentTradeSkill == TSM.enchantingName and strfind(itemLink, "enchant:") then
					local VellumString = "item:"..TSM.VellumInfo[spellID]..":0:0:0:0:0:0"
					mats[VellumString] = 1
					local name = TSMAPI:GetSafeItemInfo(VellumString) or nil
					TSM.db.factionrealm.mats[VellumString] = TSM.db.factionrealm.mats[VellumString] or {}
					TSM.db.factionrealm.mats[VellumString].name = TSM.db.factionrealm.mats[VellumString].name or name
					numMade = 1
				end
				
				local isValid = true
				for i=1, GetTradeSkillNumReagents(index) do
					local name, texture, quantity = GetTradeSkillReagentInfo(index, i)
					if not name then
						isValid = false
						break
					end
					if not reagentLinkCache[name.."\001"..texture] then
						reagentLinkCache[name.."\001"..texture] = GetTradeSkillReagentItemLink(index, i)
					end
					local matID = TSMAPI:GetItemString(reagentLinkCache[name.."\001"..texture])
					if not matID then
						isValid = false
						break
					end
					
					mats[matID] = quantity
					TSM.db.factionrealm.mats[matID] = TSM.db.factionrealm.mats[matID] or {}
					TSM.db.factionrealm.mats[matID].name = TSM.db.factionrealm.mats[matID].name or name
				end
				
				if isValid then
					local players = TSM.db.factionrealm.crafts[spellID] and TSM.db.factionrealm.crafts[spellID].players or {}
					players[playerName] = true
					local queued = TSM.db.factionrealm.crafts[spellID] and TSM.db.factionrealm.crafts[spellID].queued or 0
					local intermediateQueued = TSM.db.factionrealm.crafts[spellID] and TSM.db.factionrealm.crafts[spellID].intermediateQueued or nil
					newCrafts[spellID] = {name=craftName, itemID=itemID, mats=mats, hasCD=hasCD, numResult=numMade, queued=queued, intermediateQueued=intermediateQueued, players=players, profession=currentTradeSkill}
					if not usedItems[itemID] then
						usedItems[itemID] = true
						local itemString = TSMAPI:GetItemString(itemID)
						if itemString then
							for matItemString in pairs(mats) do
								if not presetGroupInfo[matItemString] then
									presetGroupInfo[matItemString] = TSMAPI:JoinGroupPath("Professions", currentTradeSkill, "Materials")
								end
							end
							presetGroupInfo[itemString] = TSMAPI:JoinGroupPath("Professions", currentTradeSkill, "Crafts")
						end
					end
				end
			end
		end
	end
	
	-- search for and remove any spells that we can't craft anymore
	for spellID, data in pairs(TSM.db.factionrealm.crafts) do
		if data.profession == currentTradeSkill then
			local hasCrafters = false
			for player in pairs(data.players) do
				if player ~= playerName or newCrafts[spellID] then
					hasCrafters = true
					break
				end
			end
			
			if not hasCrafters then
				TSM.db.factionrealm.crafts[spellID] = nil
			end
		end
	end
	
	-- save the new craft info
	for spellID, data in pairs(newCrafts) do
		TSM.db.factionrealm.crafts[spellID] = data
	end
	TSM.CraftingGUI:PromptPresetGroups(currentTradeSkill, presetGroupInfo) --Bugged, asks after every login. Not saving prompt result between sessions. Either saving or loading bug (works fine on /reload though).
end

function Util:StartScanSyncedProfessionThread()
	local function callback()
		TradeSkillFrame:Show()
		CloseTradeSkill()
		TSM.isSyncing = nil
	end
	TSMAPI.Threading:Start(Util.ScanSyncedProfessionThread, 0.5, callback)
end

function Util.ScanSyncedProfessionThread(self)
	local ready
	for i=1, 10 do
		if Util:IsProfessionReady() then
			ready = true
			break
		end
		self:Sleep(0.1)
	end
	if not ready then return end
	
	local newCrafts = {}
	local reagentLinkCache = {}
	local _, playerName = IsTradeSkillLinked()
	local currentTradeSkill = GetTradeSkillLine()
	if playerName ~= TSM.isSyncing.player then return end

	for index=1, GetNumTradeSkills() do
		local itemLink = GetTradeSkillItemLink(index)
		local spellLink = GetTradeSkillRecipeLink(index)
		if itemLink and spellLink and strfind(spellLink, "enchant:") then
			local spellID, itemID, craftName
			if strfind(itemLink, "enchant:") then
				-- result of craft is enchant
				spellID = Util:GetSpellID(index)
				itemID = TSM.enchantingItemIDs[spellID] and "item:"..TSM.enchantingItemIDs[spellID]..":0:0:0:0:0:0"
				craftName = GetSpellInfo(spellID)
			elseif strfind(itemLink, "item:") then
				-- result of craft is item
				itemID = TSMAPI:GetItemString(itemLink)
				craftName = TSMAPI:GetSafeItemInfo(itemLink)
				spellID = Util:GetSpellID(index)
			end
			
			if itemID and spellID then
				local lNum, hNum = GetTradeSkillNumMade(index)
				local numMade = floor(((lNum or 1) + (hNum or 1))/2)
				local hasCD = select(2, GetTradeSkillCooldown(index)) and true or nil
				local mats = {}
				if currentTradeSkill == TSM.enchantingName and strfind(itemLink, "enchant:") then
					local VellumString = "item:"..TSM.VellumInfo[spellID]..":0:0:0:0:0:0"

					mats[VellumString] = 1
					local name = TSMAPI:GetSafeItemInfo(VellumString) or nil
					TSM.db.factionrealm.mats[VellumString] = TSM.db.factionrealm.mats[VellumString] or {}
					TSM.db.factionrealm.mats[VellumString].name = TSM.db.factionrealm.mats[VellumString].name or name
					numMade = 1
				end
				
				local isValid = true
				for i=1, GetTradeSkillNumReagents(index) do
					local name, texture, quantity = GetTradeSkillReagentInfo(index, i)
					if not name then
						isValid = false
						break
					end
					if not reagentLinkCache[name.."\001"..texture] then
						reagentLinkCache[name.."\001"..texture] = GetTradeSkillReagentItemLink(index, i)
					end
					local matID = TSMAPI:GetItemString(reagentLinkCache[name.."\001"..texture])
					if not matID then
						isValid = false
						break
					end
					
					mats[matID] = quantity
					TSM.db.factionrealm.mats[matID] = TSM.db.factionrealm.mats[matID] or {}
					TSM.db.factionrealm.mats[matID].name = TSM.db.factionrealm.mats[matID].name or name
				end
				
				if isValid then
					local players = TSM.db.factionrealm.crafts[spellID] and TSM.db.factionrealm.crafts[spellID].players or {}
					players[playerName] = true
					local queued = TSM.db.factionrealm.crafts[spellID] and TSM.db.factionrealm.crafts[spellID].queued or 0
					local intermediateQueued = TSM.db.factionrealm.crafts[spellID] and TSM.db.factionrealm.crafts[spellID].intermediateQueued or nil
					newCrafts[spellID] = {name=craftName, itemID=itemID, mats=mats, hasCD=hasCD, numResult=numMade, queued=queued, intermediateQueued=intermediateQueued, players=players, profession=currentTradeSkill}
				end
			end
		end
		self:Yield()
		if currentTradeSkill ~= GetTradeSkillLine() or select(2, IsTradeSkillLinked()) ~= TSM.isSyncing.player then return end
	end
	
	-- search for and remove any spells that we can't craft anymore
	for spellID, data in pairs(TSM.db.factionrealm.crafts) do
		if data.profession == currentTradeSkill then
			local hasCrafters = false
			for player in pairs(data.players) do
				if player ~= playerName or newCrafts[spellID] then
					hasCrafters = true
					break
				end
			end
			
			if not hasCrafters then
				TSM.db.factionrealm.crafts[spellID] = nil
			end
		end
	end
	
	-- save the new craft info
	for spellID, data in pairs(newCrafts) do
		TSM.db.factionrealm.crafts[spellID] = data
	end
	local playerName = select(2, IsTradeSkillLinked())
	local skillName, level, maxLevel = GetTradeSkillLine()
	TSM.db.factionrealm.tradeSkills[playerName] = TSM.db.factionrealm.tradeSkills[playerName] or {}
	TSM.db.factionrealm.tradeSkills[playerName][skillName] = TSM.db.factionrealm.tradeSkills[playerName][skillName] or {}
	TSM.db.factionrealm.tradeSkills[playerName][skillName].link = TSM.isSyncing.link
	TSM.db.factionrealm.tradeSkills[playerName][skillName].accountKey = TSM.isSyncing.accountKey
	TSM.db.factionrealm.tradeSkills[playerName][skillName].level = level
	TSM.db.factionrealm.tradeSkills[playerName][skillName].maxLevel = maxLevel
end

function Util:GetSpellID(index)
	local spellLink = GetTradeSkillRecipeLink(index)
	if not spellLink then return end
	return TSMAPI:GetItemID(spellLink)
end

function Util:FormatTime(seconds)
	if seconds == 0 then return end
	local hours = floor(seconds/3600)
	local mins = floor((seconds%3600)/60)
	local secs = seconds % 60
	
	local str = ""
	if hours > 0 then
		str = str..format("%dh", hours)
	end
	if mins > 0 then
		str = str..format("%dm", mins)
	end
	if secs > 0 then
		str = str..format("%ds", secs)
	end
	return str
end