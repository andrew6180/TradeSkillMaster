-- ------------------------------------------------------------------------------------- --
-- 					TradeSkillMaster_Crafting - AddOn by Sapu94							 	  	  --
--   http://wow.curse.com/downloads/wow-addons/details/tradeskillmaster_crafting.aspx    --
--																													  --
--		This addon is licensed under the CC BY-NC-ND 3.0 license as described at the		  --
--				following url: http://creativecommons.org/licenses/by-nc-nd/3.0/			 	  --
-- 	Please contact the author via email at sapu94@gmail.com with any questions or		  --
--		concerns regarding this license.																	  --
-- ------------------------------------------------------------------------------------- --

-- TradeSkillMaster_Crafting Locale - koKR
-- Please use the localization app on CurseForge to update this
-- http://wow.curseforge.com/addons/TradeSkillMaster_Crafting/localization/

local L = LibStub("AceLocale-3.0"):NewLocale("TradeSkillMaster_Crafting", "koKR")
if not L then return end

L["All"] = "모두"
L["Are you sure you want to reset all material prices to the default value?"] = "정말로 모든 재료 가격을 기본값으로 재설정하시겠습니까?" -- Needs review
L["Ask Later"] = "나중에" -- Needs review
L["Auction House"] = "경매장"
L["Available Sources"] = "가능한 출처" -- Needs review
L["Buy Vendor Items"] = "상인 아이템 구매" -- Needs review
L["Characters (Bags/Bank/AH/Mail) to Ignore:"] = "캐릭터 (가방/은행/경매장/우편) 무시:" -- Needs review
L["Clear Filters"] = "필터 지우기" -- Needs review
L["Clear Queue"] = "대기열 지우기" -- Needs review
L["Click Start Gathering"] = "클릭 수집 시작" -- Needs review
L["Collect Mail"] = "우편 수집" -- Needs review
L["Cost"] = "비용"
L["Could not get link for profession."] = "전문기술의 링크를 얻을 수 없습니다." -- Needs review
L["Crafting Cost"] = "제작 비용"
L["Crafting Material Cost"] = "제작 재료 비용" -- Needs review
L["Crafting operations contain settings for restocking the items in a group. Type the name of the new operation into the box below and hit 'enter' to create a new Crafting operation."] = "제작 작업은 그룹 아이템의 재보충과 관련된 설정을 포함하고 있습니다. 아래 상자에 새 작업 이름을 입력하고 '엔터'를 치면 새 제작 작업이 생성됩니다." -- Needs review
L["Crafting will not queue any items affected by this operation with a profit below this value. As an example, a min profit of 'max(10g, 10% crafting)' would ensure atleast a 10g and 10% profit."] = "여기서 지정한 값 보다 낮은 수익을 발생하는 아이템은 대기열에 등록되지 않습니다. 예를 들면, 'max(10g, 10% crafting)'는 최소한 10g 와 10% 수익을 보장합니다." -- Needs review
L["Craft Next"] = "다음 제작"
L["Craft Price Method"] = "제작 가격 방식" -- Needs review
L["Craft Queue"] = "제작 대기열" -- Needs review
L["Create Profession Groups"] = "전문기술 그룹 생성" -- Needs review
L["Custom Price"] = "사용자 가격" -- Needs review
L["Custom Price for this item."] = "이 아이템의 사용자 가격" -- Needs review
L["Custom Price per Item"] = "아이템별 사용자 가격" -- Needs review
L["Default Craft Price Method"] = "기본 제작 가격 방식" -- Needs review
L["Default Material Cost Method"] = "기본 재료 비용 방식" -- Needs review
L["Default Price"] = "기본 가격" -- Needs review
L["Default Price Settings"] = "기본 가격 설정" -- Needs review
L["Enchant Vellum"] = "마법부여 피지" -- Needs review
L["Error creating operation. Operation with name '%s' already exists."] = "작업 생성 중 오류가 발생했습니다. 작업 이름 '%s'이(가) 이미 존재합니다." -- Needs review
L[ [=[Estimated Cost: %s
Estimated Profit: %s]=] ] = "예상 비용: %s\\n예상 수익: %s" -- Needs review
L["Exclude Crafts with a Cooldown from Craft Cost"] = "쿨다운을 가진 제작은 제작 비용에서 제외" -- Needs review
L["Filters >>"] = "필터 >>" -- Needs review
L["First select a crafter"] = "제작자를 선택하세요." -- Needs review
L["Gather"] = "수집" -- Needs review
L["Gather All Professions by Default if Only One Crafter"] = "제작자가 한 명이면 기본으로 모든 전문기술을 수집" -- Needs review
L["Gathering"] = "수집" -- Needs review
L["Gathering Crafting Mats"] = "제작 재료 수집" -- Needs review
L["Gather Items"] = "아이템 수집" -- Needs review
L["General"] = "일반" -- Needs review
L["General Settings"] = "일반 설정"
L["Give the new operation a name. A descriptive name will help you find this operation later."] = "새 작업의 이름을 지정하세요. 설명이 포함된 이름은 나중에 이 작업을 찾는 데 도움이 됩니다." -- Needs review
L["Guilds (Guild Banks) to Ignore:"] = "길드 (길드 은행) 무시:" -- Needs review
L["Here you can view and adjust how Crafting is calculating the price for this material."] = "여기서 재료 가격의 계산 방식을 확인하고 조절할 수 있습니다."
L["<< Hide Queue"] = "<< 대기열 감추기" -- Needs review
L["If checked, Crafting will never try and craft inks as intermediate crafts."] = "선택하면, 잉크는 중간 제작을 시도하지 않습니다." -- Needs review
L["If checked, if there is more than one way to craft the item then the craft cost will exclude any craft with a daily cooldown when calculating the lowest craft cost."] = "선택하면, 아이템을 제작하는 방법이 하나 이상이라면, 최저 제작 비용의 계산할 때 일일 쿨다운을 가진 제작 기술은 제외시킵니다." -- Needs review
L["If checked, if there is only one crafter for the craft queue clicking gather will gather for all professions for that crafter"] = "선택하면, 제작 대기열를 클릭하는 제작자가 한 명이라면 모든 전문기술의 재료를 수집합니다." -- Needs review
L["If checked, the crafting cost of items will be shown in the tooltip for the item."] = "선택하면, 제작 비용이 아이템의 툴팁에 표시됩니다."
L["If checked, the material cost of items will be shown in the tooltip for the item."] = "선택하면, 재료 비용이 아이템의 툴팁에 표시됩니다." -- Needs review
L["If checked, when the TSM_Crafting frame is shown (when you open a profession), the default profession UI will also be shown."] = "선택하면, TSM 제작 프레임이 열릴(전문기술 창을 열 때 ) 때 기본 전문기술 UI도 함께 열립니다." -- Needs review
L["Inventory Settings"] = "인벤토리 설정"
L["Item Name"] = "아이템 이름"
L["Items will only be added to the queue if the number being added is greater than this number. This is useful if you don't want to bother with crafting singles for example."] = "추가되는 수량이 아래 수량보다 큰 경우만 아이템이 대기열에 추가됩니다. 제작 수량이 한 개 이상인 아이템만을 제작하기 원할 때 유용합니다." -- Needs review
L["Item Value"] = "아이템 가치"
L["Left-Click|r to add this craft to the queue."] = "Left-Click|r 대기열에 추가합니다." -- Needs review
L["Link"] = "링크" -- Needs review
L["Mailing Craft Mats to %s"] = "제작 재료를 %s에게 발송" -- Needs review
L["Mail Items"] = "아이템 발송" -- Needs review
L["Mat Cost"] = "재료 비용" -- Needs review
L["Material Cost Options"] = "재료 비용 옵션"
L["Material Name"] = "재료 이름" -- Needs review
L["Materials:"] = "재료:" -- Needs review
L["Mat Price"] = "재료 가격"
L["Max Restock Quantity"] = "최대 수량"
L["Minimum Profit"] = "최소 수익" -- Needs review
L["Min Restock Quantity"] = "최소 수량"
L["Name"] = "이름"
L["Need"] = "필요"
L["Needed Mats at Current Source"] = "현재 출처의 재료 필요" -- Needs review
L["Never Queue Inks as Sub-Craftings"] = "잉크는 하위 제작 대기열 등록 안 함" -- Needs review
L["New Operation"] = "새 작업" -- Needs review
L["<None>"] = "<없음>"
L["No Thanks"] = "아니요" -- Needs review
L["Nothing To Gather"] = "수집할 아이템 없음" -- Needs review
L["Nothing to Mail"] = "발송할 아이템 없음" -- Needs review
L["Now select your profession(s)"] = "전문 직업 선택" -- Needs review
L["Number Owned"] = "소유 개수"
L["Opens the Crafting window to the first profession."] = "첫 전문기술 창을 엽니다." -- Needs review
L["Operation Name"] = "작업 이름" -- Needs review
L["Operations"] = "작업" -- Needs review
L["Options"] = "옵션"
L["Override Default Craft Price Method"] = "기본 제작 가격 방식 오버라이드" -- Needs review
L["Percent to subtract from buyout when calculating profits (5% will compensate for AH cut)."] = "수익을 계산할 때 구매가에서 뺄 비율 (경매장 수수료 5%의 손실 보상)"
L["Please switch to the Shopping Tab to perform the gathering search."] = "수집 검색을 수행하려면 쇼핑 탭으로 전환하세요." -- Needs review
L["Price:"] = "가격:"
L["Price Settings"] = "가격 설정"
L["Price Source Filter"] = "가격 출처 필터" -- Needs review
L["Profession data not found for %s on %s. Logging into this player and opening the profression may solve this issue."] = "전문 직업 %s 데이터를 %s에게서 찾을 수 없습니다. 해당 캐릭터로 로그인한 후 전문기술 창을 열면 문제를 해결할 수 있습니다." -- Needs review
L["Profession Filter"] = "전문기술 필터" -- Needs review
L["Professions"] = "전문기술" -- Needs review
L["Professions Used In"] = "사용 전문기술" -- Needs review
L["Profit"] = "수익"
L["Profit Deduction"] = "수익 공제" -- Needs review
L["Profit (Total Profit):"] = "수익 (총수익):" -- Needs review
L["Queue"] = "대기열" -- Needs review
L["Relationships"] = "관계" -- Needs review
L["Reset All Custom Prices to Default"] = "모든 사용자 가격을 기본으로 재설정" -- Needs review
L["Reset all Custom Prices to Default Price Source."] = "모든 사용자 가격을 기본 가격 출처로 재설정" -- Needs review
L["Resets the material price for this item to the defualt value."] = "이 아이템의 재료 가격을 기본 가격으로 재설정합니다." -- Needs review
L["Reset to Default"] = "기본으로 재설정" -- Needs review
L["Restocking to a max of %d (min of %d) with a min profit."] = "최소 수익으로 최대 %d (최소 %d) 재보충" -- Needs review
L["Restocking to a max of %d (min of %d) with no min profit."] = "최소 수익 없이 최대 %d (최소 %d) 재보충" -- Needs review
L["Restock Quantity Settings"] = "재보충 수량 설정" -- Needs review
L["Restock Selected Groups"] = "선택된 그룹 재보충" -- Needs review
L["Restock Settings"] = "재보충 설정" -- Needs review
L["Right-Click|r to subtract this craft from the queue."] = "Right-Click|r 대기열에서 제거합니다." -- Needs review
L["%s Avail"] = "%s 가능" -- Needs review
L["Search"] = "검색" -- Needs review
L["Search for Mats"] = "재료 검색" -- Needs review
L["Select Crafter"] = "제작자 선택" -- Needs review
L["Select one of your characters' professions to browse."] = "캐릭터의 전문기술중 하나를 선택하세요." -- Needs review
L["Set Minimum Profit"] = "최소 수익 설정" -- Needs review
L["Shift-Left-Click|r to queue all you can craft."] = "Shift-Left-Click|r 제작 가능한 모든 기술을 대기열에 추가합니다." -- Needs review
L["Shift-Right-Click|r to remove all from queue."] = "Shift-Right-Click|r 모두 대기열에서 제거합니다." -- Needs review
L["Show Crafting Cost in Tooltip"] = "툴팁에 제작 비용 표시"
L["Show Default Profession Frame"] = "기본 전문기술 프레임 표시" -- Needs review
L["Show Material Cost in Tooltip"] = "툴팁에 재료 비용 표시" -- Needs review
L["Show Queue >>"] = "대기열 보기 >>" -- Needs review
L["'%s' is an invalid operation! Min restock of %d is higher than max restock of %d."] = "'%s'은(는) 잘못된 작업입니다! 최소 재보충 수량(%d)이 최대 재보충 수량(%d)보다 큽니다." -- Needs review
L["%s (%s profit)"] = "%s (%s 수익)" -- Needs review
L["Stage %d"] = "단계 %d" -- Needs review
L["Start Gathering"] = "수집 시작" -- Needs review
L["Stop Gathering"] = "수집 중지" -- Needs review
L["This is the default method Crafting will use for determining craft prices."] = "제작 가격을 결정하는 데 사용할 기본 방식입니다." -- Needs review
L["This is the default method Crafting will use for determining material cost."] = "재료 가격을 결정하는 데 사용할 기본 방식입니다." -- Needs review
L["Total"] = "전체"
L["TSM Groups"] = "TSM 그룹" -- Needs review
L["Vendor"] = "상인"
L["Visit Bank"] = "은행 방문" -- Needs review
L["Visit Guild Bank"] = "길드 은행 방문" -- Needs review
L["Visit Vendor"] = "상인 방문" -- Needs review
L["Warning: The min restock quantity must be lower than the max restock quantity."] = "경고: 최소 재보충 수량은 최대 재보충 수량보다 작아야 합니다."
L["When you click on the \"Restock Queue\" button enough of each craft will be queued so that you have this maximum number on hand. For example, if you have 2 of item X on hand and you set this to 4, 2 more will be added to the craft queue."] = "\\\"재보충 대기열\\\" 버튼을 클릭할 때 최종적으로 얻게 될 수량에 맞춰 대기열에 등록됩니다. 예를 들면, 이미 2개를 소유하고 있는 아이템을 4개로 설정하면 대기열에는 2개만 추가됩니다." -- Needs review
L["Would you like to automatically create some TradeSkillMaster groups for this profession?"] = "자동으로 이 전문기술에 대한 몇 가지 그룹을 생성하시겠습니까?" -- Needs review
L["You can click on one of the rows of the scrolling table below to view or adjust how the price of a material is calculated."] = "재료 비용의 계산 방법을 보거나 조정하려면 아래의 스크롤 테이블에 있는 아이템을 클릭하세요."
