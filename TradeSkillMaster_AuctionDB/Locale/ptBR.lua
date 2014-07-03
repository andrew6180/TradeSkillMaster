-- ------------------------------------------------------------------------------ --
--                           TradeSkillMaster_AuctionDB                           --
--           http://www.curse.com/addons/wow/tradeskillmaster_auctiondb           --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- TradeSkillMaster_AuctionDB Locale - ptBR
-- Please use the localization app on CurseForge to update this
-- http://wow.curseforge.com/addons/TradeSkillMaster_AuctionDB/localization/

local L = LibStub("AceLocale-3.0"):NewLocale("TradeSkillMaster_AuctionDB", "ptBR")
if not L then return end

L["A full auction house scan will scan every item on the auction house but is far slower than a GetAll scan. Expect this scan to take several minutes or longer."] = "Um escaneamento completo da casa de leilões irá escanear todos os itens da casa de leilões, porém é bem mais lento que um escaneamento PegaTudo. Espere que este escaneamento demore vários minutos ou mais."
-- L["A GetAll scan is the fastest in-game method for scanning every item on the auction house. However, there are many possible bugs on Blizzard's end with it including the chance for it to disconnect you from the game. Also, it has a 15 minute cooldown."] = ""
L["Any items in the AuctionDB database that contain the search phrase in their names will be displayed."] = "Qualquer item no bando de dados do AuctionDB que contém a frase procurada em seus nomes serão exibidos."
L["Are you sure you want to clear your AuctionDB data?"] = "Você tem certeza de que quer limpar os dados do seu AuctionDB?"
L["Ascending"] = "Crescente"
L["AuctionDB - Market Value"] = "AuctionDB - Valor de Mercado"
L["AuctionDB - Minimum Buyout"] = "AuctionDB - Arremate Mínimo"
-- L["Can't run a GetAll scan right now."] = ""
L["Descending"] = "Decrescente"
-- L["Display lowest buyout value seen in the last scan in tooltip."] = ""
-- L["Display market value in tooltip."] = ""
-- L["Display number of items seen in the last scan in tooltip."] = ""
-- L["Display total number of items ever seen in tooltip."] = ""
L["Done Scanning"] = "Escaneamento Completo"
-- L["Download the FREE TSM desktop application which will automatically update your TSM_AuctionDB prices using Blizzard's online APIs (and does MUCH more). Visit %s for more info and never scan the AH again! This is the best way to update your AuctionDB prices."] = ""
L["Enable display of AuctionDB data in tooltip."] = "Habilita a exibição de dados do AuctionDB nas dicas de interface."
-- L["GetAll scan did not run successfully due to issues on Blizzard's end. Using the TSM application for your scans is recommended."] = ""
L["Hide poor quality items"] = "Esconder itens de qualidade inferior"
L["If checked, poor quality items won't be shown in the search results."] = "Se marcado, itens de qualidade inferior não serão exibidos nos resultados das buscas."
-- L["If checked, the lowest buyout value seen in the last scan of the item will be displayed."] = ""
-- L["If checked, the market value of the item will be displayed"] = ""
-- L["If checked, the number of items seen in the last scan will be displayed."] = ""
-- L["If checked, the total number of items ever seen will be displayed."] = ""
-- L["Imported %s scans worth of new auction data!"] = ""
L["Invalid value entered. You must enter a number between 5 and 500 inclusive."] = "Valor inválido. Você deve digitar um número entre 5 e 500 (inclusive)."
L["Item Link"] = "Link do Item"
L["Item MinLevel"] = "NívelMín do Item"
L["Items per page"] = "Itens por página"
L["Items %s - %s (%s total)"] = "Itens %s - %s (%s no total)"
L["Item SubType Filter"] = "Filtro de SubTipo de Item"
L["Item Type Filter"] = "Filtro de Tipo de Item"
L["It is strongly recommended that you reload your ui (type '/reload') after running a GetAll scan. Otherwise, any other scans (Post/Cancel/Search/etc) will be much slower than normal."] = "É altamente recomendado que você recarregue sua IU (digite '/reload') após rodar um escaneamento PegaTudo. De outra forma, qualquer outro escaneamento (Postagem/Cancelamento/Busca/etc) será muito mais lento que o normal."
L["Last Scanned"] = "Escaneado pela última vez"
-- L["Last updated from in-game scan %s ago."] = ""
-- L["Last updated from the TSM Application %s ago."] = ""
L["Market Value"] = "Valor de Mercado"
L["Market Value:"] = "Preço de mercado"
-- L["Market Value x%s:"] = ""
L["Min Buyout:"] = "Arremate minimo"
-- L["Min Buyout x%s:"] = ""
L["Minimum Buyout"] = "Arremate Mínimo"
L["Next Page"] = "Próxima Página"
L["No items found"] = "Nenhum item encontrado"
-- L["No scans found."] = ""
L["Not Ready"] = "Não está pronto"
-- L["Not Scanned"] = ""
L["Num(Yours)"] = "Num(Seu)"
L["Options"] = "Opções"
L["Previous Page"] = "Página anterior"
-- L["Processing data..."] = ""
L["Ready"] = "Pronto"
L["Ready in %s min and %s sec"] = "Pronto em $s min e %s seg"
L["Refreshes the current search results."] = "Refrescar os resultados da busca atual."
L["Removed %s from AuctionDB."] = "%s removido do AuctionDB."
L["Reset Data"] = "Redefinir Dados"
L["Resets AuctionDB's scan data"] = "Redefine os dados de escaneamento do AuctionDB"
L["Result Order:"] = "Order de Resultado"
L["Run Full Scan"] = "Escaneamento Completo" -- Needs review
L["Run GetAll Scan"] = "PegaTudo" -- Needs review
-- L["Running query..."] = ""
L["%s ago"] = "%s atrás"
L["Scanning page %s/%s"] = "Escaneando página %s/%s" -- Needs review
L["Scanning the auction house in game is no longer necessary!"] = "Escanear a Casa de Leilões não é mais necessário." -- Needs review
L["Search"] = "Buscar"
L["Search Options"] = "Opções de Busca"
L["Seen Last Scan:"] = "Visto no ultimo Escaneamento"
L["Select how you would like the search results to be sorted. After changing this option, you may need to refresh your search results by hitting the \"Refresh\" button."] = "Selecione como você gostaria que os resultados da busca sejam ordenados. Depois de alterar esta opção você deve refrescar os resultados de sua busca clicando no botão \"Refrescar\"."
L["Select whether to sort search results in ascending or descending order."] = "Selecione para mostrar os resultados em ordem crescente ou decrescente"
L["Shift-Right-Click to clear all data for this item from AuctionDB."] = "Shift-Clique-Direito para limpar todos os dados para este item do AuctionDB."
L["Sort items by"] = "Ordenar items por"
L["This determines how many items are shown per page in results area of the \"Search\" tab of the AuctionDB page in the main TSM window. You may enter a number between 5 and 500 inclusive. If the page lags, you may want to decrease this number."] = "Determina quantos itens são mostrados por página na área de resultados da aba \"Busca\" da página do AuctionDB na janela principal do TSM. Você pode digitar um número entre 5 e 500 (inclusive). Se houver demora na página você pode querer diminuir este número."
L["Total Seen Count:"] = "Total de vezes visto"
L["Use the search box and category filters above to search the AuctionDB data."] = "Use a caixa de busca e filtros de categoria acima para procurar nos dados do AuctionDB."
L["You can filter the results by item subtype by using this dropdown. For example, if you want to search for all herbs, you would select \"Trade Goods\" in the item type dropdown and \"Herbs\" in this dropdown."] = "Você pode filtrar os resultados por subtipo de item usando esta opção. Por exemplo, se você quer procurar todas as ervas você deve selecionar \"Mercadorias\" no menu de tipo de item e \"Ervas\" neste menu."
L["You can filter the results by item type by using this dropdown. For example, if you want to search for all herbs, you would select \"Trade Goods\" in this dropdown and \"Herbs\" as the subtype filter."] = "Você pode filtrar os resultados por tipo de item usando esta opção. Por exemplo, se você quer procurar todas as ervas você deve selecionar \"Mercadorias\" neste menu e \"Ervas\" no menu de subtipo. "
L["You can use this page to lookup an item or group of items in the AuctionDB database. Note that this does not perform a live search of the AH."] = "Você pode usar esta página para procurar por um item ou grupo de itens no banco de dados do AuctionDB. Observe que isto não executará uma pesquisa ao vivo na CL."
 