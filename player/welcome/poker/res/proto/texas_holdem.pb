
�f
texas_holdem.protoTexasHoldEm"�
S2CGameConfig
game_id (
name (	
is_privated (

time_limit (

table_size (
ante (

sb (

bb (
is_auth	 (
start_bb
 (
rebuy (
addon (

founder_id (
	insurance (
	room_type (
blind_lv (
blind_increase_time (
ip_limit (
straddle (

allianceid (
club_ids (
	gps_limit ("�
S2CGameStatu
round_index (
banker_chair (
sb_chair (
bb_chair (

game_statu (
betting_round (
total_betted (
	side_pots (
board_cards	 (,

show_cards
 (2.TexasHoldEm.S2CDealCard
is_normal_skip ("�
S2CRoundResult
round_id (

end_reason (
board_cards (3
results (2".TexasHoldEm.S2CRoundResult.Result�
Result
chair_id (
win_chip (
bet_chip (

hand_cards (
best_combination (
	hand_type (
	side_pots (
bankrool (
rid	 ("~
S2CBetResult
round_id (
chair_id (
operate_type (
chip (
bankrool (
total_betted ("�
S2CBetBlinds.
blinds_list (2.TexasHoldEm.S2CBetResult-
hands (2.TexasHoldEm.S2CBetBlinds.Card
	side_pots ('
Card
chair_id (
cards ("�
S2CStartBet
round_id (
chair_id (
	time_left (
	call_chip (

raise_chip (
	can_check (
bankrool (
chip_betted (
	can_raise	 (
total_think_times
 (
think_times (
max_bet (
total_betted (
max_raise_chip ("�
UserInfo
rid (
chair_id (
name (	
statu (
gender (
face_url (	
	vip_level (
nationality (
round_betted	 (
total_betted
 (
bankrool (

hand_cards (
last_operate (
split_id ("f
S2CUpdatePlayerInfo
round_id ((
	user_list (2.TexasHoldEm.UserInfo
full_update ("�
S2CDealCard
round_id (0
cards (2!.TexasHoldEm.S2CDealCard.CardInfo3
insuinfo (2!.TexasHoldEm.S2CDealCard.InsuInfo+
CardInfo
chair_id (
cards (�
InsuInfo

insured_id (
insured_name (	
pot_id (
insured_val (
proceeds_val (
split_id (""
S2CSitResult

error_code ("i
S2CStandUpResult
chair_id (
rid (
chips_betted (

error_code (
rank ("5
S2CLeaveGameResult
rid (

error_code ("d
	S2CGameIP
room_id (
room_ip (	
	room_type (
	room_size (
club_id ("�
TopChart.
	top_chart (2.TexasHoldEm.TopChart.Field�
Field
rid (
name (	
face_url (	
total_buyin (
bankrool (
online (
	insurance (
enter_clubid (
enter_clubname	 (	
split_id (
settled ("s
S2CMilitarySuccesses(
	top_chart (2.TexasHoldEm.TopChart
	errorcode (
rid (
	insurance ("#
C2SMilitarySuccesses
rid ("�

S2CGameLog3
records (2".TexasHoldEm.S2CGameLog.GameRecord�

GameRecord
round_id (
	flod_list (
board (A
records (20.TexasHoldEm.S2CGameLog.GameRecord.GamblerRecord
	record_id (	
dealer (

sb (

bb (�
GamblerRecord
rid (
chair_id (
name (	
face_url (	
hands (
best_combination (
	hand_type (
chips_betted (
chips_wined	 (

fold_round
 (
	insurance (
split_id ("�
S2CBillingData
game_id (
	round_cnt (
max_pot (
total_buyin ((
	top_chart (2.TexasHoldEm.TopChart
	insurance (7
	game_info (2$.TexasHoldEm.S2CBillingData.GameInfo
club_id (
begined	 (
alliance_id
 (�
GameInfo
face_url (	
	nick_name (	
create_time (
	game_time (
blind (	
	entry_fee (
start_score (

blind_time (
split_id ("
S2CTimeLeft
seconds ("5
S2C_Emoticon
chair_id (
emoticon_id ("Y
S2C_RemainingChips
chair_id (
rids (
last_operate (
chips ("C
S2C_BuyinNotify
	left_time (
chair_id (
rid ("D
S2C_BuyinResponse
rid (
	operation (
club_id ("{
MilitaryDiagramField6
field (2'.TexasHoldEm.MilitaryDiagramField.Field+
Field
round_id (
earnings ("W
S2C_MilitaryDiagram
room_id (/
data (2!.TexasHoldEm.MilitaryDiagramField"
S2C_ShowCard
mark ("$
S2C_ServerConfig
srv_type ("�
S2C_RoleInfo
rid (
game_cnt (
hand_cnt (
VPIP (
VIPIW (
	last_talk (	
last_talk_secs ("f
S2C_MarkList2
	mark_list (2.TexasHoldEm.S2C_MarkList.field"
field
rid (
mark ("H
S2C_VoiceCall
rid (
url (	
seconds (
name (	"B
S2C_Interaction
caster (
target (
item_id ("�
S2C_InsuranceNotify
board (7
entries (2&.TexasHoldEm.S2C_InsuranceNotify.Entry�
InsuInfo
pool (
pot_idx (
outs (
putin (
insured_val (
history (
outs_chosen (
statu (
multi_winner	 (�
Entry
pid (
name (	
face_url (	
hands (
statu (
time (7
info (2).TexasHoldEm.S2C_InsuranceNotify.InsuInfo
split_id ("=
S2CGamblerProps

insu_addtm (
insu_addtm_tmp ("�
S2CInsuranceOperation
pid (
statu (
time (9
info (2+.TexasHoldEm.S2CInsuranceOperation.InsuInfoM
InsuInfo
pot_idx (
outs (
insured_val (
statu ("�
S2CBuyInsuThinkTime
pid (
name (	

error_code (
time (

insu_addtm (
insu_addtm_tmp (
split_id ("G
S2C_InsuranceResult
pid (
pot_idx (

error_code ("&
S2C_GamblerOption
	insurance ("�
S2C_BlindLevelUp
lvl (
ante (

sb (

bb (
time_elapsed (
ave_chip (
bi_time (
competitor_cnt (
rank	 (
event
 ("C
S2C_SNGWashout
rank (
	win_chips (
is_final ("%
S2C_StartCountDown
seconds ("7
S2C_SignResult
	game_type (

error_code ("�
RoomOwerInfo
	FigureUrl (	
Gender (
NickName (	
sign (	
MaxNoble (
WeChat (	
clubIds ("�
GamblerInfo
rid (
name (	
gender (
noble (

figure_url (	
sign (	
we_chat (	
clubs ("�
RoomBaseInfo
room_id (
	left_time (
	entry_fee (
service_fee (
start_bb (
gambler_cnt (

table_size (
ib_time (

buyin_auth	 (

is_private
 (
ip_limit ()
founder (2.TexasHoldEm.GamblerInfo
	room_name (	"T
S2C_OpenSignPanel
	game_type (,
	room_info (2.TexasHoldEm.RoomBaseInfo"�
NormalRoomInfo
room_id (
	left_time (
ante (

sb (

bb (

table_size (

time_limit (
is_privated (
is_auth	 (
straggle
 (
ip_limit (
	insurance (
	room_name (	)
founder (2.TexasHoldEm.GamblerInfo"�
S2C_RoomInfo
	game_type (

game_statu (
enter_id (+
sng_info (2.TexasHoldEm.RoomBaseInfo0
normal_info (2.TexasHoldEm.NormalRoomInfo"�
S2C_RoomSet
op_type (

error_code (
statu ("D
OpType
INSU	
BUYIN	
CLOSE	
PAUSE
TRUSTEESHIP"!
S2C_PauseStatu
seconds ("�
S2C_RankMark1
	rank_list (2.TexasHoldEm.S2C_RankMark.markP
mark
chair (
rank (
pid (
face_url (	
name (	"�
S2CGameInfo
board (/
hands (2 .TexasHoldEm.S2CGameInfo.CardSet+
	start_bet (2.TexasHoldEm.S2CStartBet0
bet_log (2.TexasHoldEm.S2CGameInfo.BetLog4
CardSet
pid (
chair (
cards (B
BetLog
pid (
chair (
optype (
chip ("4
S2CFavorites
round_id (

total_size ("L
S2CFavoriteResult
round_id (
	operation (

error_code ("=
S2CDoShowCard
pid (
chair_id (
cards ("4
S2CBuyinResponse
chair (
	left_time ("
C2S_BetRequest
chip ("B
C2S_SitRequest
chair_id (
f_lati (
f_long ("
	C2S_BuyIn
buyin ("j
C2S_GetLookersList
looker_type ("?
LOOKER_TYPE
LOOKER_TYPE_SITTING 
LOOKER_TYPE_LOOKERS"/
C2S_Interaction
item_id (
pid ("#
C2S_Emoticon
emoticon_id ("
C2S_ShowCard
mark ("
C2S_GetRoleInfo
rid ("�
C2S_MarkPlayer
rid (
mark ("�
COLORS

COLOR_NONE
COLOR_GREEN
COLOR_YELLOW
COLOR_BROWN
COLOR_ORANGE
COLOR_DARK_BLUE

COLOR_BLUE
COLOR_LIGHT_BLUE
	COLOR_MAX	"-
C2S_VoiceCall
url (	
seconds ("A
C2S_InsuranceBuy
pot_idx (
value (
cards ("r
C2S_InsuranceOp+
op (2.TexasHoldEm.C2S_InsuranceOp.OP2
OP
pot_idx (
outs (
putin ("�
C2S_RoomSet
	insurance (
insurance_switch (

buyin_auth (

close_room (

pause_game (
trusteeship ("�
C2SGetGameInfo
board (
hands (

op (
oplog (
	insurance (
	buyin_dlg (

game_statu ("0
C2SAddToFavorite

op (
round_id ("K
C2SChangeSkin
table_cloth (	
	card_back (	

card_front (	"/
C2S_PreOperation
type (
value ("/
S2C_PreOperation
type (
value ("!
C2S_QueryGameLog
index ("G
S2C_RabbitHunting

error_code (
seconds (
cards (" 
S2CEarlySettleRes
ret ("x
C2SRoomListReq
	dwReqType (
	strRoomid (
showNum (
	pageIndex (
rid (
room_id ("�
RoomInfo
room_id (
ower_id (
state (
name (	
pwd (	
mod (
playerState (
member_count (
	max_count	 (
pvp_ip
 (	
dwIsPrivate (
strBlind (	
ante (
	dwAllTime (
bIsAuth (
	dwStartBB (
dwStartTime (
bStartOnTime (
bReBuy (
bAddOn (,
	bowerInfo (2.TexasHoldEm.RoomOwerInfo
dwSurplusTime (
clubid (0
	dwMessage (2.TexasHoldEm.BuyingPlayerInfo
bInsure (
straddle (
bIp (
clubName (	

allianceid ("�
BuyingPlayerInfo
playerid (
NickName (	
	buyingNum (
room_id (
dwSurplusTime (
	dwEndTime (
club_id (
face_url (	
split_id	 (
settled
 ("�
S2CRoomList#
list (2.TexasHoldEm.RoomInfo
	errorcode (
showNum (
	starIndex (
	totalPage (
	dwReqType (
rid (
room_id (*�
	Protocols
S2C_BET_BLINDc
S2C_UPDATE_GAME_CONFIGd
S2C_UPDATE_GAME_STATUe
S2C_UPDATE_PLAYER_STATUf
S2C_START_BETg
S2C_BET_RESULTh
S2C_DEAL_CARDi
S2C_LOOKERS_LISTj
S2C_SIT_RESULTk
S2C_STANDUP_RESULTl
S2C_LEAVE_GAME_RESULTm
S2C_GAME_IPn
S2C_GAME_RESULTo
S2C_MILITARY_SUCCESSESp
S2C_GAME_LOGq
S2C_GAME_BILLING_DATAr
S2C_TIME_LEFTs
S2C_EMOTICONt
S2C_REMAINING_CHIPSu
S2C_BUYIN_NOTIFYv
S2C_DEAL_BUYIN_RESPONSEw
S2C_MILITARY_DIAGRAMx
S2C_SHOW_CARDy
S2C_SERVER_CONFIGz
S2C_ROLE_INFO{
S2C_MARK_LIST|
S2C_VOICE_CALL}
S2C_INTERACTION~
S2C_INSURANCE_NOTIFY
S2C_INSURNACE_RESULT�
S2C_GAMBLER_OPTION�
S2C_BLIND_LEVEL_UP�
S2C_START_COUNTDOWN�
S2C_SNG_WASHOUT�
S2C_SIGN_RESULT�
S2C_OPEN_SIGN_PANEL�
S2C_ROOM_INFO�
S2C_ROOM_SET�
S2C_PAUSE_STATU�
S2C_GAMBLER_PROPS�
S2C_INSURANCE_OP�
S2C_INSURANCE_THINK_TIME�
S2C_SNG_RANK_MARK�
S2C_GAME_INFO�
S2C_FAVORITES�
S2C_FAVORITES_RESULT�
S2C_DO_SHOW_CARD�
S2C_BUYIN_RESPONSE�
S2C_PREOPERATION�
S2C_RABBIT_HUNTING�
S2C_EARLY_SETTLE�
S2C_ROOM_LIST�

C2S_DO_BETx
C2S_FOLDy
C2S_GET_LOOKERS_LISTz
C2S_SIT_DOWN{
C2S_STAND_UP|
C2S_LEAVE_GAME}
C2S_MILITARY_SUCCESS~
C2S_GET_GAME_LOG
C2S_GET_TIME_LEFT�
C2S_VOICE_CALL�
C2S_BUY_THINK_TIME�
C2S_AUTO_BUYIN�
C2S_INTERACTION�
C2S_EMOTICON�

C2S_BUY_IN�
C2S_GET_MILITARY_DIAGRAM�
C2S_SHOW_CARD�
C2S_GET_ROLE_INFO�
C2S_MARK_PLAYER�
C2S_INSURANCE_BUY�
C2S_ROOM_SET�
C2S_SNG_GET_BLIND_LEVEL�
C2S_GET_ROOM_INFO�
C2S_INSURANCE_THINK_TIME�
C2S_INSURANCE_OP�
C2S_GET_GAME_INFO�
C2S_ADD_TO_FAVORITE�
C2S_CHANGE_SKIN�
C2S_PREOPERATION�
C2S_RABBIT_HUNTING�
C2S_EARLY_SETTLE�
C2S_ROOM_LIST�*�
BettingRound
BOUNTING_ROUND_NULL 
BOUNTING_ROUND_ANTE
BOUNTING_ROUND_PREFLOP
BOUNTING_ROUND_FLOP
BOUNTING_ROUND_TURN
BOUNTING_ROUND_RIVER*�
OperateType
BET 
CALL	
RAISE	
CHECK
FOLD
BET_BIG_BLIND
BET_SMALL_BLIND
BET_ANTE
OPERATE_TYPE_NONE


ALLIN_MARK��
OPERATION_MARK��*7
GamblerInsuStatu
WAITING 

BUYING

BOUGHT