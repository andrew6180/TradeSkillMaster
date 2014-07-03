-- ------------------------------------------------------------------------------------- --
-- 					TradeSkillMaster_Crafting - AddOn by Sapu94							 	  	  --
--   http://wow.curse.com/downloads/wow-addons/details/TradeSkillMaster_Crafting.aspx   --
--																													  --
--		This addon is licensed under the CC BY-NC-ND 3.0 license as described at the		  --
--				following url: http://creativecommons.org/licenses/by-nc-nd/3.0/			 	  --
-- 	Please contact the author via email at sapu94@gmail.com with any questions or		  --
--		concerns regarding this license.																	  --
-- ------------------------------------------------------------------------------------- --

-- TradeSkillMaster_Crafting Locale - ptBR
-- Please use the localization app on CurseForge to update this
-- http://wow.curseforge.com/addons/TradeSkillMaster_Crafting/localization/

local L = LibStub("AceLocale-3.0"):NewLocale("TradeSkillMaster_Crafting", "ptBR")
if not L then return end

L["All"] = "Todos" -- Needs review
-- L["Are you sure you want to reset all material prices to the default value?"] = ""
-- L["Ask Later"] = ""
L["Auction House"] = "Casa de Leilão" -- Needs review
-- L["Available Sources"] = ""
-- L["Buy Vendor Items"] = ""
-- L["Characters (Bags/Bank/AH/Mail) to Ignore:"] = ""
-- L["Clear Filters"] = ""
L["Clear Queue"] = "Limpar fila"
-- L["Click Start Gathering"] = ""
-- L["Collect Mail"] = ""
L["Cost"] = "Custo" -- Needs review
-- L["Could not get link for profession."] = ""
L["Crafting Cost"] = "Custo de Produção"
-- L["Crafting Material Cost"] = ""
-- L["Crafting operations contain settings for restocking the items in a group. Type the name of the new operation into the box below and hit 'enter' to create a new Crafting operation."] = ""
-- L["Crafting will not queue any items affected by this operation with a profit below this value. As an example, a min profit of 'max(10g, 10% crafting)' would ensure atleast a 10g and 10% profit."] = ""
L["Craft Next"] = "Produzir próximo"
-- L["Craft Price Method"] = ""
-- L["Craft Queue"] = ""
-- L["Create Profession Groups"] = ""
-- L["Custom Price"] = ""
-- L["Custom Price for this item."] = ""
-- L["Custom Price per Item"] = ""
-- L["Default Craft Price Method"] = ""
-- L["Default Material Cost Method"] = ""
-- L["Default Price"] = ""
-- L["Default Price Settings"] = ""
-- L["Enchant Vellum"] = ""
-- L["Error creating operation. Operation with name '%s' already exists."] = ""
--[==[ L[ [=[Estimated Cost: %s
Estimated Profit: %s]=] ] = "" ]==]
-- L["Exclude Crafts with a Cooldown from Craft Cost"] = ""
-- L["Filters >>"] = ""
-- L["First select a crafter"] = ""
-- L["Gather"] = ""
-- L["Gather All Professions by Default if Only One Crafter"] = ""
L["Gathering"] = "Coleta"
-- L["Gathering Crafting Mats"] = ""
-- L["Gather Items"] = ""
L["General"] = "Geral"
L["General Settings"] = "Configurações Gerais" -- Needs review
-- L["Give the new operation a name. A descriptive name will help you find this operation later."] = ""
-- L["Guilds (Guild Banks) to Ignore:"] = ""
L["Here you can view and adjust how Crafting is calculating the price for this material."] = "Aqui você pode ver e ajustar como o Produção calcula o preço deste material." -- Needs review
L["<< Hide Queue"] = "<< Esconder a fila" -- Needs review
-- L["If checked, Crafting will never try and craft inks as intermediate crafts."] = ""
-- L["If checked, if there is more than one way to craft the item then the craft cost will exclude any craft with a daily cooldown when calculating the lowest craft cost."] = ""
-- L["If checked, if there is only one crafter for the craft queue clicking gather will gather for all professions for that crafter"] = ""
L["If checked, the crafting cost of items will be shown in the tooltip for the item."] = "Se marcado, o custo de produção dos itens será exibido na dica de interface do item." -- Needs review
-- L["If checked, the material cost of items will be shown in the tooltip for the item."] = ""
-- L["If checked, when the TSM_Crafting frame is shown (when you open a profession), the default profession UI will also be shown."] = ""
L["Inventory Settings"] = "Configurações de Invetário."
L["Item Name"] = "Nome do Item" -- Needs review
L["Items will only be added to the queue if the number being added is greater than this number. This is useful if you don't want to bother with crafting singles for example."] = "Itens somente serão adicionados à fila se o número a ser adicionado for maior que este número. Isto é útil se você não quer se preocupar em produzir um único item, por exemplo."
L["Item Value"] = "Valor do Item"
-- L["Left-Click|r to add this craft to the queue."] = ""
-- L["Link"] = ""
-- L["Mailing Craft Mats to %s"] = ""
-- L["Mail Items"] = ""
-- L["Mat Cost"] = ""
L["Material Cost Options"] = "Opções do Custo de Material" -- Needs review
-- L["Material Name"] = ""
-- L["Materials:"] = ""
L["Mat Price"] = "Preço do Material" -- Needs review
L["Max Restock Quantity"] = "Quatindade máxima de reestocagem" -- Needs review
-- L["Minimum Profit"] = ""
L["Min Restock Quantity"] = "Quantidade mínima para reabastecimento "
L["Name"] = "Nome"
L["Need"] = "Precisa" -- Needs review
-- L["Needed Mats at Current Source"] = ""
-- L["Never Queue Inks as Sub-Craftings"] = ""
-- L["New Operation"] = ""
-- L["<None>"] = ""
-- L["No Thanks"] = ""
-- L["Nothing To Gather"] = ""
-- L["Nothing to Mail"] = ""
-- L["Now select your profession(s)"] = ""
L["Number Owned"] = "Número possuído" -- Needs review
-- L["Opens the Crafting window to the first profession."] = ""
-- L["Operation Name"] = ""
-- L["Operations"] = ""
L["Options"] = "Opções" -- Needs review
-- L["Override Default Craft Price Method"] = ""
L["Percent to subtract from buyout when calculating profits (5% will compensate for AH cut)."] = "Porcentagem a ser subtraída do arremate quando calcular os lucros (5% compensará a comissão da CL)"
-- L["Please switch to the Shopping Tab to perform the gathering search."] = ""
L["Price:"] = "Preço:" -- Needs review
L["Price Settings"] = "Configurações de Preço"
-- L["Price Source Filter"] = ""
-- L["Profession data not found for %s on %s. Logging into this player and opening the profression may solve this issue."] = ""
-- L["Profession Filter"] = ""
-- L["Professions"] = ""
-- L["Professions Used In"] = ""
L["Profit"] = "Lucro" -- Needs review
L["Profit Deduction"] = "Redução do Lucro" -- Needs review
-- L["Profit (Total Profit):"] = ""
-- L["Queue"] = ""
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
L["Show Crafting Cost in Tooltip"] = "Mostar Custo de Produção na Dica de Interface" -- Needs review
-- L["Show Default Profession Frame"] = ""
-- L["Show Material Cost in Tooltip"] = ""
L["Show Queue >>"] = "Mostrar Fila >>" -- Needs review
-- L["'%s' is an invalid operation! Min restock of %d is higher than max restock of %d."] = ""
L["%s (%s profit)"] = "%s (%s lucro)" -- Needs review
-- L["Stage %d"] = ""
-- L["Start Gathering"] = ""
-- L["Stop Gathering"] = ""
-- L["This is the default method Crafting will use for determining craft prices."] = ""
-- L["This is the default method Crafting will use for determining material cost."] = ""
L["Total"] = "Total" -- Needs review
-- L["TSM Groups"] = ""
L["Vendor"] = "Vendedor"
-- L["Visit Bank"] = ""
-- L["Visit Guild Bank"] = ""
-- L["Visit Vendor"] = ""
L["Warning: The min restock quantity must be lower than the max restock quantity."] = "Atenção: A quantidade de reabastecimento mínima deve ser menor que a quantidade de reabastecimento máxima." -- Needs review
L["When you click on the \"Restock Queue\" button enough of each craft will be queued so that you have this maximum number on hand. For example, if you have 2 of item X on hand and you set this to 4, 2 more will be added to the craft queue."] = "Quando você clica no botão \"Fila de Reabastecimento\" serão enfileirados a quantidade suficiente de cada produto para que você tenha esse número máximo em mãos. Por exemplo, se você tem 2 do item X em mãos e configurou para 4, mais 2 serão adicionados à fila de produção." -- Needs review
-- L["Would you like to automatically create some TradeSkillMaster groups for this profession?"] = ""
L["You can click on one of the rows of the scrolling table below to view or adjust how the price of a material is calculated."] = "Você pode clicar em uma das linhas da tabela rolante abaixo para visualizar ou ajustar como o preço de um material é calculado."
 