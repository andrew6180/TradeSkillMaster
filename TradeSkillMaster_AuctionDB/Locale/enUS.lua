-- ------------------------------------------------------------------------------ --
--                           TradeSkillMaster_AuctionDB                           --
--           http://www.curse.com/addons/wow/tradeskillmaster_auctiondb           --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- TradeSkillMaster_AuctionDB Locale - enUS
-- Please use the localization app on CurseForge to update this
-- http://wow.curseforge.com/addons/TradeSkill-Master/localization/

local L = LibStub("AceLocale-3.0"):NewLocale("TradeSkillMaster_AuctionDB", "enUS", true)
if not L then return end

L["%s ago"] = true
L["A GetAll scan is the fastest in-game method for scanning every item on the auction house. However, there are many possible bugs on Blizzard's end with it including the chance for it to disconnect you from the game. Also, it has a 15 minute cooldown."] = true
L["A full auction house scan will scan every item on the auction house but is far slower than a GetAll scan. Expect this scan to take several minutes or longer."] = true
L["Any items in the AuctionDB database that contain the search phrase in their names will be displayed."] = true
L["Are you sure you want to clear your AuctionDB data?"] = true
L["Ascending"] = true
L["AuctionDB - Market Value"] = true
L["AuctionDB - Minimum Buyout"] = true
L["Can't run a GetAll scan right now."] = true
L["Descending"] = true
L["Display lowest buyout value seen in the last scan in tooltip."] = true
L["Display market value in tooltip."] = true
L["Done Scanning"] = true
L["Download the FREE TSM desktop application which will automatically update your TSM_AuctionDB prices using Blizzard's online APIs (and does MUCH more). Visit %s for more info and never scan the AH again! This is the best way to update your AuctionDB prices."] = true
L["Enable display of AuctionDB data in tooltip."] = true
L["GetAll scan did not run successfully due to issues on Blizzard's end. Using the TSM application for your scans is recommended."] = true
L["Hide poor quality items"] = true
L["If checked, AuctionDB will add a tab to the AH to allow for in-game scans. If you are using the TSM app exclusively for your scans, you may want to hide it by unchecking this option. This option requires a reload to take effect."] = true
L["If checked, poor quality items won't be shown in the search results."] = true
L["If checked, the lowest buyout value seen in the last scan of the item will be displayed."] = true
L["If checked, the market value of the item will be displayed"] = true
L["Imported %s scans worth of new auction data!"] = true
L["Invalid value entered. You must enter a number between 5 and 500 inclusive."] = true
L["It is strongly recommended that you reload your ui (type '/reload') after running a GetAll scan. Otherwise, any other scans (Post/Cancel/Search/etc) will be much slower than normal."] = true
L["Item Link"] = true
L["Item MinLevel"] = true
L["Item SubType Filter"] = true
L["Item Type Filter"] = true
L["Items %s - %s (%s total)"] = true
L["Items per page"] = true
L["Last Scanned"] = true
L["Last updated from in-game scan %s ago."] = true
L["Last updated from the TSM Application %s ago."] = true
L["Market Value x%s:"] = true
L["Market Value"] = true
L["Market Value:"] = true
L["Min Buyout x%s:"] = true
L["Min Buyout:"] = true
L["Minimum Buyout"] = true
L["Next Page"] = true
L["No items found"] = true
L["No scans found."] = true
L["Not Ready"] = true
L["Not Scanned"] = true
L["Options"] = true
L["Preparing Filter %d / %d"] = true
L["Preparing Filters..."] = true
L["Previous Page"] = true
L["Processing data..."] = true
L["Ready in %s min and %s sec"] = true
L["Ready"] = true
L["Refreshes the current search results."] = true
L["Removed %s from AuctionDB."] = true
L["Reset Data"] = true
L["Resets AuctionDB's scan data"] = true
L["Result Order:"] = true
L["Run Full Scan"] = true
L["Run GetAll Scan"] = true
L["Running query..."] = true
L["Scan Selected Groups"] = true
L["Scanning %d / %d (Page %d / %d)"] = true
L["Scanning page %s/%s"] = true
L["Scanning the auction house in game is no longer necessary!"] = true
L["Search Options"] = true
L["Search"] = true
L["Select how you would like the search results to be sorted. After changing this option, you may need to refresh your search results by hitting the \"Refresh\" button."] = true
L["Select whether to sort search results in ascending or descending order."] = true
L["Shift-Right-Click to clear all data for this item from AuctionDB."] = true
L["Show AuctionDB AH Tab (Requires Reload)"] = true
L["Sort items by"] = true
L["This determines how many items are shown per page in results area of the \"Search\" tab of the AuctionDB page in the main TSM window. You may enter a number between 5 and 500 inclusive. If the page lags, you may want to decrease this number."] = true
L["This will do a slow auction house scan of every item in the selected groups and update their AuctionDB prices. This may take several minutes."] = true
L["Use the search box and category filters above to search the AuctionDB data."] = true
L["You can filter the results by item subtype by using this dropdown. For example, if you want to search for all herbs, you would select \"Trade Goods\" in the item type dropdown and \"Herbs\" in this dropdown."] = true
L["You can filter the results by item type by using this dropdown. For example, if you want to search for all herbs, you would select \"Trade Goods\" in this dropdown and \"Herbs\" as the subtype filter."] = true
L["You can use this page to lookup an item or group of items in the AuctionDB database. Note that this does not perform a live search of the AH."] = true