-- ------------------------------------------------------------------------------------- --
-- 					TradeSkillMaster_Crafting - AddOn by Sapu94							 	  	  --
--   http://wow.curse.com/downloads/wow-addons/details/tradeskillmaster_crafting.aspx    --
--																													  --
--		This addon is licensed under the CC BY-NC-ND 3.0 license as described at the		  --
--				following url: http://creativecommons.org/licenses/by-nc-nd/3.0/			 	  --
-- 	Please contact the author via email at sapu94@gmail.com with any questions or		  --
--		concerns regarding this license.																	  --
-- ------------------------------------------------------------------------------------- --

-- TradeSkillMaster_Crafting Locale - deDE
-- Please use the localization app on CurseForge to update this
-- http://wow.curseforge.com/addons/TradeSkillMaster_Crafting/localization/

local L = LibStub("AceLocale-3.0"):NewLocale("TradeSkillMaster_Crafting", "deDE")
if not L then return end

L["All"] = "Alle"
L["Are you sure you want to reset all material prices to the default value?"] = "Wirklich alle Materialpreise auf den Standardwert zurücksetzen?"
L["Ask Later"] = "Später nachfragen" -- Needs review
L["Auction House"] = "Auktionshaus"
L["Available Sources"] = "Verfügbare Quellen" -- Needs review
L["Buy Vendor Items"] = "Gegenstände vom Händler kaufen" -- Needs review
L["Characters (Bags/Bank/AH/Mail) to Ignore:"] = "Charaktere (Taschen/Bank/AH/Post), die ignoriert werden:" -- Needs review
L["Clear Filters"] = "Filter zurücksetzen" -- Needs review
L["Clear Queue"] = "Warteschlange leeren"
-- L["Click Start Gathering"] = ""
L["Collect Mail"] = "Post einsammeln" -- Needs review
L["Cost"] = "Kosten"
-- L["Could not get link for profession."] = ""
L["Crafting Cost"] = "Herstellungskosten" -- Needs review
-- L["Crafting Material Cost"] = ""
L["Crafting operations contain settings for restocking the items in a group. Type the name of the new operation into the box below and hit 'enter' to create a new Crafting operation."] = "Herstellungsprozesse enthalten Einstellungen, um die Gegenstände einer Gruppe aufzufüllen. Gib den Namen des neuen Prozesses in die Box unten ein und drücke 'Enter', um einen neuen Herstellungsprozess zu erzeugen." -- Needs review
-- L["Crafting will not queue any items affected by this operation with a profit below this value. As an example, a min profit of 'max(10g, 10% crafting)' would ensure atleast a 10g and 10% profit."] = ""
L["Craft Next"] = "Nächstes herstellen"
-- L["Craft Price Method"] = ""
-- L["Craft Queue"] = ""
L["Create Profession Groups"] = "Berufsgruppen erstellen" -- Needs review
L["Custom Price"] = "Benutzerdefinierter Preis" -- Needs review
L["Custom Price for this item."] = "Benutzerdefinierter Preis für diesen Gegenstand." -- Needs review
L["Custom Price per Item"] = "Benutzerdefinierter Preis pro Gegenstand" -- Needs review
-- L["Default Craft Price Method"] = ""
-- L["Default Material Cost Method"] = ""
L["Default Price"] = "Standardpreis" -- Needs review
-- L["Default Price Settings"] = ""
-- L["Enchant Vellum"] = ""
L["Error creating operation. Operation with name '%s' already exists."] = "Fehler beim Erstellen des Prozesses. Ein Prozess mit Namen '%s' existiert bereits." -- Needs review
L[ [=[Estimated Cost: %s
Estimated Profit: %s]=] ] = [=[Vorrausichtliche Kosten: %s
Vorrausichtlicher Profit: %s]=] -- Needs review
-- L["Exclude Crafts with a Cooldown from Craft Cost"] = ""
L["Filters >>"] = "Filter >>" -- Needs review
-- L["First select a crafter"] = ""
L["Gather"] = "Sammeln" -- Needs review
-- L["Gather All Professions by Default if Only One Crafter"] = ""
L["Gathering"] = "Sammeln"
-- L["Gathering Crafting Mats"] = ""
-- L["Gather Items"] = ""
L["General"] = "Allgemein"
L["General Settings"] = "Allgemeine Einstellungen"
L["Give the new operation a name. A descriptive name will help you find this operation later."] = "Name für den neuen Prozess. Ein beschreibender Name hilft später beim Finden des Prozesses." -- Needs review
L["Guilds (Guild Banks) to Ignore:"] = "Gilden (Gildenbanken), die ignoriert werden:" -- Needs review
L["Here you can view and adjust how Crafting is calculating the price for this material."] = "Hier können Sie einsehen und anpassen wie \"Crafting\" die Preise für dieses Material kalkuliert."
L["<< Hide Queue"] = "<< Warteschlange verstecken" -- Needs review
-- L["If checked, Crafting will never try and craft inks as intermediate crafts."] = ""
-- L["If checked, if there is more than one way to craft the item then the craft cost will exclude any craft with a daily cooldown when calculating the lowest craft cost."] = ""
-- L["If checked, if there is only one crafter for the craft queue clicking gather will gather for all professions for that crafter"] = ""
L["If checked, the crafting cost of items will be shown in the tooltip for the item."] = "Wenn ausgewählt, werden die Herstellungskosten eines Gegenstandes im Tooltip angezeigt"
-- L["If checked, the material cost of items will be shown in the tooltip for the item."] = ""
-- L["If checked, when the TSM_Crafting frame is shown (when you open a profession), the default profession UI will also be shown."] = ""
L["Inventory Settings"] = "Inventareinstellungen"
L["Item Name"] = "Gegenstandsname"
L["Items will only be added to the queue if the number being added is greater than this number. This is useful if you don't want to bother with crafting singles for example."] = "Gegenstände werden nur zur Warteschlange hinzufügt, falls die hinzuzufügende Menge größer als diese Zahl ist. Dies ist beispielsweise praktisch, um die Herstellung einzelner Gegenstände zu vermeiden."
L["Item Value"] = "Wert des Gegenstands" -- Needs review
-- L["Left-Click|r to add this craft to the queue."] = ""
-- L["Link"] = ""
-- L["Mailing Craft Mats to %s"] = ""
-- L["Mail Items"] = ""
-- L["Mat Cost"] = ""
L["Material Cost Options"] = "Materialkosten - Optionen"
-- L["Material Name"] = ""
L["Materials:"] = "Materialien:" -- Needs review
L["Mat Price"] = "Materialpreis"
L["Max Restock Quantity"] = "Maximale herzustellende Menge"
L["Minimum Profit"] = "Mindest-Profit" -- Needs review
L["Min Restock Quantity"] = "Minimal herzustellende menge"
L["Name"] = "Name"
L["Need"] = "Benötigt"
-- L["Needed Mats at Current Source"] = ""
-- L["Never Queue Inks as Sub-Craftings"] = ""
L["New Operation"] = "Neuer Prozess" -- Needs review
-- L["<None>"] = ""
-- L["No Thanks"] = ""
-- L["Nothing To Gather"] = ""
-- L["Nothing to Mail"] = ""
-- L["Now select your profession(s)"] = ""
L["Number Owned"] = "Anzahl in Besitz"
-- L["Opens the Crafting window to the first profession."] = ""
L["Operation Name"] = "Prozessname" -- Needs review
L["Operations"] = "Prozesse" -- Needs review
L["Options"] = "Einstellungen"
-- L["Override Default Craft Price Method"] = ""
L["Percent to subtract from buyout when calculating profits (5% will compensate for AH cut)."] = "Vom Sofortkaufpreis abzuziehende % bei Berechnung des Profits (5% decken die AH Kosten)."
-- L["Please switch to the Shopping Tab to perform the gathering search."] = ""
L["Price:"] = "Preis:"
L["Price Settings"] = "Preiseinstellungen"
-- L["Price Source Filter"] = ""
-- L["Profession data not found for %s on %s. Logging into this player and opening the profression may solve this issue."] = ""
-- L["Profession Filter"] = ""
L["Professions"] = "Berufe" -- Needs review
-- L["Professions Used In"] = ""
L["Profit"] = "Profit"
L["Profit Deduction"] = "Profit abzug"
-- L["Profit (Total Profit):"] = ""
L["Queue"] = "Warteschlange" -- Needs review
-- L["Relationships"] = ""
-- L["Reset All Custom Prices to Default"] = ""
-- L["Reset all Custom Prices to Default Price Source."] = ""
-- L["Resets the material price for this item to the defualt value."] = ""
-- L["Reset to Default"] = ""
-- L["Restocking to a max of %d (min of %d) with a min profit."] = ""
-- L["Restocking to a max of %d (min of %d) with no min profit."] = ""
-- L["Restock Quantity Settings"] = ""
-- L["Restock Selected Groups"] = ""
-- L["Restock Settings"] = ""
-- L["Right-Click|r to subtract this craft from the queue."] = ""
-- L["%s Avail"] = ""
-- L["Search"] = ""
-- L["Search for Mats"] = ""
-- L["Select Crafter"] = ""
-- L["Select one of your characters' professions to browse."] = ""
-- L["Set Minimum Profit"] = ""
-- L["Shift-Left-Click|r to queue all you can craft."] = ""
-- L["Shift-Right-Click|r to remove all from queue."] = ""
L["Show Crafting Cost in Tooltip"] = "Zeige Herstellungskosten im Tooltip"
-- L["Show Default Profession Frame"] = ""
-- L["Show Material Cost in Tooltip"] = ""
L["Show Queue >>"] = "Warteschlange anzeigen >>" -- Needs review
L["'%s' is an invalid operation! Min restock of %d is higher than max restock of %d."] = "'%s' ist eine ungültiger Prozess! Min restock %d ist höher als max restock %d." -- Needs review
L["%s (%s profit)"] = "%s (Profit: %s)" -- Needs review
L["Stage %d"] = "Schritt %d" -- Needs review
-- L["Start Gathering"] = ""
-- L["Stop Gathering"] = ""
-- L["This is the default method Crafting will use for determining craft prices."] = ""
-- L["This is the default method Crafting will use for determining material cost."] = ""
L["Total"] = "Summe"
L["TSM Groups"] = "TSM-Gruppen" -- Needs review
L["Vendor"] = "NPC-Händler"
L["Visit Bank"] = "Bank besuchen"
L["Visit Guild Bank"] = "Gildenbank besuchen"
L["Visit Vendor"] = "Händler besuchen" -- Needs review
L["Warning: The min restock quantity must be lower than the max restock quantity."] = "Warnung: Die minimale Wiederauffüllungsmenge muss kleiner sein als die maximale."
L["When you click on the \"Restock Queue\" button enough of each craft will be queued so that you have this maximum number on hand. For example, if you have 2 of item X on hand and you set this to 4, 2 more will be added to the craft queue."] = "Wenn Sie oft genug auf den \"Restock Queue\" (Warteschlange aufstocken) Kopf drücken, wird jedes Teil in die Warteschlange gesetzt, sodass Sie die maximale (herstellbare) Anzahl vorrätig haben. Zum Beispiel: Wenn Sie 2 mal Item x vorrätig haben und Sie setzten den Wert auf 4, werden 2 weitere der Herstellungsliste hinzugefügt."
L["Would you like to automatically create some TradeSkillMaster groups for this profession?"] = "Möchtest du das TSM automatisch eine Guppe für diesen Beruf erstellt?" -- Needs review
L["You can click on one of the rows of the scrolling table below to view or adjust how the price of a material is calculated."] = "Auf eine der Reihen in der unteren Tabelle klicken, um die Preisberechnung für ein Material anzuzeigen und zu ändern." -- Needs review
