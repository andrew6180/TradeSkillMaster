-- ------------------------------------------------------------------------------------- --
-- 					TradeSkillMaster_Crafting - AddOn by Sapu94							 	  	  --
--   http://wow.curse.com/downloads/wow-addons/details/tradeskillmaster_crafting.aspx    --
--																													  --
--		This addon is licensed under the CC BY-NC-ND 3.0 license as described at the		  --
--				following url: http://creativecommons.org/licenses/by-nc-nd/3.0/			 	  --
-- 	Please contact the author via email at sapu94@gmail.com with any questions or		  --
--		concerns regarding this license.																	  --
-- ------------------------------------------------------------------------------------- --

-- TradeSkillMaster_Crafting Locale - ruRU
-- Please use the localization app on CurseForge to update this
-- http://wow.curseforge.com/addons/TradeSkillMaster_Crafting/localization/

local L = LibStub("AceLocale-3.0"):NewLocale("TradeSkillMaster_Crafting", "ruRU")
if not L then return end

L["All"] = "Все"
L["Are you sure you want to reset all material prices to the default value?"] = "Вы уверены, что хотите установить все цены на материалы по умолчанию?"
L["Ask Later"] = "Спросить позже"
L["Auction House"] = "Аукцион"
L["Available Sources"] = "Доступные источники"
L["Buy Vendor Items"] = "Купить у вендора"
L["Characters (Bags/Bank/AH/Mail) to Ignore:"] = "Игнорировать (Сумки/Банк/Аукцион/Почту) персонажа:"
L["Clear Filters"] = "Очистить фильтры"
L["Clear Queue"] = "Очистить очередь"
L["Click Start Gathering"] = "Нажмите для начала сбора"
L["Collect Mail"] = "Сбор почты"
L["Cost"] = "Стоимость"
L["Could not get link for profession."] = "Не удалось получить ссылку профессии"
L["Crafting Cost"] = "Стоимость создания"
L["Crafting Material Cost"] = "Стоимость материалов для крафта"
L["Crafting operations contain settings for restocking the items in a group. Type the name of the new operation into the box below and hit 'enter' to create a new Crafting operation."] = "Crafting операции содержат настройки по пополнению предметов в группе. Введите название новой операции в поле ниже и нажмите 'Enter' для создания новой Crafting операции."
L["Crafting will not queue any items affected by this operation with a profit below this value. As an example, a min profit of 'max(10g, 10% crafting)' would ensure atleast a 10g and 10% profit."] = "Крафт с прибылью менее указанного значения не будет добавлен в очередь. Пример: минимальная прибыль 'максимум(10з, 10% крафта)' чтобы получить минимум 10з или 10% прибыли."
L["Craft Next"] = "Создать следующее"
L["Craft Price Method"] = "Расчет цены крафта" -- Needs review
L["Craft Queue"] = "Очередь крафта"
L["Create Profession Groups"] = "Создать группу профессии" -- Needs review
L["Custom Price"] = "Своя цена"
L["Custom Price for this item."] = "Своя цена за этот предмет"
L["Custom Price per Item"] = "Своя цена за предмет"
L["Default Craft Price Method"] = "Метод расчета цены по умолчанию"
L["Default Material Cost Method"] = "Метод расчета цены материалов по умолчанию"
L["Default Price"] = "Цена по умолчанию"
L["Default Price Settings"] = "Настройка цены по умолчанию" -- Needs review
L["Enchant Vellum"] = "Материал для наложения чар" -- Needs review
L["Error creating operation. Operation with name '%s' already exists."] = "Ошибка создания операции. Операция с названием '%s' уже существует." -- Needs review
L[ [=[Estimated Cost: %s
Estimated Profit: %s]=] ] = [=[Оценочная стоимость:  %s
Оценочная прибыль: %s]=]
L["Exclude Crafts with a Cooldown from Craft Cost"] = "Исключать крафты с временем восстановления из цены крафта" -- Needs review
L["Filters >>"] = "Фильтры >>"
-- L["First select a crafter"] = ""
L["Gather"] = "Собрать" -- Needs review
L["Gather All Professions by Default if Only One Crafter"] = "Собрать все профессии по умолчанию только для одного персонажа" -- Needs review
L["Gathering"] = "Собрать"
L["Gathering Crafting Mats"] = "Сбор материалов для крафта" -- Needs review
L["Gather Items"] = "Собрать предметы"
L["General"] = "Общее"
L["General Settings"] = "Общие настройки"
L["Give the new operation a name. A descriptive name will help you find this operation later."] = "Дайте новое имя для операции. Оно поможет найти вам её позже." -- Needs review
L["Guilds (Guild Banks) to Ignore:"] = "Игнорировать (Гильд. Банк) гильдию:" -- Needs review
L["Here you can view and adjust how Crafting is calculating the price for this material."] = "Здесь можно увидеть и изменить как Crafting считает цены на этот материал."
L["<< Hide Queue"] = "Скрыть очередь"
-- L["If checked, Crafting will never try and craft inks as intermediate crafts."] = ""
L["If checked, if there is more than one way to craft the item then the craft cost will exclude any craft with a daily cooldown when calculating the lowest craft cost."] = "При расчете самой низкой стоимости крафта, выбирать метод получения материала без времени восстановления (если такой имеется)" -- Needs review
-- L["If checked, if there is only one crafter for the craft queue clicking gather will gather for all professions for that crafter"] = ""
L["If checked, the crafting cost of items will be shown in the tooltip for the item."] = "Отметьте для показа стоимости создания предмета в подсказке."
L["If checked, the material cost of items will be shown in the tooltip for the item."] = "Показывать стоимость материалов для изготовления в подсказке" -- Needs review
L["If checked, when the TSM_Crafting frame is shown (when you open a profession), the default profession UI will also be shown."] = "Показывать фрейм TSM_Crafting (если профессия открыта), стандартное UI профессии тоже будет показано" -- Needs review
L["Inventory Settings"] = "Настройки инвентаря"
L["Item Name"] = "Название предмета"
L["Items will only be added to the queue if the number being added is greater than this number. This is useful if you don't want to bother with crafting singles for example."] = "Предметы будут добавлены в очередь только если их кол-во больше этого числа. Полезно, если вы не хотите создавать единичные предметы."
L["Item Value"] = "Стоимость предмета" -- Needs review
L["Left-Click|r to add this craft to the queue."] = "ЛКМ|r для добавления в очередь" -- Needs review
L["Link"] = "Ссылка" -- Needs review
L["Mailing Craft Mats to %s"] = "Отправить материалы для крафта %s" -- Needs review
L["Mail Items"] = "Отправить предметы" -- Needs review
L["Mat Cost"] = "Стоимость материалов" -- Needs review
L["Material Cost Options"] = "Настройки цен материалов"
L["Material Name"] = "Название материала" -- Needs review
L["Materials:"] = "Материалы:" -- Needs review
L["Mat Price"] = "Цена материалов"
L["Max Restock Quantity"] = "Макс. кол-во для добавления в очередь"
L["Minimum Profit"] = "Минимальная прибыль" -- Needs review
L["Min Restock Quantity"] = "Мин. кол-во для добавления в очередь"
L["Name"] = "Название"
L["Need"] = "Требуется"
-- L["Needed Mats at Current Source"] = ""
-- L["Never Queue Inks as Sub-Craftings"] = ""
L["New Operation"] = "Новая операция" -- Needs review
L["<None>"] = "Пусто"
L["No Thanks"] = "Нет спасибо" -- Needs review
L["Nothing To Gather"] = "Нечего собирать" -- Needs review
L["Nothing to Mail"] = "Нечего отправлять" -- Needs review
L["Now select your profession(s)"] = "Сейчас выбраны профессии" -- Needs review
L["Number Owned"] = "Кол-во Имеющихся" -- Needs review
L["Opens the Crafting window to the first profession."] = "Открыть окошко крафта для первой профессии" -- Needs review
L["Operation Name"] = "Название операциии" -- Needs review
L["Operations"] = "Операции" -- Needs review
L["Options"] = "Настройки"
L["Override Default Craft Price Method"] = "Поменять метод стоимости крафта по умолчанию" -- Needs review
L["Percent to subtract from buyout when calculating profits (5% will compensate for AH cut)."] = "Процент, вычитаемый из цены выкупа при вычислении прибыли (5% компенсируют налог аукциона)."
L["Please switch to the Shopping Tab to perform the gathering search."] = "Переключитесь на вкладку Shopping для поиска материалов" -- Needs review
L["Price:"] = "Цена:"
L["Price Settings"] = "Настройки цены"
L["Price Source Filter"] = "Фильтр источника цены" -- Needs review
-- L["Profession data not found for %s on %s. Logging into this player and opening the profression may solve this issue."] = ""
L["Profession Filter"] = "Фильтр профессии" -- Needs review
L["Professions"] = "Профессии" -- Needs review
L["Professions Used In"] = "Используется в профессиях" -- Needs review
L["Profit"] = "Прибыль"
L["Profit Deduction"] = "Вычисление прибыли"
L["Profit (Total Profit):"] = "Прибыль (Всего прибыль):" -- Needs review
L["Queue"] = "Очередь" -- Needs review
L["Relationships"] = "Связи" -- Needs review
L["Reset All Custom Prices to Default"] = "Сбросить все свои цены на цены по умолчанию" -- Needs review
-- L["Reset all Custom Prices to Default Price Source."] = ""
L["Resets the material price for this item to the defualt value."] = "Сбросить цену предмета на стандартную" -- Needs review
L["Reset to Default"] = "Сбросить" -- Needs review
-- L["Restocking to a max of %d (min of %d) with a min profit."] = ""
-- L["Restocking to a max of %d (min of %d) with no min profit."] = ""
-- L["Restock Quantity Settings"] = ""
-- L["Restock Selected Groups"] = ""
-- L["Restock Settings"] = ""
-- L["Right-Click|r to subtract this craft from the queue."] = ""
L["%s Avail"] = "%s Выгода"
L["Search"] = "Поиск" -- Needs review
L["Search for Mats"] = "Поиск материалов" -- Needs review
L["Select Crafter"] = "Выбор персонажа" -- Needs review
-- L["Select one of your characters' professions to browse."] = ""
L["Set Minimum Profit"] = "Установить минимальную прибыль" -- Needs review
L["Shift-Left-Click|r to queue all you can craft."] = "Shift-Left-Click|r для добавления в очередь всех крафтов" -- Needs review
L["Shift-Right-Click|r to remove all from queue."] = "Shift-Right-Click|r для очистки очереди" -- Needs review
L["Show Crafting Cost in Tooltip"] = "Показывать стоимость создания в подсказке"
L["Show Default Profession Frame"] = "Отображать стандартное окно профессии" -- Needs review
L["Show Material Cost in Tooltip"] = "Отображать цену материалов в подсказке" -- Needs review
L["Show Queue >>"] = "Отображать очередь >>" -- Needs review
-- L["'%s' is an invalid operation! Min restock of %d is higher than max restock of %d."] = ""
L["%s (%s profit)"] = "%s (%s прибыль)"
L["Stage %d"] = "Этап %d" -- Needs review
L["Start Gathering"] = "Начать сбор" -- Needs review
L["Stop Gathering"] = "Останвоить сбор" -- Needs review
-- L["This is the default method Crafting will use for determining craft prices."] = ""
L["This is the default method Crafting will use for determining material cost."] = "Для определения стоимости материала будет использован стандартный метод" -- Needs review
L["Total"] = "Всего"
L["TSM Groups"] = "TSM Группы" -- Needs review
L["Vendor"] = "Торговец"
L["Visit Bank"] = "Посетите банк" -- Needs review
L["Visit Guild Bank"] = "Посетите Гильд. Банк" -- Needs review
L["Visit Vendor"] = "Посетите вендора" -- Needs review
L["Warning: The min restock quantity must be lower than the max restock quantity."] = "Внимание! Минимальное кол-во предметов, добавляемых в очередь, должно быть меньше максимального."
L["When you click on the \"Restock Queue\" button enough of each craft will be queued so that you have this maximum number on hand. For example, if you have 2 of item X on hand and you set this to 4, 2 more will be added to the craft queue."] = "При нажатии на кнопку \"Пополнить очередь\" в очередь будет добавлено максимальное количество доступных крафтов. Например, у вас есть 2 крафта Х, а макс. кол-во задано 4, в очередь будет добавлено 2."
L["Would you like to automatically create some TradeSkillMaster groups for this profession?"] = "Хотите автоматически создать группы профессии в TradeSkillMaster?" -- Needs review
L["You can click on one of the rows of the scrolling table below to view or adjust how the price of a material is calculated."] = "Можете клинуть на одну из строк в пролистывающейся таблице ниже, чтобы просмотреть или настроить подсчёт цены для материала."
