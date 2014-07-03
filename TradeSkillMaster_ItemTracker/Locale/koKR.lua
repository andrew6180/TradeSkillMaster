-- ------------------------------------------------------------------------------ --
--                          TradeSkillMaster_ItemTracker                          --
--          http://www.curse.com/addons/wow/tradeskillmaster_itemtracker          --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- TradeSkillMaster_ItemTracker Locale - koKR
-- Please use the localization app on CurseForge to update this
-- http://wow.curseforge.com/addons/TradeSkillMaster_ItemTracker/localization/

local L = LibStub("AceLocale-3.0"):NewLocale("TradeSkillMaster_ItemTracker", "koKR")
if not L then return end

L["AH"] = "경매" -- Needs review
L["Bags"] = "가방"
L["Bank"] = "은행"
L["Characters"] = "캐릭터"
L["Delete Character:"] = "캐릭터 삭제:"
L["Full"] = "상세히"
L["GBank"] = "길드" -- Needs review
L["Guilds"] = "길드"
L["Guilds (Guild Banks) to Ignore:"] = "길드 (길드 은행) 무시:" -- Needs review
L["Here, you can choose what ItemTracker info, if any, to show in tooltips. \"Simple\" will only show totals for bags/banks and for guild banks. \"Full\" will show detailed information for every character and guild."] = "ItemTracker 표시 방식을 지정합니다. \\\"단순히\\\"는 가방/은행/길드 은행에 있는 개수를 합산해서 간단히 나타냅니다. \\\"상세히\\\"는 모든 캐릭터와 길드에 관한 자세한 정보를 표시합니다." -- Needs review
L["If you rename / transfer / delete one of your characters, use this dropdown to remove that character from ItemTracker. There is no confirmation. If you accidentally delete a character that still exists, simply log onto that character to re-add it to ItemTracker."] = "드롭다운을 이용해서 캐릭터 이름의 변경/이전/삭제가 가능합니다. 만일 실수로 캐릭터를 삭제했다면, 그 캐릭터로 로그인한 후 다시 추가하실 수 있습니다."
L["Inventory Viewer"] = "인벤토리 뷰어"
L["Item Name"] = "아이템 이름"
L["Item Search"] = "아이템 찾기"
L["Mail"] = "우편" -- Needs review
L["Market Value Price Source"] = "시장 가격 출처" -- Needs review
L["No Tooltip Info"] = "표시 안 함" -- Needs review
L["Options"] = "옵션" -- Needs review
L["Select guilds to ingore in ItemTracker. Inventory will still be tracked but not displayed or taken into consideration by Itemtracker."] = "아이템 추적기가 무시할 길드를 선택하세요. 인벤토리는 여전히 추적하지만, 내용은 표시하지 않으며 Itemtracker에 의해 참조되지도 않습니다." -- Needs review
L["Simple"] = "단순히"
L["%s in guild bank"] = "길드 은행 %s개" -- Needs review
L["%s item(s) total"] = "전체 %s개" -- Needs review
L["Specifies the market value price source used for \"Total Market Value\" in the Inventory Viewer."] = "인벤토리 뷰어의 \\\"전체 시장 가치\\\"에 사용할 시장가격의 출처를 지정하세요." -- Needs review
L["(%s player, %s alts, %s guild banks, %s AH)"] = "플레이어(%s), 부캐(%s), 길드 은행(%s), 경매장(%s)" -- Needs review
L["\"%s\" removed from ItemTracker."] = "\\\"%s\\\"은(는) ItemTracker에서 제거되었습니다." -- Needs review
L["%s (%s bags, %s bank, %s AH, %s mail)"] = "전체(%s), 가방(%s), 은행(%s), 경매장(%s), 우편(%s)" -- Needs review
L["Total"] = "전체"
L["Total Value"] = "총가치" -- Needs review
