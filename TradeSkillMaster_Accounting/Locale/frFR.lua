-- ------------------------------------------------------------------------------ --
--                           TradeSkillMaster_Accounting                          --
--           http://www.curse.com/addons/wow/tradeskillmaster_accounting          --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- TradeSkillMaster_Accounting Locale - frFR
-- Please use the localization app on CurseForge to update this
-- http://wow.curseforge.com/addons/TradeSkillMaster_Accounting/localization/

local L = LibStub("AceLocale-3.0"):NewLocale("TradeSkillMaster_Accounting", "frFR")
if not L then return end

-- L["Accounting has not yet collect enough information for this tab. This is likely due to not having recorded enough data points or not seeing any significant fluctuations (over 1k gold) in your gold on hand."] = ""
L["Activity Type"] = "Type d'activité"
L["All"] = "Tous"
L["Aucs"] = "Ench"
L["Average Prices:"] = "Prix moyens :"
L["Avg Buy Price"] = "Prix d'achat moyen"
L["Avg Resale Profit"] = "Profit de revente moyen"
L["Avg Sell Price"] = "Prix de vente moyen"
L["Back to Previous Page"] = "Retour à la page précédente"
-- L["Balance"] = ""
--[==[ L[ [=[Below is a graph of the current character's gold on hand over time.

The x-axis is time and goes from %s to %s
The y-axis is thousands of gold.]=] ] = "" ]==]
L["Bought"] = "Acheté"
L["Buyer/Seller"] = "Acheteur/Vendeur"
L["Cancelled"] = "Annulé" -- Needs review
-- L["Cancelled Since Last Sale:"] = ""
L["Clear Old Data"] = "Supprimer les anciennes données"
L["Click for a detailed report on this item."] = "Cliquez pour un rapport détaillé sur cet objet"
L["Click this button to permanently remove data older than the number of days selected in the dropdown."] = "Cliquez sur ce bouton pour supprimer définitivement les données supérieures au nombre de jours sélectionnés dans la liste déroulante."
L["Cost"] = "Coût" -- Needs review
L["Data older than this many days will be deleted when you click on the button to the right."] = "Les données plus anciennes que ce nombre de jours seront supprimées lorsque vous cliquerez sur le bouton situé à droite."
L["Days:"] = "Jours : "
L["DD/MM/YY HH:MM"] = "JJ/MM/AA HH:MM "
L["Display Grey Items in Sales"] = "Afficher les items médiocres dans les ventes" -- Needs review
L["Don't prompt to record trades"] = "Ne pas demander d'enregistrer les échanges."
L["Earned Per Day:"] = "Gagné par jour :"
-- L["Expenses"] = ""
L["Expired"] = "Expiré" -- Needs review
-- L["Expired Since Last Sale:"] = ""
-- L["Failed Auctions"] = ""
-- L["Failed Since Last Sale (Expired/Cancelled):"] = ""
L["General Options"] = "Options générales"
L["Gold Earned:"] = "Or gagné :"
L["Gold Spent:"] = "Or dépensé :"
L["Group"] = "Groupe" -- Needs review
L["_ Hr _ Min ago"] = "Il y a _ Hr _ Min"
-- L["If checked, poor quality items will be shown in sales data. They will still be included in gold earned totals on the summary tab regardless of this setting"] = ""
L["If checked, the average purchase price that shows in the tooltip will be the average price for the most recent X you have purchased, where X is the number you have in your bags / bank / gbank using data from the ItemTracker module. Otherwise, a simple average of all purchases will be used."] = "Si coché, le prix moyen d'achat affiché dans l'infobulle sera le prix moyen des X plus récents que vous avez achetés, X étant le nombre possédé dans les sacs / la banque / la banque de guilde en utilisant les données du module ItemTracker. Sinon, une simple moyenne de tous les achats sera utilisée."
-- L["If checked, the number of cancelled auctions since the last sale will show as up as failed auctions in an item's tooltip. if no sales then the total number of cancelled auctions will be shown."] = ""
-- L["If checked, the number of expired auctions since the last sale will show as up as failed auctions in an item's tooltip. if no sales then the total number of expired auctions will be shown."] = ""
L["If checked, the number you have purchased and the average purchase price will show up in an item's tooltip."] = "Si coché, le nombre que vous avez acheté et le prix d'achat moyen seront affichés dans l'infobulle de l'objet."
L["If checked, the number you have sold and the average sale price will show up in an item's tooltip."] = "Si coché, le nombre que vous avez vendu et le prix de vente moyen seront affichés dans l'infobulle de l'objet."
-- L["If checked, the sale rate will be shown in item tooltips. sale rate is calculated as total sold / (total sold + total expired + total cancelled)."] = ""
L["If checked, whenever you buy or sell any quantity of a single item via trade, Accounting will display a popup asking if you want it to record that transaction."] = "Si coché, à chaque fois que vous achetez ou vendez n'importe quelle quantité d'un seul objet via la fenêtre d'échange, Accounting affichera une fenêtre demandant si vous souhaitez enregistrer cette transaction."
L["If checked, you won't get a popup confirmation about whether or not to track trades."] = "Si coché, vous ne recevrez pas de fenêtre de confirmation à propos du suivi des échanges."
L["Income"] = "Revenu" -- Needs review
L["Item Name"] = "Nom de l'objet"
L["Items"] = "Objets"
L["Last 14 Days"] = "14 derniers jours" -- Needs review
L["Last 30 Days"] = "30 derniers jours" -- Needs review
L["Last 30 Days:"] = "30 derniers jours :"
L["Last 60 Days"] = "60 derniers jours" -- Needs review
L["Last 7 Days"] = "7 derniers jours" -- Needs review
L["Last 7 Days:"] = "7 derniers jours :"
L["Last Purchase"] = "Dernier achat"
-- L["Last Purchased:"] = ""
L["Last Sold"] = "Dernière vente"
L["Last Sold:"] = "Dernier vendu :"
L["Market Value"] = "Valeur du marché"
L["Market Value Source"] = "Source de la valeur du marché"
L["MM/DD/YY HH:MM"] = "MM/JJ/AA HH:MM"
L["none"] = "aucun"
L["None"] = "Aucun" -- Needs review
L["Options"] = "Options"
L["Other"] = "Autre" -- Needs review
-- L["Other Income"] = ""
L["Player"] = "Joueur"
L["Player Gold"] = "Or du joueur" -- Needs review
L["Player(s)"] = "Joueur(s)"
L["Price Per Item"] = "Prix par objet"
L["Profit:"] = "Profit" -- Needs review
L["Profit Per Day:"] = "Profit par jour" -- Needs review
L["Purchase Data"] = "Données d'achat"
L["Purchased (Avg Price):"] = "Acheté (prix moyen)" -- Needs review
L["Purchased (Total Price):"] = "Acheté (prix total)" -- Needs review
L["Purchases"] = "Achats"
L["Quantity"] = "Quantité"
L["Quantity Bought:"] = "Quantité achetée :"
L["Quantity Sold:"] = "Quantité vendue :"
L["Rarity"] = "Rareté" -- Needs review
L["Removed a total of %s old records and %s items with no remaining records."] = "Suppression de %s anciens enregistrements et %s objets sans enregistrements restants."
L["Remove Old Data (No Confirmation)"] = "Supprimer les anciennes données (pas de confirmation)"
L["Resale"] = "Revente"
-- L["Revenue"] = ""
L["%s ago"] = "Il y a %s"
L["Sale Data"] = "Données de vente"
-- L["Sale Rate:"] = ""
L["Sales"] = "Ventes"
L["Search"] = "Chercher"
L["Select how you would like prices to be shown in the \"Items\" and \"Resale\" tabs; either average price per item or total value."] = "Choisissez comment vous voulez afficher les prix dans les onglets \"Objets\" et \"Revente\", soit le prix moyen par objet, soit la valeur totale."
L["Select what format Accounting should use to display times in applicable screens."] = "Choisissez quel format Accounting doit utiliser pour afficher les horaires dans les écrans concernés."
L["Select where you want Accounting to get market value info from to show in applicable screens."] = "Choisissez où vous voulez qu'Accounting récupère les informations de valeur du marché à afficher dans les écrans concernés."
-- L["Show Cancelled Auctions as Failed Auctions since Last Sale in item tooltips"] = ""
-- L["Show Expired Auctions as Failed Auctions since Last Sale in item tooltips"] = ""
L["Show purchase info in item tooltips"] = "Afficher les informations d'achat dans les infobulles d'objet"
L["Show sale info in item tooltips"] = "Afficher les informations de vente dans les infobulles d'objet"
-- L["Show Sale Rate in item tooltips"] = ""
L["Sold"] = "Vendu"
L["Sold (Avg Price):"] = "Vendu (prix moyen):" -- Needs review
-- L["Sold (Total Price):"] = ""
L["Source"] = "Source" -- Needs review
L["Spent Per Day:"] = "Dépensé par jour :"
L["Stack"] = "Pile"
L["Summary"] = "Résumé"
L["Target"] = "Cible" -- Needs review
L["There is no purchase data for this item."] = "Il n'y a pas de données d'achat pour cet objet."
L["There is no sale data for this item."] = "Il n'y a pas de données de vente pour cet objet."
L["Time"] = "Temps"
L["Time Format"] = "Format horaire"
-- L["Timeframe Filter"] = ""
L["Today"] = "Aujourd'hui" -- Needs review
L["Top Buyers:"] = "Meilleurs acheteurs :"
-- L["Top Expense by Gold:"] = ""
-- L["Top Expense by Quantity:"] = ""
-- L["Top Income by Gold:"] = ""
-- L["Top Income by Quantity:"] = ""
L["Top Item by Gold:"] = "Meilleur objet en valeur :"
L["Top Item by Quantity:"] = "Meilleur objet en quantité :"
L["Top Sellers:"] = "Meilleurs vendeurs :"
L["Total:"] = "Total :"
L["Total Buy Price"] = "Prix total d'achat"
L["Total Price"] = "Prix total"
L["Total Sale Price"] = "Prix total de vente"
L["Total Spent:"] = "Total dépensé :"
L["Total Value"] = "Valeur totale"
L["Track sales/purchases via trade"] = "Suivre les ventes/achats via la fenêtre d'échange"
-- L["TSM_Accounting detected that you just traded %s %s in return for %s. Would you like Accounting to store a record of this trade?"] = ""
L["Type"] = "Type" -- Needs review
L["Use smart average for purchase price"] = "Utiliser une moyenne intelligente pour le prix d'achat."
L["Yesterday"] = "Hier" -- Needs review
L[ [=[You can use the options below to clear old data. It is recommened to occasionally clear your old data to keep Accounting running smoothly. Select the minimum number of days old to be removed in the dropdown, then click the button.

NOTE: There is no confirmation.]=] ] = [=[Vous pouvez utiliser les options ci-dessous pour effacer les anciennes données. Il est recommandé d'effacer vos anciennes données de temps en temps pour permettre à Accounting de fonctionner facilement. Choisissez le nombre de minimum de jours à supprimer dans le menu déroulant, puis cliquez sur le bouton.

NB : Il n'y a pas de confirmation.]=]
L["YY/MM/DD HH:MM"] = "AA/MM/JJ HH:MM"
 