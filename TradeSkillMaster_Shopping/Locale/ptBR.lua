-- ------------------------------------------------------------------------------ --
--                            TradeSkillMaster_Shopping                           --
--            http://www.curse.com/addons/wow/tradeskillmaster_shopping           --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- TradeSkillMaster_Shopping Locale - ptBR
-- Please use the localization app on CurseForge to update this
-- http://wow.curseforge.com/addons/TradeSkillMaster_Shopping/localization/

local L = LibStub("AceLocale-3.0"):NewLocale("TradeSkillMaster_Shopping", "ptBR")
if not L then return end

L["Action"] = "Ação"
L["Added '%s' to your favorite searches."] = "Adicionado '%s' para pesquisas favoritas."
-- L["Below Custom Price ('0c' to disable)"] = ""
-- L["Below Max Price"] = ""
-- L["Below Vendor Sell Price"] = ""
L["Bid Percent"] = "Lance Percentual"
L["Buyout"] = "Arremate"
L[ [=[Click to search for an item.
Shift-Click to post at market value.]=] ] = [=[Click para procurar um item.
Shift-Click para postar com valor de mercado.]=]
L["Custom Filter"] = "Filtros" -- Needs review
L["Default Post Undercut Amount"] = "Post com valor de corte padrão "
L["Destroy Mode"] = "Modo destruir"
-- L["% DE Value"] = ""
-- L["Disenchant Search Profit: %s"] = ""
L["Done Scanning"] = "Escaneamento concluído"
L["Enter what you want to search for in this box. You can also use the following options for more complicated searches."] = "Digite o que você quer procurar no campo abaixo. Você pode também usar as seguintes opções para pesquisas mais complexas."
L["Error creating operation. Operation with name '%s' already exists."] = "Erro ao criar operação. Operação com o nome '%s' já existe."
L["Even (5/10/15/20) Stacks Only"] = "Apenas pilhas de (5/10/15/20)"
L["Favorite Searches"] = "Pesquisas favoritas"
L["General"] = "Geral"
L["General Operation Options"] = "Opções gerais de operação"
L["General Options"] = "Opções Gerais"
L["General Settings"] = "Configurações gerais"
L["Give the new operation a name. A descriptive name will help you find this operation later."] = "Dê um nome a nova operação. Um nome descritivo irá ajudá-lo a encontrar esta operação mais tarde."
L["Hide Grouped Items"] = "Esconder itens agrupados"
L["If checked, auctions above the max price will be shown."] = "Se marcado, leilões acima do preço máximo serão mostradas."
L["If checked, only auctions posted in even quantities will be considered for purchasing."] = "Se marcada, somente leilões postados nas mesmas quantidades serão consideradas para compra."
-- L["If checked, the maximum shopping price will be shown in the tooltip for the item."] = ""
L["If set, only items which are usable by your character will be included in the results."] = "Se definido, apenas os itens que são utilizáveis por seu personagem serão incluídos nos resultados."
L["If set, only items which exactly match the search filter you have set will be included in the results."] = "Se definido, apenas os itens que correspondem exatamente ao filtro de pesquisa que você definiu serão incluído nos resultados."
L["Import"] = "Importar"
L["Import Favorite Search"] = "Importar pesquisas favoritas"
L["Inline Filters:|r You can easily add common search filters to your search such as rarity, level, and item type. For example '%sarmor/leather/epic/85/i350/i377|r' will search for all leather armor of epic quality that requires level 85 and has an ilvl between 350 and 377 inclusive. Also, '%sinferno ruby/exact|r' will display only raw inferno rubys (none of the cuts)."] = "Filtro deLinhas:|r Você pode facilmente adicionar filtros de pesquisa comuns à sua pesquisa, como raridade, nível e tipo de item. Exemplo '%s85/90/i350/i553/Armadura/Couro/Épico|r' irá procurar por todas armaduras de couro épicas que requerem nível entre entre 85 e 90, e tenham ilvl entre 350 e 553. Ou '%sRubi Infernal/exact|r' irá mostrar apenas minérios de Rubis Infernais."
L["Invalid custom price source for %s. %s"] = "Fonte de preço personalizado pra %s inválido. %s"
L["Invalid destroy search: '%s'"] = "Pesquisa destrutiva inválida: '%s'"
L["Invalid destroy target: '%s'"] = "Destruir alvo inválido: '%s'"
L["Invalid Even Only Filter"] = "'Mesmo filtro apenas' inválido" -- Needs review
L["Invalid Exact Only Filter"] = "Filtro exato inválido" -- Needs review
L["Invalid Filter"] = "Filtro inválido"
L["Invalid Item Level"] = "Nível do item inválido"
L["Invalid Item Rarity"] = "Raridade do item Inválido"
L["Invalid Item SubType"] = "Subtipo do item inválido"
L["Invalid Item Type"] = "Tipo de item inválido"
L["Invalid Max Quantity"] = "Quantidade máxima inválida."
L["Invalid Min Level"] = "Nível mínimo inválido"
L["Invalid target item for destroy search: '%s'"] = "item alvo para procura destrutiva inválido: '%s'"
L["Invalid Usable Only Filter"] = "Filtro 'item usável' inválido" -- Needs review
L["Item"] = "Item"
L["Item Class"] = "Classe de item"
L["Item Level Range:"] = "Intervalo de nível do item" -- Needs review
L["Item SubClass"] = "Subclasse do item" -- Needs review
-- L["Items which are below their maximum price (per their group / Shopping operation) will be displayed in Sniper searches."] = ""
-- L["Items which are below their vendor sell price will be displayed in Sniper searches."] = ""
-- L["Items which are below this custom price will be displayed in Sniper searches."] = ""
L["Left-Click to run this search."] = "Click-esquerdo para executar esta pesquisa" -- Needs review
L["Log"] = "Log" -- Needs review
-- L["Management"] = ""
L["% Market Value"] = "% do Valor de Mercado"
L["Market Value Price Source"] = "Fonte de preço: Valor de mercado" -- Needs review
-- L["% Mat Price"] = ""
-- L["Max Disenchant Search Percent"] = ""
L["Maximum Auction Price (per item)"] = "Preço máximo do leilão (por item)" -- Needs review
L["Maximum quantity purchased for destroy search."] = "Quantidade máxima comprada para pesquisa destrutiva." -- Needs review
L["Maximum quantity purchased for %s."] = "Quantidade máxima comprada por %s" -- Needs review
L["Maximum Quantity to Buy:"] = "Quantidade máxima de compra:" -- Needs review
L["% Max Price"] = "% do Preço Máx"
-- L["Max Shopping Price:"] = ""
L["Minimum Rarity"] = "Raridade mínima" -- Needs review
-- L["Multiple Search Terms:|r You can search for multiple things at once by simply separated them with a ';'. For example '%selementium ore; obsidium ore|r' will search for both elementium and obsidium ore."] = ""
L["New Operation"] = "Nova operação" -- Needs review
L["No recent AuctionDB scan data found."] = "Nenhum dado de pesquisa LeilãoDB recente encontrado." -- Needs review
L["Normal Mode"] = "Modo Normal" -- Needs review
L["Normal Post Price"] = "Preço de post normal" -- Needs review
-- L["NOTE: The scan must be stopped before you can buy anything."] = ""
L["Num"] = "Num." -- Needs review
L["Operation Name"] = "Nome da operação" -- Needs review
L["Operations"] = "Operações" -- Needs review
L["Options"] = "Opções"
L["Other"] = "Outros" -- Needs review
L["Paste the search you'd like to import into the box below."] = "Cole a pesquisa que você gostaria de importar na caixa abaixo." -- Needs review
-- L["Posted a %s with a buyuot of %s."] = ""
L["Preparing Filter %d / %d"] = "Preparando filtro %d / %d" -- Needs review
L["Preparing filters..."] = "Preparando filtros..." -- Needs review
L["Press Ctrl-C to copy this saved search."] = "Pressione Ctrl-C para copiar esta pesquisa salva" -- Needs review
L["Price"] = "Preço" -- Needs review
L["Quick Posting"] = "Post rápido"
L["Quick Posting Duration"] = "Duração de postagem rápida" -- Needs review
L["Quick Posting Price"] = "Preço de postagem rápida" -- Needs review
L["Recent Searches"] = "Pesquisas recentes"
L["Relationships"] = "Relacionamentos" -- Needs review
L["Removed '%s' from your favorite searches."] = "Removido '%s' de suas pesquisas favoritas." -- Needs review
L["Removed '%s' from your recent searches."] = "Removido '%s' de suas pesquisas recentes." -- Needs review
L["Required Level Range:"] = "Intervalo de nível requerido:" -- Needs review
L["Reset Filters"] = "Redefinir filtros" -- Needs review
L["Right-Click to favorite this recent search."] = "Click-Direito para favoritar esta pesquisa recente" -- Needs review
L["Right-Click to remove from favorite searches."] = "Click-Direito para remover das pesquisas favoritas." -- Needs review
L["Saved Searches"] = "Pesquisas salvas"
-- L["Scanning %d / %d (Page %d / %d)"] = ""
L["Search Filter:"] = "Filtro de pesquisa:" -- Needs review
L["Select the groups which you would like to include in the search."] = "Selecione os grupos que você gostaria de incluir na pesquisa." -- Needs review
L["'%s' has a Shopping operation of '%s' which no longer exists. Shopping will ignore this group until this is fixed."] = "'%s'  tem uma operação de compra de '%s' que não existe mais. Shopping irá ignorar este grupo até que isso seja corrigido."
L["Shift-Left-Click to export this search."] = "Shift-Click-Esquerdo para exportar esta pesquisa." -- Needs review
L["Shift-Right-Click to remove this recent search."] = "Shift-Click-Direito para remover esta pesquisa recente." -- Needs review
L["Shopping for auctions including those above the max price."] = "Compras de leilões incluindo aqueles acima do preço máximo." -- Needs review
L["Shopping for auctions with a max price set."] = "Compras de leilões com um preço máximo definido." -- Needs review
-- L["Shopping for even stacks including those above the max price"] = ""
-- L["Shopping for even stacks with a max price set."] = ""
-- L["Shopping operations contain settings items which you regularly buy from the auction house."] = ""
-- L["Show Auctions Above Max Price"] = ""
-- L["Show Shopping Max Price in Tooltip"] = ""
-- L["Sidebar Pages:"] = ""
L["Skipped the following search term because it's invalid."] = "Pulado o seguinte termo de pesquisa, porque é inválido."
L["Skipped the following search term because it's too long. Blizzard does not allow search terms over 63 characters."] = "Pulado o seguinte termo de pesquisa, pois é muito longo. Blizzard não permite termos de pesquisa com mais de 63 caracteres."
-- L["Sniper Options"] = ""
-- L["Start Disenchant Search"] = ""
L["Start Search"] = "Iniciar pesquisa" -- Needs review
-- L["Start Sniper"] = ""
L["Start Vendor Search"] = "Iniciar pesquisa de vendedor" -- Needs review
-- L["Stop"] = ""
-- L["Stop Sniper"] = ""
L["% Target Value"] = "% do valor alvo"
-- L["The disenchant search looks for items on the AH below their disenchant value. You can set the maximum percentage of disenchant value to search for in the Shopping General options"] = ""
-- L["The duration at which items will be posted via the 'Quick Posting' frame."] = ""
-- L["The highest price per item you will pay for items in affected by this operation."] = ""
-- L["The Sniper feature will look in real-time for items that have recently been posted to the AH which are worth snatching! You can configure the parameters of Sniper in the Shopping options."] = ""
-- L["The vendor search looks for items on the AH below their vendor sell price."] = ""
-- L["This is how Shopping calculates the '% Market Value' column in the search results."] = ""
-- L["This is the default price Shopping will suggest to post items at when there's no others posted."] = ""
-- L["This is the maximum percentage of disenchant value that the Other > Disenchant search will display results for."] = ""
-- L["This is the percentage of your buyout price that your bid will be set to when posting auctions with Shopping."] = ""
-- L["This price is used to determine what items will be posted at through the 'Quick Posting' frame."] = ""
-- L["TSM Groups"] = ""
L["Unknown Filter"] = "Filtro desconhecido"
-- L["Unknown milling search target: '%s'"] = ""
L["% Vendor Price"] = "% de preço de vendedor "
-- L["Vendor Search Profit: %s"] = ""
-- L["What to set the default undercut to when posting items with Shopping."] = ""
-- L["When in destroy mode, you simply enter a target item (ink/pigment, enchanting mat, gem, etc) into the search box to search for everything you can destroy to get that item."] = ""
-- L["When in normal mode, you may run simple and filtered searches of the auction house."] = ""
 