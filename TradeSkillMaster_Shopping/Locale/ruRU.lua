-- ------------------------------------------------------------------------------ --
--                            TradeSkillMaster_Shopping                           --
--            http://www.curse.com/addons/wow/tradeskillmaster_shopping           --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- TradeSkillMaster_Shopping Locale - ruRU
-- Please use the localization app on CurseForge to update this
-- http://wow.curseforge.com/addons/TradeSkillMaster_Shopping/localization/

local L = LibStub("AceLocale-3.0"):NewLocale("TradeSkillMaster_Shopping", "ruRU")
if not L then return end

L["Action"] = "действие" -- Needs review
L["Added '%s' to your favorite searches."] = "Добавлено '%s' для избранного поиска." -- Needs review
-- L["Below Custom Price ('0c' to disable)"] = ""
-- L["Below Max Price"] = ""
-- L["Below Vendor Sell Price"] = ""
L["Bid Percent"] = "Процент ставки"
L["Buyout"] = "Выкуп"
L[ [=[Click to search for an item.
Shift-Click to post at market value.]=] ] = [=[Нажмите эту кнопку для поиска элемента.
Shift + клик пост по рыночной стоимости.]=] -- Needs review
L["Custom Filter"] = "Пользовательский Фильтр" -- Needs review
-- L["Default Post Undercut Amount"] = ""
L["Destroy Mode"] = "режим уничтожения" -- Needs review
-- L["% DE Value"] = ""
-- L["Disenchant Search Profit: %s"] = ""
L["Done Scanning"] = "Сканирование завершено" -- Needs review
L["Enter what you want to search for in this box. You can also use the following options for more complicated searches."] = "Введите то, что вы хотите найти в это поле. Вы также можете использовать следующие опции для более сложные запросы." -- Needs review
-- L["Error creating operation. Operation with name '%s' already exists."] = ""
-- L["Even (5/10/15/20) Stacks Only"] = ""
L["Favorite Searches"] = "Любимые поиски" -- Needs review
L["General"] = "Основной" -- Needs review
L["General Operation Options"] = "Настройка основных операций" -- Needs review
L["General Options"] = "Общие настройки"
-- L["General Settings"] = ""
L["Give the new operation a name. A descriptive name will help you find this operation later."] = "Дать имя новой операции. Описательное имя поможет вам найти эту операцию позже." -- Needs review
-- L["Hide Grouped Items"] = ""
-- L["If checked, auctions above the max price will be shown."] = ""
-- L["If checked, only auctions posted in even quantities will be considered for purchasing."] = ""
-- L["If checked, the maximum shopping price will be shown in the tooltip for the item."] = ""
-- L["If set, only items which are usable by your character will be included in the results."] = ""
-- L["If set, only items which exactly match the search filter you have set will be included in the results."] = ""
-- L["Import"] = ""
-- L["Import Favorite Search"] = ""
-- L["Inline Filters:|r You can easily add common search filters to your search such as rarity, level, and item type. For example '%sarmor/leather/epic/85/i350/i377|r' will search for all leather armor of epic quality that requires level 85 and has an ilvl between 350 and 377 inclusive. Also, '%sinferno ruby/exact|r' will display only raw inferno rubys (none of the cuts)."] = ""
-- L["Invalid custom price source for %s. %s"] = ""
-- L["Invalid destroy search: '%s'"] = ""
-- L["Invalid destroy target: '%s'"] = ""
-- L["Invalid Even Only Filter"] = ""
-- L["Invalid Exact Only Filter"] = ""
L["Invalid Filter"] = "Недействительный фильтр" -- Needs review
L["Invalid Item Level"] = "Недействительный уровень предмета"
L["Invalid Item Rarity"] = "Недействительное качество предмета"
-- L["Invalid Item SubType"] = ""
L["Invalid Item Type"] = "Неверный тип товара" -- Needs review
-- L["Invalid Max Quantity"] = ""
L["Invalid Min Level"] = "Недействительный минимальный уровень"
-- L["Invalid target item for destroy search: '%s'"] = ""
-- L["Invalid Usable Only Filter"] = ""
L["Item"] = "Предмет"
-- L["Item Class"] = ""
-- L["Item Level Range:"] = ""
-- L["Item SubClass"] = ""
-- L["Items which are below their maximum price (per their group / Shopping operation) will be displayed in Sniper searches."] = ""
-- L["Items which are below their vendor sell price will be displayed in Sniper searches."] = ""
-- L["Items which are below this custom price will be displayed in Sniper searches."] = ""
-- L["Left-Click to run this search."] = ""
-- L["Log"] = ""
-- L["Management"] = ""
L["% Market Value"] = "% рыноч. цены"
-- L["Market Value Price Source"] = ""
-- L["% Mat Price"] = ""
-- L["Max Disenchant Search Percent"] = ""
-- L["Maximum Auction Price (per item)"] = ""
-- L["Maximum quantity purchased for destroy search."] = ""
-- L["Maximum quantity purchased for %s."] = ""
-- L["Maximum Quantity to Buy:"] = ""
L["% Max Price"] = "% макс. цены"
-- L["Max Shopping Price:"] = ""
-- L["Minimum Rarity"] = ""
-- L["Multiple Search Terms:|r You can search for multiple things at once by simply separated them with a ';'. For example '%selementium ore; obsidium ore|r' will search for both elementium and obsidium ore."] = ""
L["New Operation"] = "Новая Операция"
-- L["No recent AuctionDB scan data found."] = ""
-- L["Normal Mode"] = ""
-- L["Normal Post Price"] = ""
-- L["NOTE: The scan must be stopped before you can buy anything."] = ""
-- L["Num"] = ""
-- L["Operation Name"] = ""
-- L["Operations"] = ""
L["Options"] = "Настройки"
-- L["Other"] = ""
-- L["Paste the search you'd like to import into the box below."] = ""
-- L["Posted a %s with a buyuot of %s."] = ""
-- L["Preparing Filter %d / %d"] = ""
-- L["Preparing filters..."] = ""
-- L["Press Ctrl-C to copy this saved search."] = ""
-- L["Price"] = ""
L["Quick Posting"] = "Быстрое размещение" -- Needs review
-- L["Quick Posting Duration"] = ""
-- L["Quick Posting Price"] = ""
L["Recent Searches"] = "Недавние поиски" -- Needs review
-- L["Relationships"] = ""
-- L["Removed '%s' from your favorite searches."] = ""
-- L["Removed '%s' from your recent searches."] = ""
-- L["Required Level Range:"] = ""
-- L["Reset Filters"] = ""
-- L["Right-Click to favorite this recent search."] = ""
-- L["Right-Click to remove from favorite searches."] = ""
L["Saved Searches"] = "Сохраненные поиски" -- Needs review
-- L["Scanning %d / %d (Page %d / %d)"] = ""
-- L["Search Filter:"] = ""
-- L["Select the groups which you would like to include in the search."] = ""
L["'%s' has a Shopping operation of '%s' which no longer exists. Shopping will ignore this group until this is fixed."] = "\"% s \" имеет Торговые операции '%s', которая больше не существует. Торговые будете игнорировать эту группу до тех пор, пока это будет Исправлено." -- Needs review
-- L["Shift-Left-Click to export this search."] = ""
-- L["Shift-Right-Click to remove this recent search."] = ""
-- L["Shopping for auctions including those above the max price."] = ""
-- L["Shopping for auctions with a max price set."] = ""
-- L["Shopping for even stacks including those above the max price"] = ""
-- L["Shopping for even stacks with a max price set."] = ""
-- L["Shopping operations contain settings items which you regularly buy from the auction house."] = ""
-- L["Show Auctions Above Max Price"] = ""
-- L["Show Shopping Max Price in Tooltip"] = ""
-- L["Sidebar Pages:"] = ""
-- L["Skipped the following search term because it's invalid."] = ""
-- L["Skipped the following search term because it's too long. Blizzard does not allow search terms over 63 characters."] = ""
-- L["Sniper Options"] = ""
-- L["Start Disenchant Search"] = ""
-- L["Start Search"] = ""
-- L["Start Sniper"] = ""
-- L["Start Vendor Search"] = ""
-- L["Stop"] = ""
-- L["Stop Sniper"] = ""
L["% Target Value"] = "% стоимость выделенного" -- Needs review
-- L["The disenchant search looks for items on the AH below their disenchant value. You can set the maximum percentage of disenchant value to search for in the Shopping General options"] = ""
-- L["The duration at which items will be posted via the 'Quick Posting' frame."] = ""
-- L["The highest price per item you will pay for items in affected by this operation."] = ""
-- L["The Sniper feature will look in real-time for items that have recently been posted to the AH which are worth snatching! You can configure the parameters of Sniper in the Shopping options."] = ""
-- L["The vendor search looks for items on the AH below their vendor sell price."] = ""
-- L["This is how Shopping calculates the '% Market Value' column in the search results."] = ""
-- L["This is the default price Shopping will suggest to post items at when there's no others posted."] = ""
-- L["This is the maximum percentage of disenchant value that the Other > Disenchant search will display results for."] = ""
-- L["This is the percentage of your buyout price that your bid will be set to when posting auctions with Shopping."] = ""
-- L["This price is used to determine what items will be posted at through the 'Quick Posting' frame."] = ""
-- L["TSM Groups"] = ""
L["Unknown Filter"] = "Фильтр не указан" -- Needs review
-- L["Unknown milling search target: '%s'"] = ""
L["% Vendor Price"] = "% цена торговца" -- Needs review
-- L["Vendor Search Profit: %s"] = ""
-- L["What to set the default undercut to when posting items with Shopping."] = ""
-- L["When in destroy mode, you simply enter a target item (ink/pigment, enchanting mat, gem, etc) into the search box to search for everything you can destroy to get that item."] = ""
-- L["When in normal mode, you may run simple and filtered searches of the auction house."] = ""
