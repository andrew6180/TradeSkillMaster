-- ------------------------------------------------------------------------------ --
--                            TradeSkillMaster_Mailing                            --
--            http://www.curse.com/addons/wow/tradeskillmaster_mailing            --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- TradeSkillMaster_Mailing Locale - deDE
-- Please use the localization app on CurseForge to update this
-- http://wow.curseforge.com/addons/tradeskillmaster_mailing/localization/

local L = LibStub("AceLocale-3.0"):NewLocale("TradeSkillMaster_Mailing", "deDE")
if not L then return end

L[ [=[Automatically rechecks mail every 60 seconds when you have too much mail.

If you loot all mail with this enabled, it will wait and recheck then keep auto looting.]=] ] = [=[Ruft die Post automatisch alle 60 Sekunden ab wenn zu viel Post im Briefkasten ist.

Wenn diese Option aktiviert ist und das automatische Plündern läuft, wird die Entnahme nach den 60 Sekunden fortgesetzt.]=]
L["Auto Recheck Mail"] = "Post automatisch aktualisieren"
L["BE SURE TO SPELL THE NAME CORRECTLY!"] = "VERSICHERE DICH, DASS DER NAME RICHTIG GESCHRIEBEN IST!"
L["Buy: %s (%d) | %s | %s"] = "Kauf: %s (%d) | %s | %s" -- Needs review
L["Cannot finish auto looting, inventory is full or too many unique items."] = "Automatisches Plündern kann nicht beendet werden. Inventar ist voll oder zu viele \"einzigartige\" Gegenstände vorhanden."
L["Chat Message Options"] = "Chatnachricht Optionen" -- Needs review
L["Clear"] = "Löschen" -- Needs review
L["Clears the item box."] = "Löscht Boxinhalt" -- Needs review
L["Click this button to send all disenchantable greens in your bags to the specified character."] = "Klicke diesen Button um alle entzauberbaren grüne Gegenstände an den genannten Charakter zu schicken." -- Needs review
L["Click this button to send excess gold to the specified character."] = "Klicke diesen Button um überschüssiges Gold an den angegeben Charakter zu schicken." -- Needs review
L["Click this button to send off the item to the specified character."] = "Klicke diesen Button um den Gegenstand an den angegenen Charakter zu schicken." -- Needs review
L["COD Amount (per Item):"] = "Nachnahmegebühr (je Gegenstand):" -- Needs review
L["COD: %s | %s | %s | %s"] = "Nachnahme: %s | %s | %s | %s" -- Needs review
L["Collected COD of %s from %s for %s."] = "Nachnahmegebühr in Höhe von %s an %s für %s eingesammelt." -- Needs review
L["Collected expired auction of %s"] = "Abgelaufene Auktion von %s abgeholt." -- Needs review
L["Collected mail from %s with a subject of '%s'."] = "Post von %s mit Betreff '%s' abgeholt." -- Needs review
L["Collected purchase of %s (%d) for %s."] = "Einkauf von %s (%d) für %s abgeholt." -- Needs review
L["Collected sale of %s (%d) for %s."] = "Verkauf von %s (%d) für %s abgeholt." -- Needs review
L["Collected %s and %s from %s."] = "Hole %s und %s von %s ab." -- Needs review
L["Collected %s from %s."] = "%s von %s abgeholt." -- Needs review
L["Collect Gold"] = "Gold Einsammeln" -- Needs review
L["Could not loot item from mail because your bags are full."] = "Kann Gegenstand nicht aus der Post entnehmen weil deine Taschen voll sind." -- Needs review
L["Could not send mail due to not having free bag space available to split a stack of items."] = "Kann keine Post verschicken, da kein freier Taschenplatz vorhanden ist um Gegenstandstapel aufzuteilen." -- Needs review
L["Display Total Money Received"] = "Zeige Gesamtsumme Erhaltenes Gold" -- Needs review
L["Drag (or place) the item that you want to send into this editbox."] = "Ziehe (oder platziere) den Gegenstand den du verschicken möchstest in die Box." -- Needs review
L["Enable Inbox Chat Messages"] = "Erlaube Posteingangsmitteilungen im Chat" -- Needs review
L["Enable Sending Chat Messages"] = "Erlaube Postversandmitteilungen im Chat" -- Needs review
L["Enter name of the character disenchantable greens should be sent to."] = "Gib den Namen des Charakters an den entzauberbare grüne Gegenstände geschickt werden sollen." -- Needs review
L["Enter the desired COD amount (per item) to send this item with. Setting this to '0c' will result in no COD being set."] = "Gib die gewünschte Nachnahmegebühr (je Gegenstand) ein mit der du den Gegenstand verschicken willst. Bei einem Betrag von '0c' wird der Gegenstand ohne Nachnahmegebühr verschickt." -- Needs review
L["Enter the name of the player you want to send excess gold to."] = "Gib den Charakternamen ein an den überschüssiges Gold geschickt werden soll." -- Needs review
L["Enter the name of the player you want to send this item to."] = "Gib den Charakternamen ein an den der Gegenstand geschickt werden soll." -- Needs review
L["Error creating operation. Operation with name '%s' already exists."] = "Fehler beim Erstellen der Operation. Operation mit Namen '%s' existiert bereits." -- Needs review
L["Expired: %s | %s"] = "Abgelaufen: %s | %s" -- Needs review
L["General"] = "Allgemein" -- Needs review
L["General Settings"] = "Allgemeine Einstellungen" -- Needs review
L["Give the new operation a name. A descriptive name will help you find this operation later."] = "Gib der neuen Operation einen Namen. Ein beschreibender Name hilft dir diese später wieder zu finden." -- Needs review
L["If checked, a maxium quantity to send to the target can be set. Otherwise, Mailing will send as many as it can."] = "Wenn markiert wird eine maximale Anzahl an das Ziel gesendet. Andernfalls schickt Mailing so viel wie es kann." -- Needs review
L["If checked, information on mails collected by TSM_Mailing will be printed out to chat."] = "Wenn markiert werden Informationen zu abgeholter Post durch TSM_Mailing im Chat ausgegeben." -- Needs review
L["If checked, information on mails sent by TSM_Mailing will be printed out to chat."] = "Wenn markiert werden Informationen von per TSM_Mailing versendeter Post im Chat ausgegebebn." -- Needs review
L["If checked, the Mailing tab of the mailbox will be the default tab."] = "Wenn markiert wird Mailing zum Standardreiter der Mailbox gemacht." -- Needs review
L["If checked, the 'Open All' button will leave any mail containing gold."] = "Wenn markiert öffnet 'Alle Öffnen' keine Nachrichten, die Gold enthalten." -- Needs review
L["If checked, the target's current inventory will be taken into account when determing how many to send. For example, if the max quantity is set to 10, and the target already has 3, Mailing will send at most 7 items."] = "Wenn markiert wird das aktuelle Inventar des Ziels für die zu schickende Anzahl berücksichtigt. Zum Beispiel wenn die maximale Anzahl auf 10 gesetzt ist und das Ziel bereits 3 Einheiten hat wird Mailing maximal 7 Einheiten verschicken." -- Needs review
L["If checked, the target's guild bank will be included in their inventory for the 'Restock Target to Max Quantity' option."] = "Wenn markiert wird die Gildenbank des Ziels berücksichtigt für die 'Fülle auf maximale Anzahl auf' Option." -- Needs review
L["If checked, the total amount of gold received will be shown at the end of automatically collecting mail."] = "Wenn markiert wird der gesamte erhaltene Goldbetrag anzegeigt nachdem alle Nachrichten automatisch eingesammelt wurden." -- Needs review
L["Inbox"] = "Posteingang" -- Needs review
L["Include Guild Bank in Restock"] = "Gildenbank beim Auffüllen berücksichtigen" -- Needs review
L["Item (Drag Into Box):"] = "Gegenstand (in Box ziehen):" -- Needs review
L["Keep Quantity"] = "Zu behaltende Menge" -- Needs review
L["Leave Gold with Open All"] = "Gold mit alle Öffnen nicht abholen" -- Needs review
L["Limit (In Gold):"] = "Limit (in Gold):" -- Needs review
L["Mail Disenchantables:"] = "Entzauberbares Verschicken:" -- Needs review
L["Mailing all to %s."] = "Alles an %s geschickt." -- Needs review
L["Mailing operations contain settings for easy mailing of items to other characters."] = "Post-Operationen enthalten Einstellungen um einfach Gegenstände an andere Charakter zu verschicken." -- Needs review
L["Mailing up to %d to %s."] = "Schicke maximal %d an %s." -- Needs review
L["Mailing will keep this number of items in the current player's bags and not mail them to the target."] = "Mailing behält diese Anzahl Gegenstände in den Taschen des gegenwärtigen Charakters ohne sie ans Ziel zu schicken." -- Needs review
L["Mail Selected Groups"] = "Ausgewählte Gruppen versenden" -- Needs review
L["Mail Send Delay"] = "Post Sendeverzögerung" -- Needs review
L["Make Mailing Default Mail Tab"] = "Mache Mailing zum Standard Post Tab" -- Needs review
L["Maxium Quantity"] = "Maximale Anzahl:" -- Needs review
L["Max Quantity:"] = "Max. Anzahl:" -- Needs review
L["Multiple Items"] = "Mehrere Gegenstände" -- Needs review
L["New Operation"] = "Neue Operation" -- Needs review
L["Next inbox update in %d seconds."] = "Nächste Aktualisierung des Posteingangs in %d Sekunden." -- Needs review
L["No Item Specified"] = "Kein Gegenstand angegeben" -- Needs review
L["No Quantity Specified"] = "Keine Anzahl angegeben" -- Needs review
L["No Target Player"] = "Kein Zielcharakter" -- Needs review
L["No Target Specified"] = "Kein Ziel angegeben" -- Needs review
L["Not sending any gold as you have less than the specified limit."] = "Gold wird nicht gesendet weil du weniger als den angegebenen Betrag besitzt." -- Needs review
L["Not Target Specified"] = "Kein Ziel angegeben" -- Needs review
L["Open All"] = "Alle öffnen"
L["Operation Name"] = "Name der Operation" -- Needs review
L["Operations"] = "Operationen" -- Needs review
L["Operation Settings"] = "Operationseinstellungen" -- Needs review
L["Options"] = "Einstellungen"
L["Other"] = "Andere" -- Needs review
L["Quick Send"] = "Schnell Senden" -- Needs review
-- L["Relationships"] = ""
L["Reload UI"] = "UI neu laden" -- Needs review
L["Restart Delay (minutes)"] = "Neustart Verzögerung (Minuten)" -- Needs review
L["Restock Target to Max Quantity"] = "Fülle Ziel auf maximale Anzahl auf" -- Needs review
L["Sale: %s (%d) | %s | %s"] = "Verkauf: %s (%d) | %s | %s" -- Needs review
L["Send Disenchantable Greens to %s"] = "Sende entzauberbare grüne Gegenstände an %s" -- Needs review
L["Send Excess Gold to Banker:"] = "Sende überschüssiges Gold an Banker:" -- Needs review
L["Send Excess Gold to %s"] = "Sende überschüssiges Gold an %s." -- Needs review
L["Sending..."] = "Verschicken..." -- Needs review
L["Send Items Individually"] = "Sende Gegenstände individuell." -- Needs review
L["Sends each unique item in a seperate mail."] = "Sende jeden einzigartigen Gegenstand in einem separaten Brief." -- Needs review
L["Send %sx%d to %s - No COD"] = "Sende %sx%d an %s - Keine Nachnahme" -- Needs review
L["Send %sx%d to %s - %s per Item COD"] = "Sende %sx%d an %s - %s Nachnahme je Gegenstand" -- Needs review
L["Sent all disenchantable greens to %s."] = "Verschicke alle entzauberbaren grünen Gegenstände an %s." -- Needs review
L["Sent %s to %s."] = "%s an %s verschickt." -- Needs review
L["Sent %s to %s with a COD of %s."] = "%s an %s mit Nachnahme von %s verschickt." -- Needs review
L["Set Max Quantity"] = "Maximale Anzahl setzen" -- Needs review
L["Sets the maximum quantity of each unique item to send to the target at a time."] = "Setzt die maximal Anzahl eines einzigartigen Gegenstand an das Ziel mit einem Mal." -- Needs review
-- L["Shift-Click to automatically re-send after the amount of time specified in the TSM_Mailing options."] = ""
L["Showing all %d mail."] = "Zeige alle %d Nachrichten." -- Needs review
L["Showing %d of %d mail."] = "Zeige %d von %d Nachrichten." -- Needs review
L["Skipping operation '%s' because there is no target."] = "Überspringe Operation '%s' weil es kein Ziel gibt." -- Needs review
L["%s to collect."] = "%s einzusammeln."
L["%s total gold collected!"] = "%s Gold insgesamt eingesammelt."
L["Target:"] = "Ziel:" -- Needs review
L["Target is Current Player"] = "Ziel ist aktueller Charakter" -- Needs review
L["Target Player"] = "Zielcharakter" -- Needs review
L["Target Player:"] = "Zielcharakter:" -- Needs review
L["The name of the player you want to mail items to."] = "Name des Charakters an den du Gegenstände schicken willst." -- Needs review
L["This is maximum amount of gold you want to keep on the current player. Any amount over this limit will be send to the specified character."] = "Dies ist der maximale Goldbetrag den der aktuelle Charakter behalten soll. Alles Gold darüber wird an den angegebenen Charakter geschickt." -- Needs review
L["This is the maximum number of the specified item to send when you click the button below."] = "Dies ist die maximale Anzahl eines bestimmten Gegenstands der verschickt wird wenn du den Button unten anklickst." -- Needs review
L["This slider controls how long the mail sending code waits between consecutive mails. If this is set too low, you will run into internal mailbox errors."] = "Dieser Regler kontrolliert wie lange zwischen dem Versenden von aufeinanderfolgenden Nachrichten gewartet werden soll. Wenn der Wert zu niedrig ist können interne Mailboxfehler auftreten." -- Needs review
L["This tab allows you to quickly send any quantity of an item to another character. You can also specify a COD to set on the mail (per item)."] = "Dieser Reiter erlaubt es schnell jede beliebige Anzahl an Gegenständen an einen anderen Charakter zu senden. Du kannst auch einen Nachnahmegebühr (je Gegenstand) angeben." -- Needs review
L["TSM Groups"] = "TSM-Gruppen" -- Needs review
L["TSM_Mailing Excess Gold"] = "TSM_Mailing überschüssiges Gold" -- Needs review
-- L["When you shift-click a send mail button, after the initial send, it will check for new items to send at this interval."] = ""
