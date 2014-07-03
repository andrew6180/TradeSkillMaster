-- ------------------------------------------------------------------------------ --
--                          TradeSkillMaster_ItemTracker                          --
--          http://www.curse.com/addons/wow/tradeskillmaster_itemtracker          --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- TradeSkillMaster_ItemTracker Locale - enUS
-- Please use the localization app on CurseForge to update this
-- http://wow.curseforge.com/addons/TradeSkill-Master/localization/

local L = LibStub("AceLocale-3.0"):NewLocale("TradeSkillMaster_ItemTracker", "enUS", true)
if not L then return end

L["%s (%s bags, %s bank, %s AH, %s mail)"] = true
L["%s in guild bank"] = true
L["%s item(s) total"] = true
L["(%s player, %s alts, %s guild banks, %s AH)"] = true
L["AH"] = true
L["Bags"] = true
L["Bank"] = true
L["Characters"] = true
L["Delete Character:"] = true
L["Full"] = true
L["GBank"] = true
L["Guilds (Guild Banks) to Ignore:"] = true
L["Guilds"] = true
L["Here, you can choose what ItemTracker info, if any, to show in tooltips. \"Simple\" will only show totals for bags/banks and for guild banks. \"Full\" will show detailed information for every character and guild."] = true
L["If you rename / transfer / delete one of your characters, use this dropdown to remove that character from ItemTracker. There is no confirmation. If you accidentally delete a character that still exists, simply log onto that character to re-add it to ItemTracker."] = true
L["Inventory Viewer"] = true
L["Item Name"] = true
L["Item Search"] = true
L["Mail"] = true
L["Market Value Price Source"] = true
L["No Tooltip Info"] = true
L["Options"] = true
L["Reset current player's inventory data."] = true
L["Select guilds to ingore in ItemTracker. Inventory will still be tracked but not displayed or taken into consideration by Itemtracker."] = true
L["Simple"] = true
L["Specifies the market value price source used for \"Total Market Value\" in the Inventory Viewer."] = true
L["Total Value"] = true
L["Total"] = true
L["\"%s\" removed from ItemTracker."] = true