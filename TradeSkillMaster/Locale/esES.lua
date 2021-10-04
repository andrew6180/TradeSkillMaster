-- ------------------------------------------------------------------------------ --
--                                TradeSkillMaster                                --
--                http://www.curse.com/addons/wow/tradeskill-master               --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- TradeSkillMaster Locale - esES
-- Please use the localization app on CurseForge to update this
-- http://wow.curseforge.com/addons/TradeSkill-Master/localization/

local L = LibStub("AceLocale-3.0"):NewLocale("TradeSkillMaster", "esES")
if not L then return end

L["Act on Scan Results"] = "Guiarse por los resultados escaneados" -- Needs review
L["A custom price of %s for %s evaluates to %s."] = "Un precio personalizado de %s para %s evaluados a %s."
L["Add >>>"] = "Añadir >>>"
L["Add Additional Operation"] = "Añade Operación Adicional"
L["Add Items to this Group"] = "Añadir items a este grupo" -- Needs review
L["Additional error suppressed"] = "Error adicional suprimido"
L["Adjust Post Parameters"] = "Ajustar parámetros de publicación" -- Needs review
L["Advanced Option Text"] = "Opción de texto avanzada" -- Needs review
L["Advanced topics..."] = "Temas Avanzados..." -- Needs review
L["A group is a collection of items which will be treated in a similar way by TSM's modules."] = "Un grupo es una colección de objetos los cuales serán tratados de una manera similar por los módulos de TSM."
L["All items with names containing the specified filter will be selected. This makes it easier to add/remove multiple items at a time."] = "Todos los objetos con nombres contenidos en el filtro especificado serán seleccionados. Esto hace mas fácil añadir/borrar múltiples objetos a la vez."
L["Allows for testing of custom prices."] = "Permitir para probar precios personalizados."
L["Allows you to build a queue of crafts that will produce a profitable, see what materials you need to obtain, and actually craft the items."] = "Te permite crear una cola de items que le producirá beneficio, ver que materiales necesitas obtener, y crear dichos items." -- Needs review
L["Allows you to quickly and easily empty your mailbox as well as automatically send items to other characters with the single click of a button."] = "Te permite rápida y fácilmente vaciar tu buzón de correos así como envíar items automáticamente a otros personajes con un solo clic de un botón. " -- Needs review
L["Allows you to use data from http://wowuction.com in other TSM modules and view its various price points in your item tooltips."] = "Te permite usar informacion de http://wowuction.com en otros modulos del TSM y ver los precios en la ventana de informacion."
L["Along the bottom of the AH are various tabs. Click on the 'Auctioning' AH tab."] = "A lo largo de la parte inferior de la CS hay varias pestañas. Haga clic en 'Subastas' de la pestaña de la CS." -- Needs review
L["Along the bottom of the AH are various tabs. Click on the 'Shopping' AH tab."] = "A lo largo de la parte inferior de la CS hay varias pestañas. Haz clic en la pestaña 'Compras' de la CS." -- Needs review
L["Along the top of the TSM_Crafting window, click on the 'Professions' button."] = "A lo largo de la parte superior de la ventana TSM_Crafting, haz clic en el botón 'Profesiones'." -- Needs review
L["Along the top of the TSM_Crafting window, click on the 'TSM Groups' button."] = "A lo largo de la parte superior de la ventana TSM_Crafting, haz clic en el botón 'Grupos TSM'." -- Needs review
L["Along top of the window, on the left side, click on the 'Groups' icon to open up the TSM group settings."] = "A lo largo de la parte superior de la ventana, en la zona izquierda, haz clic en el icono 'Grupos' para abrir la configuración de grupo de TSM." -- Needs review
L["Along top of the window, on the left side, click on the 'Module Operations / Options' icon to open up the TSM module settings."] = "A lo largo de la parte superior de la ventana, en la zona izquierda, haz clic en el icono 'Módulo de Operaciones / Opciones' para abrir la configuración de módulo de TSM." -- Needs review
L["Along top of the window, on the right side, click on the 'Crafting' icon to open up the TSM_Crafting page."] = "A lo largo de la parte superior de la ventana, en la zona derecha, haz clic en el icono 'Fabricaciones' para abrir la página TSM_Crafting" -- Needs review
L["Alt-Click to immediately buyout this auction."] = "Alt-Clic para comprar inmediatamente esta subasta."
L["A maximum of 1 convert() function is allowed."] = "Un máximo de 1 función convert() está permitida."
L["A maximum of 1 gold amount is allowed."] = "Un máximo de 1 oro acumulado está permitido."
L["Any subgroups of this group will also be deleted, with all items being returned to the parent of this group or removed completely if this group has no parent."] = "Cualquier subgrupo de este grupo será también borrado, con todos los objetos devueltos al grupo superior de este grupo o borrados completamente si este no tiene grupo superior."
L["Appearance Data"] = "Aparencia de los Datos"
L["Application and Addon Developer:"] = "Desarrollador del addon y aplicacion:"
L["Applied %s to %s."] = "Aplicado %s a %s."
L["Apply Operation to Group"] = "Aplica Operación al Grupo"
L["Are you sure you want to delete the selected profile?"] = "¿Estás seguro que quieres borrar el perfil seleccionado?"
L["A simple, fixed gold amount."] = "Un simple, fijo oro acumulado."
L["Assign this operation to the group you previously created by clicking on the 'Yes' button in the popup that's now being shown."] = "Asignar esta operación para el grupo que anteriormente creaste haciendo clic en el botón 'Sí' en la ventana emergente que ahora será mostrada." -- Needs review
L["A TSM_Auctioning operation will allow you to set rules for how auctionings are posted/canceled/reset on the auction house. To create one for this group, scroll down to the 'Auctioning' section, and click on the 'Create Auctioning Operation' button."] = "Una operación de TSM_Auctioning se mostrará para establecer reglas de cómo las subastas son publicadas/canceladas/restablecidas en la casa de subastas. Para crear una para este grupo, baje a la sección 'Subastas', y haga clic en el botón'Crear Operación de Subastas'. " -- Needs review
L["A TSM_Crafting operation will allow you automatically queue profitable items from the group you just made. To create one for this group, scroll down to the 'Crafting' section, and click on the 'Create Crafting Operation' button."] = "Una operación TSM_Crafting mostrará automáticamente la cola de items con beneficio del grupo que acaba de crear. Para crear una para este grupo, baje a la sección 'Fabricaciones', y haga clic en el botón 'Crear Operación de fabricación'." -- Needs review
L["A TSM_Shopping operation will allow you to set a maximum price we want to pay for the items in the group you just made. To create one for this group, scroll down to the 'Shopping' section, and click on the 'Create Shopping Operation' button."] = "Una operación TSM_Shopping te mostrará  el precio máximo a establecer que queremos pagar por los ítems en el grupo que acabas de crear. Para crear este grupo, baja a la sección 'Compras', y haz clic en el botón 'Crear Operación de Compras'." -- Needs review
L["At the top, switch to the 'Crafts' tab in order to view a list of crafts you can make."] = "En la parte superior, cambia a la pestaña 'Fabricaciones' para ver la lista de fabricaciones que puedes realizar." -- Needs review
L["Auctionator - Auction Value"] = "Auctionator - Valor de la subasta"
L["Auction Buyout:"] = "Compra de subasta:"
L["Auction Buyout: %s"] = "Compra de subasta: %s"
L["Auctioneer - Appraiser"] = "Auctioneer - Ascendente"
L["Auctioneer - Market Value"] = "Auctioneer - Valor de Mercado"
L["Auctioneer - Minimum Buyout"] = "Auctioneer - Precio de compra mínimo" -- Needs review
L["Auction Frame Scale"] = "Escala del marco de subasta" -- Needs review
L["Auction House Tab Settings"] = "Pestaña de configuración de la Casa de Subastas" -- Needs review
L["Auction not found. Skipped."] = "Subasta no encontrada. Omitida."
L["Auctions"] = "Subastas"
L["Author(s):"] = "Autor(es):"
L["BankUI"] = "Interfaz de Banco"
L["Below are various ways you can set the value of the current editbox. Any combination of these methods is also supported."] = "A continuación hay varias formas de poder configurar el valor del cuadro de edición actual. Cualquier combinación de estos métodos también está soportada."
L["Below are your currently available price sources. The %skey|r is what you would type into a custom price box."] = "A continuación están la fuente de precios disponibles. La tecla %s es lo que tendría que escribir en un cuadro de precios personalizado."
L["Below is a list of groups which this operation is currently applied to. Clicking on the 'Remove' button next to the group name will remove the operation from that group."] = "Abajo está la lista de grupos los cuales serán aplicadas esta operación. Haciendo clic en el botón 'Borrar' que está al lado del nombre de grupo, será borrada la operación de este grupo." -- Needs review
L["Below, set the custom price that will be evaluated for this custom price source."] = "Abajo, se establece el precio personalizado que será evaluado para esta fuente de precio personalizado." -- Needs review
L["Border Thickness (Requires Reload)"] = "Grosor del Borde (Requiere Reload)"
L["Buy from Vendor"] = "Comprar al Vendedor"
L["Buy items from the AH"] = "Compra ítems de la CS" -- Needs review
L["Buy materials for my TSM_Crafting queue"] = "Compra materiales de mi cola de TSM_Crafting" -- Needs review
L["Canceling Auction: %d/%d"] = "Cancelando Subasta: %d/%d"
L["Cancelled - Bags and bank are full"] = "Cancelado - Bolsas y banco están llenos"
L["Cancelled - Bags and guildbank are full"] = "Cancelado - Bolsas y banco de hermandad están llenos"
L["Cancelled - Bags are full"] = "Cancelado - Bolsas están llenas"
L["Cancelled - Bank is full"] = "Cancelado - Banco está lleno"
L["Cancelled - Guildbank is full"] = "Cancelado - Banco de hermandad está lleno"
L["Cancelled - You must be at a bank or guildbank"] = "Cancelado - Debes estar en el banco o banco de hermandad"
L["Cannot delete currently active profile!"] = "¡No puede borrar el perfil activo!"
L["Category Text 2 (Requires Reload)"] = "Categoria de Texto 2 (Requiere Reload)"
L["Category Text (Requires Reload)"] = "Categoria de Texto (Requiere Reload)"
-- L["|cffffff00DO NOT report this as an error to the developers.|r If you require assistance with this, make a post on the TSM forums instead."] = ""
L[ [=[|cffffff00Important Note:|r You do not currently have any modules installed / enabled for TradeSkillMaster! |cff77ccffYou must download modules for TradeSkillMaster to have some useful functionality!|r

Please visit http://www.curse.com/addons/wow/tradeskill-master and check the project description for links to download modules.]=] ] = [=[Nota importante: No tiene actualmente ningún módulo instalado / activado para TradeSkillMaster! Debe descargar módulos de TradeSkillMaster tener alguna funcionalidad útil!

Please visit http://www.curse.com/addons/wow/tradeskill-master and check the project description for links to download modules.]=]
L["Changes how many rows are shown in the auction results tables."] = "Cambia la cantidad de filas que se muestran en la tabla de resultados."
L["Changes the size of the auction frame. The size of the detached TSM auction frame will always be the same as the main auction frame."] = "Cambia el tamaño del marco de la subasta. El tamaño del marco de subasta individual TSM siempre será el mismo que el marco principal de la subasta."
L["Character Name on Other Account"] = "Nombre de personaje en otra cuenta"
L["Chat Tab"] = "Pestaña de Chat" -- Needs review
L["Check out our completely free, desktop application which has tons of features including deal notification emails, automatic updating of AuctionDB and WoWuction prices, automatic TSM setting backup, and more! You can find this app by going to %s."] = "¡Mira nuestra aplicación de escritorio gratuita la cual tiene muchas características incluidas de notificación por emails, actualización automáctica de AuctionDB y los precios deWoWuction, copias de seguridad automática de TSM y más! Puedes encontrar esta aplicación llendo a %s."
L["Check this box to override this group's operation(s) for this module."] = "Selecciona este cuadro para sobreescribir esta operación(es) de este grupo  para este módulo."
L["Clear"] = "Restablecer"
L["Clear Selection"] = "Restablecer Selección"
L["Click on the Auctioning Tab"] = "Haz clic en la pestaña de Subastas" -- Needs review
L["Click on the Crafting Icon"] = "Haz clic en el Icono de Fabricación" -- Needs review
L["Click on the Groups Icon"] = "Haz clic en el icono de Grupos" -- Needs review
L["Click on the Module Operations / Options Icon"] = "Haz clic en el icono de Módulo de Operaciones / Opciones" -- Needs review
L["Click on the Shopping Tab"] = "Haz clic en la pestaña de Compras" -- Needs review
L["Click on the 'Show Queue' button at the top of the TSM_Crafting window to show the queue if it's not already visible."] = "Haz clic en el botón 'Mostrar la cola' en la parte superior de la ventana TSM_Crafting para mostrar la cola si no está ya visible." -- Needs review
L["Click on the 'Start Sniper' button in the sidebar window."] = "Haz clic en el botón 'Empezar espionaje' en la ventana lateral." -- Needs review
L["Click on the 'Start Vendor Search' button in the sidebar window."] = "Haz clic en el botón 'Empezar búsqueda de vendedor' en la ventana lateral." -- Needs review
L["Click the button below to open the export frame for this group."] = "Haga clic en el botón de a continuación para abrir el cuadro de exportación de este grupo."
L["Click this button to completely remove this operation from the specified group."] = "Haz clic en este botón para borrar completamente esta operación del grupo especificado." -- Needs review
L["Click this button to configure the currently selected operation."] = "Haga clic en este botón para configurar la operación seleccionada actualmente."
L["Click this button to create a new operation for this module."] = "Haga clic en este botón para crear una nueva operación para este módulo."
L["Click this button to show a frame for easily exporting the list of items which are in this group."] = "Haga clic en este botón para mostrar el cuadro para exportar fácilmente el listado de objetos los cuales están en el grupo."
L["Co-Founder:"] = "Co-Fundador:"
L["Coins:"] = "Monedas:"
L["Color Group Names by Depth"] = "Nombres de colores de grupo por profundidad" -- Needs review
L["Content - Backdrop"] = "Contenido - Fondo"
L["Content - Border"] = "Contenido - Borde"
L["Content Text - Disabled"] = "Contenido del Texto - Deshabilitar"
L["Content Text - Enabled"] = "Contenido del Texto - Habilitar"
L["Copy From"] = "Copiar Desde:"
L["Copy the settings from one existing profile into the currently active profile."] = "Copiar las opciones de un perfil existente al perfil actualmente activo."
L["Craft Items from Queue"] = "Fabrica Ítems desde la Cola" -- Needs review
L["Craft items with my professions"] = "Fabrica ítems con mis profesiones" -- Needs review
L["Craft specific one-off items without making a queue"] = "Fabrica ítems únicos específicos sin hacerlo en cola" -- Needs review
L["Create a new empty profile."] = "Crear un perfil nuevo."
L["Create a New Group"] = "Crea un grupo nuevo" -- Needs review
L["Create a new group by typing a name for the group into the 'Group Name' box and pressing the <Enter> key."] = "Crea un nuevo grupo escribiendo para el grupo en la caja de 'Nombre de Grupo' y presionando la tecla <Intro>." -- Needs review
L["Create a new %s operation by typing a name for the operation into the 'Operation Name' box and pressing the <Enter> key."] = "Crea una nueva %s operación escribiendo un nombre para la operación en la caja de 'Nombre de Operación' y presionando la tecla <Intro>." -- Needs review
L["Create a %s Operation %d/5"] = "Crea un %s Operación %d/5" -- Needs review
L["Create New Subgroup"] = "Crear Nuevo Subgrupo"
L["Create %s Operation"] = "Crear %s Operación"
L["Create the Craft"] = "Crea la fabricación" -- Needs review
L["Creating a relationship for this setting will cause the setting for this operation to be equal to the equivalent setting of another operation."] = "Crear una relación para esta opción causará que la opción para esta operación sea igual a la opción equivalente a otra operación."
L["Crystals"] = "Cristales"
L["Current Profile:"] = "Perfil actual:"
L["Custom Price for this Source"] = "Precio personalizado por Fuente" -- Needs review
L["Custom Price Source"] = "Fuente de Precio Personalizado" -- Needs review
L["Custom Price Source Name"] = "Nombre de Fuente de Precio Personalizado" -- Needs review
L["Custom Price Sources"] = "Fuentes de Precio Personalizado" -- Needs review
L["Custom price sources allow you to create more advanced custom prices throughout all of the TSM modules. Just as you can use the built-in price sources such as 'vendorsell' and 'vendorbuy' in your custom prices, you can use ones you make here (which themselves are custom prices)."] = "Fuentes de Precio Personalizado te permite crear el más avanzado de todos los precios personalizados de todos los módulos de TSM. Justo como podemos construir fuentes de precio como 'Venta en el vendedor' y 'Compra en el vendedor' en tus precios personalizados, puedes usar uno que hagas aquí (los cuales son precios personalizados)." -- Needs review
L["Custom price sources to display in item tooltips:"] = "Fuentes de precio personalizado para mostrar en la ayuda emergente." -- Needs review
L["Default"] = "Por defecto"
L["Default BankUI Tab"] = "Pestaña Interfaz de Banco por Defecto"
L["Default Group Tab"] = "Pestaña Grupo por Defecto"
L["Default Tab"] = "Pestaña por Defecto"
L["Default Tab (Open Auction House to Enable)"] = "Pestaña por Defecto (Abre la Casa de Subastas para Habilitarlo)"
L["Delete a Profile"] = "Borrar un Perfil"
L["Delete Custom Price Source"] = "Borrar fuente de precio personalizado" -- Needs review
L["Delete existing and unused profiles from the database to save space, and cleanup the SavedVariables file."] = "Borrar los perfiles existentes y que no se usen de la base de datos para ahorrar espacio, y limpiar la carpeta SavedVariables."
L["Delete Group"] = "Borrar Grupo"
L["Delete Operation"] = "Borrar Operación"
L["Description:"] = "Descripción:"
L["Deselect All Groups"] = "Desmarcar Todos los Grupos"
L["Deselects all items in both columns."] = "Desmarcar todos los objetos en ambas columnas"
L["Disenchant source:"] = "Fuente de Desencantamiento"
L["Disenchant Value"] = "Valor de Desencantamiento"
L["Disenchant Value:"] = "Valor de Desencantamiento:"
L["Disenchant Value x%s:"] = "Valor de Desencantamiento x%s:"
L["Display disenchant value in tooltip."] = "Mostrar  valor de desencantamiento en la etiqueta de descripción"
L["Display Group / Operation Info in Tooltips"] = "Mostrar Información de Grupo / Operación en las etiquetas de descripción"
L["Display prices in tooltips as:"] = "Mostrar precios en las etiquetas de descripción como:"
L["Display vendor buy price in tooltip."] = "Mostrar precio de compra de vendedor en la etiqueta de descripción."
L["Display vendor sell price in tooltip."] = "Mostrar precio de venta de vendedor en la etiqueta de descripción."
L["Done"] = "Hecho"
L["Done!"] = "Hecho!" -- Needs review
L["Double-click to collapse this item and show only the cheapest auction."] = "Doble clic para comprimir este ítem y mostrar sólo la subasta más barata." -- Needs review
L["Double-click to expand this item and show all the auctions."] = "Doble clic para descomprimir este ítem y mostrar todas las subastas." -- Needs review
L["Duplicate Operation"] = "Duplicar Operación"
L["Duration:"] = "Duración:"
L["Dust"] = "Polvo"
L["Embed TSM Tooltips"] = "Ayuda emergente TSM empotrada" -- Needs review
L["Empty price string."] = "Cadena de precio vacía."
L["Enter Filters and Start Scan"] = "Introduce Filtros y Empieza a escanear" -- Needs review
L["Enter Import String"] = "Introduce la Cadena de Importación" -- Needs review
L["Error creating custom price source. Custom price source with name '%s' already exists."] = "Error creando la fuente de precio personalizado. Fuente de precio personalizado con nombre '%s' ya existe." -- Needs review
L["Error creating group. Group with name '%s' already exists."] = "Error creando grupo. Grupo con nombre '%s' ya existe."
L["Error creating subgroup. Subgroup with name '%s' already exists."] = "Error creando subgrupo. Subgrupo con nombre '%s' ya existe."
L["Error duplicating operation. Operation with name '%s' already exists."] = "Error creando operación. Operación con nombre '%s' ya existe."
L["Error Info:"] = "Error Info:"
L["Error moving group. Group '%s' already exists."] = "Error moviendo grupo. Grupo '%s' ya existe."
L["Error moving group. You cannot move this group to one of its subgroups."] = "Error moviendo el grupo. No puedes mover este grupo a uno de sus subgrupos." -- Needs review
L["Error renaming custom price source. Custom price source with name '%s' already exists."] = "Error renombrando la fuente de precio personalizado. La fuente de precio personalizado con nombre '%s' ya existe." -- Needs review
L["Error renaming group. Group with name '%s' already exists."] = "Error renombrando grupo. Grupo con ese nombre '%s' ya existe."
L["Error renaming operation. Operation with name '%s' already exists."] = "Error renombrando operación. Operación con ese nombre '%s' ya existe."
L["Essences"] = "Esencias" -- Needs review
L["Examples"] = "Ejemplos"
L["Existing Profiles"] = "Perfiles Existentes"
L["Export Appearance Settings"] = "Exportar las Opciones de Aparencia"
L["Export Group Items"] = "Exportar grupo de objetos"
L["Export Items in Group"] = "Exportar objetos del grupo"
L["Export Operation"] = "Operación Exportada" -- Needs review
L["Failed to parse gold amount."] = "Falló al analizar la cantidad de oro."
L["First, ensure your new group is selected in the group-tree and then click on the 'Restock Selected Groups' button at the bottom."] = "Primero, asegúrate que tu nuevo grupo ha sido seleccionado en el árbol de grupos y después haz clic en el botón 'Restaurar Grupos Seleccionados' en la parte inferior." -- Needs review
L["First, ensure your new group is selected in the group-tree and then click on the 'Start Cancel Scan' button at the bottom of the tab."] = "Primero, asegúrate que tu nuevo grupo ha sido seleccionado en el árbol de grupos y después haz clic en el botón 'Empezar el escaneo de cancelaciones' en la parte inferior  de la pestaña." -- Needs review
L["First, ensure your new group is selected in the group-tree and then click on the 'Start Post Scan' button at the bottom of the tab."] = "Primero, asegúrate que tu nuevo grupo ha sido seleccionado en el árbol de grupos y después haz clic en el botón 'Empezar el escaneo de publicaciones' en la parte inferior de la pestaña." -- Needs review
L["First, ensure your new group is selected in the group-tree and then click on the 'Start Search' button at the bottom of the sidebar window."] = "Primero, asegúrate que tu nuevo grupo ha sido seleccionado en el árbol de grupos y después haz clic en el botón 'Empezar búsqueda' en la parte inferior de la barra lateral." -- Needs review
L["First, log into a character on the same realm (and faction) on both accounts. Type the name of the OTHER character you are logged into in the box below. Once you have done this on both accounts, TSM will do the rest automatically. Once setup, syncing will automatically happen between the two accounts while on any character on the account (not only the one you entered during this setup)."] = "Primero, inicie sesión con un personaje en el mismo reino (y facción) en ambas cuentas. Escriba el nombre del otro personaje que está conectado a la caja de texto de abajo. Una vez que haya hecho esto en ambas cuentas, TSM hará el resto automáticamente. Una vez configurada, la sincronización ocurrirá automáticamente entre las dos cuentas, mientras que en cualquier carácter en la cuenta (no sólo la que introdujo durante esta configuración)."
L["Fixed Gold Value"] = "Cantidad de Oro Fija"
L["Forget Characters:"] = "Olvidar Personajes:"
L["Frame Background - Backdrop"] = "Marco de Fondo - Fondo"
L["Frame Background - Border"] = "Marco del Fondo - Borde"
L["General Options"] = "Opciones Generales"
L["General Settings"] = "Configuración general"
L["Give the group a new name. A descriptive name will help you find this group later."] = "Dar un nuevo nombre al grupo. Un nombre descriptivo ayudará a encontrar el grupo más tarde."
L["Give the new group a name. A descriptive name will help you find this group later."] = "Dar un nuevo nombre al grupo. Un nombre descriptivo ayudará a encontrar el grupo más tarde."
L["Give this operation a new name. A descriptive name will help you find this operation later."] = "Dar a este operación un nombre nuevo. Uno descriptivo será de ayuda para encontrarlo más tarde."
L["Give your new custom price source a name. This is what you will type in to custom prices and is case insensitive (everything will be saved as lower case)."] = "Dale a tu nueva fuente de precio personalizado un nombre. Este será el que tendrás que introducir en los precios personalizados y es sensible a mayúsculas (todo será salvado como minúsculas)." -- Needs review
L["Goblineer (by Sterling - The Consortium)"] = "Goblineer (by Sterling - The Consortium)"
L["Go to the Auction House and open it."] = "Ve a la Casa de Subastas y ábrela." -- Needs review
L["Go to the 'Groups' Page"] = "Ve a la página de 'Grupos'" -- Needs review
L["Go to the 'Import/Export' Tab"] = "Ve a la pestaña de 'Importar/Exportar'" -- Needs review
L["Go to the 'Items' Tab"] = "Ve a la pestaña de 'Items'" -- Needs review
L["Go to the 'Operations' Tab"] = "Ve a la pestaña de 'Operaciones'" -- Needs review
L["Group:"] = "Grupo:"
L["Group(Base Item):"] = "Grupo(Objeto Base):"
L["Group Item Data"] = "Grupo de datos de objetos"
L["Group Items:"] = "Grupo de Objetos:"
L["Group Name"] = "Nombre de Grupo"
L["Group names cannot contain %s characters."] = "Los Nombres de los Grupos no pueden contener %s caracteres."
L["Groups"] = "Grupos"
L["Help"] = "Ayuda"
L["Help / Options"] = "Ayuda / Opciones" -- Needs review
L["Here you can setup relationships between the settings of this operation and other operations for this module. For example, if you have a relationship set to OperationA for the stack size setting below, this operation's stack size setting will always be equal to OperationA's stack size setting."] = "Aquí puedes configurar las relaciones entre las opciones de esta operación y otras operaciones para este módulo. Por ejemplo, si tu tienes establecida una relación en la Operación A para establecer un mínimo de tamaño de objetos en montón siempre será igual a el tamaño de la Operación A establecido."
L["Hide Minimap Icon"] = "Ocultar Icono Minimapa"
L["How would you like to craft?"] = "¿Cómo te gustaría fabricarlo?" -- Needs review
L["How would you like to create the group?"] = "¿Cómo te gustaría crear el grupo?" -- Needs review
L["How would you like to post?"] = "¿Cómo te gustaría publicar?" -- Needs review
L["How would you like to shop?"] = "¿Cómo te gustaría comprar?" -- Needs review
L["Icon Region"] = "Icono de la Region"
L["If checked, all tables listing auctions will display the bid as well as the buyout of the auctions. This will not take effect immediately and may require a reload."] = "Si se selecciona, todas las tablas de subastas listadas se mostrará la oferta, así como el precio decompra de las subastas. Esto no tendrá efecto inmediato y puede requerir una recarga." -- Needs review
L["If checked, any items you import that are already in a group will be moved out of their current group and into this group. Otherwise, they will simply be ignored."] = "Si lo activas, ningún de los objetos que importes estarán ya en un grupo serán movidos fuera de su grupo actual y dentro de este grupo. De otra forma, serán simplemente ignorados."
L["If checked, group names will be colored based on their subgroup depth in group trees."] = "Si se selecciona, los nombres de grupo serán coloreado en base a la profundidad de los árboles de subgrupo." -- Needs review
L["If checked, only items which are in the parent group of this group will be imported."] = "Si es activado, sólo los objetos que están en el grupo superior de este grupo serán importados."
L["If checked, operations will be stored globally rather than by profile. TSM groups are always stored by profile. Note that if you have multiple profiles setup already with separate operation information, changing this will cause all but the current profile's operations to be lost."] = "Si es activado, las operaciones serán guardadas a nivel global más que por el perfil. Grupos TSM son siempre guardados por el perfil. Tenga en cuenta que si tiene varias configuraciones de perfiles con información de operaciones separada, cambiando esto causará que todas menos las operaciones del perfil actual se pierdan."
L["If checked, the disenchant value of the item will be shown. This value is calculated using the average market value of materials the item will disenchant into."] = "Si es activado, el valor de desencantamiento del objeto será mostrado. Este valor es calculado usando el valor medio de mercado de los material del objeto a desencantar."
L["If checked, the price of buying the item from a vendor is displayed."] = "Si es activado, el precio de compra de objecto de un vendedor será mostrado."
L["If checked, the price of selling the item to a vendor displayed."] = "Si es activado, el precio de venta de objecto de un vendedor será mostrado."
L["If checked, the structure of the subgroups will be included in the export. Otherwise, the items in this group (and all subgroups) will be exported as a flat list."] = "Si se selecciona, la estructura de subgrupos será incluida en la exportación. De otra forma, los ítems en este grupo (y todos los subgrupos) serán exportado como una lista plana." -- Needs review
L["If checked, this custom price will be displayed in item tooltips."] = "Si se selecciona, este precio personalizado será mostrado en la ayuda de ítems." -- Needs review
L["If checked, TSM's tooltip lines will be embedded in the item tooltip. Otherwise, it will show as a separate box below the item's tooltip."] = "Si se selecciona, las líneas de ayuda de TSM serán empotrada en la ayuda emergente de los ítems. De otra forma, se mostrará en una caja separada debajo de la ayuda de ítems." -- Needs review
L["If checked, ungrouped items will be displayed in the left list of selection lists used to add items to subgroups. This allows you to add an ungrouped item directly to a subgroup rather than having to add to the parent group(s) first."] = "Si es activado, los objetos no agrupados serán mostrados en el listado izquierdo de la selección de listados usado para añadir objetos a subgrupos. Esto te permite añadir un objeto no agrupado directamente a un subgrupo en vez de añadirlo primeramente a un grupo superior"
L["If checked, your bags will be automatically opened when you open the auction house."] = "Si se selecciona, las bolsas se abren automáticamente cuando se abre la AH."
L["If there are no auctions currently posted for this item, simmply click the 'Post' button at the bottom of the AH window. Otherwise, select the auction you'd like to undercut first."] = "Si actualmente no hay subastas publicadas para este ítem, simplemente haz clic en el botón 'Publicar' de la ventana de la CS. De otra forma, selecciona la subasta que te gustaría recortar el precio primero." -- Needs review
L["If you delete, rename, or transfer a character off the current faction/realm, you should remove it from TSM's list of characters using this dropdown."] = "Si borras, renombras, o transfieres un personaje fuera de la facción/reino actual, tu deberías borrarlo del listado de personajes de TSM usando este desplegable."
L[ [=[If you'd like, you can adjust the value in the 'Minimum Profit' box in order to specify the minimum profit before Crafting will queue these items.

Once you're done adjusting this setting, click the button below.]=] ] = [=[Si quieres, tu puedes ajustar el valor de la caja 'Mínimo beneficio' para especificar el beneficio mínimo antes de Fabricar  una cola de esos ítems.

Una vez acabes de ajustar este preferencia, haz clic en el botón de abajo.]=] -- Needs review
L["If you have multiple profile set up with operations, enabling this will cause all but the current profile's operations to be irreversibly lost. Are you sure you want to continue?"] = "Si tiene varios perfiles configurados con operaciones, activando esto hará que todos, menos las operaciones del perfil actual se pierdan irreversiblemente. ¿Está seguro que desea continuar?"
L["If you open your bags and shift-click the item in your bags, it will be placed in Shopping's search bar. You may need to put your cursor in the search bar first. Alternatively, you can type the name of the item manually in the search bar and then hit enter or click the 'Search' button."] = "Si abres tus bolsas y pulsas shift-clic el ítem de tus bolsas, será mostrado en la barra de búsqueda de compras. Tu necesitas poner el cursor en la barra de búsquedas previamente. Altenartivamente, puedes introducir manualmente el nombre del ítem manualmente en la barra de búsquedas y pulsar intro o clic en el botón 'Buscar'." -- Needs review
L["Ignore Operation on Characters:"] = "Ignorar Operación en Personajes:"
L["Ignore Operation on Faction-Realms:"] = "Ignorar Opoeración en Facción-Reino:"
L["Ignore Random Enchants on Ungrouped Items"] = "Ignorar Encantamientos aleatorios u Objetos sin Grupo"
L["I'll Go There Now!"] = "Voy allí ahora!" -- Needs review
L["I'm done."] = "He acabado." -- Needs review
L["Import Appearance Settings"] = "Importar las Opciones de Apariencia"
L["Import/Export"] = "Importar/Exportar"
L["Import Items"] = "Importar objetos"
L["Import Operation Settings"] = "Importar configuración de Operación" -- Needs review
L["Import Preset TSM Theme"] = "Importar ajuste preestablecido del Tema TSM"
L["Import String"] = "Importar Cadena"
L["Include Subgroup Structure in Export"] = "Incluir la Estructura de Subgrupo en Exportar." -- Needs review
L["Installed Modules"] = "Módulos Instalados" -- Needs review
L["In the confirmation window, you can adjust the buyout price, stack sizes, and auction duration. Once you're done, click the 'Post' button to post your items to the AH."] = "En la ventana de confirmación, puedes ajustar el precio de compra, tamaño de montones, y duración de subasta. Una vez lo hayas hecho, haz clic en el botón 'Publicar' para publicar tus ítems en la CS." -- Needs review
L["In the list on the left, select the top-level 'Groups' page."] = "En la lista de la izquierda, selección el nivel superior de página 'Grupos'." -- Needs review
L["Invalid appearance data."] = "Datos de apariencia no válidos."
L["Invalid custom price."] = "Precio personalizado no válido"
L["Invalid custom price for undercut amount. Using 1c instead."] = "Precio personalizado no válido por la cantidad rebajada. Usando 1c en su lugar."
L["Invalid filter."] = "Filtro no válido."
L["Invalid function."] = "Función no válida."
L["Invalid import string."] = "Cadena de importación no válida."
L["Invalid item link."] = "Enlace a objeto no válido."
L["Invalid operator at end of custom price."] = "Operador no válido al final del precio personalizado." -- Needs review
L["Invalid parameter to price source."] = "Parámetro no válido para precio personalizado." -- Needs review
L["Invalid parent argument type. Expected table, got %s."] = "Tipo de argumento matriz no válido. La tabla esperada, tiene %s."
L["Invalid price source in convert."] = "Fuente de precio en conversión no válida."
L["Invalid word: '%s'"] = "Palabra no válida: '%s'"
L["Item"] = "Objeto"
L["Item Buyout: %s"] = "Compra de objeto: %s"
L["Item Level"] = "Nivel de objeto"
L["Item links may only be used as parameters to price sources."] = "Enlaces de objeto sólo pueden ser usados como parámetros a la fuente de precios."
L["Item not found in bags. Skipping"] = "Objeto no encontrado en las bolsas. Ignorando."
L["Items"] = "Objetos"
L["Item Tooltip Text"] = "Texto del Tooltip de Objetos"
L["Jaded (by Ravanys - The Consortium)"] = "Jaded (by Ravanys - The Consortium)"
L["Just incase you didn't read this the first time:"] = "Sólo en caso que usted no leyó esto la primera vez:" -- Needs review
L[ [=[Just like the default profession UI, you can select what you want to craft from the list of crafts for this profession. Click on the one you want to craft.

Once you're done, click the button below.]=] ] = [=[Como la UI de profesiones por defecto, puedes seleccionar que quieres fabricar de la lista de fabricación para este profesión. Haz clic en el que quieres fabricar.

Una vez lo hayas hecho, clic en el botón de abajo.]=] -- Needs review
L["Keep Items in Parent Group"] = "Guardas objetos en el grupo superior"
L["Keeps track of all your sales and purchases from the auction house allowing you to easily track your income and expenditures and make sure you're turning a profit."] = "Realiza un seguimiento de todas sus ventas y compras de la casa de subastas que le permite rastrear fácilmente sus ingresos y sus gastos y asegurarse de que dan beneficios."
L["Label Text - Disabled"] = "Etiquetas de Texto - Deshabilitado"
L["Label Text - Enabled"] = "Etiquetas de Texto - Habilitado"
L["Lead Developer and Co-Founder:"] = "Lider de Desarrollo y Co-Fundador:"
L["Light (by Ravanys - The Consortium)"] = "Light (by Ravanys - The Consortium)"
L["Link Text 2 (Requires Reload)"] = "Link de Texto 2 (Requiere Reload)"
L["Link Text (Requires Reload)"] = "Links de Texto (Requiere Reload)"
L["Load Saved Theme"] = "Cargar Tema Guardado"
L["Look at what's profitable to craft and manually add things to a queue"] = "Mira que es beneficioso fabricar y manualmente añade cosas a la cola" -- Needs review
L["Look for items which can be destroyed to get raw mats"] = "Mira que ítems son los que se pueden destruir para conseguir materiales en bruto." -- Needs review
L["Look for items which can be vendored for a profit"] = "Mira que ítems puedes conseguir beneficio vendiéndolos en el vendedor." -- Needs review
L["Looks like no items were added to the queue. This may be because you are already at or above your restock levels, or there is nothing profitable to queue."] = "Parece que no se añadieron ítems a cola. Esto puede ser porque tu restauración de cola está por debajo de lo que puede ser beneficioso en tu cola." -- Needs review
L["Looks like no items were found. You can either try searching for something else, or simply close the Assistant window if you're done."] = "Parece que no se encontraron items. Puedes intentar buscar por alguna otra cosa, o simplemente cerrar la ventanta del asistente si has acabado." -- Needs review
L["Looks like no items were imported. This might be because they are already in another group in which case you might consider checking the 'Move Already Grouped Items' box to force them to move to this group."] = "Parece que no se importaron items. Esto puede ser porque ya están en otro grupo en tal caso deberías considerar seleccionar la caja 'Mover items que están agrupados' para forzarlos a moverse a este grupo." -- Needs review
L["Looks like TradeSkillMaster has detected an error with your configuration. Please address this in order to ensure TSM remains functional."] = "Parece que TradeSkillMaster detectó un error con tu configuración. Por favor envíanos el error para mantener funcional TSM." -- Needs review
L["Looks like TradeSkillMaster has encountered an error. Please help the author fix this error by copying the entire error below and following the instructions for reporting bugs listed here (unless told elsewhere by the author):"] = "Parece que TradeSkillMaster ha encontrado un error. Por favor, ayudar al autor corregir este error al copiar el error completo a continuación y siga las instrucciones para informar de fallos en la lista aquí (a menos que en otros lugares por el autor):"
L["Looks like TradeSkillMaster has encountered an error. Please help the author fix this error by following the instructions shown."] = "Parece que TradeSkillMaster ha encontrado un error. Por favor, ayudar al autor corregir este error, siga las instrucciones que se muestran."
L["Loop detected in the following custom price:"] = "Reduncia cíclica detectada en el precio personalizado seguido:" -- Needs review
L["Make a new group from an import list I have"] = "Haz un nuevo grupo a partir de una lista importada que tenga" -- Needs review
L["Make a new group from items in my bags"] = "Haz un nuevo grupo a partir de items de mis bolsas" -- Needs review
L["Make Auction Frame Movable"] = "Haga subasta bastidor móvil"
L["Management"] = "Administración"
L["Manages your inventory by allowing you to easily move stuff between your bags, bank, and guild bank."] = "Administra tu inventario por lo que le permite moverse con facilidad entre las cosas de sus bolsas, bancos, y el banco del gremio."
L["% Market Value"] = "% Valor de mercado"
L["max %d"] = "max %d"
L["Medium Text Size (Requires Reload)"] = "Tamaño medio de texto (Requiere recargar)"
L["Mills, prospects, and disenchants items at super speed!"] = "Muele, prospecta y desencanta objetos a una velocidad extraordinaria!"
L["Misplaced comma"] = "Coma fuera de lugar."
L["Module:"] = "Módulo:"
L["Module Information:"] = "Información de Módulo:"
L["Module Operations / Options"] = "Módulo Operaciones / Opciones"
L["Modules"] = "Módulos" -- Needs review
L["More Advanced Methods"] = "Mas Metodos Avanzados"
-- L["More advanced options are now designated by %sred text|r. Beginners are encourages to come back to these once they have a solid understanding of the basics."] = ""
L["Move Already Grouped Items"] = "Mover los objetos ya en grupo"
L["Moved %s to %s."] = "Movido %s a %s"
L["Move Group"] = "Mover Grupo"
L["Move to Top Level"] = "Mover al nivel mas alto"
L["Multi-Account Settings"] = "Opciones de MultiCuenta"
L["My group is selected."] = "Mi grupo está seleccionado." -- Needs review
L["My new operation is selected."] = "Mi nueva oprración está seleccionada." -- Needs review
L["New"] = "Nuevo"
L["New Custom Price Source"] = "Nueva fuente de precio personalizado" -- Needs review
L["New Group"] = "Nuevo Grupo"
L["New Group Name"] = "Nuevo Nombre de Grupo"
L["New Parent Group"] = "Nuevo Grupo Superior"
L["New Subgroup Name"] = "Nuevo Subgrupo"
-- L["No Assistant guides available for the modules which you have installed."] = ""
L["<No Group Selected>"] = "<Sin Grupo Seleccionado>" -- Needs review
L["No modules are currently loaded.  Enable or download some for full functionality!"] = "No hay módulos cargados actualmente. Activa o descarga alguno para tener una funcionalidad completa!"
L["None of your groups have %s operations assigned. Type '/tsm' and click on the 'TradeSkillMaster Groups' button to assign operations to your TSM groups."] = "Ninguno de los grupos tienen %s operaciones asignadas. Escribe '/tsm' y haz clic en el botón 'Grupos TradeSkillMaster' para asignar operaciones a tus grupos TSM."
L["<No Operation>"] = "<Sin Operación>"
L["<No Operation Selected>"] = "<Sin Operación Seleccionada>" -- Needs review
L["<No Relationship>"] = "<Sin Relación>"
L["Normal Text Size (Requires Reload)"] = "Tamaño del Texto (Requiere Reload)"
--[==[ L[ [=[Now that the scan is finished, you can look through the results shown in the log, and for each item, decide what action you want to take.

Once you're done, click on the button below.]=] ] = "" ]==]
L["Number of Auction Result Rows (Requires Reload)"] = "Numero de Filas en los Resultados (Requiere Reload)"
L["Only Import Items from Parent Group"] = "Sólo Importar Objetos desde el Grupo Superior"
L["Open All Bags with Auction House"] = "Abrir todas las Bolsas en AH"
-- L["Open one of the professions which you would like to use to craft items."] = ""
-- L["Open the Auction House"] = ""
-- L["Open the TSM Window"] = ""
-- L["Open up Your Profession"] = ""
L["Operation #%d"] = "Operación #%d"
L["Operation Management"] = "Administración de Operación"
L["Operations"] = "Operaciones"
L["Operations: %s"] = "Operaciones: %s"
L["Options"] = "Opciones"
L["Override Module Operations"] = "Anular Operaciones de Módulo"
L["Parent Group Items:"] = "Objetos de Grupo Superior:"
L["Parent/Ungrouped Items:"] = "Objetos Agrupados / No Agrupados:"
L["Past Contributors:"] = "Contribuidores anteriores:"
L["Paste the exported items into this box and hit enter or press the 'Okay' button. The recommended format for the list of items is a comma separated list of itemIDs for general items. For battle pets, the entire battlepet string should be used. For randomly enchanted items, the format is <itemID>:<randomEnchant> (ex: 38472:-29)."] = "Pegue los productos exportados en este cuadro y pulsa enter o el botón 'Ok'. El formato recomendado por la lista de elementos es una lista separada por comas de ItemIDs por artículos generales. Para los BattlePets de batalla, se debe utilizar toda la cadena de Battlepet. Para objetos encantados al azar, el formato es <itemID>: <randomEnchant> (ex: 38472: -29)."
-- L["Paste the exported operation settings into this box and hit enter or press the 'Okay' button. Imported settings will irreversibly replace existing settings for this operation."] = ""
L[ [=[Paste the list of items into the box below and hit enter or click on the 'Okay' button.

You can also paste an itemLink into the box below to add a specific item to this group.]=] ] = [=[Pegue la lista de artículos en la casilla de abajo y pulsa enter o haga clic en el botón 'Ok'.

También puede pegar una itemLink en el cuadro de abajo para agregar un elemento específico de este grupo.]=]
-- L["Paste your import string into the 'Import String' box and hit the <Enter> key to import the list of items."] = ""
L["Percent of Price Source"] = "Porcentaje de Fuente de Precios"
L["Performs scans of the auction house and calculates the market value of items as well as the minimum buyout. This information can be shown in items' tooltips as well as used by other modules."] = "Realiza los análisis de la casa de subastas y calcula el valor de mercado de los artículos, así como la compra mínima. Esta información puede ser mostrado en tooltips Artículos ', así como el usado por otros módulos."
L["Per Item:"] = "Por objeto:"
-- L["Please select the group you'd like to use."] = ""
-- L["Please select the new operation you've created."] = ""
-- L["Please wait..."] = ""
L["Post"] = "Post"
-- L["Post an Item"] = ""
-- L["Post items manually from my bags"] = ""
L["Posts and cancels your auctions to / from the auction house according to pre-set rules. Also, this module can show you markets which are ripe for being reset for a profit."] = "Publica y cancela tus subastas de / desde la casa de subastas de acuerdo a las reglas preconfiguradas. También, este módulo puede mostrarte mercados que son beneficiosos."
-- L["Post Your Items"] = ""
L["Price Per Item"] = "Precio por Objeto"
L["Price Per Stack"] = "Precio por Montón"
L["Price Per Target Item"] = "Precio por Objeto destino"
L["Prints out the available price sources for use in custom price boxes."] = "Muestra las fuentes de precios disponibles para su uso en cajas de precios personalizados."
L["Prints out the version numbers of all installed modules"] = "Muestra los números de versión de todos los módulos instalados"
L["Profiles"] = "Perfiles"
L["Provides extra functionality that doesn't fit well in other modules."] = "Proporciona funcionalidad adicional que no encaja bien en otros módulos."
L["Provides interfaces for efficiently searching for items on the auction house. When an item is found, it can easily be bought, canceled (if it's yours), or even posted from your bags."] = "Proporciona interfaces para de manera eficiente la búsqueda de elementos en la casa de subastas. Cuando se encuentra un elemento, que puede ser fácilmente comprado, cancelado (si es tuyo), o incluso publicado en su equipaje."
L["Purchasing Auction: %d/%d"] = "Comprando Subasta €d/%d"
-- L["Queue Profitable Crafts"] = ""
-- L["Quickly post my items at some pre-determined price"] = ""
L["Region - Backdrop"] = "Region - Fondo"
L["Region - Border"] = "Region - Borde"
-- L["Remove"] = ""
L["<<< Remove"] = "<<< Borrar"
-- L["Removed '%s' as a custom price source. Be sure to update any custom prices that were using this source."] = ""
L["<Remove Operation>"] = "<Borrar Operación>"
-- L["Rename Custom Price Source"] = ""
L["Rename Group"] = "Renombrar Grupo"
L["Rename Operation"] = "Renombrar Operacion"
L["Replace"] = "Reemplazar"
L["Reset Profile"] = "Resetear Perfil"
-- L["Resets the position, scale, and size of all applicable TSM and module frames."] = ""
L["Reset the current profile back to its default values, in case your configuration is broken, or you simply want to start over."] = "Resetear el actual perfil a sus valores por defecto, en caso de que la configuracion este rota, o que simplemente quieres volver a empezar."
L["Resources:"] = "Recursos"
-- L["Restart Assistant"] = ""
L["Restore Default Colors"] = "Restaurar colores predeterminados"
L["Restores all the color settings below to their default values."] = "Restaura todos los ajustes de color por debajo de sus valores predeterminados."
L["Saved theme: %s."] = "Tema Guardado: %s"
L["Save Theme"] = "Guardar Tema"
L["%sDrag%s to move this button"] = "%sArrastrar%s para mover este botón"
L["Searching for item..."] = "Buscando al objeto..."
-- L["Search the AH for items to buy"] = ""
L["See instructions above this editbox."] = "Vea las instrucciones por encima de este cuadro de edición."
L["Select a group from the list below and click 'OK' at the bottom."] = "Seleccione un grupo de la lista a continuación y haga clic en \"Aceptar\" en la parte inferior."
L["Select All Groups"] = "Seleccionar todos los Grupos"
L["Select an operation to apply to this group."] = "Seleccionar una operacion para aplicar a este grupo."
L["Select a %s operation using the dropdown above."] = "Seleccione la operación a %s usando el desplegable anterior."
L["Select a theme from this dropdown to import one of the preset TSM themes."] = "Seleccione un tema de la lista desplegable para importar uno de los temas TSM predefinidos."
L["Select a theme from this dropdown to import one of your saved TSM themes."] = "Seleccione un tema de la lista desplegable para importar uno de sus temas de TSM guardados."
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
L["Select the price source for calculating disenchant value."] = "Seleccione la fuente de precios para calcular el valor desencantamiento."
-- L["Select the 'Shopping' tab to open up the settings for TSM_Shopping."] = ""
--[==[ L[ [=[Select your new operation in the list of operation along the left of the TSM window (if it's not selected automatically) and click on the button below.

Currently Selected Operation: %s]=] ] = "" ]==]
L["Seller"] = "Vendedor"
-- L["Sell items on the AH and manage my auctions"] = ""
L["Sell to Vendor"] = "Vender al Vendedor"
L["Set All Relationships to Target"] = "Establecer todas las relaciones al objetivo"
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
L["Sets all relationship dropdowns below to the operation selected."] = "Establece todas las relaciones desplegados a continuación a la operación seleccionada."
L["Settings"] = "Opciones"
L["Setup account sync'ing with the account which '%s' is on."] = "Configuración de cuenta de la sincronización con la cuenta de que '%s' está activada."
-- L["Set up TSM to automatically cancel undercut auctions"] = ""
-- L["Set up TSM to automatically post auctions"] = ""
-- L["Set up TSM to automatically queue things to craft"] = ""
-- L["Setup TSM to automatically reset specific markets"] = ""
-- L["Set up TSM to find cheap items on the AH"] = ""
L["Shards"] = "Fragmentos"
-- L["Shift-Click an item in the sidebar window to immediately post it at your quick posting price."] = ""
-- L["Shift-Click Item in Your Bags"] = ""
L["Show Bids in Auction Results Table (Requires Reload)"] = "Mostrar las ofertas en la subasta Tabla de resultados (requiere una recarga)"
-- L["Show the 'Custom Filter' Sidebar Tab"] = ""
-- L["Show the 'Other' Sidebar Tab"] = ""
-- L["Show the Queue"] = ""
-- L["Show the 'Quick Posting' Sidebar Tab"] = ""
-- L["Show the 'TSM Groups' Sidebar Tab"] = ""
L["Show Ungrouped Items for Adding to Subgroups"] = "Mostrar elementos no agrupados para añadir a subgrupos"
L["%s is a valid custom price but did not give a value for %s."] = "%s es un precio personalizado válido pero no dió un valor para %s"
L["%s is a valid custom price but %s is an invalid item."] = "%s es un precio personalizado válido pero %s es un objeto no válido."
L["%s is not a valid custom price and gave the following error: %s"] = "%s no es un precio personalizado válido y da el siguiente error: %s"
L["Skipping auction which no longer exists."] = "Saltarse subasta que ya no existe."
L["Slash Commands:"] = "Comandos de barra:"
L["%sLeft-Click|r to select / deselect this group."] = "%sClic izquierdo para seleccionar / deseleccionar este grupo."
L["%sLeft-Click%s to open the main window"] = "%sClic izquierdo%s para abrir la ventana principal"
L["Small Text Size (Requires Reload)"] = "Tamaño del Texto Pequeño (Requiere Reload)"
-- L["Snipe items as they are being posted to the AH"] = ""
-- L["Sniping Scan in Progress"] = ""
L["%s operation(s):"] = "%s operación(es):"
-- L["Sources"] = ""
L["%sRight-Click|r to collapse / expand this group."] = "%sClic derecho para comprimir / expandir este grupo."
L["Stack Size"] = "Tamaño del monton"
L["stacks of"] = "Montones de"
-- L["Start a Destroy Search"] = ""
-- L["Start Sniper"] = ""
-- L["Start Vendor Search"] = ""
L["Status / Credits"] = "Estado / Créditos"
L["Store Operations Globally"] = "Operaciones de Almacén global"
L["Subgroup Items:"] = "Subgrupos Objetos:"
L["Subgroups contain a subset of the items in their parent groups and can be used to further refine how different items are treated by TSM's modules."] = "Subgrupos contienen un subconjunto de los objetos en sus grupos de superiores y se pueden usar para perfeccionar la forma en diferentes objetos son tratados por los módulos de TSM."
L["Successfully imported %d items to %s."] = "Éxito importadas %d elementos a %s."
-- L["Successfully imported operation settings."] = ""
-- L["Switch to Destroy Mode"] = ""
-- L["Switch to New Custom Price Source After Creation"] = ""
L["Switch to New Group After Creation"] = "Cambiar al nuevo grupo Después de Creación"
-- L["Switch to the 'Professions' Tab"] = ""
-- L["Switch to the 'TSM Groups' Tab"] = ""
L["Target Operation"] = "Objetivo de la Operacion"
L["Testers (Special Thanks):"] = "Testers (agradecimiento especial):"
L["Text:"] = "Texto:"
L["The default tab shown in the 'BankUI' frame."] = "La pestaña por defecto se muestra en el cuadro 'BankUI'."
-- L["The final set of posting settings are under the 'Posting Price Settings' header. These define the price ranges which Auctioning will post your items within. Read the tooltips of the individual settings to see what they do and set them appropriately."] = ""
-- L["The first set of posting settings are under the 'Auction Settings' header. These control things like stack size and auction duration. Read the tooltips of the individual settings to see what they do and set them appropriately."] = ""
L["The Functional Gold Maker (by Xsinthis - The Golden Crusade)"] = "The Functional Gold Maker (by Xsinthis - The Golden Crusade)"
--[==[ L[ [=[The 'Maxium Auction Price (per item)' is the most you want to pay for the items you've added to your group. If you're not sure what to set this to and have TSM_AuctionDB installed (and it contains data from recent scans), you could try '90% dbmarket' for this option.

Once you're done adjusting this setting, click the button below.]=] ] = "" ]==]
--[==[ L[ [=[The 'Max Restock Quantity' defines how many of each item you want to restock up to when using the restock queue, taking your inventory into account.

Once you're done adjusting this setting, click the button below.]=] ] = "" ]==]
L["Theme Name"] = "Nombre del Tema"
L["Theme name is empty."] = "Nombre del Tema vacio."
-- L["The name can ONLY contain letters. No spaces, numbers, or special characters."] = ""
L["There are no visible banks."] = "No hay espacios visibles."
-- L["There is only one price level and seller for this item."] = ""
-- L["The second set of posting settings are under the 'Auction Price Settings' header. These include the percentage of the buyout which the bid will be set to, and how much you want to undercut by. Read the tooltips of the individual settings to see what they do and set them appropriately."] = ""
-- L["These settings control when TSM_Auctioning will cancel your auctions. Read the tooltips of the individual settings to see what they do and set them appropriately."] = ""
--[==[ L[ [=[The 'Sniper' feature will constantly search the last page of the AH which shows items as they are being posted. This does not search existing auctions, but lets you buy items which are posted cheaply right as they are posted and buy them before anybody else can.

You can adjust the settings for what auctions are shown in TSM_Shopping's options.

Click the button below when you're done reading this.]=] ] = "" ]==]
L["This allows you to export your appearance settings to share with others."] = "Esto te permite exportar tu apariencia y compartirla."
L["This allows you to import appearance settings which other people have exported."] = "Esto te permite importar una apariencia."
L["This dropdown determines the default tab when you visit a group."] = "Este menú desplegable determina la pestaña por defecto cuando usted visita un grupo."
L["This group already has operations. Would you like to add another one or replace the last one?"] = "Este grupo ya tiene operaciones. ¿Te gustaría añadir otro o reemplazar el último?"
L["This group already has the max number of operation. Would you like to replace the last one?"] = "Este grupo ya tiene el número máximo de operación. ¿Desea reemplazar el último?"
L["This operation will be ignored when you're on any character which is checked in this dropdown."] = "Esta operación se tendrá en cuenta cuando estás en cualquier carácter que se comprueba en esta lista desplegable."
-- L["This option sets which tab TSM and its modules will use for printing chat messages."] = ""
L["Time Left"] = "Tiempo Restante"
L["Title"] = "Titulo"
L["Toggles the bankui"] = "Habilitar BankUI"
L["Tooltip Options"] = "Tooltip Opciones"
L["Tracks and manages your inventory across multiple characters including your bags, bank, and guild bank."] = "Controla y maneja su inventario a través de varios personajes, incluyendo sus bolsas, bancos, y banco de hermandad."
L["TradeSkillMaster Error Window"] = "Ventana de error de TradeSkillMaster"
L["TradeSkillMaster Info:"] = "Información TradeSkillMaster:"
L["TradeSkillMaster Team"] = "Equipo de TradeSkillMaster"
L["TSM Appearance Options"] = "Opciones de Aparencia del TSM"
-- L["TSM Assistant"] = ""
L["TSM Classic (by Jim Younkin - Power Word: Gold)"] = " TSM Classic (by Jim Younkin - Power Word: Gold)"
L["TSMDeck (by Jim Younkin - Power Word: Gold)"] = " TSMDeck (by Jim Younkin - Power Word: Gold)"
L["/tsm help|r - Shows this help listing"] = "/tsm help|r - Muestra este listado de ayuda." -- Needs review
L["TSM Info / Help"] = "Información / Ayuda TSM"
L["/tsm|r - opens the main TSM window."] = "/tsm|r - Abre la ventana principal de TSM"
L["TSM Status / Options"] = "TSM Estado / Opciones"
L["TSM Version Info:"] = "TSM Versión Info:"
L["TUJ GE - Market Average"] = "TUJ GE - Mercado Media"
L["TUJ GE - Market Median"] = "Tuj GE - mercado media"
L["TUJ RE - Market Price"] = "TUJ RE - Precio de mercado"
L["TUJ RE - Mean"] = "TUJ RE - Mean"
-- L["Type a raw material you would like to obtain via destroying in the search bar and start the search. For example: 'Ink of Dreams' or 'Spirit Dust'."] = ""
L["Type in the name of a new operation you wish to create with the same settings as this operation."] = "Escriba el nombre de una nueva operación que desea crear con la misma configuración que esta operación."
-- L["Type '/tsm' or click on the minimap icon to open the main TSM window."] = ""
L["Type '/tsm sources' to print out all available price sources."] = "Escriba \"/ tsm sources' para imprimir todas las fuentes disponibles sobre los precios."
L["Unbalanced parentheses."] = "Paréntesis no balanceados."
-- L["Underneath the 'Posting Options' header, there are two settings which control the Quick Posting feature of TSM_Shopping. The first one is the duration which Quick Posting should use when posting your items to the AH. Change this to your preferred duration for Quick Posting."] = ""
-- L["Underneath the 'Posting Options' header, there are two settings which control the Quick Posting feature of TSM_Shopping. The second one is the price at which the Quick Posting will post items to the AH. This should generally not be a fixed gold value, since it will apply to every item. Change this setting to what you'd like to post items at with Quick Posting."] = ""
-- L["Underneath the serach bar at the top of the 'Shopping' AH tab are a handful of buttons which change what's displayed in the sidebar window. Click on the 'Custom Filter' one."] = ""
-- L["Underneath the serach bar at the top of the 'Shopping' AH tab are a handful of buttons which change what's displayed in the sidebar window. Click on the 'Other' one."] = ""
-- L["Underneath the serach bar at the top of the 'Shopping' AH tab are a handful of buttons which change what's displayed in the sidebar window. Click on the 'TSM Groups' one."] = ""
-- L["Under the search bar, on the left, you can switch between normal and destroy mode for TSM_Shopping. Switch to 'Destroy Mode' now."] = ""
L["Ungrouped Items:"] = "Objetos no agrupados:"
L["Usage: /tsm price <ItemLink> <Price String>"] = "Uso: / tsm price <ItemLink> <Price String>"
-- L["Use an existing group"] = ""
-- L["Use a subset of items from an existing group by creating a subgroup"] = ""
L["Use the button below to delete this group. Any subgroups of this group will also be deleted, with all items being returned to the parent of this group or removed completely if this group has no parent."] = "Usa el botón de abajo para eliminar este grupo. Los subgrupos de este grupo también se eliminarán, con todos los artículos que vaya a devolver a los superior de este grupo o eliminado por completo si este grupo no tiene superior."
L["Use the editbox below to give this group a new name."] = "Utilice el cuadro de edición de abajo para darle a este grupo un nuevo nombre."
L["Use the group box below to move this group and all subgroups of this group. Moving a group will cause all items in the group (and its subgroups) to be removed from its current parent group and added to the new parent group."] = "Utilice el cuadro de grupo abajo para mover este grupo y todos los subgrupos de este grupo. Mover un grupo hará que todos los objetos del grupo (y sus subgrupos) para ser removidos de su grupo matriz actual y agregar al nuevo grupo de padres."
L["Use the options below to change and tweak the appearance of TSM."] = "Utilice las siguientes opciones para cambiar y modificar la apariencia de TSM."
L["Use the tabs above to select the module for which you'd like to configure operations and general options."] = "Utilice las pestañas de abajo para seleccionar el módulo para el que desea configurar las operaciones y opciones generales."
L["Use the tabs above to select the module for which you'd like to configure tooltip options."] = "Utilice las pestañas de abajo para seleccionar el módulo para el que desea configurar las opciones de tooltip."
L["Using our website you can get help with TSM, suggest features, and give feedback."] = "Utilizando nuestro sitio web puedes obtener ayuda con TSM, sugerir características, y dar retroalimentación."
L["Various modules can sync their data between multiple accounts automatically whenever you're logged into both accounts."] = "Varios módulos pueden sincronizar sus datos entre varias cuentas de forma automática cada vez que estás conectado a ambas cuentas."
L["Vendor Buy Price:"] = "Vendedor Comprar Precio"
L["Vendor Buy Price x%s:"] = "Vendedor Comprar Precio x%s:"
L["Vendor Sell Price:"] = "Vendedor Precio de venta:"
L["Vendor Sell Price x%s:"] = "Vendedor Precio de venta x%s:"
L["Version:"] = "Versión:"
-- L["View current auctions and choose what price to post at"] = ""
L["View Operation Options"] = "Ver Opciones de la Operacion"
L["Visit %s for information about the different TradeSkillMaster modules as well as download links."] = "Visita %s para información acerca de los diferentes módulos de TradeSkillMaster asi como enlaces para su descarga."
-- L["Waiting for Scan to Finish"] = ""
L["Web Master and Addon Developer:"] = "Web Master y Desarrollador del Addon:"
-- L["We will add a %s operation to this group through its 'Operations' tab. Click on that tab now."] = ""
-- L["We will add items to this group through its 'Items' tab. Click on that tab now."] = ""
-- L["We will import items into this group using the import list you have."] = ""
-- L["What do you want to do?"] = ""
--[==[ L[ [=[When checked, random enchants will be ignored for ungrouped items.

NB: This will not affect parent group items that were already added with random enchants

If you have this checked when adding an ungrouped randomly enchanted item, it will act as all possible random enchants of that item.]=] ] = "" ]==]
L["When clicked, makes this group a top-level group with no parent."] = "Al hacer clic, hace que este grupo un grupo superior."
L["Would you like to add this new operation to %s?"] = "¿Te gustaría añadir esta nueva operación a %s?"
L["Wrong number of item links."] = "Número incorrecto de vínculos de objetos."
-- L["You appear to be attempting to import an operation from a different module."] = ""
L["You can change the active database profile, so you can have different settings for every character."] = "Puede cambiar el perfil de base de datos activa, por lo que puede tener diferentes configuraciones para cada personaje."
--[==[ L[ [=[You can craft items either by clicking on rows in the queue which are green (meaning you can craft all) or blue (meaning you can craft some) or by clicking on the 'Craft Next' button at the bottom.

Click on the button below when you're done reading this. There is another guide which tells you how to buy mats required for your queue.]=] ] = "" ]==]
L["You can either create a new profile by entering a name in the editbox, or choose one of the already exisiting profiles."] = "Puedes crear un nuevo perfil mediante la introducción de un nombre en el cuadro de edición, o elegir uno de los perfiles ya existentes."
-- L["You can hold shift while clicking this button to remove the items from ALL groups rather than keeping them in the parent group (if one exists)."] = ""
--[==[ L[ [=[You can look through the tooltips of the other options to see what they do and decide if you want to change their values for this operation.

Once you're done, click on the button below.]=] ] = "" ]==]
L["You cannot create a profile with an empty name."] = "No se puede crear un perfil con un nombre vacío."
-- L["You cannot use %s as part of this custom price."] = ""
--[==[ L[ [=[You can now use the buttons near the bottom of the TSM_Crafting window to create this craft.

Once you're done, click the button below.]=] ] = "" ]==]
--[==[ L[ [=[You can use the filters at the top of the page to narrow down your search and click on a column to sort by that column. Then, left-click on a row to add one of that item to the queue, and right-click to remove one.

Once you're done adding items to the queue, click the button below.]=] ] = "" ]==]
--[==[ L[ [=[You can use this sidebar window to help build AH searches. You can also type the filter directly in the search bar at the top of the AH window.

Enter your filter and start the search.]=] ] = "" ]==]
L["You currently don't have any groups setup. Type '/tsm' and click on the 'TradeSkillMaster Groups' button to setup TSM groups."] = "Usted actualmente no tiene ningún tipo de configuración grupos. Escriba \"/ tsm 'y haga clic en el botón' TradeSkillMaster Grupos\" para configurar los grupos de TSM."
L["You have closed the bankui. Use '/tsm bankui' to view again."] = "Ha cerrado el BankUI. Use '/ tsm bankui' para ver de nuevo."
-- L["You have successfully completed this guide. If you require further assistance, visit out our website:"] = ""
