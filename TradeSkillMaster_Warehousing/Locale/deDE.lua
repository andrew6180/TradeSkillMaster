-- ------------------------------------------------------------------------------ --
--                          TradeSkillMaster_Warehousing                          --
--          http://www.curse.com/addons/wow/tradeskillmaster_warehousing          --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- TradeSkillMaster_Warehousing Locale - deDE
-- Please use the localization app on CurseForge to update this
-- http://wow.curseforge.com/addons/TradeSkillMaster_Warehousing/localization/

local L = LibStub("AceLocale-3.0"):NewLocale("TradeSkillMaster_Warehousing", "deDE")
if not L then return end

L["1) Open up a bank (either the gbank or personal bank)"] = "1) Öffnet eine Bank (entweder Gildenbank oder persönliche Bank)" -- Needs review
L["1) Select Operations on the left menu and type a name in the textbox labeled \"Operation Name\", hit okay"] = "1) Wählt Operationen im linken Menü aus, schreibt einen Namen in das Eingabefeld \"Operationsname\" und drückt dann Okay" -- Needs review
L["2) You can delete an operation by selecting the operation and then under Operation Management click the button labelled \"Delete Operation\". "] = "2) Ihr könnt eine Operation löschen, indem Ihr sie auswählt und dann unter Operationsverwaltung auf den Button \"Operation löschen\" klickt." -- Needs review
L["2) You should see a window on your right with a list of groups"] = "2) Auf der rechten Seite solltet Ihr ein Fenster mit einer Liste von Gruppen sehen" -- Needs review
L["3) Select one or more groups and hit either %s or %s"] = "3) Wählt eine oder mehrere Gruppen aus und drückt entweder %s oder %s" -- Needs review
L["Bank UI"] = "Bank-UI" -- Needs review
L["Canceled"] = "Abgebrochen" -- Needs review
L["Displays realtime move data."] = "Zeigt Verschiebungsdaten in Echtzeit an." -- Needs review
L["Empty Bags"] = "Taschen leeren"
L["Empty Bags/Restore Bags"] = "Taschen leeren/Taschen wiederherstellen"
L["Enable Restock"] = "Aktiviere Auffüllen" -- Needs review
L["Enable this to set the quantity to keep back in your bags"] = "Aktiviert dies, um eine Menge setzen zu können, die in Euren Taschen behalten werden soll." -- Needs review
L["Enable this to set the quantity to keep back in your bank / guildbank"] = "Aktiviert dies, um eine Menge setzen zu können, die in Eurer Bank / Gildenbank behalten werden soll." -- Needs review
L["Enable this to set the quantity to move, if disabled Warehousing will move all of the item"] = "Aktiviert dies, um eine Menge setzen zu können, die verschoben werden soll. Ist es deaktiviert, wird Warehousing alles von dem Gegenstand verschieben." -- Needs review
L["Enable this to set the restock quantity"] = "Aktiviert dies, um die Auffüllmenge zu setzen." -- Needs review
L["Error creating operation. Operation with name '%s' already exists."] = "Fehler beim Erstellen der Operation. Die Operation mit dem Namen '%s' existiert bereits." -- Needs review
L["Example 1: /tsm get glyph 20 - get up to 20 of each item in your bank/guildbank where the name contains\"glyph\" and place them in your bags."] = "Beispiel 1: /tsm get glyphe 20 - nimmt bis zu 20 von jedem Gegenstand aus Eurer Bank / Gildenbank, dessen Name \"glyphe\" enthält, und platziert sie in Euren Taschen." -- Needs review
L["Example 2: /tsm put 74249 - get all of item 74249 (Spirit Dust) from your bags and put them in your bank/guildbank"] = "Beispiel 2: /tsm put 74249 - nimmt alles vom Gegenstand 74249 (Geisterstaub) aus Euren Taschen und setzt sie in Eurer Bank / Gildenbank." -- Needs review
L["General"] = "Allgemein" -- Needs review
L["Gets items from the bank or guild bank matching the itemstring, itemID or partial text entered."] = "Nimmt Gegenstände aus der Bank oder Gildenbank, die mit itemString, itemID oder mit dem eingegebenen Teil des Textes übereinstimmen." -- Needs review
L["Give the new operation a name. A descriptive name will help you find this operation later."] = "Gebt der neuen Operation einen Namen. Ein beschreibender Name wird Euch helfen, diese Operation später wiederzufinden." -- Needs review
L["Help"] = "Hilfe" -- Needs review
L["Invalid criteria entered."] = "Ungültige Kriterien eingetragen." -- Needs review
L["Keep in Bags Quantity"] = "In den Taschen zu behaltende Menge" -- Needs review
L["Keep in Bank/GuildBank Quantity"] = "In der Bank/Gildenbank zu behaltende Menge" -- Needs review
L["Move Data has been turned off"] = "Verschiebungsdaten wurden ausgeschalten" -- Needs review
L["Move Data has been turned on"] = "Verschiebungsdaten wurden eingeschalten" -- Needs review
L["Move Group To Bags"] = "Gruppe in Taschen verschieben"
L["Move Group To Bank"] = "Gruppe in die Bank verschieben"
L["Move Quantity"] = "Zu Verschiebende Menge" -- Needs review
L["Move Quantity Settings"] = "Einstellungen zum Verschieben der Menge" -- Needs review
L["New Operation"] = "Neue Operation" -- Needs review
L["Nothing to Move"] = "Nichts zu verschieben" -- Needs review
L["Nothing to Restock"] = "Nichts aufzufüllen" -- Needs review
L["Operation Name"] = "Operationsname" -- Needs review
L["Operations"] = "Operationen" -- Needs review
L["Preparing to Move"] = "Bereite zum Verschieben vor" -- Needs review
L["Puts items matching the itemstring, itemID or partial text entered into the bank or guild bank."] = "Setzt Gegenstände in die Bank oder Gildenbank, die mit itemString, itemID oder mit dem eingegebenen Teil des Textes übereinstimmen." -- Needs review
L["Relationships"] = "Beziehungen" -- Needs review
L["Restock Bags"] = "Taschen auffüllen" -- Needs review
L["Restocking"] = "Auffüllen" -- Needs review
L["Restock Quantity"] = "Auffüllmenge" -- Needs review
L["Restock Settings"] = "Auffüll-Einstellungen" -- Needs review
L["Restore Bags"] = "Taschen wiederherstellen"
L["Set Keep in Bags Quantity"] = "Setze behaltende Taschenmenge"
L["Set Keep in Bank Quantity"] = "Setze behaltende Bankmenge"
L["Set Move Quantity"] = "Setze zu verschiebende Menge"
L["'%s' has a Warehousing operation of '%s' which no longer exists."] = "'%s' hat eine Warehousing-Operation von '%s', die nicht mehr existiert." -- Needs review
L["Simply hit empty bags, warehousing will remember what you had so that when you hit restore, it will grab all those items again. If you hit empty bags while your bags are empty it will overwrite the previous bag state, so you will not be able to use restore."] = "Drückt einfach 'Taschen leeren' - Warehousing wird sich merken, was Ihr hattet. Sobald Ihr 'Wiederherstellen' drückt, wird es wieder auf diese Gegenstände zurückgreifen. Drückt Ihr 'Taschen leeren', während Eure Taschen leer sind, wird der vorherige Taschenzustand überschrieben, wodurch Ihr sie nicht mehr wiederherstellen könnt." -- Needs review
L["Slash Commands"] = "Schrägstrich-Befehle" -- Needs review
L["There are no visible banks."] = "Es gibt keine sichtbaren Bänke." -- Needs review
L["To create a Warehousing Operation"] = "Um eine Warehousing-Operation zu erstellen" -- Needs review
L["To move a Group"] = "Um eine Gruppe zu verschieben" -- Needs review
L["/tsm get/put X Y - X can be either an itemID, ItemLink (shift-click item) or partial text. Y is optionally the quantity you want to move."] = "/tsm get/put X Y - X kann entweder ItemID, ItemLink (Umschalt-Klick auf Gegenstand) oder ein Teil des Textes sein. Y ist eine optionale Menge, die Ihr verschieben wollt." -- Needs review
L["Warehousing operations contain settings for moving the items in a group. Type the name of the new operation into the box below and hit 'enter' to create a new Warehousing operation."] = "Warehousing-Operationen enthalten Einstellungen, um die Gegenstände in eine Gruppe zu verschieben. Schreibt den Namen der neuen Operation in das Eingabefeld unten und drückt ENTER, um eine neue Warehousing-Operation zu erstellen." -- Needs review
L["Warehousing will ensure this number remain in your bags when moving items to the bank / guildbank."] = "Warehousing wird sichergehen, dass diese Anzahl in Euren Taschen bleibt, wenn Gegenstände in die Bank / Gildenbank verschoben werden." -- Needs review
L["Warehousing will ensure this number remain in your bank / guildbank when moving items to your bags."] = "Warehousing wird sichergehen, dass diese Anzahl in Eurer Bank / Gildenbank bleibt, wenn Gegenstände in Euren Taschen verschoben werden." -- Needs review
L["Warehousing will move all of the items in this group."] = "Warehousing wird alles von den Gegenständen in diese Gruppe verschieben." -- Needs review
L["Warehousing will move all of the items in this group keeping %d of each item back when bags > bank/gbank."] = "Warehousing wird alles von den Gegenständen in diese Gruppe verschieben, und behält %d von jedem Gegenstand, wenn Taschen größer als Bank/GBank sind." -- Needs review
L["Warehousing will move all of the items in this group keeping %d of each item back when bags > bank/gbank, %d of each item back when bank/gbank > bags."] = "Warehousing wird alles von den Gegenständen in diese Gruppe verschieben, und behält %d von jedem Gegenstand, wenn Taschen größer als Bank/GBank sind, und %d von jedem Gegenstand, wenn Bank/GBank größer als Taschen sind." -- Needs review
L["Warehousing will move all of the items in this group keeping %d of each item back when bags > bank/gbank, %d of each item back when bank/gbank > bags. Restock will maintain %d items in your bags."] = "Warehousing wird alles von den Gegenständen in diese Gruppe verschieben, und behält %d von jedem Gegenstand, wenn Taschen größer als Bank/GBank sind, und %d von jedem Gegenstand, wenn Bank/GBank größer als Taschen sind. Das Auffüllen wird %d Gegenstände in Euren Taschen aufrechterhalten." -- Needs review
L["Warehousing will move all of the items in this group keeping %d of each item back when bags > bank/gbank. Restock will maintain %d items in your bags."] = "Warehousing wird alles von den Gegenständen in diese Gruppe verschieben, und behält %d von jedem Gegenstand, wenn Taschen größer als Bank/GBank sind. Das Auffüllen wird %d Gegenstände in Euren Taschen aufrechterhalten." -- Needs review
L["Warehousing will move all of the items in this group keeping %d of each item back when bank/gbank > bags."] = "Warehousing wird alles von den Gegenständen in diese Gruppe verschieben, und behält %d von jedem Gegenstand, wenn Bank/GBank größer als Taschen sind." -- Needs review
L["Warehousing will move all of the items in this group keeping %d of each item back when bank/gbank > bags. Restock will maintain %d items in your bags."] = "Warehousing wird alles von den Gegenständen in diese Gruppe verschieben, und behält %d von jedem Gegenstand, wenn Bank/GBank größer als Taschen sind. Das Auffüllen wird %d Gegenstände in Euren Taschen aufrechterhalten." -- Needs review
L["Warehousing will move all of the items in this group. Restock will maintain %d items in your bags."] = "Warehousing wird alles von den Gegenständen in diese Gruppe verschieben. Das Auffüllen wird %d Gegenstände in Euren Taschen aufrechterhalten." -- Needs review
L["Warehousing will move a max of %d of each item in this group."] = "Warehousing wird maximal %d von jedem Gegenstand in diese Gruppe verschieben." -- Needs review
L["Warehousing will move a max of %d of each item in this group keeping %d of each item back when bags > bank/gbank."] = "Warehousing wird maximal %d von jedem Gegenstand in diese Gruppe verschieben, und behält %d von jedem Gegenstand, wenn Taschen größer als Bank/GBank sind." -- Needs review
L["Warehousing will move a max of %d of each item in this group keeping %d of each item back when bags > bank/gbank, %d of each item back when bank/gbank > bags."] = "Warehousing wird maximal %d von jedem Gegenstand in diese Gruppe verschieben, und behält %d von jedem Gegenstand, wenn Taschen größer als Bank/GBank sind, und %d von jedem Gegenstand, wenn Bank/GBank größer als Taschen sind." -- Needs review
L["Warehousing will move a max of %d of each item in this group keeping %d of each item back when bags > bank/gbank, %d of each item back when bank/gbank > bags. Restock will maintain %d items in your bags."] = "Warehousing wird maximal %d von jedem Gegenstand in diese Gruppe verschieben, und behält %d von jedem Gegenstand, wenn Taschen größer als Bank/GBank sind, und %d von jedem Gegenstand, wenn Bank/GBank größer als Taschen sind. Das Auffüllen wird %d Gegenstände in Euren Taschen aufrechterhalten." -- Needs review
L["Warehousing will move a max of %d of each item in this group keeping %d of each item back when bags > bank/gbank. Restock will maintain %d items in your bags."] = "Warehousing wird maximal %d von jedem Gegenstand in diese Gruppe verschieben, und behält %d von jedem Gegenstand, wenn Taschen größer als Bank/GBank sind. Das Auffüllen wird %d Gegenstände in Euren Taschen aufrechterhalten." -- Needs review
L["Warehousing will move a max of %d of each item in this group keeping %d of each item back when bank/gbank > bags."] = "Warehousing wird maximal %d von jedem Gegenstand in diese Gruppe verschieben, und behält %d von jedem Gegenstand, wenn Bank/GBank größer als Taschen sind." -- Needs review
L["Warehousing will move a max of %d of each item in this group keeping %d of each item back when bank/gbank > bags. Restock will maintain %d items in your bags."] = "Warehousing wird maximal %d von jedem Gegenstand in diese Gruppe verschieben, und behält %d von jedem Gegenstand, wenn Bank/GBank größer als Taschen sind. Das Auffüllen wird %d Gegenstände in Euren Taschen aufrechterhalten." -- Needs review
L["Warehousing will move a max of %d of each item in this group. Restock will maintain %d items in your bags."] = "Warehousing wird maximal %d von jedem Gegenstand in diese Gruppe verschieben. Das Auffüllen wird %d Gegenstände in Euren Taschen aufrechterhalten." -- Needs review
L["Warehousing will move this number of each item"] = "Warehousing wird diese Anzahl von jedem Gegenstand verschieben." -- Needs review
L["Warehousing will restock your bags up to this number of items"] = "Warehousing wird Eure Taschen bis zu dieser Anzahl von Gegenständen auffüllen." -- Needs review
L["Warehousing will try to get the right number of items, if there are not enough in the bank to fill out the order, it will grab all that there is."] = "Warehousing wird versuchen, die korrekte Anzahl von Gegenständen zu nehmen. Wenn die Menge in der Bank nicht mehr ausreicht, um die Menge in der Tasche zu füllen, wird Warehousing die verbleibende Menge nehmen." -- Needs review
L["You can toggle the Bank UI by typing the command "] = "Mit dem folgenden Befehl könnt die Bank-UI umschalten: "
L["You can use the following slash commands to get items from or put items into your bank or guildbank."] = "Ihr könnt die folgenden Schrägstrich-Befehle verwenden, um die Gegenstände in Eurer Bank / Gildenbank rauszunehmen oder einzufügen." -- Needs review
