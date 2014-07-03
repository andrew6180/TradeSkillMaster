-- ------------------------------------------------------------------------------ --
--                                TradeSkillMaster                                --
--                http://www.curse.com/addons/wow/tradeskill-master               --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- TradeSkillMaster Locale - koKR
-- Please use the localization app on CurseForge to update this
-- http://wow.curseforge.com/addons/TradeSkill-Master/localization/

local L = LibStub("AceLocale-3.0"):NewLocale("TradeSkillMaster", "koKR")
if not L then return end

-- L["Act on Scan Results"] = ""
L["A custom price of %s for %s evaluates to %s."] = "사용자 가격 %s인 %s의 평가 가치는 %s입니다." -- Needs review
L["Add >>>"] = "추가 >>>" -- Needs review
L["Add Additional Operation"] = "부가적인 작업 추가" -- Needs review
-- L["Add Items to this Group"] = ""
L["Additional error suppressed"] = "추가적인 오류 표시 안 함"
-- L["Adjust Post Parameters"] = ""
-- L["Advanced Option Text"] = ""
-- L["Advanced topics..."] = ""
L["A group is a collection of items which will be treated in a similar way by TSM's modules."] = "그룹은 아이템들의 집합이며 TSM 모듈에서 유사한 방식으로 취급됩니다." -- Needs review
L["All items with names containing the specified filter will be selected. This makes it easier to add/remove multiple items at a time."] = "필터에 지정된 이름을 포함하는 모든 아이템을 선택합니다. 한번에 여러 아이템을 추가/제거할 수 있습니다." -- Needs review
L["Allows for testing of custom prices."] = "시장 가격 테스트 허용" -- Needs review
L["Allows you to build a queue of crafts that will produce a profitable, see what materials you need to obtain, and actually craft the items."] = "제작에 필요한 재료를 확인하고 수익성이 있는 아이템 제작용 대기열을 생성합니다. 생성된 대기열 의해 아이템 제작도 할 수 있습니다." -- Needs review
L["Allows you to quickly and easily empty your mailbox as well as automatically send items to other characters with the single click of a button."] = "한 번의 클릭으로 빠르고 쉽게 메일을 받을 수 있으며 다른 캐릭터에게 아이템을 자동으로 발송합니다." -- Needs review
L["Allows you to use data from http://wowuction.com in other TSM modules and view its various price points in your item tooltips."] = "여러 TSM 모듈에서 http://wowuction.com의 데이터를 사용할 수 있게 해주며 다양한 가격정보를 아이템 툴팁에 표기해 줍니다."
-- L["Along the bottom of the AH are various tabs. Click on the 'Auctioning' AH tab."] = ""
-- L["Along the bottom of the AH are various tabs. Click on the 'Shopping' AH tab."] = ""
-- L["Along the top of the TSM_Crafting window, click on the 'Professions' button."] = ""
-- L["Along the top of the TSM_Crafting window, click on the 'TSM Groups' button."] = ""
-- L["Along top of the window, on the left side, click on the 'Groups' icon to open up the TSM group settings."] = ""
-- L["Along top of the window, on the left side, click on the 'Module Operations / Options' icon to open up the TSM module settings."] = ""
-- L["Along top of the window, on the right side, click on the 'Crafting' icon to open up the TSM_Crafting page."] = ""
L["Alt-Click to immediately buyout this auction."] = "Alt-Click 하면 이 아이템을 즉시 구매합니다." -- Needs review
L["A maximum of 1 convert() function is allowed."] = "convert() 함수가 허용하는 최대치는 1입니다." -- Needs review
L["A maximum of 1 gold amount is allowed."] = "1 골드가 최대 허용치입니다." -- Needs review
L["Any subgroups of this group will also be deleted, with all items being returned to the parent of this group or removed completely if this group has no parent."] = "이 그룹의 모든 하위 그룹은 삭제되고 아이템은 상위 그룹으로 반환되거나 상위 그룹이 없다면 제거됩니다." -- Needs review
L["Appearance Data"] = "외관 데이터"
L["Application and Addon Developer:"] = "애플리케이션 및 애드온 개발자:" -- Needs review
L["Applied %s to %s."] = "%s을(를) %s에 적용하였습니다." -- Needs review
L["Apply Operation to Group"] = "작업을 그룹에 적용" -- Needs review
L["Are you sure you want to delete the selected profile?"] = "정말로 선택된 프로파일을 지우시겠습니까?" -- Needs review
L["A simple, fixed gold amount."] = "단순 고정 골드 금액입니다." -- Needs review
-- L["Assign this operation to the group you previously created by clicking on the 'Yes' button in the popup that's now being shown."] = ""
-- L["A TSM_Auctioning operation will allow you to set rules for how auctionings are posted/canceled/reset on the auction house. To create one for this group, scroll down to the 'Auctioning' section, and click on the 'Create Auctioning Operation' button."] = ""
-- L["A TSM_Crafting operation will allow you automatically queue profitable items from the group you just made. To create one for this group, scroll down to the 'Crafting' section, and click on the 'Create Crafting Operation' button."] = ""
-- L["A TSM_Shopping operation will allow you to set a maximum price we want to pay for the items in the group you just made. To create one for this group, scroll down to the 'Shopping' section, and click on the 'Create Shopping Operation' button."] = ""
-- L["At the top, switch to the 'Crafts' tab in order to view a list of crafts you can make."] = ""
L["Auctionator - Auction Value"] = "Auctionator - 경매가"
L["Auction Buyout:"] = "경매 즉구가:" -- Needs review
L["Auction Buyout: %s"] = "경매 즉구가: %s" -- Needs review
L["Auctioneer - Appraiser"] = "Auctioneer -  감정인"
L["Auctioneer - Market Value"] = "Auctioneer - 시장가" -- Needs review
L["Auctioneer - Minimum Buyout"] = "Auctioneer - 최소 구매가"
L["Auction Frame Scale"] = "경매장 프레임 크기" -- Needs review
L["Auction House Tab Settings"] = "경매장 탭 설정"
L["Auction not found. Skipped."] = "경매를 찾을 수 없습니다. 건너뜁니다." -- Needs review
L["Auctions"] = "경매" -- Needs review
L["Author(s):"] = "제작: " -- Needs review
L["BankUI"] = "은행UI" -- Needs review
L["Below are various ways you can set the value of the current editbox. Any combination of these methods is also supported."] = "다음은 현재 편집 상자의 값을 설정할 수 있는 여러 가지 방법입니다. 이들 방법을 조합하는 것도 가능합니다." -- Needs review
L["Below are your currently available price sources. The %skey|r is what you would type into a custom price box."] = "아래는 현재 가능한 가격 출처입니다. %s키|r이(가) 사용자 가격 상자에 입력 될 것입니다." -- Needs review
-- L["Below is a list of groups which this operation is currently applied to. Clicking on the 'Remove' button next to the group name will remove the operation from that group."] = ""
-- L["Below, set the custom price that will be evaluated for this custom price source."] = ""
L["Border Thickness (Requires Reload)"] = "외곽선 굵기 (Reload후 적용)"
L["Buy from Vendor"] = "상인에게 구매" -- Needs review
-- L["Buy items from the AH"] = ""
-- L["Buy materials for my TSM_Crafting queue"] = ""
L["Canceling Auction: %d/%d"] = "경매 취소 중: %d/%d" -- Needs review
L["Cancelled - Bags and bank are full"] = "취소 - 가방과 은행 꽉 참" -- Needs review
L["Cancelled - Bags and guildbank are full"] = "취소 - 가방과 길드은행 꽉 참" -- Needs review
L["Cancelled - Bags are full"] = "취소 - 가방 꽉 참" -- Needs review
L["Cancelled - Bank is full"] = "취소 - 은행 꽉 참" -- Needs review
L["Cancelled - Guildbank is full"] = "취소 - 길드은행 꽉 참" -- Needs review
L["Cancelled - You must be at a bank or guildbank"] = "취소 - 은행 또는 길드은행에 있어야 합니다." -- Needs review
L["Cannot delete currently active profile!"] = "현재 활성화된 프로파일은 삭제할 수 없습니다!" -- Needs review
L["Category Text 2 (Requires Reload)"] = "카테고리 문자2 (Reload후 적용)"
L["Category Text (Requires Reload)"] = "카테고리 문자 (Reload후 적용)"
-- L["|cffffff00DO NOT report this as an error to the developers.|r If you require assistance with this, make a post on the TSM forums instead."] = ""
L[ [=[|cffffff00Important Note:|r You do not currently have any modules installed / enabled for TradeSkillMaster! |cff77ccffYou must download modules for TradeSkillMaster to have some useful functionality!|r

Please visit http://www.curse.com/addons/wow/tradeskill-master and check the project description for links to download modules.]=] ] = "|cffffff00중요 노트:|r 현재 TradeSkillMaster에 설치된 모듈이 없거나 활성화되지 않았습니다! |cff77ccff사용할 모듈을 다운로드 받아야 합니다!|r\\n\\n웹사이트(http://www.curse.com/addons/wow/tradeskill-master)에 방문하여 프로젝트 설명을 읽어 보고 필요한 모듈을 다운로드 받으세요." -- Needs review
L["Changes how many rows are shown in the auction results tables."] = "경매목록에 표시될 물품의 개수를 변경합니다."
L["Changes the size of the auction frame. The size of the detached TSM auction frame will always be the same as the main auction frame."] = "경매장 프레임의 크기를 변경합니다. 분리된 TSM 프레임은 항상 주 경매장 프레임과 같은 크기를 유지합니다." -- Needs review
L["Character Name on Other Account"] = "다른 계정에 있는 캐릭터 이름" -- Needs review
-- L["Chat Tab"] = ""
L["Check out our completely free, desktop application which has tons of features including deal notification emails, automatic updating of AuctionDB and WoWuction prices, automatic TSM setting backup, and more! You can find this app by going to %s."] = "이메일 알림, AuctionDB 와 WoWuciton 가격의 자동 업데이트, TSM 설정 자동 백업 등 많은 기능을 갖춘 데스크톱 애플리케이션을 개발하였습니다! 이 앱은 무료로 제공되며 여기(%s)에서 내려받으실 수 있습니다." -- Needs review
L["Check this box to override this group's operation(s) for this module."] = "이 모듈에서 이 그룹의 작업을 오버라이드하려면 선택하세요." -- Needs review
L["Clear"] = "해제" -- Needs review
L["Clear Selection"] = "선택 해제" -- Needs review
-- L["Click on the Auctioning Tab"] = ""
-- L["Click on the Crafting Icon"] = ""
-- L["Click on the Groups Icon"] = ""
-- L["Click on the Module Operations / Options Icon"] = ""
-- L["Click on the Shopping Tab"] = ""
-- L["Click on the 'Show Queue' button at the top of the TSM_Crafting window to show the queue if it's not already visible."] = ""
-- L["Click on the 'Start Sniper' button in the sidebar window."] = ""
-- L["Click on the 'Start Vendor Search' button in the sidebar window."] = ""
L["Click the button below to open the export frame for this group."] = "이 그룹의 내보내기 프레임을 열려면 아래 버튼을 클릭하세요." -- Needs review
-- L["Click this button to completely remove this operation from the specified group."] = ""
L["Click this button to configure the currently selected operation."] = "현재 선택된 작업의 설정을 보려면 버튼을 클릭하세요." -- Needs review
L["Click this button to create a new operation for this module."] = "이 모듈의 새 작업을 생성하려면 클릭하세요." -- Needs review
L["Click this button to show a frame for easily exporting the list of items which are in this group."] = "이 그룹 내의 아이템 리스트를 쉽게 내보내기 할 수 있는 프레임을 표시하려면 이 버튼을 클릭하세요." -- Needs review
L["Co-Founder:"] = "공동 제작자:" -- Needs review
L["Coins:"] = "동전:" -- Needs review
-- L["Color Group Names by Depth"] = ""
L["Content - Backdrop"] = "내용 - 배경"
L["Content - Border"] = "내용 - 테두리"
L["Content Text - Disabled"] = "내용 문자 - 비활성"
L["Content Text - Enabled"] = "내용 문자 - 활성"
L["Copy From"] = "복사해올 원본" -- Needs review
L["Copy the settings from one existing profile into the currently active profile."] = "기존 프로파일을 현재 활성화되어있는 프로파일에 복사합니다." -- Needs review
-- L["Craft Items from Queue"] = ""
-- L["Craft items with my professions"] = ""
-- L["Craft specific one-off items without making a queue"] = ""
L["Create a new empty profile."] = "비어있는 새 프로파일을 생성합니다." -- Needs review
-- L["Create a New Group"] = ""
-- L["Create a new group by typing a name for the group into the 'Group Name' box and pressing the <Enter> key."] = ""
-- L["Create a new %s operation by typing a name for the operation into the 'Operation Name' box and pressing the <Enter> key."] = ""
-- L["Create a %s Operation %d/5"] = ""
L["Create New Subgroup"] = "새 하위 그룹 생성" -- Needs review
L["Create %s Operation"] = "%s 작업 생성" -- Needs review
-- L["Create the Craft"] = ""
L["Creating a relationship for this setting will cause the setting for this operation to be equal to the equivalent setting of another operation."] = "이 설정에 관계를 생성하면 다른 동등한 설정의 작업과 이 작업을 같게 설정할 수 있습니다." -- Needs review
L["Crystals"] = "수정"
L["Current Profile:"] = "현재 프로파일:" -- Needs review
-- L["Custom Price for this Source"] = ""
-- L["Custom Price Source"] = ""
-- L["Custom Price Source Name"] = ""
-- L["Custom Price Sources"] = ""
-- L["Custom price sources allow you to create more advanced custom prices throughout all of the TSM modules. Just as you can use the built-in price sources such as 'vendorsell' and 'vendorbuy' in your custom prices, you can use ones you make here (which themselves are custom prices)."] = ""
-- L["Custom price sources to display in item tooltips:"] = ""
L["Default"] = "기본" -- Needs review
L["Default BankUI Tab"] = "기본 은행 UI 탭" -- Needs review
L["Default Group Tab"] = "기본 그룹 탭" -- Needs review
L["Default Tab"] = "기본 탭" -- Needs review
L["Default Tab (Open Auction House to Enable)"] = "기본 탭 (활성화하려면 경매장을 여십시오)" -- Needs review
L["Delete a Profile"] = "프로파일 삭제" -- Needs review
-- L["Delete Custom Price Source"] = ""
L["Delete existing and unused profiles from the database to save space, and cleanup the SavedVariables file."] = "공간을 절약하고 SavedVariables 파일을 정리하기 위해 데이터베이스에서 사용하지 않는 기존의 프로파일을 삭제합니다." -- Needs review
L["Delete Group"] = "그룹 삭제" -- Needs review
L["Delete Operation"] = "작업 삭제" -- Needs review
L["Description:"] = "기능: " -- Needs review
L["Deselect All Groups"] = "모든 그룹 해제" -- Needs review
L["Deselects all items in both columns."] = "양쪽 리스트에 있는 모든 아이템을 선택 해제합니다." -- Needs review
L["Disenchant source:"] = "마력추출 출처:" -- Needs review
L["Disenchant Value"] = "마력추출 가격" -- Needs review
L["Disenchant Value:"] = "마력추출 가격:" -- Needs review
L["Disenchant Value x%s:"] = "마력추출 가격 x%s:" -- Needs review
L["Display disenchant value in tooltip."] = "툴팁에 마력추출 가격 표시" -- Needs review
L["Display Group / Operation Info in Tooltips"] = "툴팁에 그룹 / 작업 정보 표시" -- Needs review
L["Display prices in tooltips as:"] = "툴팁에 가격 표시:" -- Needs review
L["Display vendor buy price in tooltip."] = "툴팁에 상인 구매가격 표시" -- Needs review
L["Display vendor sell price in tooltip."] = "툴팁에 상인 판매가격 표시" -- Needs review
L["Done"] = "완료" -- Needs review
-- L["Done!"] = ""
-- L["Double-click to collapse this item and show only the cheapest auction."] = ""
-- L["Double-click to expand this item and show all the auctions."] = ""
L["Duplicate Operation"] = "작업 복제" -- Needs review
L["Duration:"] = "지속 기간:" -- Needs review
L["Dust"] = "가루(띠끌)" -- Needs review
-- L["Embed TSM Tooltips"] = ""
L["Empty price string."] = "빈 가격 문자열." -- Needs review
-- L["Enter Filters and Start Scan"] = ""
-- L["Enter Import String"] = ""
-- L["Error creating custom price source. Custom price source with name '%s' already exists."] = ""
L["Error creating group. Group with name '%s' already exists."] = "그룹 생성 중 오류가 발생했습니다. 그룹 이름 '%s'이(가) 이미 존재합니다." -- Needs review
L["Error creating subgroup. Subgroup with name '%s' already exists."] = "하위 그룹 생성 중 오류가 발생했습니다. 하위 그룹 이름 '%s'이(가) 이미 존재합니다." -- Needs review
L["Error duplicating operation. Operation with name '%s' already exists."] = "작업 복제 중 오류가 발생했습니다. 작업 이름 '%s'이(가) 이미 존재합니다." -- Needs review
L["Error Info:"] = "에러 정보:"
L["Error moving group. Group '%s' already exists."] = "그룹 이동 중 오류가 발생했습니다. 그룹 '%s'이(가) 이미 존재합니다." -- Needs review
-- L["Error moving group. You cannot move this group to one of its subgroups."] = ""
-- L["Error renaming custom price source. Custom price source with name '%s' already exists."] = ""
L["Error renaming group. Group with name '%s' already exists."] = "그룹 이름 변경 중 오류가 발생했습니다. 그룹 이름 '%s'이(가) 이미 존재합니다." -- Needs review
L["Error renaming operation. Operation with name '%s' already exists."] = "작업 이름 변경 중 오류가 발생했습니다. 작업 이름 '%s'이(가) 이미 존재합니다." -- Needs review
L["Essences"] = "정수"
L["Examples"] = "사용 예" -- Needs review
L["Existing Profiles"] = "프로파일 선택" -- Needs review
L["Export Appearance Settings"] = "설정 저장하기"
L["Export Group Items"] = "그룹 아이템 내보내기" -- Needs review
L["Export Items in Group"] = "그룹 내의 아이템 내보내기" -- Needs review
-- L["Export Operation"] = ""
L["Failed to parse gold amount."] = "골드량 파싱 실패." -- Needs review
-- L["First, ensure your new group is selected in the group-tree and then click on the 'Restock Selected Groups' button at the bottom."] = ""
-- L["First, ensure your new group is selected in the group-tree and then click on the 'Start Cancel Scan' button at the bottom of the tab."] = ""
-- L["First, ensure your new group is selected in the group-tree and then click on the 'Start Post Scan' button at the bottom of the tab."] = ""
-- L["First, ensure your new group is selected in the group-tree and then click on the 'Start Search' button at the bottom of the sidebar window."] = ""
L["First, log into a character on the same realm (and faction) on both accounts. Type the name of the OTHER character you are logged into in the box below. Once you have done this on both accounts, TSM will do the rest automatically. Once setup, syncing will automatically happen between the two accounts while on any character on the account (not only the one you entered during this setup)."] = "먼저, 두 계정에서 같은 서버(진영)의 캐릭터로 로그인하세요. 아래 칸에 현재 로그인하지 않은 계정의 캐릭터 이름을 입력하세요. 이 과정을 두 개의 계정에서 전부 마치면, 나머지는 TSM이 자동으로 처리합니다. 설정이 완료되면, 이들 계정 안의 어느 캐릭터라도 접속되어 있으면 두 계정 간의 동기화가 자동으로 이루어집니다. (설정 중에 입력하지 않은 캐릭터도 포함)" -- Needs review
L["Fixed Gold Value"] = "고정 골드 가격" -- Needs review
L["Forget Characters:"] = "캐릭터 제거:" -- Needs review
L["Frame Background - Backdrop"] = "외부 프레임 - 배경"
L["Frame Background - Border"] = "외부 프레임 - 테두리선" -- Needs review
L["General Options"] = "일반 옵션" -- Needs review
L["General Settings"] = "일반 설정" -- Needs review
L["Give the group a new name. A descriptive name will help you find this group later."] = "그룹에 새 이름을 지정합니다. 설명이 포함된 이름은 나중에 그룹을 찾는 데 도움이 됩니다." -- Needs review
L["Give the new group a name. A descriptive name will help you find this group later."] = "새 그룹에 이름을 지정합니다. 설명이 포함된 이름은 나중에 그룹을 찾는 데 도움이 됩니다." -- Needs review
L["Give this operation a new name. A descriptive name will help you find this operation later."] = "이 작업에 새 이름을 지정합니다. 설명이 포함된 이름은 나중에 이 작업을 찾는 데 도움이 됩니다." -- Needs review
-- L["Give your new custom price source a name. This is what you will type in to custom prices and is case insensitive (everything will be saved as lower case)."] = ""
L["Goblineer (by Sterling - The Consortium)"] = "Goblineer (by Sterling - The Consortium)"
-- L["Go to the Auction House and open it."] = ""
-- L["Go to the 'Groups' Page"] = ""
-- L["Go to the 'Import/Export' Tab"] = ""
-- L["Go to the 'Items' Tab"] = ""
-- L["Go to the 'Operations' Tab"] = ""
L["Group:"] = "그룹:" -- Needs review
L["Group(Base Item):"] = "그룹 (기본 아이템):" -- Needs review
L["Group Item Data"] = "그룹 아이템 데이터" -- Needs review
L["Group Items:"] = "그룹 아이템:" -- Needs review
L["Group Name"] = "그룹 이름" -- Needs review
L["Group names cannot contain %s characters."] = "그룹 이름에 %s은(는) 포함할 수 없습니다." -- Needs review
L["Groups"] = "그룹" -- Needs review
L["Help"] = "도움말" -- Needs review
-- L["Help / Options"] = ""
L["Here you can setup relationships between the settings of this operation and other operations for this module. For example, if you have a relationship set to OperationA for the stack size setting below, this operation's stack size setting will always be equal to OperationA's stack size setting."] = "여기서는 이 모듈의 현재 작업과 다른 작업 사이의 관계를 설정할 수 있습니다. 예를 들면, 아래에서 묶음 크기의 관계를 작업A로 설정했다면 이 작업의 묶음 크기는 항상 작업A의 묶음 크기와 같습니다." -- Needs review
L["Hide Minimap Icon"] = "미니맵 아이콘 숨기기"
-- L["How would you like to craft?"] = ""
-- L["How would you like to create the group?"] = ""
-- L["How would you like to post?"] = ""
-- L["How would you like to shop?"] = ""
L["Icon Region"] = "아이콘 영역"
L["If checked, all tables listing auctions will display the bid as well as the buyout of the auctions. This will not take effect immediately and may require a reload."] = "체크 시 경매장 물품목록에 입찰과 즉구가도 표기됩니다. 즉시 적용되지 않으며 애드온의 Reload가 필요합니다." -- Needs review
L["If checked, any items you import that are already in a group will be moved out of their current group and into this group. Otherwise, they will simply be ignored."] = "선택하면, 이미 그룹에 포함되어있는 아이템을 불러오면 이전 그룹에서는 제거되고 현재 그룹에 포함합니다. 그 외에는 무시됩니다." -- Needs review
-- L["If checked, group names will be colored based on their subgroup depth in group trees."] = ""
L["If checked, only items which are in the parent group of this group will be imported."] = "선택하면, 이 그룹의 상위 그룹에 포함된 아이템만 불러옵니다." -- Needs review
L["If checked, operations will be stored globally rather than by profile. TSM groups are always stored by profile. Note that if you have multiple profiles setup already with separate operation information, changing this will cause all but the current profile's operations to be lost."] = "선택하면, 모든 설정은 프로파일을 사용하지 않고 한 개로 통합 저장됩니다. TSM 그룹은 항상 프로파일에 저장됩니다. 만일, 분리된 정보의 다중 프로파일 설정을 이미 가지고 있는 상태에서 이 옵션을 사용함으로 설정하면 현재의 프로파일은 잃게 됩니다." -- Needs review
L["If checked, the disenchant value of the item will be shown. This value is calculated using the average market value of materials the item will disenchant into."] = "선택하면, 아이템의 마력추출 가격을 표시합니다. 이 가격은 마력추출로 얻게 될 재료의 평균 시장가격으로 계산됩니다." -- Needs review
L["If checked, the price of buying the item from a vendor is displayed."] = "선택하면, 상인으로부터 구매하는 가격을 표시합니다." -- Needs review
L["If checked, the price of selling the item to a vendor displayed."] = "선택하면, 상인에게 판매하는 가격을 표시합니다." -- Needs review
-- L["If checked, the structure of the subgroups will be included in the export. Otherwise, the items in this group (and all subgroups) will be exported as a flat list."] = ""
-- L["If checked, this custom price will be displayed in item tooltips."] = ""
-- L["If checked, TSM's tooltip lines will be embedded in the item tooltip. Otherwise, it will show as a separate box below the item's tooltip."] = ""
L["If checked, ungrouped items will be displayed in the left list of selection lists used to add items to subgroups. This allows you to add an ungrouped item directly to a subgroup rather than having to add to the parent group(s) first."] = "선택하면, 그룹이 없는 아이템은 리스트의 좌측에 표시되어 하위 항목에 추가할 수 있습니다. 이는 그룹이 없는 아이템을 상위 그룹에 먼저 추가하지 않고 하위 그룹에 직접 추가할 수 있도록 합니다." -- Needs review
L["If checked, your bags will be automatically opened when you open the auction house."] = "체크 시 경매장 창이 열릴 때 모든 가방이 자동으로 열립니다."
-- L["If there are no auctions currently posted for this item, simmply click the 'Post' button at the bottom of the AH window. Otherwise, select the auction you'd like to undercut first."] = ""
L["If you delete, rename, or transfer a character off the current faction/realm, you should remove it from TSM's list of characters using this dropdown."] = "만일 캐릭터를 삭제, 이름 변경 또는 이전(진영/서버)하였다면 이 드롭다운을 이용하여 TSM 목록에서 제거해야 합니다." -- Needs review
--[==[ L[ [=[If you'd like, you can adjust the value in the 'Minimum Profit' box in order to specify the minimum profit before Crafting will queue these items.

Once you're done adjusting this setting, click the button below.]=] ] = "" ]==]
L["If you have multiple profile set up with operations, enabling this will cause all but the current profile's operations to be irreversibly lost. Are you sure you want to continue?"] = "다중 프로파일이 작업과 연결되어 있을 때 사용하면 모든 프로파일에 적용되지만 현재 프로파일의 작업은 복구 불가능한 손실이 발생합니다. 계속 하시겠습니까?" -- Needs review
-- L["If you open your bags and shift-click the item in your bags, it will be placed in Shopping's search bar. You may need to put your cursor in the search bar first. Alternatively, you can type the name of the item manually in the search bar and then hit enter or click the 'Search' button."] = ""
L["Ignore Operation on Characters:"] = "작업 무시할 캐릭터:" -- Needs review
L["Ignore Operation on Faction-Realms:"] = "작업 무시할 진영-서버:" -- Needs review
L["Ignore Random Enchants on Ungrouped Items"] = "비 그룹 아이템의 무작위 마법 부여 무시" -- Needs review
L["I'll Go There Now!"] = "지금 방문하기!" -- Needs review
-- L["I'm done."] = ""
L["Import Appearance Settings"] = "설정 불러오기"
L["Import/Export"] = "불러오기/내보내기" -- Needs review
L["Import Items"] = "아이템 불러오기" -- Needs review
-- L["Import Operation Settings"] = ""
L["Import Preset TSM Theme"] = "프리셋 불러오기" -- Needs review
L["Import String"] = "문자열 불러오기" -- Needs review
-- L["Include Subgroup Structure in Export"] = ""
L["Installed Modules"] = "설치된 모듈"
-- L["In the confirmation window, you can adjust the buyout price, stack sizes, and auction duration. Once you're done, click the 'Post' button to post your items to the AH."] = ""
-- L["In the list on the left, select the top-level 'Groups' page."] = ""
L["Invalid appearance data."] = "부정확한 외관 데이터" -- Needs review
L["Invalid custom price."] = "잘못된 사용자 가격입니다." -- Needs review
L["Invalid custom price for undercut amount. Using 1c instead."] = "에누리에 대한 사용자 가격이 잘못되었습니다. 대신 1c를 사용합니다." -- Needs review
L["Invalid filter."] = "잘못된 필터입니다." -- Needs review
L["Invalid function."] = "잘못된 기능입니다." -- Needs review
L["Invalid import string."] = "잘못된 문자열 불러오기입니다." -- Needs review
L["Invalid item link."] = "잘못된 아이템 링크입니다." -- Needs review
-- L["Invalid operator at end of custom price."] = ""
-- L["Invalid parameter to price source."] = ""
L["Invalid parent argument type. Expected table, got %s."] = "잘못된 인수 유형입니다. 테이블을 예상했지만, %s을(를) 얻었습니다." -- Needs review
L["Invalid price source in convert."] = "잘못된 가격 출처입니다." -- Needs review
L["Invalid word: '%s'"] = "잘못된 단어: '%s'" -- Needs review
L["Item"] = "아이템" -- Needs review
L["Item Buyout: %s"] = "아이템 즉구가: %s" -- Needs review
L["Item Level"] = "아이템 레벨" -- Needs review
L["Item links may only be used as parameters to price sources."] = "아이템 링크는 가격 출처에 대한 매개 변수로만 사용할 수 있습니다." -- Needs review
L["Item not found in bags. Skipping"] = "가방에 아이템이 없습니다. 건너뜁니다." -- Needs review
L["Items"] = "아이템" -- Needs review
L["Item Tooltip Text"] = "아이템 툴팁 문자"
L["Jaded (by Ravanys - The Consortium)"] = "Jaded (by Ravanys - The Consortium)"
L["Just incase you didn't read this the first time:"] = "제대로 확인하지 못한 경우를 대비해서 다시 한 번 알려드립니다:"
--[==[ L[ [=[Just like the default profession UI, you can select what you want to craft from the list of crafts for this profession. Click on the one you want to craft.

Once you're done, click the button below.]=] ] = "" ]==]
L["Keep Items in Parent Group"] = "상위 그룹 내의 아이템 유지" -- Needs review
L["Keeps track of all your sales and purchases from the auction house allowing you to easily track your income and expenditures and make sure you're turning a profit."] = "경매장을 통한 판매와 구매를 기록함으로써 수입과 지출을 관리 할 수 있으며 얼마만큼의 수익이 발생하는지 쉽게 확인할 수 있습니다."
L["Label Text - Disabled"] = "라벨 문자 - 비활성"
L["Label Text - Enabled"] = "라벨 문자 - 활성"
L["Lead Developer and Co-Founder:"] = "개발자 및 공동 개발자:" -- Needs review
L["Light (by Ravanys - The Consortium)"] = "Light (by Ravanys - The Consortium)"
L["Link Text 2 (Requires Reload)"] = "링크 문자2 (Reload후 적용)"
L["Link Text (Requires Reload)"] = "링크 문자 (Reload후 적용)"
L["Load Saved Theme"] = "저장된 테마 불러오기" -- Needs review
-- L["Look at what's profitable to craft and manually add things to a queue"] = ""
-- L["Look for items which can be destroyed to get raw mats"] = ""
-- L["Look for items which can be vendored for a profit"] = ""
-- L["Looks like no items were added to the queue. This may be because you are already at or above your restock levels, or there is nothing profitable to queue."] = ""
-- L["Looks like no items were found. You can either try searching for something else, or simply close the Assistant window if you're done."] = ""
-- L["Looks like no items were imported. This might be because they are already in another group in which case you might consider checking the 'Move Already Grouped Items' box to force them to move to this group."] = ""
-- L["Looks like TradeSkillMaster has detected an error with your configuration. Please address this in order to ensure TSM remains functional."] = ""
L["Looks like TradeSkillMaster has encountered an error. Please help the author fix this error by copying the entire error below and following the instructions for reporting bugs listed here (unless told elsewhere by the author):"] = "TradeSkillMaster에 에러가 발생한 것 같습니다. 아래 표시된 에러 전체를 복사하여 안내에 따라 버그 신고을 해 주시어 제작자가 에러를 수정할 수 있도록 도움을 주시기 바랍니다:"
L["Looks like TradeSkillMaster has encountered an error. Please help the author fix this error by following the instructions shown."] = "TradeSkillMaster에 에러가 발생한 것 같습니다. 아래 표시된 안내에 따라 제작자가 에러를 수정할 수 있도록 도움을 주시기 바랍니다."
-- L["Loop detected in the following custom price:"] = ""
-- L["Make a new group from an import list I have"] = ""
-- L["Make a new group from items in my bags"] = ""
L["Make Auction Frame Movable"] = "경매창 이동 가능"
L["Management"] = "관리" -- Needs review
L["Manages your inventory by allowing you to easily move stuff between your bags, bank, and guild bank."] = "가방, 은행, 길드 은행 간의 아이템을 쉽게 이동 관리할 수 있습니다." -- Needs review
L["% Market Value"] = "% 시장 가격" -- Needs review
L["max %d"] = "최대 %d" -- Needs review
L["Medium Text Size (Requires Reload)"] = "중간 문자 (Reload후 적용)" -- Needs review
L["Mills, prospects, and disenchants items at super speed!"] = "빠른 속도의 제분, 보석추출, 마력추출을 제공합니다"
L["Misplaced comma"] = "콤마의 위치가 잘못됐습니다." -- Needs review
L["Module:"] = "모듈: " -- Needs review
L["Module Information:"] = "모듈 정보:" -- Needs review
L["Module Operations / Options"] = "모듈 작업 / 옵션" -- Needs review
-- L["Modules"] = ""
L["More Advanced Methods"] = "좀더 고급 방식" -- Needs review
-- L["More advanced options are now designated by %sred text|r. Beginners are encourages to come back to these once they have a solid understanding of the basics."] = ""
L["Move Already Grouped Items"] = "이미 그룹화된 아이템 이동" -- Needs review
L["Moved %s to %s."] = "%s을(를) %s으로 이동했습니다." -- Needs review
L["Move Group"] = "그룹 이동" -- Needs review
L["Move to Top Level"] = "최상위 레벨로 이동" -- Needs review
L["Multi-Account Settings"] = "다중 계정 설정" -- Needs review
-- L["My group is selected."] = ""
-- L["My new operation is selected."] = ""
L["New"] = "프로파일 생성" -- Needs review
-- L["New Custom Price Source"] = ""
L["New Group"] = "새 그룹" -- Needs review
L["New Group Name"] = "새 그룹 이름" -- Needs review
L["New Parent Group"] = "새 상위 그룹" -- Needs review
L["New Subgroup Name"] = "새 하위 그룹 이름" -- Needs review
-- L["No Assistant guides available for the modules which you have installed."] = ""
-- L["<No Group Selected>"] = ""
L["No modules are currently loaded.  Enable or download some for full functionality!"] = "현재 적재된 모듈이 없습니다. 모듈을 활성화 시키거나 다운로드하세요." -- Needs review
L["None of your groups have %s operations assigned. Type '/tsm' and click on the 'TradeSkillMaster Groups' button to assign operations to your TSM groups."] = "%s 작업에 할당된 그룹이 없습니다. /tsm을 입력하고 '그룹' 버튼을 클릭하여 작업을 TSM 그룹에 할당하세요." -- Needs review
L["<No Operation>"] = "<작업 없음>" -- Needs review
-- L["<No Operation Selected>"] = ""
L["<No Relationship>"] = "<관계 없음>" -- Needs review
L["Normal Text Size (Requires Reload)"] = "일반 문자 (Reload후 적용)" -- Needs review
--[==[ L[ [=[Now that the scan is finished, you can look through the results shown in the log, and for each item, decide what action you want to take.

Once you're done, click on the button below.]=] ] = "" ]==]
L["Number of Auction Result Rows (Requires Reload)"] = "경매목록 갯수 (Reload후 적용)"
L["Only Import Items from Parent Group"] = "상위 그룹의 아이템만 불러오기" -- Needs review
L["Open All Bags with Auction House"] = "경매장 이용 시 모든 가방 열기"
-- L["Open one of the professions which you would like to use to craft items."] = ""
-- L["Open the Auction House"] = ""
-- L["Open the TSM Window"] = ""
-- L["Open up Your Profession"] = ""
L["Operation #%d"] = "작업 #%d" -- Needs review
L["Operation Management"] = "작업 관리" -- Needs review
L["Operations"] = "작업" -- Needs review
L["Operations: %s"] = "작업: %s" -- Needs review
L["Options"] = "옵션"
L["Override Module Operations"] = "모듈 작업 오버라이드" -- Needs review
L["Parent Group Items:"] = "상위 그룹 아이템:" -- Needs review
L["Parent/Ungrouped Items:"] = "상위/그룹 없는 아이템:" -- Needs review
L["Past Contributors:"] = "이전 참여자:" -- Needs review
L["Paste the exported items into this box and hit enter or press the 'Okay' button. The recommended format for the list of items is a comma separated list of itemIDs for general items. For battle pets, the entire battlepet string should be used. For randomly enchanted items, the format is <itemID>:<randomEnchant> (ex: 38472:-29)."] = "내보내기 된 아이템을 이 상자에 붙어 넣고 엔터키 또는 'Okay' 버튼을 누르세요. 아이템 리스트의 권장 포맷은 콤마로 분리된 일반 아이템의 아이템ID 목록입니다. 전투 애완동물은 이름의 전체 문자열을 입력해야 합니다. 무작위 마법 부여 아이템은 <아이템ID>:<무작위 마법 부여>입니다. (예: 38472:-29)." -- Needs review
-- L["Paste the exported operation settings into this box and hit enter or press the 'Okay' button. Imported settings will irreversibly replace existing settings for this operation."] = ""
L[ [=[Paste the list of items into the box below and hit enter or click on the 'Okay' button.

You can also paste an itemLink into the box below to add a specific item to this group.]=] ] = "아이템 리스트를 아래 상자에 붙어 넣고 엔터키를 누르거나 'Okay' 버튼을 클릭하세요.\\n\\n아래 상자에 아이템 링크를 붙여 넣어 이 그룹에 특정 아이템을 추가할 수도 있습니다." -- Needs review
-- L["Paste your import string into the 'Import String' box and hit the <Enter> key to import the list of items."] = ""
L["Percent of Price Source"] = "가격 출처의 백분율" -- Needs review
L["Performs scans of the auction house and calculates the market value of items as well as the minimum buyout. This information can be shown in items' tooltips as well as used by other modules."] = "경매장을 검색하여 아이템의 시장가와 최저구매가를 계산합니다. 이 정보는 아이템의 툴팁에 표기할 수 있으며 다른 모듈에서도 사용이 가능합니다."
L["Per Item:"] = "아이템 당:" -- Needs review
-- L["Please select the group you'd like to use."] = ""
-- L["Please select the new operation you've created."] = ""
-- L["Please wait..."] = ""
L["Post"] = "등록" -- Needs review
-- L["Post an Item"] = ""
-- L["Post items manually from my bags"] = ""
L["Posts and cancels your auctions to / from the auction house according to pre-set rules. Also, this module can show you markets which are ripe for being reset for a profit."] = "사전에 설정된 규칙에 따라 경매등록과 경매취소를 제공합니다. 이 모듈은 또한 시장의 흐름을 파악하는 데 도움을 줍니다." -- Needs review
-- L["Post Your Items"] = ""
L["Price Per Item"] = "아이템당 가격" -- Needs review
L["Price Per Stack"] = "묶음당 가격" -- Needs review
L["Price Per Target Item"] = "대상 아이템당 가격" -- Needs review
L["Prints out the available price sources for use in custom price boxes."] = "사용자 가격 상자에 사용 가능한 가격 출처를 출력합니다." -- Needs review
L["Prints out the version numbers of all installed modules"] = "설치된 모든 모듈의 버전 번호를 출력합니다." -- Needs review
L["Profiles"] = "프로파일" -- Needs review
L["Provides extra functionality that doesn't fit well in other modules."] = "다른 모듈에 포함되기에 적합하지 않은 추가 기능을 제공합니다." -- Needs review
L["Provides interfaces for efficiently searching for items on the auction house. When an item is found, it can easily be bought, canceled (if it's yours), or even posted from your bags."] = "경매장의 아이템을 효과적으로 검색할 수 있는 인터페이스를 제공합니다. 검색된 아이템은 구매하거나 경매등록 또는 경매취소(자신이 등록해 놓은 아이템일 경우) 할 수 있습니다." -- Needs review
L["Purchasing Auction: %d/%d"] = "경매 구매: %d/%d" -- Needs review
-- L["Queue Profitable Crafts"] = ""
-- L["Quickly post my items at some pre-determined price"] = ""
L["Region - Backdrop"] = "내부 프레임 - 배경"
L["Region - Border"] = "내부 프레임 - 테두리선" -- Needs review
-- L["Remove"] = ""
L["<<< Remove"] = "<<< 제거" -- Needs review
-- L["Removed '%s' as a custom price source. Be sure to update any custom prices that were using this source."] = ""
L["<Remove Operation>"] = "<작업 제거>" -- Needs review
-- L["Rename Custom Price Source"] = ""
L["Rename Group"] = "그룹 이름 변경" -- Needs review
L["Rename Operation"] = "작업 이름 변경" -- Needs review
L["Replace"] = "대체" -- Needs review
L["Reset Profile"] = "프로파일 재설정" -- Needs review
-- L["Resets the position, scale, and size of all applicable TSM and module frames."] = ""
L["Reset the current profile back to its default values, in case your configuration is broken, or you simply want to start over."] = "설정이 잘못되었거나 처음부터 새로 시작하기를 원할 경우 현재의 프로파일을 기본값으로 복원할 수 있습니다." -- Needs review
L["Resources:"] = "자원:" -- Needs review
-- L["Restart Assistant"] = ""
L["Restore Default Colors"] = "기본 색상으로 복원"
L["Restores all the color settings below to their default values."] = "아래에 설정된 모든 색상값을 기본값으로 복원합니다."
L["Saved theme: %s."] = "저장된 테마: %s." -- Needs review
L["Save Theme"] = "테마 저장" -- Needs review
L["%sDrag%s to move this button"] = "%s드레그%s : 미니맵 아이콘 이동"
L["Searching for item..."] = "아이템 검색 중..." -- Needs review
-- L["Search the AH for items to buy"] = ""
L["See instructions above this editbox."] = "이 편집 상자 위의 설명을 참고하세요." -- Needs review
L["Select a group from the list below and click 'OK' at the bottom."] = "아래 목록에서 그룹을 선택하고 'OK' 버튼을 누르세요." -- Needs review
L["Select All Groups"] = "모든 그룹 선택" -- Needs review
L["Select an operation to apply to this group."] = "이 그룹에 적용할 작업을 선택하세요." -- Needs review
L["Select a %s operation using the dropdown above."] = "위의 드롭다운을 이용해서 %s 작업을 선택하세요." -- Needs review
L["Select a theme from this dropdown to import one of the preset TSM themes."] = "드롭다운 목록에서 불러올 프리셋 TSM 테마를 선택하세요"
L["Select a theme from this dropdown to import one of your saved TSM themes."] = "드롭다운 목록에서 불러올 저장된 TSM 테마를 선택하세요." -- Needs review
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
L["Select the price source for calculating disenchant value."] = "마력추출 값을 계산할 가격의 출처를 선택하세요." -- Needs review
-- L["Select the 'Shopping' tab to open up the settings for TSM_Shopping."] = ""
--[==[ L[ [=[Select your new operation in the list of operation along the left of the TSM window (if it's not selected automatically) and click on the button below.

Currently Selected Operation: %s]=] ] = "" ]==]
L["Seller"] = "판매자" -- Needs review
-- L["Sell items on the AH and manage my auctions"] = ""
L["Sell to Vendor"] = "상인에게 판매" -- Needs review
L["Set All Relationships to Target"] = "모든 관계 설정" -- Needs review
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
L["Sets all relationship dropdowns below to the operation selected."] = "선택된 작업으로 아래의 모든 관계 드롭다운을 설정합니다." -- Needs review
L["Settings"] = "설정" -- Needs review
L["Setup account sync'ing with the account which '%s' is on."] = "계정 '%s'과 동기화 설정이 켜져있습니다." -- Needs review
-- L["Set up TSM to automatically cancel undercut auctions"] = ""
-- L["Set up TSM to automatically post auctions"] = ""
-- L["Set up TSM to automatically queue things to craft"] = ""
-- L["Setup TSM to automatically reset specific markets"] = ""
-- L["Set up TSM to find cheap items on the AH"] = ""
L["Shards"] = "조각(파편)" -- Needs review
-- L["Shift-Click an item in the sidebar window to immediately post it at your quick posting price."] = ""
-- L["Shift-Click Item in Your Bags"] = ""
L["Show Bids in Auction Results Table (Requires Reload)"] = "경매결과 테이블에 입찰정보 보기 (Reload후 적용)" -- Needs review
-- L["Show the 'Custom Filter' Sidebar Tab"] = ""
-- L["Show the 'Other' Sidebar Tab"] = ""
-- L["Show the Queue"] = ""
-- L["Show the 'Quick Posting' Sidebar Tab"] = ""
-- L["Show the 'TSM Groups' Sidebar Tab"] = ""
L["Show Ungrouped Items for Adding to Subgroups"] = "하위 그룹에 추가할 수 있도록 그룹이 없는 아이템 표시" -- Needs review
L["%s is a valid custom price but did not give a value for %s."] = "%s은(는) 유효한 사용자 가격이지만 %s에 가격이 주어지지 않았습니다." -- Needs review
L["%s is a valid custom price but %s is an invalid item."] = "%s은(는) 유효한 사용자 가격이지만 %s은(는) 유효하지 않은 아이템입니다." -- Needs review
L["%s is not a valid custom price and gave the following error: %s"] = "%s은(는) 유효하지 않은 사용자 가격이므로 에러가 발생하였습니다. %s" -- Needs review
L["Skipping auction which no longer exists."] = "더이상 존재하지 않는 경매를 건너뜁니다." -- Needs review
L["Slash Commands:"] = "슬래시 명령어:"
L["%sLeft-Click|r to select / deselect this group."] = "%sLeft-Click|r : 이 그룹을 선택 / 해제합니다." -- Needs review
L["%sLeft-Click%s to open the main window"] = "%s좌클릭%s : 설정창 열기"
L["Small Text Size (Requires Reload)"] = "작은 문자 (Reload후 적용)" -- Needs review
-- L["Snipe items as they are being posted to the AH"] = ""
-- L["Sniping Scan in Progress"] = ""
L["%s operation(s):"] = "%s 작업:" -- Needs review
-- L["Sources"] = ""
L["%sRight-Click|r to collapse / expand this group."] = "%sRight-Click|r : 이 그룹을 확장 / 축소합니다." -- Needs review
L["Stack Size"] = "묶음 크기" -- Needs review
L["stacks of"] = "묶음" -- Needs review
-- L["Start a Destroy Search"] = ""
-- L["Start Sniper"] = ""
-- L["Start Vendor Search"] = ""
L["Status / Credits"] = "상태 / 제작자" -- Needs review
L["Store Operations Globally"] = "설정 통합 저장" -- Needs review
L["Subgroup Items:"] = "하위 그룹 아이템:" -- Needs review
L["Subgroups contain a subset of the items in their parent groups and can be used to further refine how different items are treated by TSM's modules."] = "하위 그룹은 상위 그룹 아이템의 부분 집합이며 TSM 모듈에 의해서 아이템이 다른 방식으로 처리되도록 할 수 있습니다." -- Needs review
L["Successfully imported %d items to %s."] = "%d개의 아이템을 %s(으)로 불러오는 데 성공했습니다." -- Needs review
-- L["Successfully imported operation settings."] = ""
-- L["Switch to Destroy Mode"] = ""
-- L["Switch to New Custom Price Source After Creation"] = ""
L["Switch to New Group After Creation"] = "생성 후 새 그룹으로 전환" -- Needs review
-- L["Switch to the 'Professions' Tab"] = ""
-- L["Switch to the 'TSM Groups' Tab"] = ""
L["Target Operation"] = "작업 대상" -- Needs review
L["Testers (Special Thanks):"] = "테스터 (매우 감사):"
L["Text:"] = "문자:" -- Needs review
L["The default tab shown in the 'BankUI' frame."] = "'은행UI' 프레임에 표시될 기본 탭" -- Needs review
-- L["The final set of posting settings are under the 'Posting Price Settings' header. These define the price ranges which Auctioning will post your items within. Read the tooltips of the individual settings to see what they do and set them appropriately."] = ""
-- L["The first set of posting settings are under the 'Auction Settings' header. These control things like stack size and auction duration. Read the tooltips of the individual settings to see what they do and set them appropriately."] = ""
L["The Functional Gold Maker (by Xsinthis - The Golden Crusade)"] = "The Functional Gold Maker (by Xsinthis - The Golden Crusade)" -- Needs review
--[==[ L[ [=[The 'Maxium Auction Price (per item)' is the most you want to pay for the items you've added to your group. If you're not sure what to set this to and have TSM_AuctionDB installed (and it contains data from recent scans), you could try '90% dbmarket' for this option.

Once you're done adjusting this setting, click the button below.]=] ] = "" ]==]
--[==[ L[ [=[The 'Max Restock Quantity' defines how many of each item you want to restock up to when using the restock queue, taking your inventory into account.

Once you're done adjusting this setting, click the button below.]=] ] = "" ]==]
L["Theme Name"] = "테마 이름" -- Needs review
L["Theme name is empty."] = "테마 이름이 비여있습니다." -- Needs review
-- L["The name can ONLY contain letters. No spaces, numbers, or special characters."] = ""
L["There are no visible banks."] = "은행이 없습니다." -- Needs review
-- L["There is only one price level and seller for this item."] = ""
-- L["The second set of posting settings are under the 'Auction Price Settings' header. These include the percentage of the buyout which the bid will be set to, and how much you want to undercut by. Read the tooltips of the individual settings to see what they do and set them appropriately."] = ""
-- L["These settings control when TSM_Auctioning will cancel your auctions. Read the tooltips of the individual settings to see what they do and set them appropriately."] = ""
--[==[ L[ [=[The 'Sniper' feature will constantly search the last page of the AH which shows items as they are being posted. This does not search existing auctions, but lets you buy items which are posted cheaply right as they are posted and buy them before anybody else can.

You can adjust the settings for what auctions are shown in TSM_Shopping's options.

Click the button below when you're done reading this.]=] ] = "" ]==]
L["This allows you to export your appearance settings to share with others."] = "저장된 설정 값을 다른 사용자들과 공유할 수 있습니다." -- Needs review
L["This allows you to import appearance settings which other people have exported."] = "다른 사용자들이 저장한 설정 값을 불러올 수 있습니다." -- Needs review
L["This dropdown determines the default tab when you visit a group."] = "이 드롭다운은 그룹의 기본 탭을 결정합니다." -- Needs review
L["This group already has operations. Would you like to add another one or replace the last one?"] = "이 그룹은 이미 작업을 가지고 있습니다. 다른 작업을 추가하거나 마지막 작업을 교체하시겠습니까?" -- Needs review
L["This group already has the max number of operation. Would you like to replace the last one?"] = "이 그룹은 이미 최대 개수의 작업을 가지고 있습니다. 마지막 작업을 교체하시겠습니까?" -- Needs review
L["This operation will be ignored when you're on any character which is checked in this dropdown."] = "이 드롭다운에서 선택되어있는 캐릭터 중 하나로 로그인 중이라면 이 작업은 무시됩니다." -- Needs review
-- L["This option sets which tab TSM and its modules will use for printing chat messages."] = ""
L["Time Left"] = "남은 시간" -- Needs review
L["Title"] = "제목"
L["Toggles the bankui"] = "은행UI 표시/숨기기" -- Needs review
L["Tooltip Options"] = "툴팁 옵션" -- Needs review
L["Tracks and manages your inventory across multiple characters including your bags, bank, and guild bank."] = "여러 캐릭터가 보유한 가방, 은행, 길드 은행을 추적 관리할 수 있습니다."
L["TradeSkillMaster Error Window"] = "TradeSkillMaster 에러 창"
L["TradeSkillMaster Info:"] = "TradeSkillMaster 정보:"
L["TradeSkillMaster Team"] = "TradeSkillMaster 팀"
L["TSM Appearance Options"] = "TSM 외관 설정"
-- L["TSM Assistant"] = ""
L["TSM Classic (by Jim Younkin - Power Word: Gold)"] = "TSM Classic (by Jim Younkin - Power Word: Gold)" -- Needs review
L["TSMDeck (by Jim Younkin - Power Word: Gold)"] = "TSMDeck (by Jim Younkin - Power Word: Gold)"
L["/tsm help|r - Shows this help listing"] = "/tsm help|r - 도움말 목록을 보여줍니다."
L["TSM Info / Help"] = "TSM 정보 / 도움말"
L["/tsm|r - opens the main TSM window."] = "/tsm|r - TSM 창을 엽니다."
L["TSM Status / Options"] = "TSM 상태 / 옵션" -- Needs review
L["TSM Version Info:"] = "TSM 버전 정보:" -- Needs review
L["TUJ GE - Market Average"] = "TUJ GE - 시장 평균" -- Needs review
L["TUJ GE - Market Median"] = "TUJ GE - 시장 평균" -- Needs review
L["TUJ RE - Market Price"] = "TUJ RE - 시장 가격" -- Needs review
L["TUJ RE - Mean"] = "TUJ RE - 평균" -- Needs review
-- L["Type a raw material you would like to obtain via destroying in the search bar and start the search. For example: 'Ink of Dreams' or 'Spirit Dust'."] = ""
L["Type in the name of a new operation you wish to create with the same settings as this operation."] = "이 작업과 같은 설정으로 새 작업을 생성하려면 이름을 입력하세요." -- Needs review
-- L["Type '/tsm' or click on the minimap icon to open the main TSM window."] = ""
L["Type '/tsm sources' to print out all available price sources."] = "'/tsm sources'를 입력하면 사용 가능한 모든 가격 출처가 출력됩니다." -- Needs review
L["Unbalanced parentheses."] = "잘못된 괄호 사용." -- Needs review
-- L["Underneath the 'Posting Options' header, there are two settings which control the Quick Posting feature of TSM_Shopping. The first one is the duration which Quick Posting should use when posting your items to the AH. Change this to your preferred duration for Quick Posting."] = ""
-- L["Underneath the 'Posting Options' header, there are two settings which control the Quick Posting feature of TSM_Shopping. The second one is the price at which the Quick Posting will post items to the AH. This should generally not be a fixed gold value, since it will apply to every item. Change this setting to what you'd like to post items at with Quick Posting."] = ""
-- L["Underneath the serach bar at the top of the 'Shopping' AH tab are a handful of buttons which change what's displayed in the sidebar window. Click on the 'Custom Filter' one."] = ""
-- L["Underneath the serach bar at the top of the 'Shopping' AH tab are a handful of buttons which change what's displayed in the sidebar window. Click on the 'Other' one."] = ""
-- L["Underneath the serach bar at the top of the 'Shopping' AH tab are a handful of buttons which change what's displayed in the sidebar window. Click on the 'TSM Groups' one."] = ""
-- L["Under the search bar, on the left, you can switch between normal and destroy mode for TSM_Shopping. Switch to 'Destroy Mode' now."] = ""
L["Ungrouped Items:"] = "그룹 없는 아이템:" -- Needs review
L["Usage: /tsm price <ItemLink> <Price String>"] = "사용법: /tsm 가격 <아이템 링크> <가격 문자열>" -- Needs review
-- L["Use an existing group"] = ""
-- L["Use a subset of items from an existing group by creating a subgroup"] = ""
L["Use the button below to delete this group. Any subgroups of this group will also be deleted, with all items being returned to the parent of this group or removed completely if this group has no parent."] = "이 그룹을 삭제하려면 아래 버튼을 이용하세요. 이 그룹에 포함된 모든 하위 그룹은 삭제되고 모든 아이템은 상위 그룹으로 반환되거나 상위 그룹이 없다면 제거됩니다." -- Needs review
L["Use the editbox below to give this group a new name."] = "아래 편집 상자를 이용해 이 그룹에 새 이름을 부여합니다." -- Needs review
L["Use the group box below to move this group and all subgroups of this group. Moving a group will cause all items in the group (and its subgroups) to be removed from its current parent group and added to the new parent group."] = "(and its subgroups) to be removed from its current parent group and added to the new parent group.\"] = \"이 그룹과 이 그룹에 포함된 모든 하위 그룹을 이동하려면 아래 그룹 상자를 이용하세요. 그룹을 이동시키면 그룹 내의 모든 아이템(그리고 하위 그룹)은 현재의 상위 그룹에서 삭제되고 새 상위 그룹에 추가됩니다." -- Needs review
L["Use the options below to change and tweak the appearance of TSM."] = "아래 옵션을 통해서 TSM의 외관을 변경할 수 있습니다."
L["Use the tabs above to select the module for which you'd like to configure operations and general options."] = "작업 구성과 일반 옵션 설정을 원하는 모듈을 위의 탭에서 선택하세요." -- Needs review
L["Use the tabs above to select the module for which you'd like to configure tooltip options."] = "툴팁 옵션 설정을 원하는 모듈을 위의 탭에서 선택하세요." -- Needs review
L["Using our website you can get help with TSM, suggest features, and give feedback."] = "저희 웹사이트를 통해서 TSM에 대한 도움을 받으시거나 새로운 기능에 대한 제안 또는 기타 의견을 전달하실 수 있습니다." -- Needs review
L["Various modules can sync their data between multiple accounts automatically whenever you're logged into both accounts."] = "여러 계정에 로그인할 때마다 다양한 모듈 간의 데이터를 자동으로 동기화할 수 있습니다." -- Needs review
L["Vendor Buy Price:"] = "상인 구매 가격:" -- Needs review
L["Vendor Buy Price x%s:"] = "상인 구매 가격 x%s:" -- Needs review
L["Vendor Sell Price:"] = "상인 판매 가격:" -- Needs review
L["Vendor Sell Price x%s:"] = "상인 판매 가격 x%s:" -- Needs review
L["Version:"] = "버전: " -- Needs review
-- L["View current auctions and choose what price to post at"] = ""
L["View Operation Options"] = "작업 옵션 보기" -- Needs review
L["Visit %s for information about the different TradeSkillMaster modules as well as download links."] = "%s 를 방문하면 TradeSkillMaster의 여러 모듈의 정보를 확인하고 다운로드 받으실 수 있습니다." -- Needs review
-- L["Waiting for Scan to Finish"] = ""
L["Web Master and Addon Developer:"] = "웹 마스터 및 애드온 개발자 :"
-- L["We will add a %s operation to this group through its 'Operations' tab. Click on that tab now."] = ""
-- L["We will add items to this group through its 'Items' tab. Click on that tab now."] = ""
-- L["We will import items into this group using the import list you have."] = ""
-- L["What do you want to do?"] = ""
--[==[ L[ [=[When checked, random enchants will be ignored for ungrouped items.

NB: This will not affect parent group items that were already added with random enchants

If you have this checked when adding an ungrouped randomly enchanted item, it will act as all possible random enchants of that item.]=] ] = "" ]==]
L["When clicked, makes this group a top-level group with no parent."] = "선택하면, 이 그룹을 최상의 그룹으로 만듭니다." -- Needs review
L["Would you like to add this new operation to %s?"] = "이 작업을 %s에 추가하시겠습니까?" -- Needs review
L["Wrong number of item links."] = "아이템 링크의 수자가 잘못되었습니다." -- Needs review
-- L["You appear to be attempting to import an operation from a different module."] = ""
L["You can change the active database profile, so you can have different settings for every character."] = "활성 데이터베이스 프로파일을 변경할 수 있습니다. 그리하여 설정을 캐릭터별로 다르게 할 수 있습니다." -- Needs review
--[==[ L[ [=[You can craft items either by clicking on rows in the queue which are green (meaning you can craft all) or blue (meaning you can craft some) or by clicking on the 'Craft Next' button at the bottom.

Click on the button below when you're done reading this. There is another guide which tells you how to buy mats required for your queue.]=] ] = "" ]==]
L["You can either create a new profile by entering a name in the editbox, or choose one of the already exisiting profiles."] = "편집 상자에 이름을 입력하여 새 프로파일을 생성하거나 이미 존재하는 프로파일 중 하나를 선택할 수 있습니다." -- Needs review
-- L["You can hold shift while clicking this button to remove the items from ALL groups rather than keeping them in the parent group (if one exists)."] = ""
--[==[ L[ [=[You can look through the tooltips of the other options to see what they do and decide if you want to change their values for this operation.

Once you're done, click on the button below.]=] ] = "" ]==]
L["You cannot create a profile with an empty name."] = "이름이 공백인 프로파일은 생성할 수 없습니다." -- Needs review
-- L["You cannot use %s as part of this custom price."] = ""
--[==[ L[ [=[You can now use the buttons near the bottom of the TSM_Crafting window to create this craft.

Once you're done, click the button below.]=] ] = "" ]==]
--[==[ L[ [=[You can use the filters at the top of the page to narrow down your search and click on a column to sort by that column. Then, left-click on a row to add one of that item to the queue, and right-click to remove one.

Once you're done adding items to the queue, click the button below.]=] ] = "" ]==]
--[==[ L[ [=[You can use this sidebar window to help build AH searches. You can also type the filter directly in the search bar at the top of the AH window.

Enter your filter and start the search.]=] ] = "" ]==]
L["You currently don't have any groups setup. Type '/tsm' and click on the 'TradeSkillMaster Groups' button to setup TSM groups."] = "현재 설정된 그룹이 존재하지 않습니다. /tsm을 입력하고 'TradeSkillMaster 그룹' 버튼을 클릭하면 TSM 그룹을 설정할 수 있습니다." -- Needs review
L["You have closed the bankui. Use '/tsm bankui' to view again."] = "은행 UI를 닫았습니다. '/tsm bankui'를 입력하면 다시 열립니다." -- Needs review
-- L["You have successfully completed this guide. If you require further assistance, visit out our website:"] = ""
