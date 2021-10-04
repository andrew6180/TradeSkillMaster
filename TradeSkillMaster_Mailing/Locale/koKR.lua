-- ------------------------------------------------------------------------------ --
--                            TradeSkillMaster_Mailing                            --
--            http://www.curse.com/addons/wow/tradeskillmaster_mailing            --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- TradeSkillMaster_Mailing Locale - koKR
-- Please use the localization app on CurseForge to update this
-- http://wow.curseforge.com/addons/tradeskillmaster_mailing/localization/

local L = LibStub("AceLocale-3.0"):NewLocale("TradeSkillMaster_Mailing", "koKR")
if not L then return end

L[ [=[Automatically rechecks mail every 60 seconds when you have too much mail.

If you loot all mail with this enabled, it will wait and recheck then keep auto looting.]=] ] = "보유 한도를 초과해 메일을 받았을 때 60초 주기로 메일을 재검색합니다.\\n\\n이 기능이 활성화되어 있으면 60초 대기후 초과한 메일을 재검색해 자동으로 모두 받을 수 있습니다." -- Needs review
L["Auto Recheck Mail"] = "메일 자동 재검색"
L["BE SURE TO SPELL THE NAME CORRECTLY!"] = "이름의 철자가 맞는지 다시 한 번 확인하세요!" -- Needs review
L["Buy: %s (%d) | %s | %s"] = "구매: %s (%d) | %s | %s" -- Needs review
L["Cannot finish auto looting, inventory is full or too many unique items."] = "자동 메일 받기를 완료할 수 없습니다. 가방이 다 찼거나 고유아이템이 너무 많습니다."
L["Chat Message Options"] = "채팅 메시지 옵션" -- Needs review
L["Clear"] = "지우기" -- Needs review
L["Clears the item box."] = "이 아이템 상자을 지웁니다." -- Needs review
L["Click this button to send all disenchantable greens in your bags to the specified character."] = "이 버튼을 클릭하면 가방에 있는 모든 마력추출용 녹템을 지정된 캐릭터에게 발송합니다." -- Needs review
L["Click this button to send excess gold to the specified character."] = "이 버튼을 클릭하면 지정된 캐릭터에게 초과 골드를 발송합니다." -- Needs review
L["Click this button to send off the item to the specified character."] = "이 버튼을 클릭하면 지정된 캐릭터에게 아이템을 발송합니다." -- Needs review
L["COD Amount (per Item):"] = "대금 청구 금액 (개당)" -- Needs review
L["COD: %s | %s | %s | %s"] = "대금 청구: %s | %s | %s | %s" -- Needs review
L["Collected COD of %s from %s for %s."] = "대금 청구 : %s from %s for %s" -- Needs review
L["Collected expired auction of %s"] = "경매 만료 : %s" -- Needs review
L["Collected mail from %s with a subject of '%s'."] = "발신인 : %s, 제목 : '%s'의 우편 받음" -- Needs review
L["Collected purchase of %s (%d) for %s."] = "구매 : %s (%d) for %s" -- Needs review
L["Collected sale of %s (%d) for %s."] = "판매 :  %s (%d) for %s" -- Needs review
L["Collected %s and %s from %s."] = "회수 : %s와(과) %s을(를) %s로부터 받았습니다." -- Needs review
L["Collected %s from %s."] = "회수 : %s개를 %s로부터 받았습니다." -- Needs review
L["Collect Gold"] = "골드 수집" -- Needs review
L["Could not loot item from mail because your bags are full."] = "가방이 가득 차 있어서 우편함으로부터 아이템을 루팅할 수 없습니다." -- Needs review
L["Could not send mail due to not having free bag space available to split a stack of items."] = "묶음 아이템을 분할 할 수 있는 가방 공간이 부족하여 아이템을 발송하지 못했습니다." -- Needs review
L["Display Total Money Received"] = "받은 총 금액 표시" -- Needs review
L["Drag (or place) the item that you want to send into this editbox."] = "발송할 아이템을 이 상자 안으로 드래그하세요." -- Needs review
L["Enable Inbox Chat Messages"] = "받은 우편 메시지 표시" -- Needs review
L["Enable Sending Chat Messages"] = "보낸 우편 메시지 표시" -- Needs review
L["Enter name of the character disenchantable greens should be sent to."] = "마력추출용 녹템을 받을 캐릭터의 이름을 입력하세요." -- Needs review
L["Enter the desired COD amount (per item) to send this item with. Setting this to '0c' will result in no COD being set."] = "원하는 대금 청구 금액(개당)을 입력하세요. '0c'로 설정하면 대금 청구를 하지 않습니다." -- Needs review
L["Enter the name of the player you want to send excess gold to."] = "초과 골드를 보낼 플레이어의 이름을 입력하세요." -- Needs review
L["Enter the name of the player you want to send this item to."] = "아이템을 보낼 플레이어의 이름을 입력하세요." -- Needs review
L["Error creating operation. Operation with name '%s' already exists."] = "작업 생성 에러. 이름이 '%s'인 작업은 이미 존재합니다." -- Needs review
L["Expired: %s | %s"] = "만료: %s | %s" -- Needs review
L["General"] = "일반" -- Needs review
L["General Settings"] = "일반 설정" -- Needs review
L["Give the new operation a name. A descriptive name will help you find this operation later."] = "새 작업의 이름을 지정하세요. 설명이 포함된 이름은 나중에 이 작업을 찾는 데 도움이 됩니다." -- Needs review
L["If checked, a maxium quantity to send to the target can be set. Otherwise, Mailing will send as many as it can."] = "선택하면, 대상에게 발송할 최대 수량을 설정할 수 있습니다. 그렇지 않으면, 가능한 모든 수량을 발송합니다." -- Needs review
L["If checked, information on mails collected by TSM_Mailing will be printed out to chat."] = "선택하면, TSM 우편에 의해 수집된 우편에 대한 정보를 채팅창에 출력합니다." -- Needs review
L["If checked, information on mails sent by TSM_Mailing will be printed out to chat."] = "선택하면, TSM 우편에 의해 발송된 우편에 대한 정보를 채팅창에 출력합니다." -- Needs review
L["If checked, the Mailing tab of the mailbox will be the default tab."] = "선택하면, TSM 우편탭을 우편함의 기본 탭으로 지정합니다." -- Needs review
L["If checked, the 'Open All' button will leave any mail containing gold."] = "선택하면, '모두 열기'시에 골드가 첨부된 우편은 남겨둡니다." -- Needs review
L["If checked, the target's current inventory will be taken into account when determing how many to send. For example, if the max quantity is set to 10, and the target already has 3, Mailing will send at most 7 items."] = "선택하면, 발송할 수량을 결정할 때 수신자의 현재 인벤토리 수량이 고려됩니다. 예를 들면, 최대 수량이 10으로 설정되어있고 수신자가 이미 3개를 가지고 있다면 최대 7개의 아이템만 발송합니다." -- Needs review
L["If checked, the target's guild bank will be included in their inventory for the 'Restock Target to Max Quantity' option."] = "선택하면, '재보충 대상 최대 수량' 옵션에 대상의 길드 은행이 포함됩니다." -- Needs review
L["If checked, the total amount of gold received will be shown at the end of automatically collecting mail."] = "선택하면, 자동으로 받은 우편을 통해 수집된 총 골드 량을 표시합니다." -- Needs review
L["Inbox"] = "우편함" -- Needs review
L["Include Guild Bank in Restock"] = "재보충에 길드 은행 포함" -- Needs review
L["Item (Drag Into Box):"] = "아이템:" -- Needs review
L["Keep Quantity"] = "수량 유지" -- Needs review
L["Leave Gold with Open All"] = "모두 열기 시에 골드 남겨두기" -- Needs review
L["Limit (In Gold):"] = "한도 (골드):" -- Needs review
L["Mail Disenchantables:"] = "마력추출용 발송:" -- Needs review
L["Mailing all to %s."] = "모두 %s에게 발송합니다." -- Needs review
L["Mailing operations contain settings for easy mailing of items to other characters."] = "우편 작업은 다른 캐릭터에서 쉽게 아이템을 발송할 수 있도록 하는 설정을 가지고 있습니다." -- Needs review
L["Mailing up to %d to %s."] = "최대 %d개를 %s에게 발송합니다." -- Needs review
L["Mailing will keep this number of items in the current player's bags and not mail them to the target."] = "대상에게 우편을 발송하지 않고 현재 플레이어 가방 안의 아이템 개수를 유지합니다." -- Needs review
L["Mail Selected Groups"] = "선택된 그룹 메일 발송" -- Needs review
L["Mail Send Delay"] = "우편 발송 지연" -- Needs review
L["Make Mailing Default Mail Tab"] = "TSM 우편을 기본 탭으로 지정" -- Needs review
L["Maxium Quantity"] = "최대 수량" -- Needs review
L["Max Quantity:"] = "최대 수량:" -- Needs review
L["Multiple Items"] = "다중 아이템" -- Needs review
L["New Operation"] = "새 작업" -- Needs review
L["Next inbox update in %d seconds."] = "%d초 후 우편함이 업데이트됩니다." -- Needs review
L["No Item Specified"] = "지정된 아이템 없음" -- Needs review
L["No Quantity Specified"] = "지정된 수량 없음" -- Needs review
L["No Target Player"] = "대상 없음" -- Needs review
L["No Target Specified"] = "지정된 대상 없음" -- Needs review
L["Not sending any gold as you have less than the specified limit."] = "보유량이 지정된 제한보다 적으므로 골드를 발송하지 않습니다." -- Needs review
L["Not Target Specified"] = "지정된 대상 없음" -- Needs review
L["Open All"] = "모두 열기"
L["Operation Name"] = "작업 이름" -- Needs review
L["Operations"] = "작업" -- Needs review
L["Operation Settings"] = "작업 설정" -- Needs review
L["Options"] = "옵션" -- Needs review
L["Other"] = "기타" -- Needs review
L["Quick Send"] = "빠른 발송" -- Needs review
L["Relationships"] = "관계" -- Needs review
L["Reload UI"] = "UI 재시작" -- Needs review
L["Restart Delay (minutes)"] = "재시작 지연 (분)" -- Needs review
L["Restock Target to Max Quantity"] = "재보충 대상 최대 수량" -- Needs review
L["Sale: %s (%d) | %s | %s"] = "판매: %s (%d) | %s | %s" -- Needs review
L["Send Disenchantable Greens to %s"] = "마력추출용 녹템을 %s에게 발송" -- Needs review
L["Send Excess Gold to Banker:"] = "초과 골드를 창고 캐릭에게 보냄" -- Needs review
L["Send Excess Gold to %s"] = "초과 골드를 %s에게 발송" -- Needs review
L["Sending..."] = "발송 중..." -- Needs review
L["Send Items Individually"] = "아이템 개별 발송"
L["Sends each unique item in a seperate mail."] = "한 개의 메일에 여러 종류의 아이템을 첨부하지 않고, 아이템별로 별도의 메일로 발송합니다."
L["Send %sx%d to %s - No COD"] = "%sx%d개를 %s에게 발송 - 대금 청구 없음" -- Needs review
L["Send %sx%d to %s - %s per Item COD"] = "%sx%d개를 %s에게 발송 - 개당 %s 청구" -- Needs review
L["Sent all disenchantable greens to %s."] = "모든 마력추출용 녹템을 %s에게 보냈습니다." -- Needs review
L["Sent %s to %s."] = "%s개를 %s에게 보냈습니다." -- Needs review
L["Sent %s to %s with a COD of %s."] = "%s개를 %s에게 %s의 대금 청구 우편으로 보냈습니다." -- Needs review
L["Set Max Quantity"] = "최대 수량 설정" -- Needs review
L["Sets the maximum quantity of each unique item to send to the target at a time."] = "한번에 대상에게 보낼 수 있는 고유 아이템의 최대 수량을 설정합니다." -- Needs review
L["Shift-Click to automatically re-send after the amount of time specified in the TSM_Mailing options."] = "Shift-Click 하면 TSM 우편 옵션에서 지정한 시간이 지난 후 자동으로 재발송합니다." -- Needs review
L["Showing all %d mail."] = "모든 %d 우편 표시" -- Needs review
L["Showing %d of %d mail."] = "%d of %d 우편 표시" -- Needs review
L["Skipping operation '%s' because there is no target."] = "대상이 없으므로 '%s' 작업을 건너뜁니다." -- Needs review
L["%s to collect."] = "%s을(를) 회수하였습니다." -- Needs review
L["%s total gold collected!"] = "총 %s의 금화 획득!" -- Needs review
L["Target:"] = "대상:" -- Needs review
L["Target is Current Player"] = "대상은 현재 플레이어입니다." -- Needs review
L["Target Player"] = "대상 플레이어" -- Needs review
L["Target Player:"] = "대상 플레이어:" -- Needs review
L["The name of the player you want to mail items to."] = "아이템을 보낼 플레이어의 이름." -- Needs review
L["This is maximum amount of gold you want to keep on the current player. Any amount over this limit will be send to the specified character."] = "현재 플레이어가 보유할 최대 골드입니다. 이 한도를 초과하는 골드는 지정된 캐릭터에게 보냅니다." -- Needs review
L["This is the maximum number of the specified item to send when you click the button below."] = "아래의 버튼을 클릭하면 발송할 지정된 아이템의 최대 수량입니다." -- Needs review
L["This slider controls how long the mail sending code waits between consecutive mails. If this is set too low, you will run into internal mailbox errors."] = "여러 개의 메일을 연속해서 보낼 때 개별메일 발송 후 다음 메일을 보내기 전 대기하는 시간을 설정합니다. 만일 너무 짧은 시간으로 설정하면 에러가 발생할 수 있습니다." -- Needs review
L["This tab allows you to quickly send any quantity of an item to another character. You can also specify a COD to set on the mail (per item)."] = "이 탭에서는 다른 캐릭터에게 원하는 수량의 아이템을 빠르게 발송할 수 있습니다. 또한, 대금 청구 우편도 지정할 수 있습니다. (아이템별)" -- Needs review
L["TSM Groups"] = "TSM 그룹" -- Needs review
L["TSM_Mailing Excess Gold"] = "TSM 우편 초과 골드" -- Needs review
L["When you shift-click a send mail button, after the initial send, it will check for new items to send at this interval."] = "우편 발송 버튼을 Shift-Click 하면, 초기 발송 후 여기서 지정한 지연시간이 지난 후 발송할 새 아이템을 확인합니다." -- Needs review
