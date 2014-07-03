-- ------------------------------------------------------------------------------ --
--                            TradeSkillMaster_Crafting                           --
--            http://www.curse.com/addons/wow/tradeskillmaster_crafting           --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- load the parent file (TSM) into a local variable and register this file as a module
local TSM = select(2, ...)
local Sync = TSM:NewModule("Sync")
local syncQueue = {}

function Sync:OnEnable()
	Sync:BroadcastTradeSkillData()
end

function Sync:OpenTradeSkill()
	if not TSM.isSyncing then return end
	local tradeString = strsub(select(3, ("|"):split(TSM.isSyncing.link)), 2)
	SetItemRef(tradeString, TSM.isSyncing.link, "LeftButton", ChatFrame1)
end

function Sync:BroadcastTradeSkillData(timerUp)
	if not timerUp then
		TSMAPI:CreateTimeDelay("craftingSyncDelay", 3, function() Sync:BroadcastTradeSkillData(true) end)
		return
	end
	local player = UnitName("player")
	local playerTradeSkills = TSM.db.factionrealm.tradeSkills[player]
	if not playerTradeSkills then return end
	
	local packet = {tradeSkills={}, accountKey=TSMAPI.Sync:GetAccountKey()}
	for name, data in pairs(playerTradeSkills) do
		if data.accountKey == TSMAPI.Sync:GetAccountKey() then
			packet.tradeSkills[player.."~"..name] = data.link
		end
	end
	TSMAPI.Sync:BroadcastData("Crafting", "TRADESKILLS", packet)
end

function Sync:ProcessTradeSkills(data)
	for key, link in pairs(data.tradeSkills) do
		local player, tradeSkill = ("~"):split(key)
		if not (TSM.db.factionrealm.tradeSkills[player] and TSM.db.factionrealm.tradeSkills[player][tradeSkill] and TSM.db.factionrealm.tradeSkills[player][tradeSkill].link == link) then
			tinsert(syncQueue, {link=link, accountKey=data.accountKey, player=player})
		end
	end
	TSMAPI:CreateTimeDelay("craftingSyncProcessQueue", 0, Sync.ProcessQueue)
end

function Sync:ProcessQueue()
	if TSM.isSyncing then return TSMAPI:CreateTimeDelay("craftingSyncProcessQueue", 0.1, Sync.ProcessQueue) end
	TSM.isSyncing = tremove(syncQueue, 1)
	Sync:OpenTradeSkill()
	TSMAPI:CreateTimeDelay("craftingSyncProcessQueue", 1, Sync.ProcessQueue)
end

function Sync:Callback(key, data, source)
	if key == "TRADESKILLS" then
		Sync:ProcessTradeSkills(data)
	end
end