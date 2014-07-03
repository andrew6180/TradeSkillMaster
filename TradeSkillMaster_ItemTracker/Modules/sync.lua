-- ------------------------------------------------------------------------------ --
--                          TradeSkillMaster_ItemTracker                          --
--          http://www.curse.com/addons/wow/tradeskillmaster_itemtracker          --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- load the parent file (TSM) into a local variable and register this file as a module
local TSM = select(2, ...)
local Sync = TSM:NewModule("Sync")


function Sync:BroadcastUpdateRequest(timerUp)
	if not timerUp then
		TSMAPI:CreateTimeDelay("itemTrackerSyncDelay", 3, function() Sync:BroadcastUpdateRequest(true) end)
		return
	end
	local packet = {characters={}, guilds={}}
	for player, data in pairs(TSM.characters or {}) do
		if data.account == TSMAPI.Sync:GetAccountKey() then
			packet.characters[player] = CopyTable(data.lastUpdate)
		end
	end
	for guild, data in pairs(TSM.guilds or {}) do
		packet.guilds[guild] = data.lastUpdate
	end
	TSMAPI.Sync:BroadcastData("ItemTracker", "REQUEST", packet)
end

function Sync:SendUpdateResponse(target, request)
	local response = {characters={}, guilds={}}
	for player, lastUpdate in pairs(request.characters or {}) do
		for key, updateTime in pairs(lastUpdate) do
			if not TSM.characters[player] or (TSM.characters[player].lastUpdate[key] or 0) < updateTime then
				response.characters[player] = response.characters[player] or {}
				tinsert(response.characters[player], key)
			end
		end
	end
	for guild, lastUpdate in pairs(request.guilds or {}) do
		if not TSM.guilds[guild] or (TSM.guilds[guild].lastUpdate or 0) < lastUpdate then
			tinsert(response.guilds, guild)
		end
	end
	
	if next(response.characters) or #response.guilds > 0 then
		TSMAPI.Sync:SendData("ItemTracker", "RESPONSE", response, target)
	end
end

function Sync:SendUpdateData(target, response)
	local data = {characters={}, guilds={}}
	for player, keys in pairs(response.characters or {}) do
		data.characters[player] = {}
		for _, key in ipairs(keys) do
			data.characters[player][key] = TSM.characters[player][key]
			data.characters[player].lastUpdate = data.characters[player].lastUpdate or {}
			data.characters[player].lastUpdate[key] = TSM.characters[player].lastUpdate[key]
		end
	end
	for _, guild in ipairs(response.guilds or {}) do
		data.guilds[guild] = TSM.guilds[guild]
	end
	
	if next(data) then
		TSMAPI.Sync:SendData("ItemTracker", "DATA", data, target)
	end
end

function Sync:ProcessUpdateData(data)
	for player, info in pairs(data.characters or {}) do
		TSM.characters[player] = TSM.characters[player] or CopyTable(TSM.characterDefaults)
		for key, updateTime in pairs(info.lastUpdate or {}) do
			TSM.characters[player][key] = info[key]
			TSM.characters[player].lastUpdate[key] = updateTime
		end
	end
	for player, info in pairs(data.guilds or {}) do
		TSM.guilds[player] = info
	end
end

function Sync:Callback(key, data, source)
	if key == "REQUEST" then
		Sync:SendUpdateResponse(source, data)
	elseif key == "RESPONSE" then
		Sync:SendUpdateData(source, data)
	elseif key == "DATA" then
		Sync:ProcessUpdateData(data)
	end
end