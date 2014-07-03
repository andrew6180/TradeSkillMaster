-- ------------------------------------------------------------------------------ --
--                                TradeSkillMaster                                --
--                http://www.curse.com/addons/wow/tradeskill-master               --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- TradeSkillMaster Locale - frFR
-- Please use the localization app on CurseForge to update this
-- http://wow.curseforge.com/addons/TradeSkill-Master/localization/

local L = LibStub("AceLocale-3.0"):NewLocale("TradeSkillMaster", "frFR")
if not L then return end

-- L["Act on Scan Results"] = ""
-- L["A custom price of %s for %s evaluates to %s."] = ""
L["Add >>>"] = "Ajouter >>>" -- Needs review
-- L["Add Additional Operation"] = ""
-- L["Add Items to this Group"] = ""
L["Additional error suppressed"] = "Erreur(s) additionelle(s) supprimée(s)"
-- L["Adjust Post Parameters"] = ""
-- L["Advanced Option Text"] = ""
-- L["Advanced topics..."] = ""
L["A group is a collection of items which will be treated in a similar way by TSM's modules."] = "Un groupe est un ensemble d'objets qui seront traités de la même manière par les modules TSM." -- Needs review
-- L["All items with names containing the specified filter will be selected. This makes it easier to add/remove multiple items at a time."] = ""
-- L["Allows for testing of custom prices."] = ""
L["Allows you to build a queue of crafts that will produce a profitable, see what materials you need to obtain, and actually craft the items."] = "Vous permet de créer une file de craft qui produira un objet, de voir quel matériaux vous avez besoin et de créer les objets."
L["Allows you to quickly and easily empty your mailbox as well as automatically send items to other characters with the single click of a button."] = "Vous permet de vider rapidement et facilement votre boite aux lettres ainsi que d'envoyer automatiquement des objets à d'autres personnages d'un simple clic."
L["Allows you to use data from http://wowuction.com in other TSM modules and view its various price points in your item tooltips."] = "Permet d'utiliser les données de http://wowuction.com dans les autres modules de TSM et de voir les différentes variations de prix dans votre aperçu d'objet." -- Needs review
-- L["Along the bottom of the AH are various tabs. Click on the 'Auctioning' AH tab."] = ""
-- L["Along the bottom of the AH are various tabs. Click on the 'Shopping' AH tab."] = ""
-- L["Along the top of the TSM_Crafting window, click on the 'Professions' button."] = ""
-- L["Along the top of the TSM_Crafting window, click on the 'TSM Groups' button."] = ""
-- L["Along top of the window, on the left side, click on the 'Groups' icon to open up the TSM group settings."] = ""
-- L["Along top of the window, on the left side, click on the 'Module Operations / Options' icon to open up the TSM module settings."] = ""
-- L["Along top of the window, on the right side, click on the 'Crafting' icon to open up the TSM_Crafting page."] = ""
-- L["Alt-Click to immediately buyout this auction."] = ""
-- L["A maximum of 1 convert() function is allowed."] = ""
-- L["A maximum of 1 gold amount is allowed."] = ""
-- L["Any subgroups of this group will also be deleted, with all items being returned to the parent of this group or removed completely if this group has no parent."] = ""
L["Appearance Data"] = "Données d'apparence" -- Needs review
L["Application and Addon Developer:"] = "Développeur de l'application et de l'addon:" -- Needs review
-- L["Applied %s to %s."] = ""
L["Apply Operation to Group"] = "Appliquer l'opération au groupe" -- Needs review
-- L["Are you sure you want to delete the selected profile?"] = ""
-- L["A simple, fixed gold amount."] = ""
-- L["Assign this operation to the group you previously created by clicking on the 'Yes' button in the popup that's now being shown."] = ""
-- L["A TSM_Auctioning operation will allow you to set rules for how auctionings are posted/canceled/reset on the auction house. To create one for this group, scroll down to the 'Auctioning' section, and click on the 'Create Auctioning Operation' button."] = ""
-- L["A TSM_Crafting operation will allow you automatically queue profitable items from the group you just made. To create one for this group, scroll down to the 'Crafting' section, and click on the 'Create Crafting Operation' button."] = ""
-- L["A TSM_Shopping operation will allow you to set a maximum price we want to pay for the items in the group you just made. To create one for this group, scroll down to the 'Shopping' section, and click on the 'Create Shopping Operation' button."] = ""
-- L["At the top, switch to the 'Crafts' tab in order to view a list of crafts you can make."] = ""
L["Auctionator - Auction Value"] = "Auctionator - Valeur de l'enchère"
-- L["Auction Buyout:"] = ""
-- L["Auction Buyout: %s"] = ""
-- L["Auctioneer - Appraiser"] = ""
L["Auctioneer - Market Value"] = "Auctioneer - Valeur du marché"
L["Auctioneer - Minimum Buyout"] = "Auctioneer - Achat minimum"
L["Auction Frame Scale"] = "Echelle de la fenêtre des métiers"
L["Auction House Tab Settings"] = "Option de l'onglet HDV"
-- L["Auction not found. Skipped."] = ""
L["Auctions"] = "Enchères" -- Needs review
L["Author(s):"] = "Auteur(s):"
-- L["BankUI"] = ""
-- L["Below are various ways you can set the value of the current editbox. Any combination of these methods is also supported."] = ""
-- L["Below are your currently available price sources. The %skey|r is what you would type into a custom price box."] = ""
-- L["Below is a list of groups which this operation is currently applied to. Clicking on the 'Remove' button next to the group name will remove the operation from that group."] = ""
-- L["Below, set the custom price that will be evaluated for this custom price source."] = ""
L["Border Thickness (Requires Reload)"] = "Largeur du rebord (Requiert un rechargement)" -- Needs review
-- L["Buy from Vendor"] = ""
-- L["Buy items from the AH"] = ""
-- L["Buy materials for my TSM_Crafting queue"] = ""
L["Canceling Auction: %d/%d"] = "Annulation de l'enchère: %d/%d" -- Needs review
L["Cancelled - Bags and bank are full"] = "Annulé - Les sacs et la banque sont pleins" -- Needs review
L["Cancelled - Bags and guildbank are full"] = "Annulé - Les sacs et la banque de guilde sont pleins" -- Needs review
L["Cancelled - Bags are full"] = "Annulé - Les sacs sont pleins" -- Needs review
L["Cancelled - Bank is full"] = "Annulé - La banque est pleine" -- Needs review
L["Cancelled - Guildbank is full"] = "Annulé - La banque de guilde est pleine" -- Needs review
L["Cancelled - You must be at a bank or guildbank"] = "Annulé - Vous devez être à la banque ou à la banque de guilde" -- Needs review
L["Cannot delete currently active profile!"] = "Impossible de supprimer le profil en cours d'utilisation !" -- Needs review
-- L["Category Text 2 (Requires Reload)"] = ""
L["Category Text (Requires Reload)"] = "Texte de la catégorie (Requiert un rechargement)" -- Needs review
-- L["|cffffff00DO NOT report this as an error to the developers.|r If you require assistance with this, make a post on the TSM forums instead."] = ""
--[==[ L[ [=[|cffffff00Important Note:|r You do not currently have any modules installed / enabled for TradeSkillMaster! |cff77ccffYou must download modules for TradeSkillMaster to have some useful functionality!|r

Please visit http://www.curse.com/addons/wow/tradeskill-master and check the project description for links to download modules.]=] ] = "" ]==]
L["Changes how many rows are shown in the auction results tables."] = "Change le nombre de lignes affichées dans la table de résultats d'enchères." -- Needs review
L["Changes the size of the auction frame. The size of the detached TSM auction frame will always be the same as the main auction frame."] = "Changer la taille de la fenêtre HDV. La taille de la fenêtre TSM sera toujours la même que celle de l'HDV."
-- L["Character Name on Other Account"] = ""
-- L["Chat Tab"] = ""
-- L["Check out our completely free, desktop application which has tons of features including deal notification emails, automatic updating of AuctionDB and WoWuction prices, automatic TSM setting backup, and more! You can find this app by going to %s."] = ""
-- L["Check this box to override this group's operation(s) for this module."] = ""
L["Clear"] = "Effacer" -- Needs review
L["Clear Selection"] = "Effacer la sélection" -- Needs review
-- L["Click on the Auctioning Tab"] = ""
-- L["Click on the Crafting Icon"] = ""
-- L["Click on the Groups Icon"] = ""
-- L["Click on the Module Operations / Options Icon"] = ""
-- L["Click on the Shopping Tab"] = ""
-- L["Click on the 'Show Queue' button at the top of the TSM_Crafting window to show the queue if it's not already visible."] = ""
-- L["Click on the 'Start Sniper' button in the sidebar window."] = ""
-- L["Click on the 'Start Vendor Search' button in the sidebar window."] = ""
-- L["Click the button below to open the export frame for this group."] = ""
-- L["Click this button to completely remove this operation from the specified group."] = ""
L["Click this button to configure the currently selected operation."] = "Cliquer ce bouton pour configuer l'opération sélectionnée." -- Needs review
L["Click this button to create a new operation for this module."] = "Cliquer ce bouton pour créer une nouvelle opération pour ce module." -- Needs review
-- L["Click this button to show a frame for easily exporting the list of items which are in this group."] = ""
L["Co-Founder:"] = "Co-fondateur:" -- Needs review
-- L["Coins:"] = ""
-- L["Color Group Names by Depth"] = ""
-- L["Content - Backdrop"] = ""
L["Content - Border"] = "Contenu - Bordure" -- Needs review
L["Content Text - Disabled"] = "Text de contenu - Désactivé" -- Needs review
L["Content Text - Enabled"] = "Text de contenu - Activé" -- Needs review
L["Copy From"] = "Copier depuis" -- Needs review
L["Copy the settings from one existing profile into the currently active profile."] = "Copier les paramètres depuis un profil existant vers le profil actif." -- Needs review
-- L["Craft Items from Queue"] = ""
-- L["Craft items with my professions"] = ""
-- L["Craft specific one-off items without making a queue"] = ""
L["Create a new empty profile."] = "Créer un nouveau profil." -- Needs review
-- L["Create a New Group"] = ""
-- L["Create a new group by typing a name for the group into the 'Group Name' box and pressing the <Enter> key."] = ""
-- L["Create a new %s operation by typing a name for the operation into the 'Operation Name' box and pressing the <Enter> key."] = ""
-- L["Create a %s Operation %d/5"] = ""
L["Create New Subgroup"] = "Créer un nouveau sous-groupe" -- Needs review
-- L["Create %s Operation"] = ""
-- L["Create the Craft"] = ""
-- L["Creating a relationship for this setting will cause the setting for this operation to be equal to the equivalent setting of another operation."] = ""
L["Crystals"] = "Cristaux" -- Needs review
L["Current Profile:"] = "Profil actif:" -- Needs review
-- L["Custom Price for this Source"] = ""
-- L["Custom Price Source"] = ""
-- L["Custom Price Source Name"] = ""
-- L["Custom Price Sources"] = ""
-- L["Custom price sources allow you to create more advanced custom prices throughout all of the TSM modules. Just as you can use the built-in price sources such as 'vendorsell' and 'vendorbuy' in your custom prices, you can use ones you make here (which themselves are custom prices)."] = ""
-- L["Custom price sources to display in item tooltips:"] = ""
-- L["Default"] = ""
-- L["Default BankUI Tab"] = ""
-- L["Default Group Tab"] = ""
-- L["Default Tab"] = ""
-- L["Default Tab (Open Auction House to Enable)"] = ""
L["Delete a Profile"] = "Supprimer un profil" -- Needs review
-- L["Delete Custom Price Source"] = ""
-- L["Delete existing and unused profiles from the database to save space, and cleanup the SavedVariables file."] = ""
L["Delete Group"] = "Supprimer le groupe" -- Needs review
L["Delete Operation"] = "Supprimer l'opération" -- Needs review
L["Description:"] = "Description:"
L["Deselect All Groups"] = "Déselectionner tous les groupes" -- Needs review
-- L["Deselects all items in both columns."] = ""
-- L["Disenchant source:"] = ""
-- L["Disenchant Value"] = ""
-- L["Disenchant Value:"] = ""
-- L["Disenchant Value x%s:"] = ""
-- L["Display disenchant value in tooltip."] = ""
-- L["Display Group / Operation Info in Tooltips"] = ""
-- L["Display prices in tooltips as:"] = ""
-- L["Display vendor buy price in tooltip."] = ""
-- L["Display vendor sell price in tooltip."] = ""
L["Done"] = "Terminé" -- Needs review
-- L["Done!"] = ""
-- L["Double-click to collapse this item and show only the cheapest auction."] = ""
-- L["Double-click to expand this item and show all the auctions."] = ""
L["Duplicate Operation"] = "Dupliquer l'opération" -- Needs review
L["Duration:"] = "Durée:" -- Needs review
L["Dust"] = "Poussière"
-- L["Embed TSM Tooltips"] = ""
-- L["Empty price string."] = ""
-- L["Enter Filters and Start Scan"] = ""
-- L["Enter Import String"] = ""
-- L["Error creating custom price source. Custom price source with name '%s' already exists."] = ""
L["Error creating group. Group with name '%s' already exists."] = "Erreur à la création du groupe. Le groupe '%s' existe déjà." -- Needs review
L["Error creating subgroup. Subgroup with name '%s' already exists."] = "Erreur à la création du sous-groupe. Le sous-groupe '%s' existe déjà." -- Needs review
L["Error duplicating operation. Operation with name '%s' already exists."] = "Erreur à la duplication de l'opération. L'opération '%s' existe déjà." -- Needs review
L["Error Info:"] = "Erreur: "
L["Error moving group. Group '%s' already exists."] = "Erreur au déplacement du groupe. Le groupe '%s' existe déjà." -- Needs review
-- L["Error moving group. You cannot move this group to one of its subgroups."] = ""
-- L["Error renaming custom price source. Custom price source with name '%s' already exists."] = ""
L["Error renaming group. Group with name '%s' already exists."] = "Erreur au renommage du groupe. Le groupe '%s' existe déjà." -- Needs review
L["Error renaming operation. Operation with name '%s' already exists."] = "Erreur au renommage de l'opération. L'opération '%s' existe déjà." -- Needs review
L["Essences"] = "Essences"
L["Examples"] = "Exemples" -- Needs review
L["Existing Profiles"] = "Profils existants" -- Needs review
L["Export Appearance Settings"] = "Exporter les paramètres d'apparence" -- Needs review
-- L["Export Group Items"] = ""
-- L["Export Items in Group"] = ""
-- L["Export Operation"] = ""
-- L["Failed to parse gold amount."] = ""
-- L["First, ensure your new group is selected in the group-tree and then click on the 'Restock Selected Groups' button at the bottom."] = ""
-- L["First, ensure your new group is selected in the group-tree and then click on the 'Start Cancel Scan' button at the bottom of the tab."] = ""
-- L["First, ensure your new group is selected in the group-tree and then click on the 'Start Post Scan' button at the bottom of the tab."] = ""
-- L["First, ensure your new group is selected in the group-tree and then click on the 'Start Search' button at the bottom of the sidebar window."] = ""
-- L["First, log into a character on the same realm (and faction) on both accounts. Type the name of the OTHER character you are logged into in the box below. Once you have done this on both accounts, TSM will do the rest automatically. Once setup, syncing will automatically happen between the two accounts while on any character on the account (not only the one you entered during this setup)."] = ""
L["Fixed Gold Value"] = "Montant fixe" -- Needs review
-- L["Forget Characters:"] = ""
-- L["Frame Background - Backdrop"] = ""
-- L["Frame Background - Border"] = ""
L["General Options"] = "Options générales" -- Needs review
L["General Settings"] = "Paramètres généraux"
L["Give the group a new name. A descriptive name will help you find this group later."] = "Donner un nouveau nom au groupe. Un nom comportant une bonne description vous permettra de retrouver ce groupe plus facilement." -- Needs review
L["Give the new group a name. A descriptive name will help you find this group later."] = "Donner un nom au nouveau groupe. Un nom comportant une bonne description vous permettra de retrouver ce groupe plus facilement." -- Needs review
L["Give this operation a new name. A descriptive name will help you find this operation later."] = "Donner un nouveau nom à cette opération. Un nom comportant une bonne description vous permettra de retrouver cette opération plus facilement." -- Needs review
-- L["Give your new custom price source a name. This is what you will type in to custom prices and is case insensitive (everything will be saved as lower case)."] = ""
L["Goblineer (by Sterling - The Consortium)"] = "Goblineer (par Sterling - The Consortium)" -- Needs review
-- L["Go to the Auction House and open it."] = ""
-- L["Go to the 'Groups' Page"] = ""
-- L["Go to the 'Import/Export' Tab"] = ""
-- L["Go to the 'Items' Tab"] = ""
-- L["Go to the 'Operations' Tab"] = ""
L["Group:"] = "Groupe:" -- Needs review
-- L["Group(Base Item):"] = ""
-- L["Group Item Data"] = ""
-- L["Group Items:"] = ""
L["Group Name"] = "Nom du groupe" -- Needs review
L["Group names cannot contain %s characters."] = "Les noms de groupe ne peuvent pas contenir les caractères %s." -- Needs review
L["Groups"] = "Groupes" -- Needs review
L["Help"] = "Aide" -- Needs review
-- L["Help / Options"] = ""
-- L["Here you can setup relationships between the settings of this operation and other operations for this module. For example, if you have a relationship set to OperationA for the stack size setting below, this operation's stack size setting will always be equal to OperationA's stack size setting."] = ""
L["Hide Minimap Icon"] = "Cacher l'icône de la Mini-carte"
-- L["How would you like to craft?"] = ""
-- L["How would you like to create the group?"] = ""
-- L["How would you like to post?"] = ""
-- L["How would you like to shop?"] = ""
L["Icon Region"] = "Zone d'icône" -- Needs review
L["If checked, all tables listing auctions will display the bid as well as the buyout of the auctions. This will not take effect immediately and may require a reload."] = "Si coché, toutes les listes d'enchères afficheront le dépôt ainsi que le prix d'achat immédiat. Cela ne prendra pas effet immédiatement et peut nécessiter un rafraîchissement."
L["If checked, any items you import that are already in a group will be moved out of their current group and into this group. Otherwise, they will simply be ignored."] = "si coché, tous objets importé et déjà dans un groupe en sera retiré et sera déplacé dans ce groupe. Sinon, ils seront simplement ignorés." -- Needs review
-- L["If checked, group names will be colored based on their subgroup depth in group trees."] = ""
-- L["If checked, only items which are in the parent group of this group will be imported."] = ""
-- L["If checked, operations will be stored globally rather than by profile. TSM groups are always stored by profile. Note that if you have multiple profiles setup already with separate operation information, changing this will cause all but the current profile's operations to be lost."] = ""
-- L["If checked, the disenchant value of the item will be shown. This value is calculated using the average market value of materials the item will disenchant into."] = ""
-- L["If checked, the price of buying the item from a vendor is displayed."] = ""
-- L["If checked, the price of selling the item to a vendor displayed."] = ""
-- L["If checked, the structure of the subgroups will be included in the export. Otherwise, the items in this group (and all subgroups) will be exported as a flat list."] = ""
-- L["If checked, this custom price will be displayed in item tooltips."] = ""
-- L["If checked, TSM's tooltip lines will be embedded in the item tooltip. Otherwise, it will show as a separate box below the item's tooltip."] = ""
-- L["If checked, ungrouped items will be displayed in the left list of selection lists used to add items to subgroups. This allows you to add an ungrouped item directly to a subgroup rather than having to add to the parent group(s) first."] = ""
L["If checked, your bags will be automatically opened when you open the auction house."] = "Si coché, ouvre vos sacs automatiquement lorsque vous ouvrez l'hôtel des ventes." -- Needs review
-- L["If there are no auctions currently posted for this item, simmply click the 'Post' button at the bottom of the AH window. Otherwise, select the auction you'd like to undercut first."] = ""
-- L["If you delete, rename, or transfer a character off the current faction/realm, you should remove it from TSM's list of characters using this dropdown."] = ""
--[==[ L[ [=[If you'd like, you can adjust the value in the 'Minimum Profit' box in order to specify the minimum profit before Crafting will queue these items.

Once you're done adjusting this setting, click the button below.]=] ] = "" ]==]
-- L["If you have multiple profile set up with operations, enabling this will cause all but the current profile's operations to be irreversibly lost. Are you sure you want to continue?"] = ""
-- L["If you open your bags and shift-click the item in your bags, it will be placed in Shopping's search bar. You may need to put your cursor in the search bar first. Alternatively, you can type the name of the item manually in the search bar and then hit enter or click the 'Search' button."] = ""
-- L["Ignore Operation on Characters:"] = ""
-- L["Ignore Operation on Faction-Realms:"] = ""
-- L["Ignore Random Enchants on Ungrouped Items"] = ""
L["I'll Go There Now!"] = "J'y vais maintenant !"
-- L["I'm done."] = ""
L["Import Appearance Settings"] = "Importer les paramètres d'apparence" -- Needs review
L["Import/Export"] = "Import/Export" -- Needs review
-- L["Import Items"] = ""
-- L["Import Operation Settings"] = ""
L["Import Preset TSM Theme"] = "Importer le thème TSM prédéfini" -- Needs review
-- L["Import String"] = ""
-- L["Include Subgroup Structure in Export"] = ""
L["Installed Modules"] = "Modules installés"
-- L["In the confirmation window, you can adjust the buyout price, stack sizes, and auction duration. Once you're done, click the 'Post' button to post your items to the AH."] = ""
-- L["In the list on the left, select the top-level 'Groups' page."] = ""
L["Invalid appearance data."] = "Données d'apparence non valides." -- Needs review
-- L["Invalid custom price."] = ""
-- L["Invalid custom price for undercut amount. Using 1c instead."] = ""
L["Invalid filter."] = "Filtre invalide." -- Needs review
L["Invalid function."] = "Fonction invalide." -- Needs review
-- L["Invalid import string."] = ""
-- L["Invalid item link."] = ""
-- L["Invalid operator at end of custom price."] = ""
-- L["Invalid parameter to price source."] = ""
-- L["Invalid parent argument type. Expected table, got %s."] = ""
-- L["Invalid price source in convert."] = ""
L["Invalid word: '%s'"] = "Mot invalide: '%s'" -- Needs review
L["Item"] = "Objet" -- Needs review
-- L["Item Buyout: %s"] = ""
L["Item Level"] = "Niveau d'objet" -- Needs review
-- L["Item links may only be used as parameters to price sources."] = ""
-- L["Item not found in bags. Skipping"] = ""
L["Items"] = "Objets" -- Needs review
L["Item Tooltip Text"] = "texte d'infobulle de l'objet" -- Needs review
-- L["Jaded (by Ravanys - The Consortium)"] = ""
L["Just incase you didn't read this the first time:"] = "Au cas ou vous n'auriez pas lu ceci la première fois:"
--[==[ L[ [=[Just like the default profession UI, you can select what you want to craft from the list of crafts for this profession. Click on the one you want to craft.

Once you're done, click the button below.]=] ] = "" ]==]
-- L["Keep Items in Parent Group"] = ""
L["Keeps track of all your sales and purchases from the auction house allowing you to easily track your income and expenditures and make sure you're turning a profit."] = "Garde la trace de vos ventes et de vos achats à l'hôtel des ventes pour vous permettre de suivre facilement vos revenus et dépenses et vous assurer de générer du profit." -- Needs review
-- L["Label Text - Disabled"] = ""
-- L["Label Text - Enabled"] = ""
-- L["Lead Developer and Co-Founder:"] = ""
L["Light (by Ravanys - The Consortium)"] = "Light (par Ravanys - The Consortium)" -- Needs review
L["Link Text 2 (Requires Reload)"] = "Texte de lien 2 (Requiert rechargement)" -- Needs review
L["Link Text (Requires Reload)"] = "Texte de lien (Requiert rechargement)" -- Needs review
L["Load Saved Theme"] = "Charger un thème sauvegardé" -- Needs review
-- L["Look at what's profitable to craft and manually add things to a queue"] = ""
-- L["Look for items which can be destroyed to get raw mats"] = ""
-- L["Look for items which can be vendored for a profit"] = ""
-- L["Looks like no items were added to the queue. This may be because you are already at or above your restock levels, or there is nothing profitable to queue."] = ""
-- L["Looks like no items were found. You can either try searching for something else, or simply close the Assistant window if you're done."] = ""
-- L["Looks like no items were imported. This might be because they are already in another group in which case you might consider checking the 'Move Already Grouped Items' box to force them to move to this group."] = ""
-- L["Looks like TradeSkillMaster has detected an error with your configuration. Please address this in order to ensure TSM remains functional."] = ""
L["Looks like TradeSkillMaster has encountered an error. Please help the author fix this error by copying the entire error below and following the instructions for reporting bugs listed here (unless told elsewhere by the author):"] = "Il semble que TSM ait rencontré une erreur. Merci d'aider le développeur de TSM en copiant l'ensemble du message d'erreur et en suivant les instructions permettant de faire remonter les bugs."
L["Looks like TradeSkillMaster has encountered an error. Please help the author fix this error by following the instructions shown."] = "Il semblerait que TradeSkillMaster ai rencontré une erreur. Merci d'aider l'auteur à corriger cette erreur en suivant les instructions affichées."
-- L["Loop detected in the following custom price:"] = ""
-- L["Make a new group from an import list I have"] = ""
-- L["Make a new group from items in my bags"] = ""
L["Make Auction Frame Movable"] = "Déverrouiller la frame"
-- L["Management"] = ""
L["Manages your inventory by allowing you to easily move stuff between your bags, bank, and guild bank."] = "Gérez votre inventaire en vous permettant de bouger facilement les objets entre vos sacs, banque et banque de guilde."
L["% Market Value"] = "% de la valeur du marché" -- Needs review
-- L["max %d"] = ""
-- L["Medium Text Size (Requires Reload)"] = ""
L["Mills, prospects, and disenchants items at super speed!"] = "Moudre, prospecter et désenchanter de manière rapide."
L["Misplaced comma"] = "Virgule mal placée" -- Needs review
L["Module:"] = "Module: "
L["Module Information:"] = "Informations sur le module:" -- Needs review
L["Module Operations / Options"] = "Opérations / Options du module" -- Needs review
-- L["Modules"] = ""
L["More Advanced Methods"] = "Méthodes plus avancées" -- Needs review
-- L["More advanced options are now designated by %sred text|r. Beginners are encourages to come back to these once they have a solid understanding of the basics."] = ""
-- L["Move Already Grouped Items"] = ""
-- L["Moved %s to %s."] = ""
L["Move Group"] = "Déplacer le groupe" -- Needs review
-- L["Move to Top Level"] = ""
L["Multi-Account Settings"] = "Paramètres multi-comptes" -- Needs review
-- L["My group is selected."] = ""
-- L["My new operation is selected."] = ""
L["New"] = "Nouveau" -- Needs review
-- L["New Custom Price Source"] = ""
L["New Group"] = "Nouveau groupe" -- Needs review
L["New Group Name"] = "Nouveau nom de groupe" -- Needs review
L["New Parent Group"] = "Nouveau groupe parent" -- Needs review
L["New Subgroup Name"] = "Nouveau nom de sous-groupe" -- Needs review
-- L["No Assistant guides available for the modules which you have installed."] = ""
-- L["<No Group Selected>"] = ""
L["No modules are currently loaded.  Enable or download some for full functionality!"] = "Aucun module n'est actuellement chargé. Activez ou téléchargez-en pour un plein fonctionnement!" -- Needs review
-- L["None of your groups have %s operations assigned. Type '/tsm' and click on the 'TradeSkillMaster Groups' button to assign operations to your TSM groups."] = ""
L["<No Operation>"] = "<Aucune opération>" -- Needs review
-- L["<No Operation Selected>"] = ""
L["<No Relationship>"] = "<Aucune relation>" -- Needs review
L["Normal Text Size (Requires Reload)"] = "Taille de texte normale (nécessite de recharger)" -- Needs review
--[==[ L[ [=[Now that the scan is finished, you can look through the results shown in the log, and for each item, decide what action you want to take.

Once you're done, click on the button below.]=] ] = "" ]==]
-- L["Number of Auction Result Rows (Requires Reload)"] = ""
-- L["Only Import Items from Parent Group"] = ""
L["Open All Bags with Auction House"] = "Ouvrir tous les sacs avec l'hôtel des ventes" -- Needs review
-- L["Open one of the professions which you would like to use to craft items."] = ""
-- L["Open the Auction House"] = ""
-- L["Open the TSM Window"] = ""
-- L["Open up Your Profession"] = ""
L["Operation #%d"] = "Opération #%d" -- Needs review
L["Operation Management"] = "Gestion des opérations" -- Needs review
L["Operations"] = "Opérations" -- Needs review
L["Operations: %s"] = "Opérations: %s" -- Needs review
L["Options"] = "Options"
-- L["Override Module Operations"] = ""
L["Parent Group Items:"] = "Objets du groupe parent:" -- Needs review
L["Parent/Ungrouped Items:"] = "Objets du groupe parent/ non groupés" -- Needs review
L["Past Contributors:"] = "Precedents Contributeurs: " -- Needs review
-- L["Paste the exported items into this box and hit enter or press the 'Okay' button. The recommended format for the list of items is a comma separated list of itemIDs for general items. For battle pets, the entire battlepet string should be used. For randomly enchanted items, the format is <itemID>:<randomEnchant> (ex: 38472:-29)."] = ""
-- L["Paste the exported operation settings into this box and hit enter or press the 'Okay' button. Imported settings will irreversibly replace existing settings for this operation."] = ""
L[ [=[Paste the list of items into the box below and hit enter or click on the 'Okay' button.

You can also paste an itemLink into the box below to add a specific item to this group.]=] ] = "Copiez la liste d'objets dans le champs ci-dessous et tapez entrée ouclickez sur OK." -- Needs review
-- L["Paste your import string into the 'Import String' box and hit the <Enter> key to import the list of items."] = ""
L["Percent of Price Source"] = "Pourcentage du prix référence" -- Needs review
L["Performs scans of the auction house and calculates the market value of items as well as the minimum buyout. This information can be shown in items' tooltips as well as used by other modules."] = "Scan l'HV et calcule les prix de marché des objets ainsi que leur prix d'achat le plus bas. Ces informations peuvent être visibles dans l'infotexte des objets et également utilisées par d'autres modules." -- Needs review
L["Per Item:"] = "Par objet:" -- Needs review
-- L["Please select the group you'd like to use."] = ""
-- L["Please select the new operation you've created."] = ""
-- L["Please wait..."] = ""
L["Post"] = "Envoyer" -- Needs review
-- L["Post an Item"] = ""
-- L["Post items manually from my bags"] = ""
-- L["Posts and cancels your auctions to / from the auction house according to pre-set rules. Also, this module can show you markets which are ripe for being reset for a profit."] = ""
-- L["Post Your Items"] = ""
L["Price Per Item"] = "Prix par objet" -- Needs review
L["Price Per Stack"] = "Prix par pile" -- Needs review
L["Price Per Target Item"] = "Prix par objet ciblé" -- Needs review
-- L["Prints out the available price sources for use in custom price boxes."] = ""
L["Prints out the version numbers of all installed modules"] = "Affiche les numéros de versions des modules installés" -- Needs review
L["Profiles"] = "Profils" -- Needs review
L["Provides extra functionality that doesn't fit well in other modules."] = "Fournit des fonctionnalités additionnelles qui ne vont pas dans les autres modules." -- Needs review
L["Provides interfaces for efficiently searching for items on the auction house. When an item is found, it can easily be bought, canceled (if it's yours), or even posted from your bags."] = "fournit une interface qui permet de chercher des objets efficacement à l’hôtel des ventes. Quand un objet est trouvé, il peut facilement être acheté, annulé (si c'est le votre), ou même posté depuis vos sacs." -- Needs review
L["Purchasing Auction: %d/%d"] = "Payer l'enchère: %d/%d" -- Needs review
-- L["Queue Profitable Crafts"] = ""
-- L["Quickly post my items at some pre-determined price"] = ""
-- L["Region - Backdrop"] = ""
-- L["Region - Border"] = ""
-- L["Remove"] = ""
-- L["<<< Remove"] = ""
-- L["Removed '%s' as a custom price source. Be sure to update any custom prices that were using this source."] = ""
-- L["<Remove Operation>"] = ""
-- L["Rename Custom Price Source"] = ""
L["Rename Group"] = "Renommer le groupe" -- Needs review
L["Rename Operation"] = "Renommer l'opération" -- Needs review
L["Replace"] = "Remplacer" -- Needs review
L["Reset Profile"] = "Réinitialiser le profil" -- Needs review
-- L["Resets the position, scale, and size of all applicable TSM and module frames."] = ""
-- L["Reset the current profile back to its default values, in case your configuration is broken, or you simply want to start over."] = ""
-- L["Resources:"] = ""
-- L["Restart Assistant"] = ""
L["Restore Default Colors"] = "Restaurer les couleurs par défaut"
L["Restores all the color settings below to their default values."] = "Restaure les réglages de couleurs ci-dessous à leur valeur par défaut."
-- L["Saved theme: %s."] = ""
-- L["Save Theme"] = ""
L["%sDrag%s to move this button"] = "%sGlisser%s pour bouger le bouton"
L["Searching for item..."] = "Recherche de l'objet..." -- Needs review
-- L["Search the AH for items to buy"] = ""
-- L["See instructions above this editbox."] = ""
L["Select a group from the list below and click 'OK' at the bottom."] = "Sélectionner un groupe dans la liste ci-dessous et cliquer 'OK'." -- Needs review
L["Select All Groups"] = "Sélectionner tous les groupes" -- Needs review
L["Select an operation to apply to this group."] = "Choisir une opération à appliquer à ce groupe." -- Needs review
L["Select a %s operation using the dropdown above."] = "Sélectionner une %s opération en utilisant la liste ci-dessus." -- Needs review
-- L["Select a theme from this dropdown to import one of the preset TSM themes."] = ""
-- L["Select a theme from this dropdown to import one of your saved TSM themes."] = ""
-- L["Select Existing Group"] = ""
-- L["Select Group and Click Restock Button"] = ""
-- L["Select Group and Start Scan"] = ""
-- L["Select the Cancel Tab"] = ""
-- L["Select the 'Cancel' tab within the operation to set the canceling options for the TSM_Auctioning operation."] = ""
-- L["Select the Craft"] = ""
-- L["Select the 'Crafts' Tab"] = ""
-- L["Select the 'General' Tab"] = ""
-- L["Select the 'General' tab within the operation to set the general options for the TSM_Shopping operation."] = ""
--[==[ L[ [=[Select the group you'd like to use. Once you have done this, click on the button below.

Currently Selected Group: %s]=] ] = "" ]==]
-- L["Select the items you want to add in the left column and then click on the 'Add >>>' button at the top to add them to this group."] = ""
-- L["Select the 'Operations' page from the list on the left of the TSM window."] = ""
-- L["Select the Options Page"] = ""
-- L["Select the 'Options' page to change general settings for TSM_Shopping"] = ""
-- L["Select the Post Tab"] = ""
-- L["Select the 'Post' tab within the operation to set the posting options for the TSM_Auctioning operation."] = ""
-- L["Select the price source for calculating disenchant value."] = ""
-- L["Select the 'Shopping' tab to open up the settings for TSM_Shopping."] = ""
--[==[ L[ [=[Select your new operation in the list of operation along the left of the TSM window (if it's not selected automatically) and click on the button below.

Currently Selected Operation: %s]=] ] = "" ]==]
L["Seller"] = "Vendeur" -- Needs review
-- L["Sell items on the AH and manage my auctions"] = ""
-- L["Sell to Vendor"] = ""
-- L["Set All Relationships to Target"] = ""
-- L["Set a Maximum Price"] = ""
-- L["Set Auction Price Settings"] = ""
-- L["Set Auction Settings"] = ""
-- L["Set Cancel Settings"] = ""
-- L["Set Max Restock Quantity"] = ""
-- L["Set Minimum Profit"] = ""
-- L["Set Other Options"] = ""
-- L["Set Posting Price Settings"] = ""
-- L["Set Quick Posting Duration"] = ""
-- L["Set Quick Posting Price"] = ""
-- L["Sets all relationship dropdowns below to the operation selected."] = ""
L["Settings"] = "Paramètres" -- Needs review
-- L["Setup account sync'ing with the account which '%s' is on."] = ""
-- L["Set up TSM to automatically cancel undercut auctions"] = ""
-- L["Set up TSM to automatically post auctions"] = ""
-- L["Set up TSM to automatically queue things to craft"] = ""
-- L["Setup TSM to automatically reset specific markets"] = ""
-- L["Set up TSM to find cheap items on the AH"] = ""
L["Shards"] = "Eclats"
-- L["Shift-Click an item in the sidebar window to immediately post it at your quick posting price."] = ""
-- L["Shift-Click Item in Your Bags"] = ""
L["Show Bids in Auction Results Table (Requires Reload)"] = "Montre vos enchères dans la table des résultats des enchères." -- Needs review
-- L["Show the 'Custom Filter' Sidebar Tab"] = ""
-- L["Show the 'Other' Sidebar Tab"] = ""
-- L["Show the Queue"] = ""
-- L["Show the 'Quick Posting' Sidebar Tab"] = ""
-- L["Show the 'TSM Groups' Sidebar Tab"] = ""
-- L["Show Ungrouped Items for Adding to Subgroups"] = ""
-- L["%s is a valid custom price but did not give a value for %s."] = ""
-- L["%s is a valid custom price but %s is an invalid item."] = ""
-- L["%s is not a valid custom price and gave the following error: %s"] = ""
-- L["Skipping auction which no longer exists."] = ""
L["Slash Commands:"] = "Commandes Slash: "
-- L["%sLeft-Click|r to select / deselect this group."] = ""
L["%sLeft-Click%s to open the main window"] = "%sClic gauche%s pour ouvrir la fenêtre principale"
-- L["Small Text Size (Requires Reload)"] = ""
-- L["Snipe items as they are being posted to the AH"] = ""
-- L["Sniping Scan in Progress"] = ""
-- L["%s operation(s):"] = ""
-- L["Sources"] = ""
-- L["%sRight-Click|r to collapse / expand this group."] = ""
L["Stack Size"] = "Taille de la pile" -- Needs review
L["stacks of"] = "piles de" -- Needs review
-- L["Start a Destroy Search"] = ""
-- L["Start Sniper"] = ""
-- L["Start Vendor Search"] = ""
L["Status / Credits"] = "Status / Crédits"
-- L["Store Operations Globally"] = ""
-- L["Subgroup Items:"] = ""
-- L["Subgroups contain a subset of the items in their parent groups and can be used to further refine how different items are treated by TSM's modules."] = ""
-- L["Successfully imported %d items to %s."] = ""
-- L["Successfully imported operation settings."] = ""
-- L["Switch to Destroy Mode"] = ""
-- L["Switch to New Custom Price Source After Creation"] = ""
-- L["Switch to New Group After Creation"] = ""
-- L["Switch to the 'Professions' Tab"] = ""
-- L["Switch to the 'TSM Groups' Tab"] = ""
L["Target Operation"] = "Opération cible" -- Needs review
L["Testers (Special Thanks):"] = "Testeurs (Remerciements spécial):"
L["Text:"] = "Texte:" -- Needs review
L["The default tab shown in the 'BankUI' frame."] = "L'onglet affiché par défaut dans la fenêtre 'BankUI'." -- Needs review
-- L["The final set of posting settings are under the 'Posting Price Settings' header. These define the price ranges which Auctioning will post your items within. Read the tooltips of the individual settings to see what they do and set them appropriately."] = ""
-- L["The first set of posting settings are under the 'Auction Settings' header. These control things like stack size and auction duration. Read the tooltips of the individual settings to see what they do and set them appropriately."] = ""
-- L["The Functional Gold Maker (by Xsinthis - The Golden Crusade)"] = ""
--[==[ L[ [=[The 'Maxium Auction Price (per item)' is the most you want to pay for the items you've added to your group. If you're not sure what to set this to and have TSM_AuctionDB installed (and it contains data from recent scans), you could try '90% dbmarket' for this option.

Once you're done adjusting this setting, click the button below.]=] ] = "" ]==]
--[==[ L[ [=[The 'Max Restock Quantity' defines how many of each item you want to restock up to when using the restock queue, taking your inventory into account.

Once you're done adjusting this setting, click the button below.]=] ] = "" ]==]
L["Theme Name"] = "Nom du thème" -- Needs review
L["Theme name is empty."] = "Le nom du thème est vide." -- Needs review
-- L["The name can ONLY contain letters. No spaces, numbers, or special characters."] = ""
L["There are no visible banks."] = "Aucune banque n'est visible." -- Needs review
-- L["There is only one price level and seller for this item."] = ""
-- L["The second set of posting settings are under the 'Auction Price Settings' header. These include the percentage of the buyout which the bid will be set to, and how much you want to undercut by. Read the tooltips of the individual settings to see what they do and set them appropriately."] = ""
-- L["These settings control when TSM_Auctioning will cancel your auctions. Read the tooltips of the individual settings to see what they do and set them appropriately."] = ""
--[==[ L[ [=[The 'Sniper' feature will constantly search the last page of the AH which shows items as they are being posted. This does not search existing auctions, but lets you buy items which are posted cheaply right as they are posted and buy them before anybody else can.

You can adjust the settings for what auctions are shown in TSM_Shopping's options.

Click the button below when you're done reading this.]=] ] = "" ]==]
L["This allows you to export your appearance settings to share with others."] = "Permet d'exporter vos paramètres d'affichage pour les partager avec d'autres." -- Needs review
L["This allows you to import appearance settings which other people have exported."] = "Permet d'importer les paramètres d'affichage que d'autres ont exportés." -- Needs review
-- L["This dropdown determines the default tab when you visit a group."] = ""
-- L["This group already has operations. Would you like to add another one or replace the last one?"] = ""
-- L["This group already has the max number of operation. Would you like to replace the last one?"] = ""
-- L["This operation will be ignored when you're on any character which is checked in this dropdown."] = ""
-- L["This option sets which tab TSM and its modules will use for printing chat messages."] = ""
L["Time Left"] = "Temps restant" -- Needs review
L["Title"] = "Titre" -- Needs review
-- L["Toggles the bankui"] = ""
-- L["Tooltip Options"] = ""
L["Tracks and manages your inventory across multiple characters including your bags, bank, and guild bank."] = "Unifie et gère l'inventaire de plusieurs personnages, y compris les sacs, banques et banques de guilde."
L["TradeSkillMaster Error Window"] = "Fenêtre d'erreur de TradeSkillMaster"
L["TradeSkillMaster Info:"] = "Informations de TradeSkillMaster:"
L["TradeSkillMaster Team"] = "Equipe TradeSkillMaster" -- Needs review
L["TSM Appearance Options"] = "Options d'affichage TSM" -- Needs review
-- L["TSM Assistant"] = ""
-- L["TSM Classic (by Jim Younkin - Power Word: Gold)"] = ""
-- L["TSMDeck (by Jim Younkin - Power Word: Gold)"] = ""
L["/tsm help|r - Shows this help listing"] = "/tsm help|r - Montre cette liste d'aide"
L["TSM Info / Help"] = "Infos/Aide de TSM"
L["/tsm|r - opens the main TSM window."] = "/tsm|r - Ouvre la fenêtre principale de TSM"
-- L["TSM Status / Options"] = ""
L["TSM Version Info:"] = "Infos sur la version de TSM" -- Needs review
L["TUJ GE - Market Average"] = "TUJ GE - Moyenne du marché" -- Needs review
L["TUJ GE - Market Median"] = "TUJ GE - Médiane du marché" -- Needs review
L["TUJ RE - Market Price"] = "TUJ RE - Prix du marché" -- Needs review
-- L["TUJ RE - Mean"] = ""
-- L["Type a raw material you would like to obtain via destroying in the search bar and start the search. For example: 'Ink of Dreams' or 'Spirit Dust'."] = ""
-- L["Type in the name of a new operation you wish to create with the same settings as this operation."] = ""
-- L["Type '/tsm' or click on the minimap icon to open the main TSM window."] = ""
L["Type '/tsm sources' to print out all available price sources."] = "Ecrivez '/tsm sources' pour afficher toutes les sources de prix disponibles." -- Needs review
-- L["Unbalanced parentheses."] = ""
-- L["Underneath the 'Posting Options' header, there are two settings which control the Quick Posting feature of TSM_Shopping. The first one is the duration which Quick Posting should use when posting your items to the AH. Change this to your preferred duration for Quick Posting."] = ""
-- L["Underneath the 'Posting Options' header, there are two settings which control the Quick Posting feature of TSM_Shopping. The second one is the price at which the Quick Posting will post items to the AH. This should generally not be a fixed gold value, since it will apply to every item. Change this setting to what you'd like to post items at with Quick Posting."] = ""
-- L["Underneath the serach bar at the top of the 'Shopping' AH tab are a handful of buttons which change what's displayed in the sidebar window. Click on the 'Custom Filter' one."] = ""
-- L["Underneath the serach bar at the top of the 'Shopping' AH tab are a handful of buttons which change what's displayed in the sidebar window. Click on the 'Other' one."] = ""
-- L["Underneath the serach bar at the top of the 'Shopping' AH tab are a handful of buttons which change what's displayed in the sidebar window. Click on the 'TSM Groups' one."] = ""
-- L["Under the search bar, on the left, you can switch between normal and destroy mode for TSM_Shopping. Switch to 'Destroy Mode' now."] = ""
-- L["Ungrouped Items:"] = ""
L["Usage: /tsm price <ItemLink> <Price String>"] = "Utilisation: /tsm price <ItemLink> <Price String>" -- Needs review
-- L["Use an existing group"] = ""
-- L["Use a subset of items from an existing group by creating a subgroup"] = ""
-- L["Use the button below to delete this group. Any subgroups of this group will also be deleted, with all items being returned to the parent of this group or removed completely if this group has no parent."] = ""
-- L["Use the editbox below to give this group a new name."] = ""
-- L["Use the group box below to move this group and all subgroups of this group. Moving a group will cause all items in the group (and its subgroups) to be removed from its current parent group and added to the new parent group."] = ""
L["Use the options below to change and tweak the appearance of TSM."] = "Utiliser les options ci-dessous pour changer et ajuster l'affichage de TSM." -- Needs review
-- L["Use the tabs above to select the module for which you'd like to configure operations and general options."] = ""
-- L["Use the tabs above to select the module for which you'd like to configure tooltip options."] = ""
-- L["Using our website you can get help with TSM, suggest features, and give feedback."] = ""
-- L["Various modules can sync their data between multiple accounts automatically whenever you're logged into both accounts."] = ""
L["Vendor Buy Price:"] = "Prix d'achat au marchand:" -- Needs review
L["Vendor Buy Price x%s:"] = "Prix d'achat au marchand x%s:" -- Needs review
L["Vendor Sell Price:"] = "Prix de vente au marchand:" -- Needs review
L["Vendor Sell Price x%s:"] = "Prix de vente au marchand x%s:" -- Needs review
L["Version:"] = "Version:"
-- L["View current auctions and choose what price to post at"] = ""
L["View Operation Options"] = "Voir les options de l'opération" -- Needs review
L["Visit %s for information about the different TradeSkillMaster modules as well as download links."] = "Visiter %s pour plus d'information sur les modules TradeSkillMaster ainsi que les liens de téléchargement."
-- L["Waiting for Scan to Finish"] = ""
L["Web Master and Addon Developer:"] = "Webmaster et dévelopeur de l'addon:" -- Needs review
-- L["We will add a %s operation to this group through its 'Operations' tab. Click on that tab now."] = ""
-- L["We will add items to this group through its 'Items' tab. Click on that tab now."] = ""
-- L["We will import items into this group using the import list you have."] = ""
-- L["What do you want to do?"] = ""
--[==[ L[ [=[When checked, random enchants will be ignored for ungrouped items.

NB: This will not affect parent group items that were already added with random enchants

If you have this checked when adding an ungrouped randomly enchanted item, it will act as all possible random enchants of that item.]=] ] = "" ]==]
-- L["When clicked, makes this group a top-level group with no parent."] = ""
L["Would you like to add this new operation to %s?"] = "Voulez-vous ajouter cette nouvelle opération à %s?" -- Needs review
-- L["Wrong number of item links."] = ""
-- L["You appear to be attempting to import an operation from a different module."] = ""
-- L["You can change the active database profile, so you can have different settings for every character."] = ""
--[==[ L[ [=[You can craft items either by clicking on rows in the queue which are green (meaning you can craft all) or blue (meaning you can craft some) or by clicking on the 'Craft Next' button at the bottom.

Click on the button below when you're done reading this. There is another guide which tells you how to buy mats required for your queue.]=] ] = "" ]==]
-- L["You can either create a new profile by entering a name in the editbox, or choose one of the already exisiting profiles."] = ""
-- L["You can hold shift while clicking this button to remove the items from ALL groups rather than keeping them in the parent group (if one exists)."] = ""
--[==[ L[ [=[You can look through the tooltips of the other options to see what they do and decide if you want to change their values for this operation.

Once you're done, click on the button below.]=] ] = "" ]==]
L["You cannot create a profile with an empty name."] = "Vous ne pouvez pas créer de profil avec un nom vide." -- Needs review
-- L["You cannot use %s as part of this custom price."] = ""
--[==[ L[ [=[You can now use the buttons near the bottom of the TSM_Crafting window to create this craft.

Once you're done, click the button below.]=] ] = "" ]==]
--[==[ L[ [=[You can use the filters at the top of the page to narrow down your search and click on a column to sort by that column. Then, left-click on a row to add one of that item to the queue, and right-click to remove one.

Once you're done adding items to the queue, click the button below.]=] ] = "" ]==]
--[==[ L[ [=[You can use this sidebar window to help build AH searches. You can also type the filter directly in the search bar at the top of the AH window.

Enter your filter and start the search.]=] ] = "" ]==]
-- L["You currently don't have any groups setup. Type '/tsm' and click on the 'TradeSkillMaster Groups' button to setup TSM groups."] = ""
-- L["You have closed the bankui. Use '/tsm bankui' to view again."] = ""
-- L["You have successfully completed this guide. If you require further assistance, visit out our website:"] = ""
