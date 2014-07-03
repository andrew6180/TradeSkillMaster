-- ------------------------------------------------------------------------------ --
--                           TradeSkillMaster_Accounting                          --
--           http://www.curse.com/addons/wow/tradeskillmaster_accounting          --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- TradeSkillMaster_Accounting Locale - koKR
-- Please use the localization app on CurseForge to update this
-- http://wow.curseforge.com/addons/TradeSkillMaster_Accounting/localization/

local L = LibStub("AceLocale-3.0"):NewLocale("TradeSkillMaster_Accounting", "koKR")
if not L then return end

L["Accounting has not yet collect enough information for this tab. This is likely due to not having recorded enough data points or not seeing any significant fluctuations (over 1k gold) in your gold on hand."] = "회계는 아직 이 탭을 표시하기 위한 충분한 정보를 수집하지 못했습니다. 이는 충분한 양의 데이터를 기록하지 못했거나 충분한 골드(1000 골드 이상)의 흐름이 없었기 때문입니다." -- Needs review
L["Activity Type"] = "활동 유형"
L["All"] = "모두"
L["Aucs"] = "경매"
L["Average Prices:"] = "평균가:"
L["Avg Buy Price"] = "평균 구매가"
L["Avg Resale Profit"] = "평균 재판매 수익"
L["Avg Sell Price"] = "평균 판매가"
L["Back to Previous Page"] = "이전 페이지로"
L["Balance"] = "잔고" -- Needs review
L[ [=[Below is a graph of the current character's gold on hand over time.

The x-axis is time and goes from %s to %s
The y-axis is thousands of gold.]=] ] = "아래의 그래프는 현재 캐릭터가 소지한 골드가 시간에 따라 변화한 양을 나타냅니다.\\n\\nX 축은 %s에서 %s로 이동하는 시간입니다.\\nY 축은 1,000단위의 골드 양입니다." -- Needs review
L["Bought"] = "구매"
L["Buyer/Seller"] = "구매자/판매자"
L["Cancelled"] = "취소" -- Needs review
L["Cancelled Since Last Sale:"] = "최근 판매 이후 취소:" -- Needs review
L["Clear Old Data"] = "오래된 데이터 삭제"
L["Click for a detailed report on this item."] = "이 아이템의 자세한 정보를 보려면 클릭하세요."
L["Click this button to permanently remove data older than the number of days selected in the dropdown."] = "이 버튼을 클릭하면 좌측 드롭다운에서 지정한 날짜 이상의 데이터는 영구적으로 삭제됩니다."
L["Cost"] = "비용" -- Needs review
L["Data older than this many days will be deleted when you click on the button to the right."] = "우측의 버튼을 클릭하면 여기서 지정한 날짜 이상의 테이터는 삭제됩니다."
L["Days:"] = "날짜:"
L["DD/MM/YY HH:MM"] = "일/월/년 시:분" -- Needs review
L["Display Grey Items in Sales"] = "판매에 회색(하급) 아이템 표시" -- Needs review
L["Don't prompt to record trades"] = "거래 기록 확인하지 않음"
L["Earned Per Day:"] = "일별 골드 획득:"
L["Expenses"] = "지출" -- Needs review
L["Expired"] = "만료" -- Needs review
L["Expired Since Last Sale:"] = "최근 판매 이후 만료:" -- Needs review
L["Failed Auctions"] = "경매 실패" -- Needs review
L["Failed Since Last Sale (Expired/Cancelled):"] = "최근 판매 이후 실패 (만료/취소):" -- Needs review
L["General Options"] = "일반 옵션"
L["Gold Earned:"] = "골드 획득:"
L["Gold Spent:"] = "골드 소비:"
L["Group"] = "그룹" -- Needs review
L["_ Hr _ Min ago"] = "_ 시간 _ 분 전"
L["If checked, poor quality items will be shown in sales data. They will still be included in gold earned totals on the summary tab regardless of this setting"] = "선택하면, 판매 데이터에 하급 아이템이 표시됩니다. 이 설정과 관계없이 하급 아이템의 판매 금액은 요약 탭의 골드 획득 합계에 포함됩니다." -- Needs review
L["If checked, the average purchase price that shows in the tooltip will be the average price for the most recent X you have purchased, where X is the number you have in your bags / bank / gbank using data from the ItemTracker module. Otherwise, a simple average of all purchases will be used."] = "선택하면, 툴팁에 표시되는 평균 구매가격은 최근 구매한 X의 가격에 대한 평균이 될 것입니다. X는 ItemTracker 모듈에 의해서 관리되는 가방/은행/길드 은행에 있는 아이템의 개수입니다. 체크하지 않으면, 모든 구매 아이템에 대한 평균이 사용됩니다." -- Needs review
L["If checked, the number of cancelled auctions since the last sale will show as up as failed auctions in an item's tooltip. if no sales then the total number of cancelled auctions will be shown."] = "선택하면, 최근 판매 이후로 취소된 경매의 횟수를 아이템 툴팁에 표시합니다. 판매된 적이 없는 아이템이라면, 전체 취소 횟수가 표시됩니다." -- Needs review
L["If checked, the number of expired auctions since the last sale will show as up as failed auctions in an item's tooltip. if no sales then the total number of expired auctions will be shown."] = "선택하면, 최근 판매 이후로 만료된 경매의 횟수를 아이템 툴팁에 표시합니다. 판매된 적이 없는 아이템이라면, 전체 만료 횟수가 표시됩니다." -- Needs review
L["If checked, the number you have purchased and the average purchase price will show up in an item's tooltip."] = "선택하면, 구매 수량과 평균 구매가격이 아이템의 툴팁에 표시됩니다." -- Needs review
L["If checked, the number you have sold and the average sale price will show up in an item's tooltip."] = "선택하면, 판매 수량과 평균 판매가격이 아이템의 툴팁에 표시됩니다." -- Needs review
L["If checked, the sale rate will be shown in item tooltips. sale rate is calculated as total sold / (total sold + total expired + total cancelled)."] = "선택하면, 판매율이 아이템 툴팁에 표시됩니다. 판매율은 총 판매 / (총 판매 + 총 만료 + 총 취소)로 계산됩니다." -- Needs review
L["If checked, whenever you buy or sell any quantity of a single item via trade, Accounting will display a popup asking if you want it to record that transaction."] = "선택하면, 거래로 단일 아이템을 판매 또는 구매할 때 이 매매를 기록할지를 묻는 알림창을 표시합니다." -- Needs review
L["If checked, you won't get a popup confirmation about whether or not to track trades."] = "선택하면, 거래의 추적 여부를 확인하는 알림창을 띄우지 않습니다." -- Needs review
L["Income"] = "수입" -- Needs review
L["Item Name"] = "아이템 이름"
L["Items"] = "아이템"
L["Last 14 Days"] = "최근 14일" -- Needs review
L["Last 30 Days"] = "최근 30일" -- Needs review
L["Last 30 Days:"] = "최근 30일:"
L["Last 60 Days"] = "최근 60일" -- Needs review
L["Last 7 Days"] = "최근 7일" -- Needs review
L["Last 7 Days:"] = "최근 7일:"
L["Last Purchase"] = "최근 구매"
L["Last Purchased:"] = "최근 구매:" -- Needs review
L["Last Sold"] = "최근 판매"
L["Last Sold:"] = "최근 판매:"
L["Market Value"] = "시장가"
L["Market Value Source"] = "시장가 출처"
L["MM/DD/YY HH:MM"] = "월/일/년 시:분" -- Needs review
L["none"] = "없음"
L["None"] = "없음" -- Needs review
L["Options"] = "옵션"
L["Other"] = "기타" -- Needs review
L["Other Income"] = "기타 수입" -- Needs review
L["Player"] = "플레이어"
L["Player Gold"] = "플레이어 골드" -- Needs review
L["Player(s)"] = "플레이어"
L["Price Per Item"] = "아이템별 가격"
L["Profit:"] = "이윤" -- Needs review
L["Profit Per Day:"] = "일별 이윤" -- Needs review
L["Purchase Data"] = "구매 데이터"
L["Purchased (Avg Price):"] = "구매 (평균 가격):" -- Needs review
L["Purchased (Total Price):"] = "구매 (전체 가격):" -- Needs review
L["Purchases"] = "구매"
L["Quantity"] = "수량"
L["Quantity Bought:"] = "구매 수량:"
L["Quantity Sold:"] = "판매량:"
L["Rarity"] = "품질" -- Needs review
L["Removed a total of %s old records and %s items with no remaining records."] = "전체 %s 개의 오래된 기록과 %s 개의 아이템을 제거했습니다."
L["Remove Old Data (No Confirmation)"] = "오래된 데이터 제거 (확인 없음)"
L["Resale"] = "재판매"
L["Revenue"] = "수입" -- Needs review
L["%s ago"] = "%s 전"
L["Sale Data"] = "판매 데이터"
L["Sale Rate:"] = "판매율:" -- Needs review
L["Sales"] = "판매"
L["Search"] = "검색"
L["Select how you would like prices to be shown in the \"Items\" and \"Resale\" tabs; either average price per item or total value."] = "\\\"아이템\\\" 과 \\\"재판매\\\" 탭에 가격이 어떻게 표시될지 선택하세요. 아이템별 가격 또는 총액" -- Needs review
L["Select what format Accounting should use to display times in applicable screens."] = "표시될 시간 형식을 선택하세요."
L["Select where you want Accounting to get market value info from to show in applicable screens."] = "표시될 시장가의 정보를 가져올 출처를 선택하세요."
L["Show Cancelled Auctions as Failed Auctions since Last Sale in item tooltips"] = "최근 판매 이후 취소로 인한 경매 실패를 아이템 툴팁에 표시" -- Needs review
L["Show Expired Auctions as Failed Auctions since Last Sale in item tooltips"] = "최근 판매 이후 만료로 인한 경매 실패를 아이템 툴팁에 표시" -- Needs review
L["Show purchase info in item tooltips"] = "구매 정보를 아이템 툴팁에 표시" -- Needs review
L["Show sale info in item tooltips"] = "판매 정보를 아이템 툴팁에 표시" -- Needs review
L["Show Sale Rate in item tooltips"] = "판매율을 아이템 툴팁에 표시" -- Needs review
L["Sold"] = "판매"
L["Sold (Avg Price):"] = "판매 (평균 가격):" -- Needs review
L["Sold (Total Price):"] = "판매 (전체 가격):" -- Needs review
L["Source"] = "출처" -- Needs review
L["Spent Per Day:"] = "일별 골드 소비:"
L["Stack"] = "묶음"
L["Summary"] = "요약"
L["Target"] = "대상" -- Needs review
L["There is no purchase data for this item."] = "이 아이템의 구매 정보가 없습니다."
L["There is no sale data for this item."] = "이 아이템의 판매 정보가 없습니다."
L["Time"] = "시간"
L["Time Format"] = "시간 형식"
L["Timeframe Filter"] = "기간 필터" -- Needs review
L["Today"] = "오늘" -- Needs review
L["Top Buyers:"] = "최고 구매자:"
L["Top Expense by Gold:"] = "골드별 최상위 지출" -- Needs review
L["Top Expense by Quantity:"] = "수량별 최상위 지출" -- Needs review
L["Top Income by Gold:"] = "골드별 총 수입" -- Needs review
L["Top Income by Quantity:"] = "수량별 총 수입" -- Needs review
L["Top Item by Gold:"] = "골드별 최상위 아이템:"
L["Top Item by Quantity:"] = "수량별 최상위 아이템:"
L["Top Sellers:"] = "최고 판매자:"
L["Total:"] = "총:"
L["Total Buy Price"] = "총 구매가"
L["Total Price"] = "총액"
L["Total Sale Price"] = "총 판매가"
L["Total Spent:"] = "총 소비:"
L["Total Value"] = "총액"
L["Track sales/purchases via trade"] = "거래에 의한 판매/구매 기록"
L["TSM_Accounting detected that you just traded %s %s in return for %s. Would you like Accounting to store a record of this trade?"] = "TSM_Accounting가 %s에게 %s을(를) 주고 %s을(를) 받은 거래를 감지했습니다. 이 거래를 회계에 기록하시겠습니까?" -- Needs review
L["Type"] = "종류" -- Needs review
L["Use smart average for purchase price"] = "구매가의 스마트 평균 사용"
L["Yesterday"] = "어제" -- Needs review
L[ [=[You can use the options below to clear old data. It is recommened to occasionally clear your old data to keep Accounting running smoothly. Select the minimum number of days old to be removed in the dropdown, then click the button.

NOTE: There is no confirmation.]=] ] = "오래된 데이터를 삭제하려면 아래의 옵션을 사용하세요. Accounting의 원활한 동작을 위해 가끔 오래된 데이터를 삭제하시기 바랍니다. 드롭다운에서 오래된 데이터가 삭제될 최소 일자를 선택하시고 버튼을 클릭하세요.\\n\\n중요: 확인 메시지 없이 바로 삭제됩니다." -- Needs review
L["YY/MM/DD HH:MM"] = "년/월/일 시:분" -- Needs review
 