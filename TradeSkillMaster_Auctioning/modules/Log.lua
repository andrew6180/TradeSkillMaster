-- ------------------------------------------------------------------------------ --
--                           TradeSkillMaster_Auctioning                          --
--           http://www.curse.com/addons/wow/tradeskillmaster_auctioning          --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

local TSM = select(2, ...)
local Log = TSM:NewModule("Log", "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster_Auctioning")

local records = {}

local RED = "|cffff2211"
local ORANGE = "|cffff8811"
local GREEN = "|cff22ff22"
local CYAN = "|cff99ffff"

local info = {
	post = {
		invalid = {L["Item/Group is invalid."], RED},
		notEnough = {L["Not enough items in bags."], ORANGE},
		belowMinPrice = {L["Cheapest auction below min price."], ORANGE},
		tooManyPosted = {L["Maximum amount already posted."], CYAN},
		postingNormal = {L["Posting at normal price."], GREEN},
		postingResetMin = {L["Below min price. Posting at min price."], GREEN},
		postingResetMax = {L["Below min price. Posting at max price."], GREEN},
		postingResetNormal = {L["Below min price. Posting at normal price."], GREEN},
		aboveMaxMin = {L["Above max price. Posting at min price."], GREEN},
		aboveMaxMax = {L["Above max price. Posting at max price."], GREEN},
		aboveMaxNormal = {L["Above max price. Posting at normal price."], GREEN},
		postingPlayer = {L["Posting at your current price."], GREEN},
		postingWhitelist = {L["Posting at whitelisted player's price."], GREEN},
		notPostingWhitelist = {L["Lowest auction by whitelisted player."], ORANGE},
		postingUndercut = {L["Undercutting competition."], GREEN},
		invalidSeller = {L["Invalid seller data returned by server."], RED},
	},
	cancel = {
		bid = {L["Auction has been bid on."], CYAN},
		atReset = {L["Not canceling auction at reset price."], GREEN},
		reset = {L["Canceling to repost at reset price."], CYAN},
		belowMinPrice = {L["Not canceling auction below min price."], ORANGE},
		undercut = {L["You've been undercut."], RED},
		whitelistUndercut = {L["Undercut by whitelisted player."], RED},
		atNormal = {L["At normal price and not undercut."], GREEN},
		atAboveMax = {L["At above max price and not undercut."], GREEN},
		repost = {L["Canceling to repost at higher price."], CYAN},
		notUndercut = {L["Your auction has not been undercut."], GREEN},
		cancelAll = {L["Canceling all auctions."], CYAN},
		notLowest = {L["Canceling auction which you've undercut."], CYAN},
		invalidSeller = {L["Invalid seller data returned by server."], RED},
		atWhitelist = {L["Posted at whitelisted player's price."], GREEN},
		keepPosted = {L["Keeping undercut auctions posted."], CYAN},
	},
}

function Log:GetInfo(mode, reason)
	return info[mode][reason] and info[mode][reason][1]
end

function Log:GetColor(mode, reason)
	return mode and reason and info[mode] and info[mode][reason] and info[mode][reason][2]
end

function Log:AddLogRecord(itemString, mode, action, reason, operation, buyout)
	local info = Log:GetInfo(mode, reason)
	local record = {itemString=itemString, info=info, action=action, mode=mode, reason=reason, operation=operation, buyout=buyout}
	tinsert(records, record)
end

function Log:GetInfoForItem(itemString)
	for _, record in ipairs(records) do
		if record.itemString == itemString then
			return record.info
		end
	end
end

function Log:GetData()
	return records
end

function Log:Clear()
	wipe(records)
end