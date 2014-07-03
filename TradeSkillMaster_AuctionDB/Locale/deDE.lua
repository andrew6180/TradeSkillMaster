-- ------------------------------------------------------------------------------ --
--                           TradeSkillMaster_AuctionDB                           --
--           http://www.curse.com/addons/wow/tradeskillmaster_auctiondb           --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- TradeSkillMaster_AuctionDB Locale - deDE
-- Please use the localization app on CurseForge to update this
-- http://wow.curseforge.com/addons/TradeSkillMaster_AuctionDB/localization/

local L = LibStub("AceLocale-3.0"):NewLocale("TradeSkillMaster_AuctionDB", "deDE")
if not L then return end

L["A full auction house scan will scan every item on the auction house but is far slower than a GetAll scan. Expect this scan to take several minutes or longer."] = "Ein voller Auktionshausscan wird jedes einzelne Item im Auktionshaus scannen, ist aber sehr viel langsamer als der GetAll-Scan. Erwarte, dass es mehrere Minuten dauert oder länger."
L["A GetAll scan is the fastest in-game method for scanning every item on the auction house. However, there are many possible bugs on Blizzard's end with it including the chance for it to disconnect you from the game. Also, it has a 15 minute cooldown."] = "Ein GetAll-Scan ist die schnellste Methode, um in-game alle Gegenstände im Auktionshaus zu scannen. Allerdings gibt es viele mögliche Bugs seitens Blizzard die auftreten können, inklusive der Möglichkeit, dass deine Verbindung zum Spiel getrennt wird. Außerdem gibt es einen 15-Minuten-Cooldown."
L["Any items in the AuctionDB database that contain the search phrase in their names will be displayed."] = "Es werden alle Gegenstände in der \"AuctionDB\" Datenbank angezeigt, deren Namen mit der Sucheingabe übereinstimmen."
L["Are you sure you want to clear your AuctionDB data?"] = "Sind Sie sicher, dass Sie die \"AuctionDB\" Daten löschen wollen?"
L["Ascending"] = "Aufsteigend"
L["AuctionDB - Market Value"] = "AuctionDB - Marktwert"
L["AuctionDB - Minimum Buyout"] = "AuctionDB - Mindestpreis"
L["Can't run a GetAll scan right now."] = "Kann im Moment keinen GetAll Scan durchführen."
L["Descending"] = "Absteigend"
L["Display lowest buyout value seen in the last scan in tooltip."] = "Zeige den niedrigsten Sofortkauf-Betrag aus dem letzten Scan im Tooltip."
L["Display market value in tooltip."] = "Zeige Marktwert im Tooltip."
L["Display number of items seen in the last scan in tooltip."] = "Zeige Anzahl der gefundenen Gegenstände vom letzten Scan im Tooltip."
L["Display total number of items ever seen in tooltip."] = "Zeige Gesamtzahl der je gefundenen Gegenstände im Tooltip."
L["Done Scanning"] = "Scannen beendet"
L["Download the FREE TSM desktop application which will automatically update your TSM_AuctionDB prices using Blizzard's online APIs (and does MUCH more). Visit %s for more info and never scan the AH again! This is the best way to update your AuctionDB prices."] = "Lade die KOSTENLOSE TSM Desktopsoftware herunter die automatisch deine TSM_AuctionDB mit den Preisen aus Blizzard's online API aktualisiert (und noch VIEL mehr kann). Besuche %s für weitere Informationen und scanne das AH nie wieder! Dies ist die beste Art deine AuctionDB Preise aktuell zu halten."
L["Enable display of AuctionDB data in tooltip."] = "Aktiviere die Anzeige der AuctionDB-Daten im Tooltip."
L["GetAll scan did not run successfully due to issues on Blizzard's end. Using the TSM application for your scans is recommended."] = "GetAll scan nicht erfolgreich aufgrund von Problemen bei Blizzard. Nutzung der TSM Software für deinen Scan wird empfohlen."
L["Hide poor quality items"] = "Verstecke Gegenstände schlechter Qualität"
L["If checked, poor quality items won't be shown in the search results."] = "Wenn markiert, tauchen Gegenstände schlechter Qualität nicht in den Suchergebnissen auf."
L["If checked, the lowest buyout value seen in the last scan of the item will be displayed."] = "Wenn ausgewählt, wird der niedrigste Sofortkaufpreis der im letzten Scan gefunden wurde angezeigt."
L["If checked, the market value of the item will be displayed"] = "Wenn ausgewählt wird der Marktwert des Gegenstands angezeigt."
L["If checked, the number of items seen in the last scan will be displayed."] = "Wenn ausgewählt wird die Anzahl der gefundenen Gegestände vom letzten Scan angezeigt."
L["If checked, the total number of items ever seen will be displayed."] = "Wenn ausgewählt wird die Anzahl der jemals gefundenen Gegenstände angezeigt."
L["Imported %s scans worth of new auction data!"] = "%s Scans mit neuen Auktionsdaten importiert!"
L["Invalid value entered. You must enter a number between 5 and 500 inclusive."] = "Eingebener Wert ist ungültig. Sie müssen eine Zahl zwischen 5 und 500 eingeben."
L["Item Link"] = "Gegenstands-Link"
L["Item MinLevel"] = "Gegenstand MinLevel"
L["Items per page"] = "Gegenstände pro Seite"
L["Items %s - %s (%s total)"] = "Gegenstände %s - %s (%s gesamt)"
L["Item SubType Filter"] = "Gegenstands-Unterkategorie-Filter"
L["Item Type Filter"] = "Gegenstands-Kategorie-Filter"
L["It is strongly recommended that you reload your ui (type '/reload') after running a GetAll scan. Otherwise, any other scans (Post/Cancel/Search/etc) will be much slower than normal."] = "Es wird sehr empfohlen, dass du die UI neu lädst (tippe \"/reload\"), nachdem du einen GetAll-Scan gemacht hast. Sonst werden andere Scans (Posten/Abbrechen/Suchen/etc) sehr viel langsamer als Normal laufen."
L["Last Scanned"] = "Zuletzt gescannt"
L["Last updated from in-game scan %s ago."] = "Zuletzt aktualisiert durch in-game Scan vor %s"
L["Last updated from the TSM Application %s ago."] = "Zuletzt aktualisiert durch TSM-Applikation vor %s"
L["Market Value"] = "Marktwert"
L["Market Value:"] = "Marktwert:"
L["Market Value x%s:"] = "Marktwert x%s:"
L["Min Buyout:"] = "Mindest-Sofortkauf:" -- Needs review
L["Min Buyout x%s:"] = "Min. Sofortkauf x%s:" -- Needs review
L["Minimum Buyout"] = "Minimaler Sofortkaufpreis"
L["Next Page"] = "Nächste Seite"
L["No items found"] = "Keine Gegenstände gefunden"
L["No scans found."] = "Keine Scans gefunden."
L["Not Ready"] = "Nicht bereit"
L["Not Scanned"] = "Nicht gescannt"
L["Num(Yours)"] = "Num(Deine)"
L["Options"] = "Optionen"
L["Previous Page"] = "Vorherige Seite"
L["Processing data..."] = "Verarbeite Daten..."
L["Ready"] = "Bereit"
L["Ready in %s min and %s sec"] = "Bereit in %s Minuten und %s Sekunden"
L["Refreshes the current search results."] = "Aktualisiert die derzeitigen Suchergebnisse."
L["Removed %s from AuctionDB."] = "%s von AuctionDB entfernt."
L["Reset Data"] = "Daten zurücksetzen"
L["Resets AuctionDB's scan data"] = "Setzt die Scandaten der \"AuctionDB\" zurück"
L["Result Order:"] = "Reihenfolge der Ergebnisse:"
L["Run Full Scan"] = "Starte einen vollen Scan"
L["Run GetAll Scan"] = "Starte Komplettscan"
L["Running query..."] = "Abfrage läuft..."
L["%s ago"] = "Vor %s"
L["Scanning page %s/%s"] = "Scanne Seite %s/%s"
L["Scanning the auction house in game is no longer necessary!"] = "In-Game-Scan des Auktionshauses ist nicht mehr erforderlich!" -- Needs review
L["Search"] = "Suche"
L["Search Options"] = "Suchoptionen"
L["Seen Last Scan:"] = "Zuletzt gesehen:" -- Needs review
L["Select how you would like the search results to be sorted. After changing this option, you may need to refresh your search results by hitting the \"Refresh\" button."] = "Wählen Sie aus, wie die Suchergebnisse sortiert werden sollen. Nach Ändern der Option kann es notwendig sein Ihre Suchergebnisse zu aktualisieren, indem Sie den \"Aktualisieren\"-Button drücken."
L["Select whether to sort search results in ascending or descending order."] = "Wähle, ob die Suchergebnisse aufsteigend oder absteigend sortiert werden sollen."
L["Shift-Right-Click to clear all data for this item from AuctionDB."] = "Shift-Rechtsklick um alle Daten für das Item aus AuctionDB zu löschen."
L["Sort items by"] = "Sortiere Gegenstände nach"
L["This determines how many items are shown per page in results area of the \"Search\" tab of the AuctionDB page in the main TSM window. You may enter a number between 5 and 500 inclusive. If the page lags, you may want to decrease this number."] = "Dies bestimmt wieviele Gegenstände pro Seite im Ergebnisbereich des \"Suche\"-Reiters der \"AuctionDB\" im TSM Hauptfenster angezeigt werden. Sie können eine Zahl zwischen 5 und 500 eingeben. Wenn die Seite Verzögerungen verursacht, wäre es ratsam die Anzahl zu reduzieren."
L["Total Seen Count:"] = "Summe insgesamt gesehen:" -- Needs review
L["Use the search box and category filters above to search the AuctionDB data."] = "Benutzen Sie die Sucheingabe und Kategorie-Filter oben um die \"AuctionDB\"-Daten zu durchsuchen."
L["You can filter the results by item subtype by using this dropdown. For example, if you want to search for all herbs, you would select \"Trade Goods\" in the item type dropdown and \"Herbs\" in this dropdown."] = "Sie können die Ergebnisse eingrenzen, indem Sie eine Gegenstands-Unterkategorie aus der Auswahlliste wählen. Wenn Sie zum Beispiel nach allen Kräutern suchen wollen, würden Sie \"Handwerkswaren\" als Gegenstands-Kategorie wählen und \"Kräuter\" in dieser Auswahlliste."
L["You can filter the results by item type by using this dropdown. For example, if you want to search for all herbs, you would select \"Trade Goods\" in this dropdown and \"Herbs\" as the subtype filter."] = "Sie können die Ergebnisse eingrenzen, indem Sie eine Gegenstands-Kategorie aus der Auswahlliste wählen. Wenn Sie zum Beispiel nach allen Kräutern suchen wollen, würden Sie \"Handwerkswaren\" in dieser Auswahlliste wählen und \"Kräuter\" in der Auswahlliste für die Gegenstands-Unterkategorie."
L["You can use this page to lookup an item or group of items in the AuctionDB database. Note that this does not perform a live search of the AH."] = "Diese Seite können Sie benutzen um Gegenstände oder Gegenstandsgruppe in der \"AuctionDB\"-Datenbank nachzuschlagen. Beachten Sie, dass dies keine Echtzeitsuche für das AH ist."
 