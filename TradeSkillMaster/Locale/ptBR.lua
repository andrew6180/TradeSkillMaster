-- ------------------------------------------------------------------------------ --
--                                TradeSkillMaster                                --
--                http://www.curse.com/addons/wow/tradeskill-master               --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- TradeSkillMaster Locale - ptBR
-- Please use the localization app on CurseForge to update this
-- http://wow.curseforge.com/addons/TradeSkill-Master/localization/

local L = LibStub("AceLocale-3.0"):NewLocale("TradeSkillMaster", "ptBR")
if not L then return end

-- L["Act on Scan Results"] = ""
L["A custom price of %s for %s evaluates to %s."] = "O preço personalizado de %s para %s calcula em %s." -- Needs review
L["Add >>>"] = "Adicionar >>>"
L["Add Additional Operation"] = "Adicionar Operação" -- Needs review
-- L["Add Items to this Group"] = ""
L["Additional error suppressed"] = "Erro adicional suprimido"
-- L["Adjust Post Parameters"] = ""
-- L["Advanced Option Text"] = ""
-- L["Advanced topics..."] = ""
L["A group is a collection of items which will be treated in a similar way by TSM's modules."] = "Um grupo é uma coleção de itens que serão tradados de uma forma similar pelos módulos do TSM." -- Needs review
L["All items with names containing the specified filter will be selected. This makes it easier to add/remove multiple items at a time."] = "Todos os itens com nomes contendo o filtro especificado serão selecionadas. Facilita a adição/remoção de múltiplos itens ao mesmo tempo."
L["Allows for testing of custom prices."] = "Permite o teste de preços personalizados." -- Needs review
L["Allows you to build a queue of crafts that will produce a profitable, see what materials you need to obtain, and actually craft the items."] = "Permite a você construir uma fila de fabricações que irão produzir um lucro, veja quais materiais você precisa obter, e então fabrique os itens."
L["Allows you to quickly and easily empty your mailbox as well as automatically send items to other characters with the single click of a button."] = "Permite que você rapidamente e facilmente esvazie a sua caixa de correio, bem como enviar automaticamente itens para outros personagens com o único clique de um botão."
L["Allows you to use data from http://wowuction.com in other TSM modules and view its various price points in your item tooltips."] = "Permite que você use os dados de http://wowuction.com em outros módulos do TSM e que veja os diversos pontos de preço nos balões de informações dos itens." -- Needs review
-- L["Along the bottom of the AH are various tabs. Click on the 'Auctioning' AH tab."] = ""
-- L["Along the bottom of the AH are various tabs. Click on the 'Shopping' AH tab."] = ""
-- L["Along the top of the TSM_Crafting window, click on the 'Professions' button."] = ""
-- L["Along the top of the TSM_Crafting window, click on the 'TSM Groups' button."] = ""
-- L["Along top of the window, on the left side, click on the 'Groups' icon to open up the TSM group settings."] = ""
-- L["Along top of the window, on the left side, click on the 'Module Operations / Options' icon to open up the TSM module settings."] = ""
-- L["Along top of the window, on the right side, click on the 'Crafting' icon to open up the TSM_Crafting page."] = ""
L["Alt-Click to immediately buyout this auction."] = "Alt-Clique para arrematar imediatamente este leilão." -- Needs review
L["A maximum of 1 convert() function is allowed."] = "É permitido no máximo 1 função convert()." -- Needs review
L["A maximum of 1 gold amount is allowed."] = "É permitido no máximo 1 quantia em ouro." -- Needs review
L["Any subgroups of this group will also be deleted, with all items being returned to the parent of this group or removed completely if this group has no parent."] = "Qualquer subgrupo deste grupo também será apagado, com todos os itens retornados para o pai deste grupo ou removido completamente se o grupo não tiver um pai." -- Needs review
L["Appearance Data"] = "Dados das Definições de Aparência" -- Needs review
L["Application and Addon Developer:"] = "Desenvolvedor da Aplicação e do Addon:"
L["Applied %s to %s."] = "Aplicado %s em %s."
L["Apply Operation to Group"] = "Aplicar Operação para Grupo"
L["Are you sure you want to delete the selected profile?"] = "Tem certeza de que deseja excluir o perfil selecionado?" -- Needs review
L["A simple, fixed gold amount."] = "Uma simples, quantia fixa em ouro."
-- L["Assign this operation to the group you previously created by clicking on the 'Yes' button in the popup that's now being shown."] = ""
-- L["A TSM_Auctioning operation will allow you to set rules for how auctionings are posted/canceled/reset on the auction house. To create one for this group, scroll down to the 'Auctioning' section, and click on the 'Create Auctioning Operation' button."] = ""
-- L["A TSM_Crafting operation will allow you automatically queue profitable items from the group you just made. To create one for this group, scroll down to the 'Crafting' section, and click on the 'Create Crafting Operation' button."] = ""
-- L["A TSM_Shopping operation will allow you to set a maximum price we want to pay for the items in the group you just made. To create one for this group, scroll down to the 'Shopping' section, and click on the 'Create Shopping Operation' button."] = ""
-- L["At the top, switch to the 'Crafts' tab in order to view a list of crafts you can make."] = ""
L["Auctionator - Auction Value"] = "Auctionator - Valor de Leilão"
L["Auction Buyout:"] = "Arremate do Leilão:" -- Needs review
L["Auction Buyout: %s"] = "Arremate do Leilão: %s" -- Needs review
L["Auctioneer - Appraiser"] = "Auctioneer - Avaliador"
L["Auctioneer - Market Value"] = "Auctioneer - Valor de Mercado"
L["Auctioneer - Minimum Buyout"] = "Auctioneer - Arremate Mínimo"
L["Auction Frame Scale"] = "Escala do Quadro de Leilão"
L["Auction House Tab Settings"] = "Definições da Aba da Casa de Leilões"
L["Auction not found. Skipped."] = "Leilão não encontrado. Pulado." -- Needs review
L["Auctions"] = "Leilões" -- Needs review
L["Author(s):"] = "Autor(es):"
L["BankUI"] = "IUBanco" -- Needs review
L["Below are various ways you can set the value of the current editbox. Any combination of these methods is also supported."] = "Abaixo estão várias formas que você pode definir o valor da caixa de edição atual. Qualquer combinação desses métodos é também suportada." -- Needs review
L["Below are your currently available price sources. The %skey|r is what you would type into a custom price box."] = "Abaixo estão suas fontes de preços atualmente disponíveis. A %schave|r é o que você deve digitar na caixa de edição de um preço personalizado." -- Needs review
-- L["Below is a list of groups which this operation is currently applied to. Clicking on the 'Remove' button next to the group name will remove the operation from that group."] = ""
-- L["Below, set the custom price that will be evaluated for this custom price source."] = ""
L["Border Thickness (Requires Reload)"] = "Largura de Borda (Necessário Recarregamento)" -- Needs review
L["Buy from Vendor"] = "Comprar do Vendedor"
-- L["Buy items from the AH"] = ""
-- L["Buy materials for my TSM_Crafting queue"] = ""
L["Canceling Auction: %d/%d"] = "Cancelando Leilão: %d/%d"
L["Cancelled - Bags and bank are full"] = "Cancelado - Bolsas e banco estão cheios"
L["Cancelled - Bags and guildbank are full"] = "Cancelado - Bolsas e banco da guilda estão cheios"
L["Cancelled - Bags are full"] = "Cancelado - Bolsas estão cheias"
L["Cancelled - Bank is full"] = "Cancelado - Banco está cheio"
L["Cancelled - Guildbank is full"] = "Cancelado - Banco da guilda está cheio"
L["Cancelled - You must be at a bank or guildbank"] = "Cancelado - Você deve estar no banco ou no banco da guilda"
L["Cannot delete currently active profile!"] = "Não é possível excluir o perfil ativo no momento!"
L["Category Text 2 (Requires Reload)"] = "Texto das Categorias 2 (Necessário Recarregamento)" -- Needs review
L["Category Text (Requires Reload)"] = "Texto das Categorias (Necessário Recarregamento)" -- Needs review
-- L["|cffffff00DO NOT report this as an error to the developers.|r If you require assistance with this, make a post on the TSM forums instead."] = ""
L[ [=[|cffffff00Important Note:|r You do not currently have any modules installed / enabled for TradeSkillMaster! |cff77ccffYou must download modules for TradeSkillMaster to have some useful functionality!|r

Please visit http://www.curse.com/addons/wow/tradeskill-master and check the project description for links to download modules.]=] ] = [=[|cffffff00Nota Importante:|r Vc não tem nenhum módulo instalado / Ative-o pro TradeSkillMaster! |cff77ccffVc deve baixa-los pro TradeSkillMaster ter alguma função!|r

Por favor, visite http://www.curse.com/addons/wow/tradeskill-master e verifique a descrição do projeto para os links dos módulos.]=] -- Needs review
L["Changes how many rows are shown in the auction results tables."] = "Ajusta quantas linhas devem ser exibidas na tabela de resultados busca de leilão." -- Needs review
L["Changes the size of the auction frame. The size of the detached TSM auction frame will always be the same as the main auction frame."] = "Altera o tamanho do quadro de leilão. O tamanho do quadro separado de leilão do TSM sempre será do mesmo tamanho do quadro de leilão principal."
L["Character Name on Other Account"] = "Nome do personagem na outra conta"
-- L["Chat Tab"] = ""
L["Check out our completely free, desktop application which has tons of features including deal notification emails, automatic updating of AuctionDB and WoWuction prices, automatic TSM setting backup, and more! You can find this app by going to %s."] = "Confira nosso aplicativo para desktop, totalmente gratuito, que tem inúmeros recursos incluindo notificações de negócios por e-mail, atualização automática de preços do AuctionDB e WoWuction, cópia de segurança automática do TSM e mais! Você pode encontrar este app indo em %s." -- Needs review
L["Check this box to override this group's operation(s) for this module."] = "Marque esta caixa para sobrescrever as operações deste grupo para este módulo." -- Needs review
L["Clear"] = "Limpar"
L["Clear Selection"] = "Limpar Seleção"
-- L["Click on the Auctioning Tab"] = ""
-- L["Click on the Crafting Icon"] = ""
-- L["Click on the Groups Icon"] = ""
-- L["Click on the Module Operations / Options Icon"] = ""
-- L["Click on the Shopping Tab"] = ""
-- L["Click on the 'Show Queue' button at the top of the TSM_Crafting window to show the queue if it's not already visible."] = ""
-- L["Click on the 'Start Sniper' button in the sidebar window."] = ""
-- L["Click on the 'Start Vendor Search' button in the sidebar window."] = ""
L["Click the button below to open the export frame for this group."] = "Clique no botão abaixo para abrir o quadro de exportação para este grupo."
-- L["Click this button to completely remove this operation from the specified group."] = ""
L["Click this button to configure the currently selected operation."] = "Clique neste botão para configurar a operação selecionada." -- Needs review
L["Click this button to create a new operation for this module."] = "Clique neste botão para criar uma nova operação para este módulo." -- Needs review
L["Click this button to show a frame for easily exporting the list of items which are in this group."] = "Clique neste botão para mostrar um quadro que permite exportar facilmente a lista de itens que estão neste grupo" -- Needs review
L["Co-Founder:"] = "Co-Fundador:"
L["Coins:"] = "Moedas:"
-- L["Color Group Names by Depth"] = ""
L["Content - Backdrop"] = "Conteúdo - Fundo" -- Needs review
L["Content - Border"] = "Conteúdo - Borda"
L["Content Text - Disabled"] = "Texto do Conteúdo - Desativado" -- Needs review
L["Content Text - Enabled"] = "Texto do Conteúdo - Ativado" -- Needs review
L["Copy From"] = "Copiar De"
L["Copy the settings from one existing profile into the currently active profile."] = "Copiar a configuração de uma existente dentro do perfil ativo." -- Needs review
-- L["Craft Items from Queue"] = ""
-- L["Craft items with my professions"] = ""
-- L["Craft specific one-off items without making a queue"] = ""
L["Create a new empty profile."] = "Criar um perfil vazio."
-- L["Create a New Group"] = ""
-- L["Create a new group by typing a name for the group into the 'Group Name' box and pressing the <Enter> key."] = ""
-- L["Create a new %s operation by typing a name for the operation into the 'Operation Name' box and pressing the <Enter> key."] = ""
-- L["Create a %s Operation %d/5"] = ""
L["Create New Subgroup"] = "Criar novo subgrupo"
L["Create %s Operation"] = "Criar %s operações" -- Needs review
-- L["Create the Craft"] = ""
L["Creating a relationship for this setting will cause the setting for this operation to be equal to the equivalent setting of another operation."] = "Criar uma relação para esta configuração fará com que ela fique igual à configuração equivalente de outra operação." -- Needs review
L["Crystals"] = "Cristais" -- Needs review
L["Current Profile:"] = "Perfil atual:"
-- L["Custom Price for this Source"] = ""
-- L["Custom Price Source"] = ""
-- L["Custom Price Source Name"] = ""
-- L["Custom Price Sources"] = ""
-- L["Custom price sources allow you to create more advanced custom prices throughout all of the TSM modules. Just as you can use the built-in price sources such as 'vendorsell' and 'vendorbuy' in your custom prices, you can use ones you make here (which themselves are custom prices)."] = ""
-- L["Custom price sources to display in item tooltips:"] = ""
L["Default"] = "Padrão"
L["Default BankUI Tab"] = "Aba padrão no Banco" -- Needs review
L["Default Group Tab"] = "Aba grupo padrão" -- Needs review
L["Default Tab"] = "Aba padrão"
L["Default Tab (Open Auction House to Enable)"] = "Aba padrão(abra a Casa de Leilão para ativar)" -- Needs review
L["Delete a Profile"] = "Excluir um perfil" -- Needs review
-- L["Delete Custom Price Source"] = ""
L["Delete existing and unused profiles from the database to save space, and cleanup the SavedVariables file."] = "Excluir os perfis não utilizados a partir do banco de dados para economizar espaço, e limpar do arquivo SavedVariables." -- Needs review
L["Delete Group"] = "Excluir grupo" -- Needs review
L["Delete Operation"] = "Excluir operação" -- Needs review
L["Description:"] = "Descrição:"
L["Deselect All Groups"] = "Deselecionar todos" -- Needs review
L["Deselects all items in both columns."] = "Desconsiderar todos os itens em ambas colunas." -- Needs review
L["Disenchant source:"] = "Fonte desencanto:" -- Needs review
L["Disenchant Value"] = "Valor de desencanto"
L["Disenchant Value:"] = "Valor de desencanto:" -- Needs review
L["Disenchant Value x%s:"] = "Valor desencanto x%s" -- Needs review
L["Display disenchant value in tooltip."] = "Mostrar valor de desencanto na dica."
L["Display Group / Operation Info in Tooltips"] = "Mostrar grupo/informações de operações nas dicas"
L["Display prices in tooltips as:"] = "Mostrar preços nas dicas como:"
L["Display vendor buy price in tooltip."] = "Mostrar preço de compra de vendedor npc nas dicas" -- Needs review
L["Display vendor sell price in tooltip."] = "Mostrar preço de venda de vendedor npc nas dicas" -- Needs review
L["Done"] = "Concluído"
-- L["Done!"] = ""
-- L["Double-click to collapse this item and show only the cheapest auction."] = ""
-- L["Double-click to expand this item and show all the auctions."] = ""
L["Duplicate Operation"] = "Duplicar operação"
L["Duration:"] = "Duração:"
L["Dust"] = "Pó"
-- L["Embed TSM Tooltips"] = ""
L["Empty price string."] = "Preço vazio" -- Needs review
-- L["Enter Filters and Start Scan"] = ""
-- L["Enter Import String"] = ""
-- L["Error creating custom price source. Custom price source with name '%s' already exists."] = ""
L["Error creating group. Group with name '%s' already exists."] = "Erro ao criar grupo. '%s' já existe." -- Needs review
L["Error creating subgroup. Subgroup with name '%s' already exists."] = "Erro ao criar subgrupo. '%s' já existe." -- Needs review
L["Error duplicating operation. Operation with name '%s' already exists."] = "Erro ao duplicar operação. '%s\" já existe." -- Needs review
L["Error Info:"] = "Informações do Erro:"
L["Error moving group. Group '%s' already exists."] = "Erro ao mover grupo. '%s' já existe." -- Needs review
-- L["Error moving group. You cannot move this group to one of its subgroups."] = ""
-- L["Error renaming custom price source. Custom price source with name '%s' already exists."] = ""
L["Error renaming group. Group with name '%s' already exists."] = "Erro ao renomear grupo. '%s' já existe." -- Needs review
L["Error renaming operation. Operation with name '%s' already exists."] = "Erro ao renomear operação.  '%s' já existe." -- Needs review
L["Essences"] = "Essências"
L["Examples"] = "Exemplos"
L["Existing Profiles"] = "Perfis existentes"
L["Export Appearance Settings"] = "Exportar Definições de Aparência"
L["Export Group Items"] = "Exportar itens do grupo" -- Needs review
L["Export Items in Group"] = "Exportar itens do grupo" -- Needs review
-- L["Export Operation"] = ""
L["Failed to parse gold amount."] = "Falha ao analisar a quantidade de ouro."
-- L["First, ensure your new group is selected in the group-tree and then click on the 'Restock Selected Groups' button at the bottom."] = ""
-- L["First, ensure your new group is selected in the group-tree and then click on the 'Start Cancel Scan' button at the bottom of the tab."] = ""
-- L["First, ensure your new group is selected in the group-tree and then click on the 'Start Post Scan' button at the bottom of the tab."] = ""
-- L["First, ensure your new group is selected in the group-tree and then click on the 'Start Search' button at the bottom of the sidebar window."] = ""
L["First, log into a character on the same realm (and faction) on both accounts. Type the name of the OTHER character you are logged into in the box below. Once you have done this on both accounts, TSM will do the rest automatically. Once setup, syncing will automatically happen between the two accounts while on any character on the account (not only the one you entered during this setup)."] = "Primeiramente, entrar em um personagem do mesmo reino (e facção) em ambas as contas. Digite o nome do outro personagem que você está logado na caixa abaixo. Depois de ter feito isso em ambas as contas, TSM fará o resto automaticamente. Uma vez configurado, a sincronização acontecerá automaticamente entre as duas contas ao mesmo tempo em qualquer personagem na conta (e não apenas o que você digitou durante esta configuração)." -- Needs review
L["Fixed Gold Value"] = "Valor fixo de ouro"
L["Forget Characters:"] = "Esquecer personagens:"
L["Frame Background - Backdrop"] = "Fundo da Janela - Fundo" -- Needs review
L["Frame Background - Border"] = "Fundo da Janela - Borda" -- Needs review
L["General Options"] = "Opções gerais"
L["General Settings"] = "Definições Gerais"
L["Give the group a new name. A descriptive name will help you find this group later."] = "Dá um nome ao grupo. Um nome que irá lhe ajudar a achar o grupo depois." -- Needs review
L["Give the new group a name. A descriptive name will help you find this group later."] = "Dá um nome ao grupo. Um nome que irá lhe ajudar a achar o grupo depois." -- Needs review
L["Give this operation a new name. A descriptive name will help you find this operation later."] = "Dá um nome à operação. Um nome que irá lhe ajudar a achar a operação depois." -- Needs review
-- L["Give your new custom price source a name. This is what you will type in to custom prices and is case insensitive (everything will be saved as lower case)."] = ""
L["Goblineer (by Sterling - The Consortium)"] = "Goblineer (por Sterling - The Consortium)" -- Needs review
-- L["Go to the Auction House and open it."] = ""
-- L["Go to the 'Groups' Page"] = ""
-- L["Go to the 'Import/Export' Tab"] = ""
-- L["Go to the 'Items' Tab"] = ""
-- L["Go to the 'Operations' Tab"] = ""
L["Group:"] = "Grupo:" -- Needs review
L["Group(Base Item):"] = "Grupo(item base):" -- Needs review
L["Group Item Data"] = [=[Dados do grupo de itens
]=] -- Needs review
L["Group Items:"] = "Grupo de itens:" -- Needs review
L["Group Name"] = "Nome do grupo" -- Needs review
L["Group names cannot contain %s characters."] = "Nome do grupo não pode conter caracteres %s . " -- Needs review
L["Groups"] = "Grupos" -- Needs review
L["Help"] = "Ajuda" -- Needs review
-- L["Help / Options"] = ""
L["Here you can setup relationships between the settings of this operation and other operations for this module. For example, if you have a relationship set to OperationA for the stack size setting below, this operation's stack size setting will always be equal to OperationA's stack size setting."] = "Aqui você pode configurar as relações entre as definições desta operação e outras operações para este módulo. Exemplo, se você tem uma relação definida para operaçãoA para a definição do tamanho da pilha abaixo, ajuste o tamanho da pilha desta operação será sempre igual a definição do tamanho da pilha da operação A." -- Needs review
L["Hide Minimap Icon"] = "Esconder Ícone do Minimapa"
-- L["How would you like to craft?"] = ""
-- L["How would you like to create the group?"] = ""
-- L["How would you like to post?"] = ""
-- L["How would you like to shop?"] = ""
L["Icon Region"] = "Região do Ícone"
L["If checked, all tables listing auctions will display the bid as well as the buyout of the auctions. This will not take effect immediately and may require a reload."] = "Se marcado, todas as tabelas de listagem de leilões exibirão o lance assim como o arremate dos leilões. Isto não terá efeito imediatamente e pode necessitar um recarregamento."
L["If checked, any items you import that are already in a group will be moved out of their current group and into this group. Otherwise, they will simply be ignored."] = "Se marcado, qualquer item que você importar que já está em um grupo serão removidos de seu grupo atual e irá  este grupo. Caso contrário, eles serão ignorados." -- Needs review
-- L["If checked, group names will be colored based on their subgroup depth in group trees."] = ""
L["If checked, only items which are in the parent group of this group will be imported."] = "Se marcado, apenas os itens que estão no grupo de pais deste grupo serão importados." -- Needs review
L["If checked, operations will be stored globally rather than by profile. TSM groups are always stored by profile. Note that if you have multiple profiles setup already with separate operation information, changing this will cause all but the current profile's operations to be lost."] = "Se marcado, as operações serão armazenados globalmente ao invés de perfil. Grupos de TSM são sempre armazenados por perfil. Note que se você tem a configuração de vários perfis já com informações de operação separada, mudando isso fará com que todas as configurações sejam perdidas." -- Needs review
L["If checked, the disenchant value of the item will be shown. This value is calculated using the average market value of materials the item will disenchant into."] = "Se marcado, o valor desencanto do item será mostrado. Este valor é calculado usando o valor médio de mercado dos materiais do item  que irá desencantar." -- Needs review
L["If checked, the price of buying the item from a vendor is displayed."] = "se verificado, o preço de compra do item de um vendedor é exibido." -- Needs review
L["If checked, the price of selling the item to a vendor displayed."] = "se verificado, o preço de venda do item de um vendedor é exibido." -- Needs review
-- L["If checked, the structure of the subgroups will be included in the export. Otherwise, the items in this group (and all subgroups) will be exported as a flat list."] = ""
-- L["If checked, this custom price will be displayed in item tooltips."] = ""
-- L["If checked, TSM's tooltip lines will be embedded in the item tooltip. Otherwise, it will show as a separate box below the item's tooltip."] = ""
L["If checked, ungrouped items will be displayed in the left list of selection lists used to add items to subgroups. This allows you to add an ungrouped item directly to a subgroup rather than having to add to the parent group(s) first."] = "se verificado, os itens não agrupados serão exibidos na lista à esquerda de listas de seleção utilizados para adicionar itens ao subgrupos. Isso permite que você adicione um item não agrupado diretamente para um subgrupo invés de ter que adicionar ao grupo pai manualmente." -- Needs review
L["If checked, your bags will be automatically opened when you open the auction house."] = "Se marcado, suas bolsas serão abertas automáticamente quando você abrir a casa de leilão." -- Needs review
-- L["If there are no auctions currently posted for this item, simmply click the 'Post' button at the bottom of the AH window. Otherwise, select the auction you'd like to undercut first."] = ""
L["If you delete, rename, or transfer a character off the current faction/realm, you should remove it from TSM's list of characters using this dropdown."] = "Se vc deletar, renomear ou transferir um personagem da facção/reino atual, vc deve remove-lo da lista de personagens do TSM usando esta lista suspensa." -- Needs review
--[==[ L[ [=[If you'd like, you can adjust the value in the 'Minimum Profit' box in order to specify the minimum profit before Crafting will queue these items.

Once you're done adjusting this setting, click the button below.]=] ] = "" ]==]
L["If you have multiple profile set up with operations, enabling this will cause all but the current profile's operations to be irreversibly lost. Are you sure you want to continue?"] = "se você tem vários perfis configurado com esta operação, ativando isso fará com que tudo com exceção as operações do perfil atual seja irreversivelmente perdido. Tem certeza de que deseja continuar?" -- Needs review
-- L["If you open your bags and shift-click the item in your bags, it will be placed in Shopping's search bar. You may need to put your cursor in the search bar first. Alternatively, you can type the name of the item manually in the search bar and then hit enter or click the 'Search' button."] = ""
L["Ignore Operation on Characters:"] = "Ignorar operação no(s) personagem(ns):"
L["Ignore Operation on Faction-Realms:"] = "Ignorar operação na facção/reino:"
L["Ignore Random Enchants on Ungrouped Items"] = "Ignorar Encantamentos randômicos em itens sem grupo" -- Needs review
L["I'll Go There Now!"] = "Irei Lá Agora!"
-- L["I'm done."] = ""
L["Import Appearance Settings"] = "Importar Definições de Aparência"
L["Import/Export"] = "Importar/Exportar"
L["Import Items"] = "Importar itens"
-- L["Import Operation Settings"] = ""
L["Import Preset TSM Theme"] = "Importar Tema do TSM"
L["Import String"] = "Importar valor"
-- L["Include Subgroup Structure in Export"] = ""
L["Installed Modules"] = "Módulos Instalados"
-- L["In the confirmation window, you can adjust the buyout price, stack sizes, and auction duration. Once you're done, click the 'Post' button to post your items to the AH."] = ""
-- L["In the list on the left, select the top-level 'Groups' page."] = ""
L["Invalid appearance data."] = "Dados de aparência inválidos."
L["Invalid custom price."] = "Preço personalizado inválido."
L["Invalid custom price for undercut amount. Using 1c instead."] = "Preço personalizado inválido para corte. Usando 1c" -- Needs review
L["Invalid filter."] = "Filtro inválido."
L["Invalid function."] = "Função inválida."
L["Invalid import string."] = "Valor importado inválido."
L["Invalid item link."] = "Link inválido de item." -- Needs review
-- L["Invalid operator at end of custom price."] = ""
-- L["Invalid parameter to price source."] = ""
L["Invalid parent argument type. Expected table, got %s."] = "Tipo de argumento pai inválido. Usando %s" -- Needs review
L["Invalid price source in convert."] = "Fonte de preço inválido convertido." -- Needs review
L["Invalid word: '%s'"] = "Palavra inválida: '%s'"
L["Item"] = "Item"
L["Item Buyout: %s"] = "Item de arremate: %s"
L["Item Level"] = "Lvl de item"
L["Item links may only be used as parameters to price sources."] = "Links de itens só podem se utilizados em parâmetros para fontes de preço." -- Needs review
L["Item not found in bags. Skipping"] = "Item não encontrado nas bolsas. Pulando." -- Needs review
L["Items"] = "Itens"
L["Item Tooltip Text"] = "Texto do Balão dos Itens" -- Needs review
L["Jaded (by Ravanys - The Consortium)"] = "Jaded (por Ravanys - The Consortium)" -- Needs review
L["Just incase you didn't read this the first time:"] = "Apenas caso você não leu isto da primeira vez:"
--[==[ L[ [=[Just like the default profession UI, you can select what you want to craft from the list of crafts for this profession. Click on the one you want to craft.

Once you're done, click the button below.]=] ] = "" ]==]
L["Keep Items in Parent Group"] = "Manter itens no grupo pai"
L["Keeps track of all your sales and purchases from the auction house allowing you to easily track your income and expenditures and make sure you're turning a profit."] = "Mantém o controle de todas as suas compras e vendas a partir da casa de leilões permitindo que você controle facilmente seus lucros e despesas e certificar que você está fazendo lucro." -- Needs review
L["Label Text - Disabled"] = "Rótulo de Texto - Desativado" -- Needs review
L["Label Text - Enabled"] = "Rótulo de Texto - Ativado" -- Needs review
L["Lead Developer and Co-Founder:"] = "Desenvolvedor Chefe e Co-Fundador:" -- Needs review
L["Light (by Ravanys - The Consortium)"] = "Light (por Ravanys - The Consortium)" -- Needs review
L["Link Text 2 (Requires Reload)"] = "Texto dos Links 2 (Necessário Recarregamento)" -- Needs review
L["Link Text (Requires Reload)"] = "Texto dos Links (Necessário Recarregamento)" -- Needs review
L["Load Saved Theme"] = "Carregar tema salvo"
-- L["Look at what's profitable to craft and manually add things to a queue"] = ""
-- L["Look for items which can be destroyed to get raw mats"] = ""
-- L["Look for items which can be vendored for a profit"] = ""
-- L["Looks like no items were added to the queue. This may be because you are already at or above your restock levels, or there is nothing profitable to queue."] = ""
-- L["Looks like no items were found. You can either try searching for something else, or simply close the Assistant window if you're done."] = ""
-- L["Looks like no items were imported. This might be because they are already in another group in which case you might consider checking the 'Move Already Grouped Items' box to force them to move to this group."] = ""
-- L["Looks like TradeSkillMaster has detected an error with your configuration. Please address this in order to ensure TSM remains functional."] = ""
L["Looks like TradeSkillMaster has encountered an error. Please help the author fix this error by copying the entire error below and following the instructions for reporting bugs listed here (unless told elsewhere by the author):"] = "Parece que o TradeSkillMaster encontrou um erro. Por favor ajude o autor a corrigir este erro copiando todo o erro abaixo e seguindo as instruções para o relato de erros listado aqui (a não ser que tenha sido dito em algum outro lugar pelo autor):" -- Needs review
L["Looks like TradeSkillMaster has encountered an error. Please help the author fix this error by following the instructions shown."] = "Parece que o TradeSkillMaster encontrou um erro. Por favor ajude o autor a corrigir este erro seguindo as instruções exibidas." -- Needs review
-- L["Loop detected in the following custom price:"] = ""
-- L["Make a new group from an import list I have"] = ""
-- L["Make a new group from items in my bags"] = ""
L["Make Auction Frame Movable"] = "Tornar o Quadro de Leilão Móvel"
L["Management"] = "Administração"
L["Manages your inventory by allowing you to easily move stuff between your bags, bank, and guild bank."] = "Gerencia seu inventário permitindo que mova facilmente as coisas entre suas bolsas, banco e banco da guilda."
L["% Market Value"] = "% Valor de Mercado"
L["max %d"] = "max %d" -- Needs review
L["Medium Text Size (Requires Reload)"] = "Texto tamanho médio(requer recarregar)"
L["Mills, prospects, and disenchants items at super speed!"] = "Tritura, prospecta, e desencanta itens em super velocidade!"
L["Misplaced comma"] = "Vírgula mal colocada" -- Needs review
L["Module:"] = "Módulo:"
L["Module Information:"] = "Informações do Módulo:" -- Needs review
L["Module Operations / Options"] = "Módulo de operações/opções" -- Needs review
-- L["Modules"] = ""
L["More Advanced Methods"] = "Métodos mais avançados"
-- L["More advanced options are now designated by %sred text|r. Beginners are encourages to come back to these once they have a solid understanding of the basics."] = ""
L["Move Already Grouped Items"] = "Mover itens já agrupados"
L["Moved %s to %s."] = "Movido %s para %s."
L["Move Group"] = "Mover grupo" -- Needs review
L["Move to Top Level"] = "Mover para o topo" -- Needs review
L["Multi-Account Settings"] = "Configurações multi-contas" -- Needs review
-- L["My group is selected."] = ""
-- L["My new operation is selected."] = ""
L["New"] = "Novo"
-- L["New Custom Price Source"] = ""
L["New Group"] = "Novo grupo"
L["New Group Name"] = "Novo nome do grupo"
L["New Parent Group"] = "Novo grupo pai"
L["New Subgroup Name"] = "Novo nome de subgrupo"
-- L["No Assistant guides available for the modules which you have installed."] = ""
-- L["<No Group Selected>"] = ""
L["No modules are currently loaded.  Enable or download some for full functionality!"] = "Nenhum módulo carregado atualmente. Habilite ou baixe alguns para funcionalidade total!"
L["None of your groups have %s operations assigned. Type '/tsm' and click on the 'TradeSkillMaster Groups' button to assign operations to your TSM groups."] = "Nenhum dos grupos tem %s operações atribuídas. Digita '/tsm' e clique no botão 'Grupo de TradeSkillMaster'  para atribuir operações para seu grupo TSM." -- Needs review
L["<No Operation>"] = "<Sem Operação>" -- Needs review
-- L["<No Operation Selected>"] = ""
L["<No Relationship>"] = "<Sem Relacionamento>" -- Needs review
L["Normal Text Size (Requires Reload)"] = "Tamanho do Texto Normal (Necessário Recarregamento)"
--[==[ L[ [=[Now that the scan is finished, you can look through the results shown in the log, and for each item, decide what action you want to take.

Once you're done, click on the button below.]=] ] = "" ]==]
L["Number of Auction Result Rows (Requires Reload)"] = "Número de Resultados de Leilão"
L["Only Import Items from Parent Group"] = "Importa apenas itens do grupo pai" -- Needs review
L["Open All Bags with Auction House"] = "Abrir Todas Bolsas com a Casa de Leilões"
-- L["Open one of the professions which you would like to use to craft items."] = ""
-- L["Open the Auction House"] = ""
-- L["Open the TSM Window"] = ""
-- L["Open up Your Profession"] = ""
L["Operation #%d"] = "Operação $%d"
L["Operation Management"] = "Gestão de operações"
L["Operations"] = "Operações"
L["Operations: %s"] = "Operações: %s"
L["Options"] = "Opções"
L["Override Module Operations"] = "Módulo de Operação que sobrepõe" -- Needs review
L["Parent Group Items:"] = "Itens do grupo pai:"
L["Parent/Ungrouped Items:"] = "itens pai/sem grupo" -- Needs review
L["Past Contributors:"] = "Antigos Contribuidores::"
L["Paste the exported items into this box and hit enter or press the 'Okay' button. The recommended format for the list of items is a comma separated list of itemIDs for general items. For battle pets, the entire battlepet string should be used. For randomly enchanted items, the format is <itemID>:<randomEnchant> (ex: 38472:-29)."] = [=[Copie o itens exportados para o campo abaixo e clique em 'Okay' botão. Formato recomendado para itens em geral é uma lista de IDs dos itens separados por virgula.. Para mascotes de batalha, o nome completo deve ser utilizado. Para itens de encantamento aleatório, o fomato é <id do item>:<encantamento aleatório>(ex: 38472:-29).
]=] -- Needs review
-- L["Paste the exported operation settings into this box and hit enter or press the 'Okay' button. Imported settings will irreversibly replace existing settings for this operation."] = ""
L[ [=[Paste the list of items into the box below and hit enter or click on the 'Okay' button.

You can also paste an itemLink into the box below to add a specific item to this group.]=] ] = [=[Copie a lista de itens para o campo abaixo e clique no botão 'ok'.

Você também pode colar o link do item dentro do campo abaixo para adicionar um item específico neste grupo.]=] -- Needs review
-- L["Paste your import string into the 'Import String' box and hit the <Enter> key to import the list of items."] = ""
L["Percent of Price Source"] = "Percentual de fonte do preço" -- Needs review
L["Performs scans of the auction house and calculates the market value of items as well as the minimum buyout. This information can be shown in items' tooltips as well as used by other modules."] = "Realiza escaneamentos da casa de leilões e calcula o valor de mercado de itens assim como o arremate mínimo. Esta informação pode ser exibida nas dicas dos itens assim como ser utilizada por outros módulos."
L["Per Item:"] = "Por item:" -- Needs review
-- L["Please select the group you'd like to use."] = ""
-- L["Please select the new operation you've created."] = ""
-- L["Please wait..."] = ""
L["Post"] = "Postar" -- Needs review
-- L["Post an Item"] = ""
-- L["Post items manually from my bags"] = ""
L["Posts and cancels your auctions to / from the auction house according to pre-set rules. Also, this module can show you markets which are ripe for being reset for a profit."] = "Posta e cancela seus leilões para/de a casa de leilão de acordo com regras pré-estabelecidas. Este módulo também mostra os 'mercados' que pode ser resetados para gerar lucro." -- Needs review
-- L["Post Your Items"] = ""
L["Price Per Item"] = "Preço por item"
L["Price Per Stack"] = "Preço por pilha"
L["Price Per Target Item"] = "Preços por item alvo"
L["Prints out the available price sources for use in custom price boxes."] = "Mostra as fontes dos preços atuais para usar preços personalizados." -- Needs review
L["Prints out the version numbers of all installed modules"] = "Mostra a versão dos módulos instalados" -- Needs review
L["Profiles"] = "Perfis"
L["Provides extra functionality that doesn't fit well in other modules."] = "Fornece funcionalidade extra que não se encaixa bem em outros módulos."
L["Provides interfaces for efficiently searching for items on the auction house. When an item is found, it can easily be bought, canceled (if it's yours), or even posted from your bags."] = "Fornece interfaces para a busca eficiente de itens na casa de leilões. Quando um item é encontrado, ele pode ser facilmente comprado, cancelado (se é seu), ou até postado de seus sacos." -- Needs review
L["Purchasing Auction: %d/%d"] = "Adquirindo leilão: %d/%d"
-- L["Queue Profitable Crafts"] = ""
-- L["Quickly post my items at some pre-determined price"] = ""
L["Region - Backdrop"] = "Região - Fundo"
L["Region - Border"] = "Região - Borda"
-- L["Remove"] = ""
L["<<< Remove"] = "<<< Remover"
-- L["Removed '%s' as a custom price source. Be sure to update any custom prices that were using this source."] = ""
L["<Remove Operation>"] = "<Remover Operação>" -- Needs review
-- L["Rename Custom Price Source"] = ""
L["Rename Group"] = "Renomear grupo"
L["Rename Operation"] = "Renomear operação"
L["Replace"] = "Substituir"
L["Reset Profile"] = "Resetar perfil"
-- L["Resets the position, scale, and size of all applicable TSM and module frames."] = ""
L["Reset the current profile back to its default values, in case your configuration is broken, or you simply want to start over."] = "Resetar o perfil atual para os valores padrões, no caso de sua configuração 'quebrar', ou vc querer iniciar novamente." -- Needs review
L["Resources:"] = "Fontes:" -- Needs review
-- L["Restart Assistant"] = ""
L["Restore Default Colors"] = "Restaurar Cores Padrão"
L["Restores all the color settings below to their default values."] = "Restaura todas as definições de cores abaixo para seus valores padrões." -- Needs review
L["Saved theme: %s."] = "Tema salvo: %s."
L["Save Theme"] = "Salvar tema" -- Needs review
L["%sDrag%s to move this button"] = "%sArraste%s para mover este botão"
L["Searching for item..."] = "Procurando por item..."
-- L["Search the AH for items to buy"] = ""
L["See instructions above this editbox."] = "Veja as instruções acima desta caixa de texto."
L["Select a group from the list below and click 'OK' at the bottom."] = "Selecione um grupo na lista abaixo e clique em \"OK\" na parte inferior."
L["Select All Groups"] = "Selecionar todos os grupos"
L["Select an operation to apply to this group."] = "Selecione uma operação para aplicar a este grupo."
L["Select a %s operation using the dropdown above."] = "Selecione uma operação %s usando o menu acima." -- Needs review
L["Select a theme from this dropdown to import one of the preset TSM themes."] = "Selecione um tema desta caixa de seleção para importar um dos temas pré-definidos do TSM."
L["Select a theme from this dropdown to import one of your saved TSM themes."] = "Selecione um tema a partir desta lista para importar um de seus temas TSM salvos."
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
L["Select the price source for calculating disenchant value."] = "Selecione a fonte de preços para cálculo do valor desencanto."
-- L["Select the 'Shopping' tab to open up the settings for TSM_Shopping."] = ""
--[==[ L[ [=[Select your new operation in the list of operation along the left of the TSM window (if it's not selected automatically) and click on the button below.

Currently Selected Operation: %s]=] ] = "" ]==]
L["Seller"] = "Vendedor"
-- L["Sell items on the AH and manage my auctions"] = ""
L["Sell to Vendor"] = "Vender para um npc."
L["Set All Relationships to Target"] = "Defina todos os relacionamentos para o alvo"
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
L["Sets all relationship dropdowns below to the operation selected."] = "Defina todos os relacionamentos da lista abaixo para a operação selecionada."
L["Settings"] = "Configurações"
L["Setup account sync'ing with the account which '%s' is on."] = "Sincronização de configuração de conta com a conta '%s' que está ativa." -- Needs review
-- L["Set up TSM to automatically cancel undercut auctions"] = ""
-- L["Set up TSM to automatically post auctions"] = ""
-- L["Set up TSM to automatically queue things to craft"] = ""
-- L["Setup TSM to automatically reset specific markets"] = ""
-- L["Set up TSM to find cheap items on the AH"] = ""
L["Shards"] = "Estilhaço"
-- L["Shift-Click an item in the sidebar window to immediately post it at your quick posting price."] = ""
-- L["Shift-Click Item in Your Bags"] = ""
L["Show Bids in Auction Results Table (Requires Reload)"] = "Exibir Lances na Tabela de Resultados de Leilão (Requer Recarregamento)"
-- L["Show the 'Custom Filter' Sidebar Tab"] = ""
-- L["Show the 'Other' Sidebar Tab"] = ""
-- L["Show the Queue"] = ""
-- L["Show the 'Quick Posting' Sidebar Tab"] = ""
-- L["Show the 'TSM Groups' Sidebar Tab"] = ""
L["Show Ungrouped Items for Adding to Subgroups"] = "Mostrar itens sem grupo para adicionar à subgrupos" -- Needs review
L["%s is a valid custom price but did not give a value for %s."] = "%s é um preço personalizado válido mas deu um valor para %."
L["%s is a valid custom price but %s is an invalid item."] = "%s é um preço personalizado válido mas %s é um item inválido."
L["%s is not a valid custom price and gave the following error: %s"] = "%s não é um preço personalizado válido e deu o seguinte erro: %s"
L["Skipping auction which no longer exists."] = "Ignorando leilão que não existe mais." -- Needs review
L["Slash Commands:"] = "Comandos de linha:" -- Needs review
L["%sLeft-Click|r to select / deselect this group."] = "%sClique-Esquerdo|r para selecionar / desselecionar esse grupo." -- Needs review
L["%sLeft-Click%s to open the main window"] = "%sClique-esquerdo%s para abrir a janela principal"
L["Small Text Size (Requires Reload)"] = "Tamanho do Texto Pequeno (Necessário Recarregamento)"
-- L["Snipe items as they are being posted to the AH"] = ""
-- L["Sniping Scan in Progress"] = ""
L["%s operation(s):"] = "Operações de %s:" -- Needs review
-- L["Sources"] = ""
L["%sRight-Click|r to collapse / expand this group."] = "%sClique-Direito|r para colapsar / expandir este grupo." -- Needs review
L["Stack Size"] = "Tamanho da pilha" -- Needs review
L["stacks of"] = "pilha de" -- Needs review
-- L["Start a Destroy Search"] = ""
-- L["Start Sniper"] = ""
-- L["Start Vendor Search"] = ""
L["Status / Credits"] = "Status / Créditos"
L["Store Operations Globally"] = "Armazenar as operações globalmente" -- Needs review
L["Subgroup Items:"] = "Itens do subgrupo:" -- Needs review
L["Subgroups contain a subset of the items in their parent groups and can be used to further refine how different items are treated by TSM's modules."] = "Subgrupos contém um subconjunto dos elementos dos seus grupos principais e pode ser utilizado para refinar mais como itens são tratados pelos módulos do TSM." -- Needs review
L["Successfully imported %d items to %s."] = "%d items de %s importado com sucesso." -- Needs review
-- L["Successfully imported operation settings."] = ""
-- L["Switch to Destroy Mode"] = ""
-- L["Switch to New Custom Price Source After Creation"] = ""
L["Switch to New Group After Creation"] = "Trocar para o novo grupo depois de cria-lo" -- Needs review
-- L["Switch to the 'Professions' Tab"] = ""
-- L["Switch to the 'TSM Groups' Tab"] = ""
L["Target Operation"] = "Operação alvo"
L["Testers (Special Thanks):"] = "Testadores (Agradecimentos Especiais):"
L["Text:"] = "Texto:" -- Needs review
L["The default tab shown in the 'BankUI' frame."] = "A aba padrão mostrada na janela do 'banco' ." -- Needs review
-- L["The final set of posting settings are under the 'Posting Price Settings' header. These define the price ranges which Auctioning will post your items within. Read the tooltips of the individual settings to see what they do and set them appropriately."] = ""
-- L["The first set of posting settings are under the 'Auction Settings' header. These control things like stack size and auction duration. Read the tooltips of the individual settings to see what they do and set them appropriately."] = ""
L["The Functional Gold Maker (by Xsinthis - The Golden Crusade)"] = "O Funcional Criador de Ouro (por Xsinthis - A Cruzada de Ouro)"
--[==[ L[ [=[The 'Maxium Auction Price (per item)' is the most you want to pay for the items you've added to your group. If you're not sure what to set this to and have TSM_AuctionDB installed (and it contains data from recent scans), you could try '90% dbmarket' for this option.

Once you're done adjusting this setting, click the button below.]=] ] = "" ]==]
--[==[ L[ [=[The 'Max Restock Quantity' defines how many of each item you want to restock up to when using the restock queue, taking your inventory into account.

Once you're done adjusting this setting, click the button below.]=] ] = "" ]==]
L["Theme Name"] = "Nome do tema" -- Needs review
L["Theme name is empty."] = "Nome do tema está vazio."
-- L["The name can ONLY contain letters. No spaces, numbers, or special characters."] = ""
L["There are no visible banks."] = "Não há bancos visíveis." -- Needs review
-- L["There is only one price level and seller for this item."] = ""
-- L["The second set of posting settings are under the 'Auction Price Settings' header. These include the percentage of the buyout which the bid will be set to, and how much you want to undercut by. Read the tooltips of the individual settings to see what they do and set them appropriately."] = ""
-- L["These settings control when TSM_Auctioning will cancel your auctions. Read the tooltips of the individual settings to see what they do and set them appropriately."] = ""
--[==[ L[ [=[The 'Sniper' feature will constantly search the last page of the AH which shows items as they are being posted. This does not search existing auctions, but lets you buy items which are posted cheaply right as they are posted and buy them before anybody else can.

You can adjust the settings for what auctions are shown in TSM_Shopping's options.

Click the button below when you're done reading this.]=] ] = "" ]==]
L["This allows you to export your appearance settings to share with others."] = "Permite que exporte suas deifinições de aparência para que compartilhe com outras pessoas." -- Needs review
L["This allows you to import appearance settings which other people have exported."] = "Permite que importe definições de aparência que outras pessoas tenham exportado." -- Needs review
L["This dropdown determines the default tab when you visit a group."] = "Esta lista determina a aba padrão quando você visita um grupo."
L["This group already has operations. Would you like to add another one or replace the last one?"] = "Este grupo já tem operações. Gostaria de acrescentar mais um ou substituir o último?"
L["This group already has the max number of operation. Would you like to replace the last one?"] = "Este grupo já tem o número máximo de operações . Gostaria de substituir o último?"
L["This operation will be ignored when you're on any character which is checked in this dropdown."] = "Esta operação será ignorada quando você estiver em qualquer personagem que esteja marcado nesta lista."
-- L["This option sets which tab TSM and its modules will use for printing chat messages."] = ""
L["Time Left"] = "Tempo restante"
L["Title"] = "Título" -- Needs review
L["Toggles the bankui"] = "Alterna a tela do banco" -- Needs review
L["Tooltip Options"] = "Opções das dicas"
L["Tracks and manages your inventory across multiple characters including your bags, bank, and guild bank."] = "Rastreia e gerencia o inventário de diversos personagens seus incluindo sacos, banco, e banco da guilda." -- Needs review
L["TradeSkillMaster Error Window"] = "Janela de Erro do TradeSkillMaster"
L["TradeSkillMaster Info:"] = "Informação sobre o TradeSkillMaster:"
L["TradeSkillMaster Team"] = "Equipe do TradeSkillMaster" -- Needs review
L["TSM Appearance Options"] = "Opções de Aparência do TSM" -- Needs review
-- L["TSM Assistant"] = ""
L["TSM Classic (by Jim Younkin - Power Word: Gold)"] = "TSM Classic ( por Jim Youkin - Power World: Gold)" -- Needs review
L["TSMDeck (by Jim Younkin - Power Word: Gold)"] = "TSMDeck (por Jim Younkin - Power Word: Gold)" -- Needs review
L["/tsm help|r - Shows this help listing"] = "/tsm help|r - Mostra esta lista de ajuda"
L["TSM Info / Help"] = "Informações do TSM / Ajuda"
L["/tsm|r - opens the main TSM window."] = "/tsm|r - abre a janela principal do TSM."
L["TSM Status / Options"] = "TSM Status / Opções"
L["TSM Version Info:"] = "Informações da versão TSM:"
L["TUJ GE - Market Average"] = "TUJ GE - Média de mercado"
L["TUJ GE - Market Median"] = "TUJ GE - Valor médio" -- Needs review
L["TUJ RE - Market Price"] = "TUJ - RE - Preço de mercado"
L["TUJ RE - Mean"] = "TUJ RE - Média limitada"
-- L["Type a raw material you would like to obtain via destroying in the search bar and start the search. For example: 'Ink of Dreams' or 'Spirit Dust'."] = ""
L["Type in the name of a new operation you wish to create with the same settings as this operation."] = "Digite o nome de uma nova operação que você deseja criar com as mesmas configurações desta operação."
-- L["Type '/tsm' or click on the minimap icon to open the main TSM window."] = ""
L["Type '/tsm sources' to print out all available price sources."] = "Digite '/tsm sources' para mostrar todas as fontes de preço disponíveis." -- Needs review
L["Unbalanced parentheses."] = "Parênteses errados."
-- L["Underneath the 'Posting Options' header, there are two settings which control the Quick Posting feature of TSM_Shopping. The first one is the duration which Quick Posting should use when posting your items to the AH. Change this to your preferred duration for Quick Posting."] = ""
-- L["Underneath the 'Posting Options' header, there are two settings which control the Quick Posting feature of TSM_Shopping. The second one is the price at which the Quick Posting will post items to the AH. This should generally not be a fixed gold value, since it will apply to every item. Change this setting to what you'd like to post items at with Quick Posting."] = ""
-- L["Underneath the serach bar at the top of the 'Shopping' AH tab are a handful of buttons which change what's displayed in the sidebar window. Click on the 'Custom Filter' one."] = ""
-- L["Underneath the serach bar at the top of the 'Shopping' AH tab are a handful of buttons which change what's displayed in the sidebar window. Click on the 'Other' one."] = ""
-- L["Underneath the serach bar at the top of the 'Shopping' AH tab are a handful of buttons which change what's displayed in the sidebar window. Click on the 'TSM Groups' one."] = ""
-- L["Under the search bar, on the left, you can switch between normal and destroy mode for TSM_Shopping. Switch to 'Destroy Mode' now."] = ""
L["Ungrouped Items:"] = "Itens sem grupo:"
L["Usage: /tsm price <ItemLink> <Price String>"] = "Uso: /tsm price <Link Item> <Valor de Preço>"
-- L["Use an existing group"] = ""
-- L["Use a subset of items from an existing group by creating a subgroup"] = ""
L["Use the button below to delete this group. Any subgroups of this group will also be deleted, with all items being returned to the parent of this group or removed completely if this group has no parent."] = "Utilize o botão abaixo para excluir este grupo. Quaisquer subgrupos deste grupo também serão excluídos, com todos os itens que estão sendo devolvidos para o pai deste grupo ou removido completamente se este grupo não tem nenhum pai." -- Needs review
L["Use the editbox below to give this group a new name."] = "Use o campo abaixo para dar um nome a este grupo."
L["Use the group box below to move this group and all subgroups of this group. Moving a group will cause all items in the group (and its subgroups) to be removed from its current parent group and added to the new parent group."] = "Use a caixa de grupo abaixo para mover este grupo e todos os subgrupos deste grupo. Movendo um grupo fará com que todos os artigos do grupo (e os seus subgrupos) serão removidos a partir do seu grupo pai atual e adicionado ao novo grupo pai." -- Needs review
L["Use the options below to change and tweak the appearance of TSM."] = "Use as opções abaixo para mudar e ajustar a aparência do TSM." -- Needs review
L["Use the tabs above to select the module for which you'd like to configure operations and general options."] = "Use as guias acima para selecionar o módulo para o qual você gostaria de configurar as operações e opções gerais." -- Needs review
L["Use the tabs above to select the module for which you'd like to configure tooltip options."] = "Use as guias acima para selecionar o módulo para o qual você gostaria de configurar as opções de dica de ferramenta." -- Needs review
L["Using our website you can get help with TSM, suggest features, and give feedback."] = "Usando nosso site você pode obter ajuda com o TSM, sugerir funcionalidades, e dar feedback." -- Needs review
L["Various modules can sync their data between multiple accounts automatically whenever you're logged into both accounts."] = "Vários módulos podem sincronizar seus dados entre várias contas automaticamente sempre que você estiver conectado à elas." -- Needs review
L["Vendor Buy Price:"] = "Preço de compra npc: " -- Needs review
L["Vendor Buy Price x%s:"] = "Preço de compra npc x %s:" -- Needs review
L["Vendor Sell Price:"] = "Preço de venda npc:" -- Needs review
L["Vendor Sell Price x%s:"] = "Preço de venda npc x %s:" -- Needs review
L["Version:"] = "Versão:"
-- L["View current auctions and choose what price to post at"] = ""
L["View Operation Options"] = "Ver opções de operação" -- Needs review
L["Visit %s for information about the different TradeSkillMaster modules as well as download links."] = "Visite %s para informações a respeito dos diferentes módulos do TradeSkillMaster assim como os links para download." -- Needs review
-- L["Waiting for Scan to Finish"] = ""
L["Web Master and Addon Developer:"] = "Desenvolvedor do Addon e Web Master"
-- L["We will add a %s operation to this group through its 'Operations' tab. Click on that tab now."] = ""
-- L["We will add items to this group through its 'Items' tab. Click on that tab now."] = ""
-- L["We will import items into this group using the import list you have."] = ""
-- L["What do you want to do?"] = ""
--[==[ L[ [=[When checked, random enchants will be ignored for ungrouped items.

NB: This will not affect parent group items that were already added with random enchants

If you have this checked when adding an ungrouped randomly enchanted item, it will act as all possible random enchants of that item.]=] ] = "" ]==]
L["When clicked, makes this group a top-level group with no parent."] = "Quando clicado, faz deste um grupo sem pai no topo." -- Needs review
L["Would you like to add this new operation to %s?"] = "Gostaria de acrescentar esta nova operação à %s?"
L["Wrong number of item links."] = "Número de links de itens errado."
-- L["You appear to be attempting to import an operation from a different module."] = ""
L["You can change the active database profile, so you can have different settings for every character."] = "Você pode mudar os dados do perfil ativo, assim você terá uma configuração diferente pra cada personagem." -- Needs review
--[==[ L[ [=[You can craft items either by clicking on rows in the queue which are green (meaning you can craft all) or blue (meaning you can craft some) or by clicking on the 'Craft Next' button at the bottom.

Click on the button below when you're done reading this. There is another guide which tells you how to buy mats required for your queue.]=] ] = "" ]==]
L["You can either create a new profile by entering a name in the editbox, or choose one of the already exisiting profiles."] = "Você pode criar um novo perfil colocando no nome do campo ou escolhe um dos perfis já existente." -- Needs review
-- L["You can hold shift while clicking this button to remove the items from ALL groups rather than keeping them in the parent group (if one exists)."] = ""
--[==[ L[ [=[You can look through the tooltips of the other options to see what they do and decide if you want to change their values for this operation.

Once you're done, click on the button below.]=] ] = "" ]==]
L["You cannot create a profile with an empty name."] = "Você não pode criar um perfil com nome em branco."
-- L["You cannot use %s as part of this custom price."] = ""
--[==[ L[ [=[You can now use the buttons near the bottom of the TSM_Crafting window to create this craft.

Once you're done, click the button below.]=] ] = "" ]==]
--[==[ L[ [=[You can use the filters at the top of the page to narrow down your search and click on a column to sort by that column. Then, left-click on a row to add one of that item to the queue, and right-click to remove one.

Once you're done adding items to the queue, click the button below.]=] ] = "" ]==]
--[==[ L[ [=[You can use this sidebar window to help build AH searches. You can also type the filter directly in the search bar at the top of the AH window.

Enter your filter and start the search.]=] ] = "" ]==]
L["You currently don't have any groups setup. Type '/tsm' and click on the 'TradeSkillMaster Groups' button to setup TSM groups."] = "Você não tem nenhuma configuração de grupo. Digita '/tsm'  e clique botão 'Grupos de TradeSkillMaster'  para configurar os grupos."
L["You have closed the bankui. Use '/tsm bankui' to view again."] = "Você fechou a UI do banco. Use '/tsm bankui' para vê-lo novamente." -- Needs review
-- L["You have successfully completed this guide. If you require further assistance, visit out our website:"] = ""
