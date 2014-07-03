-- ------------------------------------------------------------------------------ --
--                           TradeSkillMaster_AuctionDB                           --
--           http://www.curse.com/addons/wow/tradeskillmaster_auctiondb           --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- TradeSkillMaster_AuctionDB Locale - koKR
-- Please use the localization app on CurseForge to update this
-- http://wow.curseforge.com/addons/TradeSkillMaster_AuctionDB/localization/

local L = LibStub("AceLocale-3.0"):NewLocale("TradeSkillMaster_AuctionDB", "koKR")
if not L then return end

L["A full auction house scan will scan every item on the auction house but is far slower than a GetAll scan. Expect this scan to take several minutes or longer."] = "전체 검색은 경매장 내의 모든 아이템을 검색하지만 GetAll 검색보다는 훨씬 느립니다. 이 검색은 몇 분 정도 또는 그 이상의 시간이 소요됩니다."
L["A GetAll scan is the fastest in-game method for scanning every item on the auction house. However, there are many possible bugs on Blizzard's end with it including the chance for it to disconnect you from the game. Also, it has a 15 minute cooldown."] = "GetAll 검색은 게임 내에서 경매장의 모든 아이템을 검색하기 위한 가장 빠른 검색 방법입니다. 하지만 블리자드 쪽에 많은 버그가 존재하며 게임의 접속이 끊길 가능성도 있습니다. 또한, 15분의 쿨다운이 존재합니다." -- Needs review
L["Any items in the AuctionDB database that contain the search phrase in their names will be displayed."] = "이름에 검색 구문을 포함하는 AuctionDB 데이터베이스 내의 모든 아이템이 표시됩니다."
L["Are you sure you want to clear your AuctionDB data?"] = "모든 AuctionDB 데이터를 삭제 하시겠습니까?"
L["Ascending"] = "오름차순"
L["AuctionDB - Market Value"] = "AuctionDB - 시장 가격"
L["AuctionDB - Minimum Buyout"] = "AuctionDB - 최소 구매가격"
L["Can't run a GetAll scan right now."] = "지금은 GetAll 검색을 실행할 수 없습니다." -- Needs review
L["Descending"] = "내림차순"
L["Display lowest buyout value seen in the last scan in tooltip."] = "최근 검색 시 본 최소 구매가를 툴팁에 표시합니다." -- Needs review
L["Display market value in tooltip."] = "시장 가격을 툴팁에 표시합니다." -- Needs review
L["Display number of items seen in the last scan in tooltip."] = "최근 검색 시 본 아이템의 개수를 툴팁에 표시합니다." -- Needs review
L["Display total number of items ever seen in tooltip."] = "아이템의 전체 출현 회수를 툴팁에 표시합니다." -- Needs review
L["Done Scanning"] = "검색 완료"
L["Download the FREE TSM desktop application which will automatically update your TSM_AuctionDB prices using Blizzard's online APIs (and does MUCH more). Visit %s for more info and never scan the AH again! This is the best way to update your AuctionDB prices."] = "무료 TSM 데스크톱 애플리케이션을 다운로드하면 TSM_AuctionDB 가격을 블리자드의 온라인 API를 이용해 자동으로 업데이트합니다. %s을 방문하여 더 많은 정보를 얻고 더 이상은 경매장 검색을 하지 마세요! 이것은 AuctionDB 가격을 업데이트하는 최고의 방법입니다." -- Needs review
L["Enable display of AuctionDB data in tooltip."] = "AuctionDB 데이터를 툴팁에 표시" -- Needs review
L["GetAll scan did not run successfully due to issues on Blizzard's end. Using the TSM application for your scans is recommended."] = "블리자드의 문제로 GetAll 검색이 성공적으로 수행되지 못했습니다. TSM 애플리케이션의 사용한 검색을 추천합니다." -- Needs review
L["Hide poor quality items"] = "저급 품질 아이템 숨기기"
L["If checked, poor quality items won't be shown in the search results."] = "선택하면, 저급 품질 아이템은 검색 결과에 표시하지 않습니다."
L["If checked, the lowest buyout value seen in the last scan of the item will be displayed."] = "선택하면, 최근 검색에서 본 아이템의 최소 구매 가격을 표시합니다." -- Needs review
L["If checked, the market value of the item will be displayed"] = "선택하면, 아이템의 시장 가격을 표시합니다." -- Needs review
L["If checked, the number of items seen in the last scan will be displayed."] = "선택하면, 최근 검색에서 본 아이템의 개수를 표시합니다." -- Needs review
L["If checked, the total number of items ever seen will be displayed."] = "선택하면, 아이템의 전체 출현 회수를 표시합니다." -- Needs review
L["Imported %s scans worth of new auction data!"] = "%s개의 새로운 경매 데이터를 불러왔습니다." -- Needs review
L["Invalid value entered. You must enter a number between 5 and 500 inclusive."] = "잘못된 수치가 입력되었습니다. 5에서 500 사이의 숫자를 입력해 주세요."
L["Item Link"] = "아이템 링크"
L["Item MinLevel"] = "아이템 레벨"
L["Items per page"] = "페이지당 아이템 개수"
L["Items %s - %s (%s total)"] = "아이템 %s - %s (전체 %s)"
L["Item SubType Filter"] = "아이템 하위 유형 필터" -- Needs review
L["Item Type Filter"] = "아이템 유형 필터"
L["It is strongly recommended that you reload your ui (type '/reload') after running a GetAll scan. Otherwise, any other scans (Post/Cancel/Search/etc) will be much slower than normal."] = "GetAll 검색을 실행한 후 UI를 다시 로드('/reload' 입력)해 주시길 바랍니다. 그렇게 하지 않으면, 다른 검색(등록/취소/검색/기타)은 정상보다 훨씬 느려지게 됩니다."
L["Last Scanned"] = "최근 검색"
L["Last updated from in-game scan %s ago."] = "게임 내 검색의 최근 업데이트 %s 전." -- Needs review
L["Last updated from the TSM Application %s ago."] = "TSM 애플리케이션의 최근 업데이트 %s 전." -- Needs review
L["Market Value"] = "시장가"
L["Market Value:"] = "시장가격:"
L["Market Value x%s:"] = "시장 가격  x%s:" -- Needs review
L["Min Buyout:"] = "최소 구매가격:"
L["Min Buyout x%s:"] = "최소 구매가 x%s:" -- Needs review
L["Minimum Buyout"] = "최소 구매가"
L["Next Page"] = "다음 페이지"
L["No items found"] = "아이템을 찾을 수 없습니다."
L["No scans found."] = "검색을 찾을 수 없습니다." -- Needs review
L["Not Ready"] = "준비 안 됨" -- Needs review
L["Not Scanned"] = "검색 안 됨" -- Needs review
L["Num(Yours)"] = "개수(소유)"
L["Options"] = "옵션"
L["Previous Page"] = "이전 페이지"
L["Processing data..."] = "데이터 처리 중..." -- Needs review
L["Ready"] = "준비 됨"
L["Ready in %s min and %s sec"] = "%s 분 %s 초 후 준비됨"
L["Refreshes the current search results."] = "현재 검색 결과 새로 고침."
L["Removed %s from AuctionDB."] = "AuctionDB에서 %s 삭제."
L["Reset Data"] = "데이터 리셋"
L["Resets AuctionDB's scan data"] = "AuctionDB의 검색 데이터 리셋"
L["Result Order:"] = "결과 정렬:" -- Needs review
L["Run Full Scan"] = "전체 검색"
L["Run GetAll Scan"] = "GetAll 검색"
L["Running query..."] = "쿼리 실행 중..." -- Needs review
L["%s ago"] = "%s 전"
L["Scanning page %s/%s"] = "페이지 검색 %s/%s" -- Needs review
L["Scanning the auction house in game is no longer necessary!"] = "이제는 게임 내에서 경매장을 검색할 필요가 없습니다!" -- Needs review
L["Search"] = "검색"
L["Search Options"] = "검색 옵션"
L["Seen Last Scan:"] = "최근 검색시 출현횟수:"
L["Select how you would like the search results to be sorted. After changing this option, you may need to refresh your search results by hitting the \"Refresh\" button."] = "검색 결과가 정렬될 방식을 선택하세요. 이 옵션을 바꾼 후 \\\"새로 고침\\\" 버튼을 눌러 주어야 결과가 반영됩니다." -- Needs review
L["Select whether to sort search results in ascending or descending order."] = "검색 결과를 오름차순으로 정렬할지 내림차순으로 정렬할지 선택하세요."
L["Shift-Right-Click to clear all data for this item from AuctionDB."] = "Shift-Right-Click 하면 이 아이템의 모든 데이터가 AuctionDB에서 삭제됩니다." -- Needs review
L["Sort items by"] = "아이템 정렬"
L["This determines how many items are shown per page in results area of the \"Search\" tab of the AuctionDB page in the main TSM window. You may enter a number between 5 and 500 inclusive. If the page lags, you may want to decrease this number."] = "주 TSM 창의 AuctionDB 페이지의 검색 탭 안의 결과 영역에 표시될 페이지당 아이템의 숫자를 결정합니다. 5 에서 500 사이의 숫자를 입력할 수 있습니다. 페이지 렉이 발생하면 수치를 줄여 주세요."
L["Total Seen Count:"] = "전체 출현 횟수:" -- Needs review
L["Use the search box and category filters above to search the AuctionDB data."] = "AuctionDB를 검색하려면 위의 검색 상자와 분류 필터를 사용하세요."
L["You can filter the results by item subtype by using this dropdown. For example, if you want to search for all herbs, you would select \"Trade Goods\" in the item type dropdown and \"Herbs\" in this dropdown."] = "이 드롭다운을 사용하여 하위 아이템 유형 필터링할 수 있습니다. 예를 들어 모든 약초를 검색하고자 한다면, 아이템 유형 필터 드롭다운에서 \\\"직업 용품\\\"을 선택하고 이 드롭다운에서 \\\"약초\\\"를 선택합니다." -- Needs review
L["You can filter the results by item type by using this dropdown. For example, if you want to search for all herbs, you would select \"Trade Goods\" in this dropdown and \"Herbs\" as the subtype filter."] = "이 드롭다운을 사용하여 아이템 유형을 필터링할 수 있습니다. 예를 들어 모든 약초를 검색하고자 한다면, 이 드롭다운에서 \\\"직업 용품\\\"을 선택하고 하위 아이템 유형 필터에서 \\\"약초\\\"를 선택합니다." -- Needs review
L["You can use this page to lookup an item or group of items in the AuctionDB database. Note that this does not perform a live search of the AH."] = "이 페이지에서 AuctionDB의 데이터베이스에 있는 아이템 또는 아이템 그룹을 살펴보실 수 있습니다. 경매장의 실시간 검색을 실행하지는 않는다는 점을 명심하기 바랍니다."
 