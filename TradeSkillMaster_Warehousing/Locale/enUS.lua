-- ------------------------------------------------------------------------------ --
--                          TradeSkillMaster_Warehousing                          --
--          http://www.curse.com/addons/wow/tradeskillmaster_warehousing          --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- TradeSkillMaster_Warehousing Locale - enUS
-- Please use the localization app on CurseForge to update this
-- http://wow.curseforge.com/addons/TradeSkillMaster_Warehousing/localization/

local L = LibStub("AceLocale-3.0"):NewLocale("TradeSkillMaster_Warehousing", "enUS", true)
if not L then return end

L["'%s' has a Warehousing operation of '%s' which no longer exists."] = true
L["/tsm get/put X Y - X can be either an itemID, ItemLink (shift-click item) or partial text. Y is optionally the quantity you want to move."] = true
L["1) Open up a bank (either the gbank or personal bank)"] = true
L["1) Select Operations on the left menu and type a name in the textbox labeled \"Operation Name\", hit okay"] = true
L["2) You can delete an operation by selecting the operation and then under Operation Management click the button labelled \"Delete Operation\". "] = true
L["2) You should see a window on your right with a list of groups"] = true
L["3) Select one or more groups and hit either %s or %s"] = true
L["Bank UI"] = true
L["Canceled"] = true
L["Displays realtime move data."] = true
L["Empty Bags"] = true
L["Empty Bags/Restore Bags"] = true
L["Enable Restock"] = true
L["Enable this to set the quantity to keep back in your bags"] = true
L["Enable this to set the quantity to keep back in your bank / guildbank"] = true
L["Enable this to set the quantity to move, if disabled Warehousing will move all of the item"] = true
L["Enable this to set the restock quantity"] = true
L["Enable this to set the stack size multiple to be moved"] = true
L["Error creating operation. Operation with name '%s' already exists."] = true
L["Example 1: /tsm get glyph 20 - get up to 20 of each item in your bank/guildbank where the name contains\"glyph\" and place them in your bags."] = true
L["Example 2: /tsm put 74249 - get all of item 74249 (Spirit Dust) from your bags and put them in your bank/guildbank"] = true
L["General"] = true
L["Gets items from the bank or guild bank matching the itemstring, itemID or partial text entered."] = true
L["Give the new operation a name. A descriptive name will help you find this operation later."] = true
L["Help"] = true
L["Invalid criteria entered."] = true
L["Invalid criteria entered."] = true
L["Keep in Bags Quantity"] = true
L["Keep in Bank/GuildBank Quantity"] = true
L["Management"] = true
L["Move Data has been turned off"] = true
L["Move Data has been turned on"] = true
L["Move Group To Bags"] = true
L["Move Group To Bank"] = true
L["Move Quantity Settings"] = true
L["Move Quantity Settings"] = true
L["Move Quantity"] = true
L["New Operation"] = true
L["Nothing to Move"] = true
L["Nothing to Move"] = true
L["Nothing to Move"] = true
L["Nothing to Restock"] = true
L["Operation Name"] = true
L["Operations"] = true
L["Preparing to Move"] = true
L["Preparing to Move"] = true
L["Preparing to Move"] = true
L["Puts items matching the itemstring, itemID or partial text entered into the bank or guild bank."] = true
L["Relationships"] = true
L["Restock Bags"] = true
L["Restock Quantity"] = true
L["Restock Settings"] = true
L["Restock Settings"] = true
L["Restocking"] = true
L["Restore Bags"] = true
L["Set Keep in Bags Quantity"] = true
L["Set Keep in Bank Quantity"] = true
L["Set Move Quantity"] = true
L["Set Stack Size for bags"] = true
L["Simply hit empty bags, warehousing will remember what you had so that when you hit restore, it will grab all those items again. If you hit empty bags while your bags are empty it will overwrite the previous bag state, so you will not be able to use restore."] = true
L["Slash Commands"] = true
L["Stack Size Multiple"] = true
L["There are no visible banks."] = true
L["There are no visible banks."] = true
L["There are no visible banks."] = true
L["To create a Warehousing Operation"] = true
L["To move a Group"] = true
L["Warehousing operations contain settings for moving the items in a group. Type the name of the new operation into the box below and hit 'enter' to create a new Warehousing operation."] = true
L["Warehousing will ensure this number remain in your bags when moving items to the bank / guildbank."] = true
L["Warehousing will ensure this number remain in your bank / guildbank when moving items to your bags."] = true
L["Warehousing will move a max of %d of each item in this group keeping %d of each item back when bags > bank/gbank, %d of each item back when bank/gbank > bags. Restock will maintain %d items in your bags."] = true
L["Warehousing will move a max of %d of each item in this group keeping %d of each item back when bags > bank/gbank, %d of each item back when bank/gbank > bags."] = true
L["Warehousing will move a max of %d of each item in this group keeping %d of each item back when bags > bank/gbank. Restock will maintain %d items in your bags."] = true
L["Warehousing will move a max of %d of each item in this group keeping %d of each item back when bags > bank/gbank."] = true
L["Warehousing will move a max of %d of each item in this group keeping %d of each item back when bank/gbank > bags. Restock will maintain %d items in your bags."] = true
L["Warehousing will move a max of %d of each item in this group keeping %d of each item back when bank/gbank > bags."] = true
L["Warehousing will move a max of %d of each item in this group. Restock will maintain %d items in your bags."] = true
L["Warehousing will move a max of %d of each item in this group."] = true
L["Warehousing will move all of the items in this group keeping %d of each item back when bags > bank/gbank, %d of each item back when bank/gbank > bags. Restock will maintain %d items in your bags."] = true
L["Warehousing will move all of the items in this group keeping %d of each item back when bags > bank/gbank, %d of each item back when bank/gbank > bags."] = true
L["Warehousing will move all of the items in this group keeping %d of each item back when bags > bank/gbank. Restock will maintain %d items in your bags."] = true
L["Warehousing will move all of the items in this group keeping %d of each item back when bags > bank/gbank."] = true
L["Warehousing will move all of the items in this group keeping %d of each item back when bank/gbank > bags. Restock will maintain %d items in your bags."] = true
L["Warehousing will move all of the items in this group keeping %d of each item back when bank/gbank > bags."] = true
L["Warehousing will move all of the items in this group. Restock will maintain %d items in your bags."] = true
L["Warehousing will move all of the items in this group."] = true
L["Warehousing will move this number of each item"] = true
L["Warehousing will only move items in multiples of the stack size set when moving to your bags, this is useful for milling/prospecting etc to ensure you don't move items you can't process"] = true
L["Warehousing will restock your bags up to this number of items"] = true
L["Warehousing will try to get the right number of items, if there are not enough in the bank to fill out the order, it will grab all that there is."] = true
L["You can toggle the Bank UI by typing the command "] = true
L["You can use the following slash commands to get items from or put items into your bank or guildbank."] = true