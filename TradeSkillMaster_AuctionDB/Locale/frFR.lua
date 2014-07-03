-- ------------------------------------------------------------------------------ --
--                           TradeSkillMaster_AuctionDB                           --
--           http://www.curse.com/addons/wow/tradeskillmaster_auctiondb           --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- TradeSkillMaster_AuctionDB Locale - frFR
-- Please use the localization app on CurseForge to update this
-- http://wow.curseforge.com/addons/TradeSkillMaster_AuctionDB/localization/

local L = LibStub("AceLocale-3.0"):NewLocale("TradeSkillMaster_AuctionDB", "frFR")
if not L then return end

L["A full auction house scan will scan every item on the auction house but is far slower than a GetAll scan. Expect this scan to take several minutes or longer."] = "Une analyse complète de l'Hôtel des ventes examinera tous les objets de l'hôtel des ventes mais est beaucoup plus lente que la méthode du GetAll. Attendez-vous à ce que cette analyse dure de nombreuses minutes."
-- L["A GetAll scan is the fastest in-game method for scanning every item on the auction house. However, there are many possible bugs on Blizzard's end with it including the chance for it to disconnect you from the game. Also, it has a 15 minute cooldown."] = ""
L["Any items in the AuctionDB database that contain the search phrase in their names will be displayed."] = "Tout objets présent dans la base de donnée d'AuctionDB contenant la phrase recherchée dans son nom sera affiché."
L["Are you sure you want to clear your AuctionDB data?"] = "Êtes-vous sûr de vouloir vider les données d'AuctionDB?"
L["Ascending"] = "Croissant"
L["AuctionDB - Market Value"] = "AuctionDB - Valeur du Marché"
L["AuctionDB - Minimum Buyout"] = "AuctionDB - Achat minimum"
-- L["Can't run a GetAll scan right now."] = ""
L["Descending"] = "Décroissant"
-- L["Display lowest buyout value seen in the last scan in tooltip."] = ""
-- L["Display market value in tooltip."] = ""
-- L["Display number of items seen in the last scan in tooltip."] = ""
-- L["Display total number of items ever seen in tooltip."] = ""
L["Done Scanning"] = "Analyse terminée"
-- L["Download the FREE TSM desktop application which will automatically update your TSM_AuctionDB prices using Blizzard's online APIs (and does MUCH more). Visit %s for more info and never scan the AH again! This is the best way to update your AuctionDB prices."] = ""
L["Enable display of AuctionDB data in tooltip."] = "Activer l'affichage des données d'AuctionDB dans les info-bulles."
-- L["GetAll scan did not run successfully due to issues on Blizzard's end. Using the TSM application for your scans is recommended."] = ""
L["Hide poor quality items"] = "Masquer les objets gris"
L["If checked, poor quality items won't be shown in the search results."] = "Si coché, les objets gris ne seront pas affiché lors de la recherche."
-- L["If checked, the lowest buyout value seen in the last scan of the item will be displayed."] = ""
-- L["If checked, the market value of the item will be displayed"] = ""
-- L["If checked, the number of items seen in the last scan will be displayed."] = ""
-- L["If checked, the total number of items ever seen will be displayed."] = ""
-- L["Imported %s scans worth of new auction data!"] = ""
L["Invalid value entered. You must enter a number between 5 and 500 inclusive."] = "Valeur non valide. Vous devez entrer un nombre entre 5 et 500 inclus."
L["Item Link"] = "Lien de l'objet"
L["Item MinLevel"] = "Niveau min. de l'objet"
L["Items per page"] = "Objets par page"
L["Items %s - %s (%s total)"] = "Objets %s - %s (%s au total)"
L["Item SubType Filter"] = "Sous-catégorie de l'objet"
L["Item Type Filter"] = "Catégorie de l'objet"
L["It is strongly recommended that you reload your ui (type '/reload') after running a GetAll scan. Otherwise, any other scans (Post/Cancel/Search/etc) will be much slower than normal."] = "Il est fortement recommandé que vous rechargez votre interface (tapez '/reload') après une analyse GetAll. Sinon, toutes les autres analyses (Poster/Annuler/Rechercher/etc) vont être plus longue que d'habitude."
L["Last Scanned"] = "Dernière fois analysé"
-- L["Last updated from in-game scan %s ago."] = ""
-- L["Last updated from the TSM Application %s ago."] = ""
L["Market Value"] = "Prix du  Marché"
L["Market Value:"] = "Valeur du marché:" -- Needs review
L["Market Value x%s:"] = "Valeur du marché x%s:" -- Needs review
L["Min Buyout:"] = "Achat min:" -- Needs review
L["Min Buyout x%s:"] = "Achat min x%s:" -- Needs review
L["Minimum Buyout"] = "Prix d'achat Minimum"
L["Next Page"] = "Page suivante"
L["No items found"] = "Aucun objet trouvé"
L["No scans found."] = "Aucun scan trouvé." -- Needs review
L["Not Ready"] = "Non prêt"
-- L["Not Scanned"] = ""
L["Num(Yours)"] = "Num(Les vôtres)"
L["Options"] = "Options"
L["Previous Page"] = "Page précédente"
-- L["Processing data..."] = ""
L["Ready"] = "Prêt"
L["Ready in %s min and %s sec"] = "Prêt dans %s min et %s sec"
L["Refreshes the current search results."] = "Actualise les résultats de recherche actuels."
L["Removed %s from AuctionDB."] = "Suppresion %s d'AuctionDB."
L["Reset Data"] = "Réinitialiser les données"
L["Resets AuctionDB's scan data"] = "Réinitialise les données d'AuctionDB"
-- L["Result Order:"] = ""
L["Run Full Scan"] = "Analyse complète"
L["Run GetAll Scan"] = "Analyse GetAll"
-- L["Running query..."] = ""
L["%s ago"] = "Il y a %s"
L["Scanning page %s/%s"] = "Scan de la page %s/%s" -- Needs review
L["Scanning the auction house in game is no longer necessary!"] = "Scanner l'hôtel des ventes dans le jeu n'est plus nécessaire !" -- Needs review
L["Search"] = "Rechercher"
L["Search Options"] = "Options de recherche"
-- L["Seen Last Scan:"] = ""
L["Select how you would like the search results to be sorted. After changing this option, you may need to refresh your search results by hitting the \"Refresh\" button."] = "Choisissez comment vous voulez que les objets soient trié. Après avoir changé cette option, cliquez sur \"Actualiser\" pour mettre à jour le mode de tri."
-- L["Select whether to sort search results in ascending or descending order."] = ""
L["Shift-Right-Click to clear all data for this item from AuctionDB."] = "Maj-clic droit pour effacer toutes les données d'AuctionDB pour cet objet."
L["Sort items by"] = "Trier les objets par"
L["This determines how many items are shown per page in results area of the \"Search\" tab of the AuctionDB page in the main TSM window. You may enter a number between 5 and 500 inclusive. If the page lags, you may want to decrease this number."] = "Ceci détermine combien d'objets seront affiché par page dans l'onglet de Recherche d'AuctionDB. Vous pouvez entrer un nombre entre 5 et 500 inclus. Si vous subissez quelques lags, baissez ce nombre."
-- L["Total Seen Count:"] = ""
L["Use the search box and category filters above to search the AuctionDB data."] = "Utilisez le champs de recherche ainsi que le tri par catégorie pour faire une recherche dans les données d'AuctionDB."
L["You can filter the results by item subtype by using this dropdown. For example, if you want to search for all herbs, you would select \"Trade Goods\" in the item type dropdown and \"Herbs\" in this dropdown."] = "Vous pouvez filtrez les résultats en utilisant cette option. Par exemple, si vous voulez chercher toute les herbes, vous choisiriez \"Artisanat\" dans la catégorie puis \"Herbes\" dans la sous catégorie."
L["You can filter the results by item type by using this dropdown. For example, if you want to search for all herbs, you would select \"Trade Goods\" in this dropdown and \"Herbs\" as the subtype filter."] = "Vous pouvez filtrez les résultats en utilisant cette option. Par exemple, si vous voulez chercher toute les herbes, vous choisiriez \"Artisanat\" dans la catégorie puis \"Herbes\" dans la sous catégorie."
L["You can use this page to lookup an item or group of items in the AuctionDB database. Note that this does not perform a live search of the AH."] = "Vous pouvez utiliser cette page pour cherche un objet ou un groupe d'objets dans la base de donnée d'AuctionDB. Notez que ca ne lance pas une analyse en direct de 'HV, mais ne fait que parcourir la base de donnée de AuctionDB."
 