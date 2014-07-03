-- ------------------------------------------------------------------------------ --
--                           TradeSkillMaster_Accounting                          --
--           http://www.curse.com/addons/wow/tradeskillmaster_accounting          --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- TradeSkillMaster_Accounting Locale - esES
-- Please use the localization app on CurseForge to update this
-- http://wow.curseforge.com/addons/TradeSkillMaster_Accounting/localization/

local L = LibStub("AceLocale-3.0"):NewLocale("TradeSkillMaster_Accounting", "esES")
if not L then return end

L["Accounting has not yet collect enough information for this tab. This is likely due to not having recorded enough data points or not seeing any significant fluctuations (over 1k gold) in your gold on hand."] = "La Contabilidad no ha recopilado suficiente información para este pestaña. Esto se debe a no haber registrado suficiente puntos de datos o no ver las fluctuaciones relevantes (sobre 1k oro) en tu oro probable." -- Needs review
L["Activity Type"] = "Tipo de Actividad" -- Needs review
L["All"] = "Todo" -- Needs review
L["Aucs"] = "Subastas" -- Needs review
L["Average Prices:"] = "Precios Medios:" -- Needs review
L["Avg Buy Price"] = "Precio Medio de Compra" -- Needs review
L["Avg Resale Profit"] = "Beneficio media de Reventa" -- Needs review
L["Avg Sell Price"] = "Precio Medio de Venta" -- Needs review
L["Back to Previous Page"] = "Volver a la Página Anterior" -- Needs review
L["Balance"] = "Balance" -- Needs review
L[ [=[Below is a graph of the current character's gold on hand over time.

The x-axis is time and goes from %s to %s
The y-axis is thousands of gold.]=] ] = [=[Debajo hay una gráfica del oro del personaje activo en probabilidad con el tiempo.

El eje X es el tiempo y va desde %s a %s
El eje Y está en miles de oros.]=] -- Needs review
L["Bought"] = "Comprado" -- Needs review
L["Buyer/Seller"] = "Comprador/Vendedor" -- Needs review
L["Cancelled"] = "Cancelado" -- Needs review
L["Cancelled Since Last Sale:"] = "Cancelado desde la Última Venta:" -- Needs review
L["Clear Old Data"] = "Borrar Datos Antiguos" -- Needs review
L["Click for a detailed report on this item."] = "Clic para un informe detallado de este objeto." -- Needs review
L["Click this button to permanently remove data older than the number of days selected in the dropdown."] = "Clic en este botón para borrar permanentemente los datos antiguos antes del número de días seleccionado en el desplegable." -- Needs review
L["Cost"] = "Coste" -- Needs review
L["Data older than this many days will be deleted when you click on the button to the right."] = "Datos más antiguos que estos días serán borrados cuando haga clic en el botón de la derecha." -- Needs review
L["Days:"] = "Días:" -- Needs review
L["DD/MM/YY HH:MM"] = "DD/MM/YY HH:MM" -- Needs review
L["Display Grey Items in Sales"] = "Mostrar los Objetos Grises en Ventas" -- Needs review
L["Don't prompt to record trades"] = "No preguntas para registrar operaciones" -- Needs review
L["Earned Per Day:"] = "Ganado por Día:" -- Needs review
L["Expenses"] = "Gastos" -- Needs review
L["Expired"] = "Terminado" -- Needs review
L["Expired Since Last Sale:"] = "Terminado desde la Última Venta:" -- Needs review
L["Failed Auctions"] = "Subastas Falladas" -- Needs review
L["Failed Since Last Sale (Expired/Cancelled):"] = "Fallada desde la Última Venta (Terminada/Cancelada):" -- Needs review
L["General Options"] = "Opciones Generales" -- Needs review
L["Gold Earned:"] = "Oro Ganado:" -- Needs review
L["Gold Spent:"] = "Oro Gastado:" -- Needs review
L["Group"] = "Grupo" -- Needs review
L["_ Hr _ Min ago"] = "hace _Hr_Min " -- Needs review
L["If checked, poor quality items will be shown in sales data. They will still be included in gold earned totals on the summary tab regardless of this setting"] = "Si es activado, los artículos de baja calidad son mostrados en los datos de venta. Ellos todavía serán incluidos en las ganancias de oro en la pestaña de resumen independientemente de los ajustes." -- Needs review
L["If checked, the average purchase price that shows in the tooltip will be the average price for the most recent X you have purchased, where X is the number you have in your bags / bank / gbank using data from the ItemTracker module. Otherwise, a simple average of all purchases will be used."] = "Si es activado, el precio medio de compra que se muestra en las etiquetas será el precio medio para la compra más reciente X, X es el número que tienes en tus bolsas/banco/banco de hermandad usando datos desde el módulo de Registro de Objetos, un simple promedio de todas las compras serán usadas." -- Needs review
L["If checked, the number of cancelled auctions since the last sale will show as up as failed auctions in an item's tooltip. if no sales then the total number of cancelled auctions will be shown."] = "Si es activado, el número de subastas canceladas desde la última venta se mostrará como subastas fallidas en una etiqueta de objeto. Si no hay ventas, entonces se mostrará el número de subastas canceladas." -- Needs review
L["If checked, the number of expired auctions since the last sale will show as up as failed auctions in an item's tooltip. if no sales then the total number of expired auctions will be shown."] = "Si es activado, el número de subastas terminadas desde la última venta se mostrará como subastas fallidas en una etiqueta de objeto. Si no hay ventas, entonces se mostrará el número de subastas terminadas." -- Needs review
L["If checked, the number you have purchased and the average purchase price will show up in an item's tooltip."] = "Si es activado, el número al que ha comprado y el precio medio de compra se mostrará en las etiquetas del objeto." -- Needs review
L["If checked, the number you have sold and the average sale price will show up in an item's tooltip."] = "Si es activado, el número al que ha vendido y el precio medio de venta se mostrará en las etiquetas del objeto." -- Needs review
L["If checked, the sale rate will be shown in item tooltips. sale rate is calculated as total sold / (total sold + total expired + total cancelled)."] = "Si es activado, el ratio de ventas será mostrado en las etiquetas de objetos, ratio de venta se calcula como total de ventas/(total de ventas + total terminadas + total canceladas)." -- Needs review
L["If checked, whenever you buy or sell any quantity of a single item via trade, Accounting will display a popup asking if you want it to record that transaction."] = "Si es activado, cada vez que compre o venda cualquier cantidad de un solo objeto a través de tratos, Contabilidad mostrará una ventana emergente que le preguntará si desea registrar la transacción." -- Needs review
L["If checked, you won't get a popup confirmation about whether or not to track trades."] = "Si es activado, no tendrá ventanas de confirmación emergente acerca de si debe o no registrar las ventas por tratos." -- Needs review
L["Income"] = "Ingresos" -- Needs review
L["Item Name"] = "Nombre de Objeto" -- Needs review
L["Items"] = "Objetos" -- Needs review
L["Last 14 Days"] = "Últimos 14 Días" -- Needs review
L["Last 30 Days"] = "Últimos 30 Días" -- Needs review
L["Last 30 Days:"] = "Últimos 30 Días:" -- Needs review
L["Last 60 Days"] = "Últimos 60 Días" -- Needs review
L["Last 7 Days"] = "Últimos 7 Días" -- Needs review
L["Last 7 Days:"] = "Últimos 7 Días:" -- Needs review
L["Last Purchase"] = "Última Compra" -- Needs review
L["Last Purchased:"] = "Última Compra:" -- Needs review
L["Last Sold"] = "Última Venta" -- Needs review
L["Last Sold:"] = "Última Venta:" -- Needs review
L["Market Value"] = "Valor de Mercado" -- Needs review
L["Market Value Source"] = "Valor de Mercado Fuente" -- Needs review
L["MM/DD/YY HH:MM"] = "MM/DD/YY HH:MM" -- Needs review
L["none"] = "Ninguno" -- Needs review
L["None"] = "Ninguno" -- Needs review
L["Options"] = "Opciones" -- Needs review
L["Other"] = "Otro" -- Needs review
L["Other Income"] = "Otro Ingreso" -- Needs review
L["Player"] = "Jugador" -- Needs review
L["Player Gold"] = "Oro del Jugador" -- Needs review
L["Player(s)"] = "Jugador(es)" -- Needs review
L["Price Per Item"] = "Precio por Objeto" -- Needs review
L["Profit:"] = "Beneficio:" -- Needs review
L["Profit Per Day:"] = "Beneficio por Día:" -- Needs review
L["Purchase Data"] = "Datos de Compra" -- Needs review
L["Purchased (Avg Price):"] = "Compras (Precio Medio):" -- Needs review
L["Purchased (Total Price):"] = "Compras (Precio Total):" -- Needs review
L["Purchases"] = "Compras" -- Needs review
L["Quantity"] = "Cantidad" -- Needs review
L["Quantity Bought:"] = "Cantidad Comprada:" -- Needs review
L["Quantity Sold:"] = "Cantidad Vendida:" -- Needs review
L["Rarity"] = "Rareza" -- Needs review
L["Removed a total of %s old records and %s items with no remaining records."] = "Borrados un total de %s registros antiguos y %s objetos sin registros restantes." -- Needs review
L["Remove Old Data (No Confirmation)"] = "Borrar Datos Antiguos (Sin Confirmación)" -- Needs review
L["Resale"] = "Reventa" -- Needs review
L["Revenue"] = "Renovar" -- Needs review
L["%s ago"] = "hace %s " -- Needs review
L["Sale Data"] = "Datos de Venta" -- Needs review
L["Sale Rate:"] = "Ratio de Venta:" -- Needs review
L["Sales"] = "Ventas" -- Needs review
L["Search"] = "Buscar" -- Needs review
L["Select how you would like prices to be shown in the \"Items\" and \"Resale\" tabs; either average price per item or total value."] = "Seleccione cómo desea que los precios se muestren en las pestañas de \"objetos\" y \"reventa\"; ya sea el precio medio por objeto o el valor total." -- Needs review
L["Select what format Accounting should use to display times in applicable screens."] = "Selecciona que formato Contable debería usar para mostrar los tiempos  en las pantallas correspondientes." -- Needs review
L["Select where you want Accounting to get market value info from to show in applicable screens."] = "Seleccione dónde desea Contabilidad para obtener información del valor de mercado para mostrarlo en las pantallas correspondientes." -- Needs review
L["Show Cancelled Auctions as Failed Auctions since Last Sale in item tooltips"] = "Mostrar SubastasCanceladas como Fallidas desde la Última Venta en las etiquetas de objetos" -- Needs review
L["Show Expired Auctions as Failed Auctions since Last Sale in item tooltips"] = "Mostrar Subastas terminadas desde la Última Venta en las etiquetas de objetos" -- Needs review
L["Show purchase info in item tooltips"] = "Mostrar información de compra en las etiquetas de objetos" -- Needs review
L["Show sale info in item tooltips"] = "Mostrar información de venta en las etiquetas de objetos" -- Needs review
L["Show Sale Rate in item tooltips"] = "Mostrar Ratio de Venta en las etiquetas de objetos" -- Needs review
L["Sold"] = "Venta" -- Needs review
L["Sold (Avg Price):"] = "Ventas (Precio Medio):" -- Needs review
L["Sold (Total Price):"] = "Ventas (Precio Total):" -- Needs review
L["Source"] = "Fuente" -- Needs review
L["Spent Per Day:"] = "Ventas por Día:" -- Needs review
L["Stack"] = "Montón" -- Needs review
L["Summary"] = "Resumen" -- Needs review
L["Target"] = "Destino" -- Needs review
L["There is no purchase data for this item."] = "No hay datos de compra para este objeto." -- Needs review
L["There is no sale data for this item."] = "No hay datos de venta para este objeto." -- Needs review
L["Time"] = "Tiempo" -- Needs review
L["Time Format"] = "Formato de Tempo" -- Needs review
L["Timeframe Filter"] = "Filtrar Plazo de Tiempo" -- Needs review
L["Today"] = "Hoy" -- Needs review
L["Top Buyers:"] = "Top Compradores:" -- Needs review
L["Top Expense by Gold:"] = "Top Gastos por Oro:" -- Needs review
L["Top Expense by Quantity:"] = "Top Gastos por Cantidad:" -- Needs review
L["Top Income by Gold:"] = "Top Ingresos por Oro:" -- Needs review
L["Top Income by Quantity:"] = "Top Ingresos por Cantidad:" -- Needs review
L["Top Item by Gold:"] = "Top Oro por Objeto:" -- Needs review
L["Top Item by Quantity:"] = "Top Cantidad por Objeto" -- Needs review
L["Top Sellers:"] = "Top Vendedores:" -- Needs review
L["Total:"] = "Total:" -- Needs review
L["Total Buy Price"] = "Precio de Compra Total" -- Needs review
L["Total Price"] = "Precio Total" -- Needs review
L["Total Sale Price"] = "Precio de Venta Total" -- Needs review
L["Total Spent:"] = "Total de Venta:" -- Needs review
L["Total Value"] = "Valor Total" -- Needs review
L["Track sales/purchases via trade"] = "Registra ventas/compras a través de tratos" -- Needs review
L["TSM_Accounting detected that you just traded %s %s in return for %s. Would you like Accounting to store a record of this trade?"] = "TSM_Accounting detectó que acaba de comerciar %s %s a cambio de %s. ¿Quiere que Contabilidad almacene un registro de este trato?" -- Needs review
L["Type"] = "Tipo" -- Needs review
L["Use smart average for purchase price"] = "Use la media inteligente para precio de compra" -- Needs review
L["Yesterday"] = "Ayer" -- Needs review
L[ [=[You can use the options below to clear old data. It is recommened to occasionally clear your old data to keep Accounting running smoothly. Select the minimum number of days old to be removed in the dropdown, then click the button.

NOTE: There is no confirmation.]=] ] = [=[Puede usar las opciones a continuación para borrar los datos antiguos. Se recomienda ocasionalmente borrar sus datos antiguos para guardar la Contabilidad funcionando sin problemas. Seleccione el número mínimo de días de antigüedad para ser borrados de la lista desplegable, después hacer clic en el botón.

NOTA: No hay confirmación.]=] -- Needs review
L["YY/MM/DD HH:MM"] = "YY/MM/DD HH:MM" -- Needs review
 