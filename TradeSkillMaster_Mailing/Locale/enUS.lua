-- ------------------------------------------------------------------------------ --
--                            TradeSkillMaster_Mailing                            --
--            http://www.curse.com/addons/wow/tradeskillmaster_mailing            --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- TradeSkillMaster_Mailing Locale - enUS
-- Please use the localization app on CurseForge to update this
-- http://wow.curseforge.com/addons/TradeSkill-Master/localization/

local L = LibStub("AceLocale-3.0"):NewLocale("TradeSkillMaster_Mailing", "enUS", true)
if not L then return end

L["%s to collect."] = true
L["%s total gold collected!"] = true
L["AH Mail:"] = true
L["Auto Recheck Mail"] = true
L["Automatically rechecks mail every 60 seconds when you have too much mail.\n\nIf you loot all mail with this enabled, it will wait and recheck then keep auto looting."] = true
L["BE SURE TO SPELL THE NAME CORRECTLY!"] = true
L["Buys"] = true
L["Buy: %s (%d) | %s | %s"] = true
L["Cancels"] = true
L["COD Amount (per Item):"] = true
L["COD: %s | %s | %s | %s"] = true
L["Cannot finish auto looting, keeping %s slots free."] = true
L["Cannot finish auto looting, inventory is full or too many unique items."] = true
L["Chat Message Options"] = true
L["Clear"] = true
L["Clears the item box."] = true
L["Click this button to send all disenchantable greens in your bags to the specified character."] = true
L["Click this button to send excess gold to the specified character."] = true
L["Click this button to send off the item to the specified character."] = true
L["Collected %s and %s from %s."] = true
L["Collected %s from %s."] = true
L["Collected COD of %s from %s for %s."] = true
L["Collected expired auction of %s"] = true
L["Collected mail from %s with a subject of '%s'."] = true
L["Collected purchase of %s (%d) for %s."] = true
L["Collected sale of %s (%d) for %s."] = true
L["Could not loot item from mail because your bags are full."] = true
L["Could not send mail due to not having free bag space available to split a stack of items."] = true
L["Default Mailing Page"] = true
L["Display Total Money Received"] = true
L["Done sending mail."] = true
L["Drag (or place) the item that you want to send into this editbox."] = true
L["Enable Inbox Chat Messages"] = true
L["Enable Sending Chat Messages"] = true
L["Enter name of the character disenchantable greens should be sent to."] = true
L["Enter the desired COD amount (per item) to send this item with. Setting this to '0c' will result in no COD being set."] = true
L["Enter the name of the player you want to send excess gold to."] = true
L["Enter the name of the player you want to send this item to."] = true
L["Error creating operation. Operation with name '%s' already exists."] = true
L["Expired: %s | %s"] = true
L["Expires"] = true
L["General Settings"] = true
L["General"] = true
L["Give the new operation a name. A descriptive name will help you find this operation later."] = true
L["If checked, a maximum quantity to send to the target can be set. Otherwise, Mailing will send as many as it can."] = true
L["If checked, a 'Reload UI' button will be shown while waiting for the inbox to refresh. Reloading will cause the mailbox to refresh and may be faster than waiting for the next refresh."] = true
L["If checked, information on mails collected by TSM_Mailing will be printed out to chat."] = true
L["If checked, information on mails sent by TSM_Mailing will be printed out to chat."] = true
L["If checked, the 'Open All' button will leave any mail containing gold."] = true
L["If checked, the Mailing tab of the mailbox will be the default tab."] = true
L["If checked, the target's current inventory will be taken into account when determing how many to send. For example, if the max quantity is set to 10, and the target already has 3, Mailing will send at most 7 items."] = true
L["If checked, the target's guild bank will be included in their inventory for the 'Restock Target to Max Quantity' option."] = true
L["If checked, the total amount of gold received will be shown at the end of automatically collecting mail."] = true
L["Inbox"] = true
L["Include Guild Bank in Restock"] = true
L["Item (Drag Into Box):"] = true
L["Keep Free Bag Space"] = true
L["Keep Quantity"] = true
L["Leave Gold with Open All"] = true
L["Limit (In Gold):"] = true
L["Mail Disenchantables:"] = true
L["Mail Selected Groups"] = true
L["Mail Send Delay"] = true
L["Mailing all to %s."] = true
L["Mailing operations contain settings for easy mailing of items to other characters."] = true
L["Mailing up to %d to %s."] = true
L["Mailing will keep this number of items in the current player's bags and not mail them to the target."] = true
L["Make Mailing Default Mail Tab"] = true
L["Management"] = true
L["Max Quantity:"] = true
L["Maximum Quantity"] = true
L["Multiple Items"] = true
L["New Operation"] = true
L["Next inbox update in %d seconds."] = true
L["No Item Specified"] = true
L["No Target Player"] = true
L["No Target Specified"] = true
L["Not Target Specified"] = true
L["Not sending any gold as you have less than the specified limit."] = true
L["Open All Mail"] = true
L["Operation Name"] = true
L["Operation Settings"] = true
L["Operations"] = true
L["Options"] = true
L["Other"] = true
L["Quick Send"] = true
L["Relationships"] = true
L["Reload UI"] = true
L["Restart Delay (minutes)"] = true
L["Restock Target to Max Quantity"] = true
L["Sales"] = true
L["Sale: %s (%d) | %s | %s"] = true
L["Send all %s to %s - %s per Item COD"] = true
L["Send %sx%d to %s - %s per Item COD"] = true
L["Send all %s to %s - No COD"] = true
L["Send %sx%d to %s - No COD"] = true
L["Send Disenchantable Greens to %s"] = true
L["Send Excess Gold to %s"] = true
L["Send Excess Gold to Banker:"] = true
L["Send Items Individually"] = true
L["Sending..."] = true
L["Sends each unique item in a seperate mail."] = true
L["Sent %s to %s with a COD of %s."] = true
L["Sent %s to %s."] = true
L["Sent %s to %s."] = true
L["Sent all disenchantable greens to %s."] = true
L["Set Max Quantity"] = true
L["Sets the maximum quantity of each unique item to send to the target at a time."] = true
L["Shift-Click to automatically re-send after the amount of time specified in the TSM_Mailing options."] = true
L["Show Reload UI Button"] = true
L["Showing %d of %d mail."] = true
L["Showing all %d mail."] = true
L["Skipping operation '%s' because there is no target."] = true
L["Specifies the default page that'll show when you select the TSM_Mailing tab."] = true
L["TSM Groups"] = true
L["TSM_Mailing Excess Gold"] = true
L["Target Player"] = true
L["Target Player:"] = true
L["Target is Current Player"] = true
L["Target:"] = true
L["The name of the player you want to mail items to."] = true
L["This is maximum amount of gold you want to keep on the current player. Any amount over this limit will be send to the specified character."] = true
L["This is the maximum number of the specified item to send when you click the button below. Setting this to 0 will send ALL items."] = true
L["This slider controls how long the mail sending code waits between consecutive mails. If this is set too low, you will run into internal mailbox errors."] = true
L["This slider controls how much free space to keep in your bags when looting from the mailbox. This only applies to bags that any item can go in."] = true
L["This tab allows you to quickly send any quantity of an item to another character. You can also specify a COD to set on the mail (per item)."] = true
L["When you shift-click a send mail button, after the initial send, it will check for new items to send at this interval."] = true