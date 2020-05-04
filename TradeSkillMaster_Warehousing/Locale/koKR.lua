-- ------------------------------------------------------------------------------ --
--                          TradeSkillMaster_Warehousing                          --
--          http://www.curse.com/addons/wow/tradeskillmaster_warehousing          --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- TradeSkillMaster_Warehousing Locale - koKR
-- Please use the localization app on CurseForge to update this
-- http://wow.curseforge.com/addons/TradeSkillMaster_Warehousing/localization/

local L = LibStub("AceLocale-3.0"):NewLocale("TradeSkillMaster_Warehousing", "koKR")
if not L then return end
L["1) Open up a bank (either the gbank or personal bank)"] = "1) 은행을 엽니다. (개인 은행 또는 길드 은행)" -- Needs review
L["1) Select Operations on the left menu and type a name in the textbox labeled \"Operation Name\", hit okay"] = "1) 왼쪽 메뉴에서 작업을 선택하고 \\\"작업 이름\\\" 항목의 텍스트 상자에 이름을 입력한 후 Okey를 클릭하세요." -- Needs review
L["2) You can delete an operation by selecting the operation and then under Operation Management click the button labelled \"Delete Operation\". "] = "2) 작업을 선택하고 작업 관리 아래에 있는 \\\"작업 삭제\\\" 버튼을 클릭하면 작업을 삭제할 수 있습니다." -- Needs review
L["2) You should see a window on your right with a list of groups"] = "2) 우측에 그룹 리스트가 나열된 창이 나타납니다." -- Needs review
L["3) Select one or more groups and hit either %s or %s"] = "3) 하나 또는 그 이상의 그룹을 선택하고 %s 또는 %s 버튼 중 하나를 클릭합니다." -- Needs review
L["Bank UI"] = "은행 UI" -- Needs review
L["Canceled"] = "취소" -- Needs review
L["Displays realtime move data."] = "데이터 이동을 실시간으로 표시합니다." -- Needs review
L["Empty Bags"] = "가방 비우기"
L["Empty Bags/Restore Bags"] = "가방 비우기/가방 복구" -- Needs review
L["Enable Restock"] = "재보충 사용" -- Needs review
L["Enable this to set the quantity to keep back in your bags"] = "활성화 시 가방에 유지할 수량을 설정할 수 있습니다." -- Needs review
L["Enable this to set the quantity to keep back in your bank / guildbank"] = "활성화 시 은행/길드 은행에 유지할 수량을 설정할 수 있습니다." -- Needs review
L["Enable this to set the quantity to move, if disabled Warehousing will move all of the item"] = "활성화 시 이동할 수량을 설정할 수 있습니다. 비활성화 시 모든 아이템이 이동됩니다." -- Needs review
L["Enable this to set the restock quantity"] = "활성화 시 재보충 수량을 설정할 수 있습니다." -- Needs review
L["Error creating operation. Operation with name '%s' already exists."] = "작업 생성 중 오류가 발생했습니다. 작업 이름 '%s'이(가) 이미 존재합니다." -- Needs review
L["Example 1: /tsm get glyph 20 - get up to 20 of each item in your bank/guildbank where the name contains\"glyph\" and place them in your bags."] = "예 1: /tsm get 문양 20 - 은행/길드 은행에서 이름에 \\\"문양\\\"이 포함된 각각의 아이템 20개씩을 가방으로 가져옵니다." -- Needs review
L["Example 2: /tsm put 74249 - get all of item 74249 (Spirit Dust) from your bags and put them in your bank/guildbank"] = "예 2: /tsm put 74249 - 가방에 있는 모든 아이템 74249 (영혼 티끌)을 은행/길드 은행에 넣습니다." -- Needs review
L["General"] = "일반" -- Needs review
L["Gets items from the bank or guild bank matching the itemstring, itemID or partial text entered."] = "아이템 링크, 아이템ID, 입력된 부분적인 아이템 이름과 일치하는 아이템을 은행 또는 길드 은행에서 가져옵니다." -- Needs review
L["Give the new operation a name. A descriptive name will help you find this operation later."] = "작업에 새 이름을 지정합니다. 설명이 포함된 이름은 나중에 작업을 찾는 데 도움이 됩니다." -- Needs review
L["Help"] = "도움말" -- Needs review
L["Invalid criteria entered."] = "입력이 잘못되었습니다." -- Needs review
L["Keep in Bags Quantity"] = "가방에 유지할 수량" -- Needs review
L["Keep in Bank/GuildBank Quantity"] = "은행/길드 은행에 유지할 수량" -- Needs review
L["Move Data has been turned off"] = "데이터 이동 중지" -- Needs review
L["Move Data has been turned on"] = "데이터 이동 가능" -- Needs review
L["Move Group To Bags"] = "가방으로 이동"
L["Move Group To Bank"] = "은행으로 이동"
L["Move Quantity"] = "이동 수량" -- Needs review
L["Move Quantity Settings"] = "이동 수량 설정" -- Needs review
L["New Operation"] = "새 작업" -- Needs review
L["Nothing to Move"] = "이동할 아이템 없음" -- Needs review
L["Nothing to Restock"] = "재보충할 아이템 없음" -- Needs review
L["Operation Name"] = "작업 이름" -- Needs review
L["Operations"] = "작업" -- Needs review
L["Preparing to Move"] = "이동 준비" -- Needs review
L["Puts items matching the itemstring, itemID or partial text entered into the bank or guild bank."] = "아이템 링크, 아이템ID, 입력된 부분적인 아이템 이름과 일치하는 아이템을 은행 또는 길드 은행에 넣습니다." -- Needs review
L["Relationships"] = "관계" -- Needs review
L["Restock Bags"] = "가방 재보충" -- Needs review
L["Restocking"] = "재보충 중" -- Needs review
L["Restock Quantity"] = "재보충 수량" -- Needs review
L["Restock Settings"] = "재보충 설정" -- Needs review
L["Restore Bags"] = "가방 복구"
L["Set Keep in Bags Quantity"] = "가방에 유지할 수량 설정" -- Needs review
L["Set Keep in Bank Quantity"] = "은행에 유지할 수량 설정" -- Needs review
L["Set Move Quantity"] = "이동 수량 설정" -- Needs review
L["'%s' has a Warehousing operation of '%s' which no longer exists."] = "'%s' 그룹에 포함된 '%s' 작업은 더이상 존재하지 않습니다." -- Needs review
L["Simply hit empty bags, warehousing will remember what you had so that when you hit restore, it will grab all those items again. If you hit empty bags while your bags are empty it will overwrite the previous bag state, so you will not be able to use restore."] = "가방 비우기를 클릭하면, 창고 관리자는 가지고 있던 아이템들을 기억하고 있다가 가방 복구를 클릭할 때 이 아이템들을 모두 다시 가방으로 가져옵니다. 가방이 비어있는 상태에서 가방 비우기를 클릭하면 이전의 가방 상태를 덮어쓰기 때문에 가방 복원은 할 수 없습니다." -- Needs review
L["Slash Commands"] = "명령어" -- Needs review
L["There are no visible banks."] = "은행이 없습니다." -- Needs review
L["To create a Warehousing Operation"] = "창고 작업 생성" -- Needs review
L["To move a Group"] = "그룹 이동" -- Needs review
L["/tsm get/put X Y - X can be either an itemID, ItemLink (shift-click item) or partial text. Y is optionally the quantity you want to move."] = "/tsm get/put X Y - X는 아이템ID, 아이템 링크(Shift-Click 아이템) 또는 부분적인 아이템 이름일 수 있습니다. Y는 이동을 원하는 수량으로 선택사항입니다." -- Needs review
L["Warehousing operations contain settings for moving the items in a group. Type the name of the new operation into the box below and hit 'enter' to create a new Warehousing operation."] = "창고 작업은 아이템 그룹을 이동할 수 있는 설정을 가지고 있습니다. 아래 상자에 새 작업 이름을 입력하고 '엔터'를 치면 새 창고 작업이 생성됩니다." -- Needs review
L["Warehousing will ensure this number remain in your bags when moving items to the bank / guildbank."] = "은행 / 길드 은행으로 아이템을 이동시킬 때 이 수량만큼은 가방에 남겨둡니다." -- Needs review
L["Warehousing will ensure this number remain in your bank / guildbank when moving items to your bags."] = "가방으로 아이템을 이동시킬 때 이 수량만큼은 은행 / 길드 은행에 남겨둡니다." -- Needs review
L["Warehousing will move all of the items in this group."] = "창고 관리자는 이 그룹의 모든 아이템을 이동시킵니다." -- Needs review
L["Warehousing will move all of the items in this group keeping %d of each item back when bags > bank/gbank."] = "창고 관리자는 이 그룹의 모든 아이템을 이동시킵니다. 가방에서 은행/길드은행으로 이동 시 각각 %d개의 아이템을 유지합니다." -- Needs review
L["Warehousing will move all of the items in this group keeping %d of each item back when bags > bank/gbank, %d of each item back when bank/gbank > bags."] = "창고 관리자는 이 그룹의 모든 아이템을 이동시킵니다. 가방에서 은행/길드은행으로 이동 시 각각 %d개의 아이템을 유지하고, 은행/길드은행에서 가방으로 이동 시 각각 %d개의 아이템을 유지합니다." -- Needs review
L["Warehousing will move all of the items in this group keeping %d of each item back when bags > bank/gbank, %d of each item back when bank/gbank > bags. Restock will maintain %d items in your bags."] = "창고 관리자는 이 그룹의 모든 아이템을 이동시킵니다. 가방에서 은행/길드은행으로 이동 시 각각 %d개의 아이템을 유지하고, 은행/길드은행에서 가방으로 이동 시 각각 %d개의 아이템을 유지합니다. 재보충으로 %d개의 아이템을 가방에 유지합니다." -- Needs review
L["Warehousing will move all of the items in this group keeping %d of each item back when bags > bank/gbank. Restock will maintain %d items in your bags."] = "창고 관리자는 이 그룹의 모든 아이템을 이동시킵니다. 가방에서 은행/길드은행으로 이동 시 각각 %d개의 아이템을 유지합니다. 재보충으로 %d개의 아이템을 가방에 유지합니다." -- Needs review
L["Warehousing will move all of the items in this group keeping %d of each item back when bank/gbank > bags."] = "창고 관리자는 이 그룹의 모든 아이템을 이동시킵니다. 은행/길드은행에서 가방으로 이동 시 각각 %d개의 아이템을 유지합니다." -- Needs review
L["Warehousing will move all of the items in this group keeping %d of each item back when bank/gbank > bags. Restock will maintain %d items in your bags."] = "창고 관리자는 이 그룹의 모든 아이템을 이동시킵니다. 은행/길드은행에서 가방으로 이동 시 각각 %d개의 아이템을 유지합니다. 재보충으로 %d개의 아이템을 가방에 유지합니다." -- Needs review
L["Warehousing will move all of the items in this group. Restock will maintain %d items in your bags."] = "창고 관리자는 이 그룹의 모든 아이템을 이동시킵니다. 재보충으로 %d개의 아이템을 가방에 유지합니다." -- Needs review
L["Warehousing will move a max of %d of each item in this group."] = "창고 관리자는 이 그룹 아이템을 각각 최대 %d개씩 이동시킵니다." -- Needs review
L["Warehousing will move a max of %d of each item in this group keeping %d of each item back when bags > bank/gbank."] = "창고 관리자는 이 그룹 아이템을 각각 최대 %d개씩 이동시킵니다. 가방에서 은행/길드은행으로 이동 시 각각 %d개의 아이템을 유지합니다." -- Needs review
L["Warehousing will move a max of %d of each item in this group keeping %d of each item back when bags > bank/gbank, %d of each item back when bank/gbank > bags."] = "창고 관리자는 이 그룹 아이템을 각각 최대 %d개씩 이동시킵니다. 가방에서 은행/길드은행으로 이동 시 각각 %d개의 아이템을 유지하고, 은행/길드은행에서 가방으로 이동 시 각각 %d개의 아이템을 유지합니다." -- Needs review
L["Warehousing will move a max of %d of each item in this group keeping %d of each item back when bags > bank/gbank, %d of each item back when bank/gbank > bags. Restock will maintain %d items in your bags."] = "창고 관리자는 이 그룹 아이템을 각각 최대 %d개씩 이동시킵니다. 가방에서 은행/길드은행으로 이동 시 각각 %d개의 아이템을 유지하고, 은행/길드은행에서 가방으로 이동 시 각각 %d개의 아이템을 유지합니다. 재보충으로 %d개의 아이템을 가방에 유지합니다." -- Needs review
L["Warehousing will move a max of %d of each item in this group keeping %d of each item back when bags > bank/gbank. Restock will maintain %d items in your bags."] = "창고 관리자는 이 그룹 아이템을 각각 최대 %d개씩 이동시킵니다. 가방에서 은행/길드은행으로 이동 시 각각 %d개의 아이템을 유지합니다. 재보충으로 %d개의 아이템을 가방에 유지합니다." -- Needs review
L["Warehousing will move a max of %d of each item in this group keeping %d of each item back when bank/gbank > bags."] = "창고 관리자는 이 그룹 아이템을 각각 최대 %d개씩 이동시킵니다. 은행/길드은행에서 가방으로 이동 시 각각 %d개의 아이템을 유지합니다." -- Needs review
L["Warehousing will move a max of %d of each item in this group keeping %d of each item back when bank/gbank > bags. Restock will maintain %d items in your bags."] = "창고 관리자는 이 그룹 아이템을 각각 최대 %d개씩 이동시킵니다. 은행/길드은행에서 가방으로 이동 시 각각 %d개의 아이템을 유지합니다. 재보충으로 %d개의 아이템을 가방에 유지합니다." -- Needs review
L["Warehousing will move a max of %d of each item in this group. Restock will maintain %d items in your bags."] = "창고 관리자는 이 그룹 아이템을 각각 최대 %d개씩 이동시킵니다. 재보충으로 %d개의 아이템을 가방에 유지합니다." -- Needs review
L["Warehousing will move this number of each item"] = "각 아이템을 이 수량만큼 이동시킵니다." -- Needs review
L["Warehousing will restock your bags up to this number of items"] = "최대 이 수량만큼의 아이템을 가방에 재보충합니다." -- Needs review
L["Warehousing will try to get the right number of items, if there are not enough in the bank to fill out the order, it will grab all that there is."] = "창고 관리자는 정확한 수량의 아이템을 가져오려고 시도하지만, 만일 은행에 충분한 수량의 아이템이 존재하지 않는다면 은행 내의 나머지 아이템을 모두 가져옵니다." -- Needs review
L["You can toggle the Bank UI by typing the command "] = "명령어를 입력하여 은행 UI를 온/오프 시킬 수 있습니다. " -- Needs review
L["You can use the following slash commands to get items from or put items into your bank or guildbank."] = "다음 명령어를 이용해 아이템을 은행 또는 길드 은행에 넣거나 꺼내올 수 있습니다." -- Needs review
