-- 0 - disable debug info, 1 - less debug info, 2 - verbose debug info
local ui_word = require("game_config/ui_word")

RES_FPS = 60  --美术资源制作帧率 

resCount={} --资源引用计算,当为0时候彻底释放
TEST_FONT = false
SKILL_DEBUG = false

TEST_FLG = false

IS_SYNC_SERVER_TIME = false

USE_LIGHT_MAPPING = true
local news=require("game_config/news")

rpc_print = print
cclog = print
if DEBUG and DEBUG <= 0 then
	table.print = function() end
	rpc_print = function() end
end

rpc_client_print_rpc_msg = function()
	rpc_print = print
end

DEBUG_FPS = false
DEBUG_NET=true    --网络模式
IS_BUGALERT_OPEN = true

--登录界面的登录模式
LOGIN_STEP_BIND = 1 			--新手完成，拉起登录，以绑定帐号的方式登录
LOGIN_STEP_CHECK_UUID = 2 			--常以请求uuid状态的方式登录
LOGIN_STEP_AUTH	= 3 				--发现已经绑定过拉起登录，以验证的方式登录
LOGIN_STEP_RELINK =  4 		--断线重连

RELIC_EVENT_HELP = 1
RELIC_EVENT_GO = 2
RELIC_EVENT_FIGHT = 3

--启动特权
BOOT_QQ = "qq_startup"
BOOT_WX = "wx_startup"
--商店页签Tab
GUILD_CONTRIBUTE_SHOP = 1
GUILD_GIFT = 2

IS_LEADER = 1
IS_TEAMATER = 2

---公用吊袋tag
SHOW_COMMON_REWARD_TAG = 1

--角色ID
TAB_ADVENTURE = 1
TAB_NAVY = 2
TAB_PIRATE = 3

SCENE_TPYE_ID = {
	EXPORT = 1,
	PORT = 2,
	COPY = 3,
	BATTLE = 1999,
}

POS_TYP = {
	CENTER = 1,
	BOTTOM = 2
}

GIFT_GET = 1
GIFT_GETTED = 2

--造船厂
TAB_BUILD = 1
TAB_STRENGTHEN = 2
TAB_REFINE = 3
TAB_EQUIP = 4
TAB_SHOP = 5

--小按钮的缩放比例  MyMenuItme({scale=SMALL_BUTTON_SCALE,..}
SMALL_BUTTON_SCALE=0.6

NORMAL_LOOT_TYPE = 1 --一般掠夺
TIME_LOOT_TYPE = 2 --时段掠夺

--提示弹框类型
TIP_WIN_LONG_BTN = 1
--掠夺提示类型
LOOT_TIME_PANEL = 1
LOOT_ATTACT_PANEL = 2

INITIATIVE_PK_TIP = 1 --主动切磋
PASSIVITY_PK_TIP = 2 --切磋被动
IS_VIRTUA_TEAM = false

--场景类型
SCENE_TYPE_START = 0 --登录
SCENE_TYPE_LOGIN = 1 --登录
SCENE_TYPE_PORT = 2 --港口
SCENE_TYPE_EXPLORE = 3 --探索
SCENE_TYPE_BATTLE = 4 --战斗
SCENE_TYPE_BATTLE_ACCOUNT = 5 --战斗结算
SCENE_TYPE_GUILD_EXPLORE = 6 --公会战探索
SCENE_TYPE_SELECT_ROLE = 7 --角色选择
SCENE_TYPE_FAR_ARENA = 8 -- 风云大赛
SCENE_TYPE_MISSION3D = 9 -- 3d任务场景

TRADE_COMPLETE_STATUS_NO_OPEN = 0--表示没有开启
TRADE_COMPLETE_STATUS_OPEN = 1 --表示开启了
SAILOR_STAR_SIX = 6 --S级

--掠夺提示类型
LOOT_TIME_TIP = 1
BE_LOOT_TIME_TIP = 2

--风云大赛状态
TEAM_ARENA_STATUS_NO = 0 --未开放
TEAM_ARENA_STATUS_JOIN = 1   --可以参加状态
TEAM_ARENA_STATUS_WAIT = 2   --结束参加，但没有正式开始
TEAM_ARENA_STATUS_MATCH = 3    --匹配状态，可以不管
TEAM_ARENA_STATUS_START = 4    --开始打的状态
TEAM_ARENA_STATUS_END = 5   --活动结束的状态

TEAM_INVITE_TYPE = {
	FREE = 1,
	INVITE = 2,
}

-- PORT_BATTLE_STATUS = {
-- 	CLOSE = 0,
-- 	APPLY = 1,
-- 	DONATE = 2,
-- 	READY = 3,
-- 	FIGHT = 4,
-- 	END = 5,
-- }

--掠夺提示类型
LEVEL_ENOUTH_VIEW = 1
LEVEL_NOT_ENOUGH_VIEW = 2
GO_BATTLE_TIP_VIEW = 3
WAITE_BATTLE_TIP_VIEW = 4
--掠夺消耗体力数
TAKE_POWER = 50

NO_PEOPLE_AREA = 10000
--竞技场提示类型
ARENA_STAGE_TIP = 1
ARENA_BOX_TIP = 2
ARENA_INTRODUCE_TIP = 3
--竞技场经验类型
ARENA_EXP_NOT_CHANGE = 0
ARENA_EXP_UP = 1
ARENA_EXP_DOWN = 2

--宝箱奖励
STATUS_CLOSE = 0
STATUS_GET = 1
STATUS_EMPTY = 2

--竞技场舵轮状态
STATUS_AVERAGE = 1 --匀速
STATUS_ADD_SPEED = 2 --加速
--竞技场结束类型
ARENA_WIN_END = 1
ARENA_FAIL_END = 2
--商会礼包状态信息
GUILD_GIFT_NOT_GIVE_OUT = 0 --未发放
GUILD_GIFT_GVIING_OUT = 1 --已发放
GUILD_GIFT_CLOSE = 2--已领完

GUILD_GIFT_GIVE = 1 --商会给你了
GUILD_GIFT_GRAB_INFO = 2 --查看抢夺信息

--用于表示打开任务面板的类型
TASK_STATUS = {
	-- 接受任务
	get = 1,
	-- 完成任务
	complete = 2,
	-- 完成悬赏任务
	complete_reward = 3
}

---自动悬赏总次数
MISSION_TASK_ALL_TIMES = 20 

--角色
ROLE_ID_1 = 1
ROLE_ID_2 = 2
ROLE_ID_3 = 3
ROLE_ID_4 = 4


---主角技能满级
ROLE_SKILL_FULL_LEVEL = 10

---首冲和累充总次数
RECHARGE_ALL_TIMES = 14

-- 活动状态
ACTIVITY_STATUS_CLOSE       = 0
ACTIVITY_STATUS_OPEN        = 1
ACTIVITY_STATUS_NO_ACTIVITY = 2
ACTIVITY_STATUS_END         = 3   --
ACTIVITY_STATUS_SOON 		= 4   ---- 即将开始

-- 活动类型
ACTIVITY_TYPE_DAILY = 1 -- 日常活动
ACTIVITY_TYPE_TIMED = 2 -- 限时活动

CHAT_PORT_COMMON = 0 --港口
CHAT_PORT_AREA = 1 --港口
CHAT_SEA_AREA = 2 --海域

--tab类型
KIND_CHAT = "chat_btn"
KIND_MISSION = "mission_btn"


---商会学习技能
GUILD_SKILL_STUDY = {
	["remote"] = 1,
	["melee"] = 1,
	["durable"] = 1,
	["defense"] = 1,
}


--聊天玩家按钮的状态
PLAYER_STATUS_NO = 0     --表示无状态
PLAYER_STATUS_PRIVATE = 1--表示私聊状态
PLAYER_STATUS_BLACK = 2  --表示黑名单

--聊天系统页签类型
INDEX_WORLD = 1
INDEX_NOW = 2
INDEX_GUILD = 3
INDEX_TEAM = 4
INDEX_PRIVATE = 5
INDEX_SYSTEM = 6
INDEX_PLAYER = 7

--聊天频道类型
KIND_WORLD = 1
KIND_GUILD = 2
KIND_PRIVATE = 3
KIND_SYSTEM = 4
KIND_TEAM = 5
KIND_NOW = 6
KIND_INVITE = 7

--聊天数据类型
DATA_WORLD = 1
DATA_GUILD = 2
DATA_PRIVATE = 3
DATA_SYSTEM = 4
DATA_TEAM = 5
DATA_NOW = 6
DATA_INVITE = 7
DATA_BLACK = 8

get_index_by_type = {
	[KIND_WORLD] = INDEX_WORLD,
	[KIND_GUILD] = INDEX_GUILD,
	[KIND_TEAM] = INDEX_TEAM,
	[KIND_SYSTEM] = INDEX_SYSTEM,
	[KIND_NOW] = INDEX_NOW
}

LIMITNUM = 50
MAX_REMAIN_LIMIT_TIME = 30

ZERO = 0
BTN = 1 --控件类型为按钮
TEXT = 2

--酒馆
HOTEL_RECRUIT = 1
HOTEL_REWARD = 2

TASK_CAN_ACCEPT_STATUS = 0
TASK_ACCEPTED_STATUS = 1
TASK_FINISH_STATUS = 2

--添加好友的提示
KIND_TIP_SEARCH_AND_RECOMMEND_NOT_RESULT = 0 --没有搜到结果而且推荐也没有
KIND_TIP_SEARCH_NOT_BUT_RECOMMEND_HAVE_RESULT = 1 --没有搜到结果但是推荐有
KIND_TIP_SEARCH_HAVE_RESULT = 2 --搜到了
KIND_TIP_NOT_RECOMMEND = 3 --没有推荐好友
KIND_TIP_HAVE_RECOMMEND = 4 --有推荐好友

--好友dataHandler类型
DATA_FRIEND = 1
DATA_APPLY = 2
DATA_SEARCH = 3
DATA_RECOMMEND = 4

--好友提示类
DELETE_FRIEND_TIP = 1
NOITCE_SEND_GIFT_TIP = 2

--拒绝申请参数
FRIEND_APPLY_UNREFUSE = 0
FRIEND_APPLY_REFUSE = 1

ROBOT_FRIEND_ID = 9999
FRIENT_MAX_NUM = 30 --好友上限
MAX_SEND_POWER = 10
MAX_ACCEPT_POWER = 10
ONLINE = -1
APPLY_FRIEND_STATUS = 1 --已经发出了申请

FRIEND_STATUS_ADD = 1  --添加好友
FRIEND_STATUS_SUB  = 2 --删除好友
PER_ASK_RECOMMEND_MORE_THAN = 5 --如果推荐好友足够的话，就会每次推荐5个过来

--从哪里来到此界面的
COME_FEET_UI = 1

FRIEND_BTN_STATUS_NULL = 0 --表示已赞或者已接收
FRIEND_BTN_STATUS_CAN_DIAN_ZAN = 1 --点赞
FRIEND_BTN_STATUS_CAN_ACCEPT_POWER = 2    --能够接收
FRIEND_BTN_STATUS_CAN_ACCEPT_WITH_SEND_POWER = 3 --接收并回赠

--页签类型
FRIEND_MYFRIEND = 1
FRIEND_ADDFRIEND = 2
FRIEND_WECHAT = 3
FRIEND_NEAR = 4
FRIEND_REPORT = 5

--子页签类型
TAB_RANK = 1
TAB_THANKS = 2

TAB_PLUNDER = 1
TAB_PLUNDERED = 2

--触摸优先级
TOUCH_PRIORITY_LOW = 0
TOUCH_PRIORITY_NORMAL = -128
TOUCH_PRIORITY_HIGHT = -129

TOUCH_PRIORITY_MORE_HIGHT = -130
TOUCH_PRIORITY_CRAZY = -200
TOUCH_PRIORITY_GOD = -300

--具体模块触摸优先级
TOUCH_PRIORITY_BTN = TOUCH_PRIORITY_NORMAL
TOUCH_PRIORITY_RPCWAIT = -10000
TOUCH_PRIORITY_SCENETOUCH = -299
TOUCH_PRIORITY_MISSION = -5000
TOUCH_PRIORITY_ALERT = -202
TOUCH_PRIORITY_COMMONREWARD = -130
TOUCH_PRIORITY_RPCTIPS = -10010

--聊天界面触摸控制
--左下角面板
TOUCH_PRIORITY_CHAT_PANEL_LAYER = -152--左下角面板layer触摸
TOUCH_PRIORITY_CHAT_PANEL_UI_LAYER = -153--ui_layer触摸
TOUCH_PRIORITY_LIST = -154--左下角面板list触摸
TOUCH_PRIORITY_MSG = -155--聊天信息触摸

--聊天主界面触摸设置
TOUCH_PRIORITY_CHAT_MAIN_BASE = -150--主界面触摸控制
TOUCH_PRIORITY_CHAT_MAIN_LAYER = -151--主界面中ui_layer触摸控制
TOUCH_PRIORITY_CHAT_MAIN_BOX = -152--主界面中editbox触摸控制
TOUCH_PRIORITY_CHAT_MAIN_LIST = -153--主界面中listView触摸控制
TOUCH_PRIORITY_CHAT_RECORD_BTN = -154--语音按钮触摸控制
TOUCH_PRIORITY_MSG_EXPAND = -155--主界面中扩展框界面触摸
TOUCH_PRIORITY_POP_BASE_LAYER = -156--弹框底层layer触摸
TOUCH_PRIORITY_POP_UI_LAYER = -157--弹框ui_layer触摸

------竞速副本与竞技副本的事件类型 start ----------------

SCENE_OBJECT_TYPE_PLAYER = 0 --玩家
SCENE_OBJECT_TYPE_ROCK = 1 --礁石
SCENE_OBJECT_TYPE_ICE = 2 --浮冰
SCENE_OBJECT_TYPE_BITE_BOAT = 3 --鲨鱼
SCENE_OBJECT_TYPE_MERMAID = 4 --美人鱼
SCENE_OBJECT_TYPE_BOX = 5 --宝箱
SCENE_OBJECT_TYPE_FLAT = 6 --酒桶
SCENE_OBJECT_TYPE_FOG = 12 --迷雾
SCENE_OBJECT_TYPE_SEA_ROCK = 13 --海底礁石
SCENE_OBJECT_TYPE_CORAL = 14 --海底珊瑚
SCENE_OBJECT_TYPE_SEA_DOWN_FISH = 15 --海底鱼群
SCENE_OBJECT_TYPE_SEA_SHARK = 16 --海底鲨鱼
SCENE_OBJECT_TYPE_WERCK = 17 --海底沉船
SCENE_OBJECT_TYPE_SEA_WRECK = 18 --沉船
SCENE_OBJECT_TYPE_MONSTER = 19 --海怪
SCENE_OBJECT_TYPE_CLOUD = 20 --云
SCENE_OBJECT_TYPE_WHALE = 21 --鲸鱼
SCENE_OBJECT_TYPE_SEAGULL = 22 --海鸥
SCENE_OBJECT_TYPE_TORNADO = 23 --龙卷风
SCENE_OBJECT_TYPE_XUANWO = 32 --漩涡
SCENE_OBJECT_TYPE_JUDIAN = 33 --据点
SCENE_OBJECT_TYPE_MELEE_WRECK = 34 --据点
SCENE_OBJECT_TYPE_WHIRLPOOL = 41 --商会战漩涡
-- SCENE_OBJECT_TYPE_PILLER = 46 --柱子
-- SCENE_OBJECT_TYPE_RUINS = 47 --废墟
SCENE_OBJECT_TYPE_HAISHEN = {--海神副本海神像
	42, 43, 44, 45, 46, 47, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68,69,70,71,72,73,
}
SCENE_OBJECT_SEAGOD_BOSS = { --海神副本NPC
	48, 49, 50, 51, 52, 53, 54, 55, 56, 57
}
SCENE_OBJECT_TYPE_SCULPTURE = 74 --雕像
SCENE_OBJECT_TYPE_BATTERY = 75 --炮台
SCENE_OBJECT_TYPE_WARSHIP = 76 --巨舰
SCENE_OBJECT_TYPE_SUPPLY = 77 --补给堆
SCENE_OBJECT_TYPE_MELEE_GOD = 78 --深渊祝福海神像
SCENE_OBJECT_TYPE_MELEE_BOSS = 79 --深渊boat船

-------副本的动作类型 ------------------------- 

SCENE_ACTION_FIGHT = 1 

-------副本的动作类型 ------------------------- 

--礼包的触摸优先级
TOUCH_PRIORIY_GUILD_GIFT = -15000

------竞速副本雨与竞技副本的事件类型 end ----------------
-----------dialoglayer触摸优先级-------------------------
TOUCH_PRIORITY_DIALOG_LAYER = -2000
TOUCH_PRIORITY_PRIZON_TOUCH = - 1500
-----------------------------------------------



typeCollection ={
	TYPE_FRIEND = 1,
	TYPE_SELF = 0,
	type=0,
}

ACHIEVE_QIHAI=2
ACHIEVE_OTHER=1

-- 战斗地图size
TILESIZE    = 256  --一个图块大小
TILE_WIDTH  = 10   -- 横10块
TILE_HEIGHT = 5    -- 高

HALF_OPACITY = 127
TOATL_OPACITY = 255

SAILOR_LEVEL_MAX=60
PLAYER_LEVEL_MAX=60

--------船只添加流光
BOAT_ADD_FLOW_COLOR = 3



--船只的状态值
BOAT_STATE_OWN=0
BOAT_STATE_BUILD=1
BOAT_STATE_BUILDING=2
BOAT_STATE_LOCK=3

GAME_SYSTEM_ID = 10000

portZorder = {
	BG=0,
	-- BGPhoto = 0,
	MAIN = 2,
	CHAT = 3,
	TASK = 4,
	ITEM = 5,
	DIALOG = 6,
}
--聊天组件层
CHAT_COMPONENT_ZORDER = 50
--数据处理结果
DATA_DEAL_RESULT_EXCE = 0  --出现异常
DATA_DEAL_RESULT_SUCC = 1  --成功

-- 全屏界面关闭按钮的位置
FULL_SCREEN_CLOSEBTN_POS = {x = 927, y = 497}
NOT_FULL_SCREEN_CLOSEBTN_POS={x=840,y=439}
ALERT_HORIZONAL_CLOSE_POS = {x = 398, y = 241}
ALERT_VERTICAL_CLOSE_POS = {x = 400, y = 242}

--性别
SEX_F = 0 --女
SEX_M = 1 --男

--港口状态
PORT_STATUS_HIDE = -1 --未开放
PORT_STATUS_ZHONGLI = 0 --中立
PORT_STATUS_ZHANLING = 1 --友好（占领）
PORT_STATUS_DIDUI = 2 --敌对

PORT_MAP_STATE = {
	TASK_OPEN = 1, -- 任务开启的港口
	NEAR = 2, --靠近过的港口
	HAS_ENTER = 3, --进入过的港口
	PRE_TASK = 4, --任务前置条件未完成
}

--港口势力归属状态
PORT_POWER_STATUS_NEUTRAL = 0 --中立
PORT_POWER_STATUS_HOSTILITY = 1 --敌对
PORT_POWER_STATUS_FRIENDLY = 2 --友善

--探索PVE
EX_PVE_TYPE_PORT = 0 --港口
EX_PVE_TYPE_STRONGHOLD = 1 --海上据点

EX_PVE_STATUS_LOCK = 1 --锁定
EX_PVE_STATUS_OPEN_LOCK = 2 --出现（锁住）
EX_PVE_STATUS_HIDE = 3 --消失
EX_PVE_STATUS_OPEN_ALL = 4 --出现（解锁）
EX_PVE_STATUS_COOL_DOWN = 5 --冷却中（现在只有海上据点有这个状态）

--乱斗状态
WAIT_STATUS = 0 --等待状态
PVE_STATUS = 1 --10minPVE状态
PVP_STATUS = 2 --20minPVP状态
MELEE_WRECK_STATUS = 3 --沉船状态

--商会战场景状态
GROUP_FIGHT_WAIT_STATUS = 0 --等待状态
GROUP_FIGHT_FIGHTING_STATUS = 1 --战斗状态
GROUP_FIGHT_END_STATUS = 2 --结束状态

--港口争夺战场景状态
PORT_BATTLE_WAIT_STATUS = 0 --等待状态
PORT_BATTLE_FIGHTING_STATUS = 1 --战斗状态
PORT_BATTLE_END_STATUS = 2 --结束状态

--港口争夺战真正活动时间
POPT_BATTLE_ACTITY_TIME = 1500

--商会战真正活动时间
GUILD_BATTLE_ACTITY_TIME = 1500

---精英战役全部完成
ELITE_BATTLE_ALL_COMPLATED_STATUS = 1

EX_PVE_PORT_RES = {
	[EX_PVE_STATUS_LOCK] = "ex_box",
	[EX_PVE_STATUS_OPEN_LOCK] = "ex_box",
	[EX_PVE_STATUS_HIDE] = "ex_box",
	[EX_PVE_STATUS_OPEN_ALL] = "ex_box",
}

EX_PVE_SH_RES = {
	[EX_PVE_STATUS_LOCK] = "bt_base_001",
	[EX_PVE_STATUS_OPEN_LOCK] = "bt_base_001",
	[EX_PVE_STATUS_HIDE] = "bt_base_001",
	[EX_PVE_STATUS_OPEN_ALL] = "bt_base_001",
	[EX_PVE_STATUS_COOL_DOWN] = "bt_base_001",
}

EXPLORE_OBJECT_TYPE = {
	TIME_PIRATE = "OBJ_TYPE_SEVEN_AREA",
	MINERAL_POINT = "SCENE_OBJ_TYPE_DEPOSIT",
	MINERAL_POINT_TYPE_ID = 300,
}

EXPLORE_TRANSFER_TYPE = {
	PORT = 1,
	RELIC = 2,
	WHIRLPOOL = 3,
	WORDLD_MISSION = 4,
}

TRANSFER_ITEM = {
	ID = 233,
	NEED_GOLD = 5,
}

--出海补给类型
SUPPLY_GO_NOW = 1
SUPPLY_GO_SAILING = 2
SUPPLY_ONE_KEY = 3
SUPPLY_GO_LOOT = 4

--出海导航类型
EXPLORE_NAV_TYPE_NONE = 0 --直接出海
EXPLORE_NAV_TYPE_PORT = 1 --港口
EXPLORE_NAV_TYPE_SH = 2 --海上据点
EXPLORE_NAV_TYPE_LOOT = 3 --掠夺
EXPLORE_NAV_TYPE_POS = 4 --某个位置
EXPLORE_NAV_TYPE_WHIRLPOOL = 5 --漩涡
EXPLORE_NAV_TYPE_RELIC = 6  --遗迹
EXPLORE_NAV_TYPE_OTHER = 7  --其它
EXPLORE_NAV_TYPE_PVE_PORT = 8  --港口(pve)
EXPLORE_NAV_TYPE_TIME_PIRATE = 9  --时段海盗
EXPLORE_NAV_TYPE_REWARD_PIRATE = 10 --悬赏海盗
-- EXPLORE_NAV_TYPE_MINERAL_POINT = 11 --海上矿产
EXPLORE_NAV_TYPE_SALVE_SHIP = 12   --悬赏打捞沉船
EXPLORE_NAV_TYPE_WORLD_MISSION = 13 -- 世界随机任务
EXPLORE_NAV_TYPE_CONVOY_MISSION = 14 -- 运镖任务

------------ 战斗相关----------
--攻击范围
R_NORMAL=    300--正常的距离
R_FIGHT_CLOSE= 160--近战半径
R_FIGHT_FAR_3= 200--远程半径
R_FIGHT_FAR_2= 260--远程半径
R_FIGHT_FAR_1= 300--远程半径

-- 行径AI
AI_FAR   = 3  --远程AI
AI_SPEED = 2  --速度AI
AI_NEAR  = 1  --近战AI
AI_NONE  = 0  --没有AI

PLAYER_TEAM_ID = 1 -- 我放teamId
ENEMY_TEAM_ID = 2 -- 敌方teamId

----------------------------------
--水手职业  技能  类型
KIND_EXPORE=1    --瞭望手  冒险家
KIND_SAILOR=2    --水手长  海军
KIND_GUN=3       --火炮手  雇佣军

JOB_TITLE = {
	[KIND_EXPORE] = T("冒险家"),    --瞭望手  冒险家
	[KIND_SAILOR] = T("海军"),      --水手长  海军
	[KIND_GUN] = T("雇佣军"),       --火炮手  雇佣军
}

JOB_RES = {
	[KIND_EXPORE] = "common_job_adventure.png",
	[KIND_SAILOR] = "common_job_navy.png",
	[KIND_GUN] = "common_job_pirate.png",
}

GOODS_MODE_NORMAL =0  --商品类型
GOODS_MODE_AREA =1    --区域商品
GOODS_MODE_PORT =2    --港口商品
GOODS_MODE_SELL_HOT =3--流行商品

STORE_NORMAL =1 --正常买卖
STORE_EMPTY =2 --缺货
STORE_LOCK =3  --未解锁

MISSION_STATUS_DOING = 1
MISSION_STATUS_COMPLETE = 2
MISSION_STATUS_COMPLETE_REWARD = 3

AREA_ACHIEVE_STAR_MAX=4  --海域成就星级 4


--水手觉醒
SAILOR_AWAKEN_TIMES = 30

SAILOR_STAR_EXP = {
	"d_exp",
	"d_exp",
	"c_exp",
	"b_exp",
	"a_exp",
	"s_exp",
	"legend_exp",
}

STAR_SPRITE = {
	[1] = "E",
	[2] = "D",
	[3] = "C",
	[4] = "B",
	[5] = "A",
	[6] = "S"
}

STAR_SPRITE_SMALL = {
	[1] = "e",
	[2] = "d",
	[3] = "c",
	[4] = "b",
	[5] = "a",
	[6] = "s"
}

SAILOR_UP_STAR_ITEM_PIC = {
	[82] = "common_item_keepsake_d.png",
	[83] = "common_item_keepsake_c.png",
	[84] = "common_item_keepsake_b.png",
	[85] = "common_item_keepsake_a.png",
	[86] = "common_item_keepsake_s.png",
}

STAR_SPRITE_RES = {
	[1] = {gray = "common_letter_e1.png", big = "common_letter_e2.png", small = "common_letter_e3.png"},
	[2] = {gray = "common_letter_d1.png", big = "common_letter_d2.png", small = "common_letter_d3.png"},
	[3] = {gray = "common_letter_c1.png", big = "common_letter_c2.png", small = "common_letter_c3.png"},
	[4] = {gray = "common_letter_b1.png", big = "common_letter_b2.png", small = "common_letter_b3.png"},
	[5] = {gray = "common_letter_a1.png", big = "common_letter_a2.png", small = "common_letter_a3.png"},
	[6] = {gray = "common_letter_s1.png", big = "common_letter_s2.png", small = "common_letter_s3.png"},
	[7] = {gray = "common_letter_ss.png", big = "common_letter_legend.png", small = "common_letter_legend.png"},
	[100] = {big = "common_letter_legend.png"}, --目前只有船舶用到100，即传说船
}

-- layer zOrder
ZORDER_INDEX_ONE = 1
ZORDER_INDEX_TWO = 2
ZORDER_INDEX_THREE = 3
ZORDER_SAILOR_EXP_UP = 4
ZORDER_INDEX_FIVE = 5
ZORDER_INDEX_EIGHT = 8
ZORDER_UI_LAYER = 10
ZORDER_INDEX_ELEVEN = 11
ZORDER_INDEX_TWENTY = 20
ZORDER_TRANSIT_VIEW = 50
ZORDER_DIALOG = 90
ZORDER_SKIP_LAYER = 99
ZORDER_PORT_LOADING = 100
ZORDER_DIALOG_LAYER = 101
ZORDER_MISSION = 120
ZORDER_ALERT = 500
ZORDER_BATTLE_PLOT = 999
ZORDER_ERROR_INFO = 88888
TOP_ZORDER = 999999
TOPEST_ZORDER = 99999999   --特效的渲染层
QSPEECH_LAYER_ZORDER = TOPEST_ZORDER + 1   --语音层

RATE_HEAD=106/204

-- main layer type
TYPE_LAYER_PORT = 4
TYPE_LAYER_SHOP = 5
TYPE_LAYER_BLACK = 18

-- port type
PORT_TYPE_MARKET = "market" --商业港口
PORT_TYPE_SHIP = "ship" --工业港口
PORT_TYPE_PUB = "pub" --文化港口

-- good type
GOOD_TYPE_COMMON = "common" --普通商品
GOOD_TYPE_AREA = "area" --海域商品
GOOD_TYPE_PORT = "port" --港口商品

-- port building type
BUILD_HOTEL = 1
BUILD_MARKET = 2
BUILD_SHIPYARD = 3
BUILD_TOWN = 4
BUILD_QUAY = 5
BUILD_ALL = 6
BUILD_FLEET_MAIN = 7
BUILD_GUILD= 8
BUILD_CAMP= 9

-- 悬赏任务类型
DAILY_MISSION_TYPE_SHOPPING = "shopping"

-- Angle about
FULL_ANGLE = 360
HALF_RIGHT_ANGLE = 45
RIGHT_ANGLE = 90
STRAIGHT_ANGLE = 180
ANTRIGHT_ANGLE = 270
NO_ANGLE = -999
QUADRANT_ONE = 1
QUADRANT_TWO = 2
QUADRANT_THR = 3
QUADRANT_FOR = 4

--[[#define POINT_CASH 1 #define POINT_GOLD 2#define POINT_TILI 3#define POINT_HONOUR 4]]

TYPE_INFOR_CASH=1 --银币
TYPE_INFOR_COLD=2  --金币
TYPE_INFOR_POWER=3  --体力
TYPE_INFOR_HONOUR=4  --荣誉
TYPE_INFOR_LEVEL=5  --等级
TYPE_INFOR_EXPERIENCE=6  --经验
TYPE_BATTLE_POWER = 7 --总战力
TYPE_INFOR_PIRATE = 8 --掠夺次数
-- TYPE_PROSPERITY = 21  --势力声望

-- 阵营
CAMP_TYPE_PIRATE = 3      -- 海盗阵营
CAMP_TYPE_NAVY = 4        -- 海军阵营
--[[#define TYPE_NULL 0 #define TYPE_OPEN 1  #define TYPE_LOCK 2 #define TYPE_UNLOCK 3]]
TYPE_NULL =0
TYPE_OPEN =1
TYPE_LOCK =2
TYPE_UNLOCK =3

--sailor state
STATUS_NULL= 0
STATUS_APPOINT =1 --船舱任命
STATUS_LEARN =2   --正在学习
STATUS_CAPTAIN =3 --舰长任命

-- Physic to pixel
PTM_RATIO = 32

-- Res name format
BATTLE_EFFECT_RES_NAME_FORMAT = "%s%i.png"
BATTLE_EFFECT_RES_NAME_FORMAT_JPG = "%s%i.jpg"

-- Sail check interval
SAIL_INTERVAL = 0.02
SAIL_CHECK_INTERVAL = 0.24


-- Label size
LABEL_SIZE_23 = 23

-- Battle time max.
BATTLE_TIME_MAX = 120

-- Separate sign character.
SEPARATE_SPACA = ' '
SEPARATE_COMMA = ','
SEPARATE_MIDLINE = '-'
SEPARATE_NIL = ""
SEPARATE_L = "L"
SEPARATE_R = "R"
SEPARATE_WRAP = "\n"

BOAT_FIREFAR_ATTRI = 1
BOAT_FIRECLOSE_ATTRI= 2
BOAT_SPEED_ATTRI = 3
BOAT_DURABLE_ATTRI = 4

STATUS_DOING = 1
STATUS_FINISHED = 2
STATUS_REWARDED = 3

MSG_BOAT_NAME_LONGGERTHAN_12 = T("名字长度超过12")
MSG_BOAT_NAME_SET_FAIL = T("更改名字失败")

FIGHT_TYPE_NPC = 0
FIGHT_TYPE_PLAYER = 1

SMOKE_TYPE_SMALL = 1
SMOKE_TYPE_BIG = 2

FIGHT_REPORT_KIND_ATTACK = 1
FIGHT_REPORT_KIND_DEFEND = 2

TAG_FRIEND_MY = 1
TAG_FRIEND_SEARCH = 2
TAG_FRIEND_APPLY = 3
TAG_WRITEMSG = 4
TAG_READMSG = 5
TAG_RANK_RECOMMEND = 6
TAG_RANK_GRADE = 7
TAG_RANK_MONEY = 8
TAG_RANK_POWER = 9
TAG_RANK_ARENA = 10
TAG_RANK_POPULARITY = 11
TAG_RANK_COLLECT = 12

--好友数量限制
FRIEND_TOTAL_LIMIT = 200
--探索 战斗点击特效
CLICK_EFFECT = "tx_2008"
UI_RES =
	{

		RES_COM_BLUEWIDE_BTN_1 = "#common_btn_blue1.png",
		RES_COM_BLUEWIDE_BTN_2 = "#common_btn_blue2.png",
		RES_COM_BLUEWIDE_BTN_3 = "#common_btn_blue1.png",
	}

DIRECTION_VERTICAL   = 1
DIRECTION_HORIZONTAL = 2
STATUS_UNACTIVE = -1 --未激活
STATUS_ACTIVE = 0 --激活
STATUS_ACTIVE_REWARD = 1 --领奖

--好友系统
TYPE_MYFRIEND = 1
TYPE_ADDFRIEND = 2
TYPE_FRAPPLY = 3

--投资分享
KIND_VEST_SAILOR = 1
KIND_VEST_GOODS = 2
VEST_GOODS_SHARE_CON = 5400 -- 商品分享需要达到的投资繁荣度
VEST_SAILOR_SHARE_CON = 2600 -- 水手分享需要达到的投资繁荣度

--装备类型，舰队强化界面用了，后面删了
KIND_EQUIP_FAR = 1 --远程
KIND_EQUIP_NEAR = 2 --近战
KIND_EQUIP_SPEED = 3 --船帆
KIND_EQUIP_ARMOR = 4 --甲板
KIND_EQUIP_CARGO = 5 --载货
KIND_EQUIP_EXPLORE_SUPPLY = 6 --探索补给
KIND_EQUIP_EXPLORE_SAILOR = 7 --探索水手
KIND_EQUIP_DEFENSE = 8 --防御

--船舶改造的宝物类型
KIND_TRANS_BAOWU_TYPE_FAR = "cannon" --火炮
KIND_TRANS_BAOWU_TYPE_FARFIRE = "longcannon" --长管炮 --没有用了
KIND_TRANS_BAOWU_TYPE_CLOSEFIRE = "shortcannon" --加农炮--没有用了
KIND_TRANS_BAOWU_TYPE_ARMOR = "deck" --船甲板
KIND_TRANS_BAOWU_TYPE_SAILOR_WEAPON = "weapon" --武器
KIND_TRANS_BAOWU_TYPE_SAILOR_ARMOR = "armor" --防具
KIND_TRANS_BAOWU_TYPE_SAILOR_BOOK = "book" --书籍
KIND_TRANS_BAOWU_TYPE_ANTIQUE = "antique" --古董
KIND_TRANS_BAOWU_TYPE_INSTRUMENT = "instrument" --工具
KIND_TRANS_BAOWU_TYPE_SAIL = "sail" --船帆
KIND_TRANS_BAOWU_TYPE_NEAR = "assault" --冲锋室
KIND_TRANS_BAOWU_TYPE_HEAD = "statue" --船首像

taskLayerOpened = false
--玩家名字长度限制
NAME_LEN_LIMIT = 10
--船舶名字长度限制
BOAT_NAME_LEN_LIMIT = 7
BATTLE_DATA = {
	WIN_OUR = 1,
	WIN_TAEGET = 2,
	FIGHT_TYPE_BATTLE = 1,
	FIGHT_TYPE_PLUNDER = 2,
	FIGHT_TYPE_REVENGE = 3,
	FIGHTER_TYPE_EXPLORE = 5,
	FIGHTER_TYPE_NPC = 0,
	FIGHTER_TYPE_PLAYER = 1,
	DEFAULT_START_TIME = 0,
	NO_STAR = 0,
	ONE_STAR = 1,
	TWO_STAR = 2,
	THREE_STAR = 3,
	DIST_NEAR = 0,
	DIST_MIDDLE = 200,
	DIST_FAR = 300,
}

--按钮特效类型
EFFECT_TYPE = {
	BUILDING = 1,
	LONG 	 = 2,
	SHORT 	 = 3,
	TRAPEZIFORM = 4,
	CIRCLE 	 = 5,
	QUAY	 = 6,
	FRIEND	 = 7,
	SAILOR	 = 8,
}

-- 战役状态
BATTLE_STATUS_WIN = 1
BATTLE_STATUS_LOSE = 2
BATTLE_STATUS_OPEN = 3
BATTLE_STATUS_UNOPEN = 4

-- 奖励类型
ITEM_INDEX_MATERIAL = 1				--材料
ITEM_INDEX_DARWING = 2				--图纸
ITEM_INDEX_EQUIP = 3				--装备
ITEM_INDEX_GOODS = 4				--物品
ITEM_INDEX_CASH = 5					--银币
ITEM_INDEX_EXP = 6					--经验
ITEM_INDEX_GOLD = 7					--金币
ITEM_INDEX_TILI = 8					--体力
ITEM_INDEX_HONOUR = 9				--荣誉
ITEM_INDEX_BAOWU = 10  				--宝物
ITEM_INDEX_ARENA = 11  				--竞技场点数
ITEM_INDEX_SAILOR = 12 				--水手
ITEM_INDEX_STATUS = 13  				--各种状态
ITEM_INDEX_KEEPSAKE = 14 				--信物
ITEM_INDEX_PROP = 15				--道具
ITEM_INDEX_NO = 17 				--
ITEM_INDEX_HOTEL_REWARD = 18 		--各种状态
ITEM_INDEX_CONTRIBUTE = 19  		--贡献
ITEM_INDEX_DONATE = 20   			--捐献
ITEM_INDEX_FOOD = 21 				--食物
ITEM_INDEX_TITLE = 22				--称号
ITEM_INDEX_BOAT = 23                --船舶
ITEM_INDEX_REPUTATION = 24          --阵营声望
ITEM_INDEX_GROUP_PRESTIGE = 25 -- 商会声望
ITEM_INDEX_GROUP_POINT = 26 --商会战积分
ITEM_INDEX_GROUP_BATTLE_SINGLE_POINT = 27 --公会战个人积分
ITEM_INDEX_GROUP_SUPPLY = 28 --商会战个人补给
ITEM_INDEX_RANDOM_SAILOR = 29 --随机水手
ITEM_INDEX_PROSPER = 30			--繁荣度 (todo:以后删)
ITEM_INDEX_GROUP_EXP = 32      ---商会经验
ITEM_INDEX_GIFT_BAG   = 33      --礼包
ITEM_INDEX_BOX = 34             ---宝箱
-- 船只朝向
SHIP_ROTA_UP = 1
SHIP_ROTA_UP_RIGHT = 2
SHIP_ROTA_RIGHT = 3
SHIP_ROTA_DOWN_RITHT = 4
SHIP_ROTA_DOWN = 5
SHIP_ROTA_DOWN_LEFT = 6
SHIP_ROTA_LEFT = 7
SHIP_ROTA_UP_LEFT = 8

-- 舰队朝向
FLEET_DIR_UP = 1
FlEET_DIR_UP_RIGHT = 2
FLEET_DIR_RIGHT = 3
FLEET_DIR_DOWN_RITHT = 4
FLEET_DIR_DOWN = 5
FLEET_DIR_DOWN_LEFT = 6
FLEET_DIR_LEFT = 7
FLEET_DIR_UP_LEFT = 8

BAG_PROP_TYPE_ASSEMB = 1--材料
BAG_PROP_TYPE_COMSUME = 2--道具
BAG_PROP_TYPE_SAILOR_BAOWU = 4
BAG_PROP_TYPE_BOAT_BAOWU = 5
BAG_PROP_TYPE_BAOWU = 6
BAG_PROP_TYPE_FLEET = 7
BAG_PROP_TYPE_ALL = 8

--背包页签类型
BACKPACK_TAB_ALWAYS = 1
BACKPACK_TAB_BOAT = 2
BACKPACK_TAB_EQUIP = 3
BACKPACK_TAB_OTHER = 4

--探索气泡的方向
DIRECTION_LEFT = 1
DIRECTION_RIGHT = 2
DIRECTION_UP = 3
DIRECTION_DOWN = 4


--道具细分类型（针对item_info表）
PROP_ITEM_BACKPACK_OTHER = 0 -- 其它
PROP_ITEM_BACKPACK_DRAWING = 1 -- 图纸
PROP_ITEM_BACKPACK_BOX = 2 -- 水手宝物盒子
PROP_ITEM_BACKPACK_ESSENCE = 3 -- 宝物精华
PROP_ITEM_BACKPACK_BOAT_BOX = 4 -- 船舶宝物盒子
PROP_ITEM_BACKPACK_SKIN = 5 -- 船舶宝物盒子

--针对item_info表中的use_item_type字段
ITEM_NORMAL_TYPE = 0 --普通类型
ITEM_USE_TYPE = 1  --图纸类型
ITEM_USE_BAOWU_BOX = 2  --宝物盒子

ITEM_USE_LIMIT_STATE = 1  --消耗物品是否限制个数，不能连续使用

ITEM_USE_TIPS = 1  ---消耗item弹出二次确认框
ITEM_USE_HOTSELL_TIPS = 2  ---消耗item弹出二次确认框，使用热销商品
-------------------------------------------------------------------------------------------------------------新战斗相关
FV_BOAT_KEY = "boat_key"
FV_TYPE = "boat_id"
FV_NAME = "boat_name"
FV_LV = "boat_lv"
FV_POWER = "power"
FV_BOAT_COLOR = "boat_color"

FV_FLEET_POS = "pos"
FV_ATT_NEAR = "melee"
FV_ATT_FAR = "remote"
FV_FAR_RANGE = "range"
FV_DEFENSE = "defense"
FV_SPEED = "speed"
FV_HP = "hp"
FV_HP_MAX = "durable"
FV_CRIT_RATE = "crits"
FV_DODGE = "dodge"

FV_HIT_RATE = "hit"
FV_RESIST_CRIT = "anti_crits"
FV_DAMAGE_INC = "damage_increase"
FV_DAMAGE_DEC = "damage_reduction"

FV_FIRE_RATE = "fire_rate"
FV_MINUS_CD = "minus_cd"

FV_MINE = "mine"
FV_ENEMY = "enemy"

FIGHT_SCALE = 100

FV_BOOL_TRUE = 1
FV_BOOL_FALSE = 0

DYNAMIC_REFRESH = 1
ASTAR_FIND_PATH = 2

FV_MOVE_DODGE = "dodge"
FV_MOVE_CRUISE = "cruise"
FV_MOVE_FOLLOW = "follow"
FV_MOVE_MOVETO = "move_to"
FV_MOVE_SERVER = "from_server"
FV_MOVE_FROM_LAND = "away_from_Land"
FV_MOVE_USER_ORDER = "user_order"

CHECK_DIST = 60
--------------------------------------------------------------------------------------------------------------新战斗相关

-- 技能类型
SKILL_AUTO = -1
SKILL_INITIATIVE = 1
SKILL_AURA = 2
SKILL_AURA_JUST_DISPLAY = 3

-- 场景状态形状
SKILL_SHAPE_CIRCLE = 1
SKILL_SHAPE_RECTANGLE = 2

preloadFile = function(file)
	local list = require(file)
	if type(list) == "table"  then
		for k, v in ipairs(list) do
			require(v)
		end
	end
end

topLayer = function()
	return display.newLayer()
end

setAnchPos = function(node,x,y,anX,anY) -- todo: 位置需调整，暂放此文件
	local posX , posY , aX , aY = x or 0 , y or 0 , anX or 0 , anY or 0
	node:setAnchorPoint(ccp(aX,aY))
	node:setPosition(ccp(posX,posY))
end

runFadeAction = function(target,formAlpha,toAlpha,delay,callBack)   --for greySprite
	target:setAlpha(formAlpha)

	local scheduler=CCDirector:sharedDirector():getScheduler()
	local timer =nil
	local count = math.floor((delay/0.05))+1
	local addAlpha = (toAlpha-formAlpha)/count

	timer = scheduler:scheduleScriptFunc(function(dt)
		formAlpha = formAlpha+addAlpha
		if tolua.isnull(target) then
			scheduler:unscheduleScriptEntry(timer)
			return
		end
		if not target.setAlpha then
			scheduler:unscheduleScriptEntry(timer)
			return
		end
		target:setAlpha(formAlpha)
		count = count-1
		if count == 0 then
			scheduler:unscheduleScriptEntry(timer)
			timer = nil

			if type(callBack) == "function" then
				callBack()
			end
		end
	end, 0.05, false)
	return timer
end

local split
split = function(str, pat)
	local t = {}
	local fpat = "(.-)" .. pat
	local last_end = 1
	local s, e, cap = str:find(fpat, 1)
	while s do
		if s ~= 1 or cap ~= "" then
			table.insert(t,cap)
		end
		last_end = e+1
		s, e, cap = str:find(fpat, last_end)
	end
	if last_end <= #str then
		cap = str:sub(last_end)
		table.insert(t, cap)
	end
	return t
end

checkNameTextValid = function(text)
	print("text =====", text)
	if regx.is_valid_name(text)then
		return true
	else
		local Alert = require("ui/tools/alert")
		Alert:warning({msg=news.SENSITIVE_NAME.msg})
		return false
	end
end

checkUserNameTextValid = function(text)
	if regx.is_valid_user_name(text) then
		return true
	else
		local Alert = require("ui/tools/alert")
		Alert:warning({msg=news.SENSITIVE_SET_NAME.msg})
		return false
	end
end

checkChatTextValid = function(text, not_tip)
	if regx.is_valid_chat_str(text)then
		return true
	else
		if not not_tip then
			local Alert = require("ui/tools/alert")
			Alert:warning({msg=news.SENSITIVE_CHAT_CONTENT.msg})
		end
		return false
	end
end

replaceValidText = function(text)
	return regx.replace_valid_chat_str(text)
end 

newQtzGraySprite = function(filename, x, y, alpha) --默认透明度0.4
	local sprite
	if not filename then
		sprite = QtzGraySprite:create()
	elseif string.byte(filename) == 35 then -- first char is #
		local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(string.sub(filename, 2))
		if not frame then
			echoError("QtzGraySprite new Sprite Frame - invalid frame, name %s", tostring(filename))
		end
		if frame then
			sprite = QtzGraySprite:createWithSpriteFrame(frame)
		end
	else
		sprite = QtzGraySprite:create(filename)
	end

	local x = x or 0
	local y = y or 0
	local alpha = alpha or 0.4

	if sprite then
		CCSpriteExtend.extend(sprite)
		sprite:setPosition(x, y)
		sprite:setAlpha(alpha)
	else
		echoError("display.newQtzGraySprite() - create sprite failure, filename %s", tostring(filename))
	end

	return sprite
end

local startNumberStringMap = {
	[1] = "E",
	[2] = "D",
	[3] = "C",
	[4] = "B",
	[5] = "A",
	[6] = "S",
}
starNumberToString = function(number)
	return startNumberStringMap[number]
end

local cNumberStringMap = {
	[1] = T("一"),
	[2] = T("二"),
	[3] = T("三"),
	[4] = T("四"),
	[5] = T("五"),
	[6] = T("六"),
	[7] = T("七"),
	[8] = T("八"),
	[9] = T("九"),
	[10] = T("十"),
}

numberToCNumber = function(number)
	return cNumberStringMap[number]
end

getSailLevel = function(sailor)
	--航海术级别=（航海士档次*3+航海士阶级）*航海士等级
	for k,v in pairs(sailor.skills) do
		if v.id == 1001 then
			--航海术最大等级
			sailor.maxSkill = v.level / sailor.level * 60
			return  v.level
		end
	end
	return 20
end

-- updateNearFriends = function(friends)
--     friends = '{"flag":0,"msg":{"1":{"gender":"男","nickName":"潘清伟","openId":"social12","pictureLarge":"http:\/\/q.qlogo.cn\/qqapp\/1104681464\/0F78733DF633A3A91EDB486F1908E88F\/100","pictureMiddle":"http:\/\/q.qlogo.cn\/qqapp\/1104681464\/0F78733DF633A3A91EDB486F1908E88F\/40","pictureSmall":"http:\/\/q.qlogo.cn\/qqapp\/1104681464\/0F78733DF633A3A91EDB486F1908E88F\/40","provice":"","city":"","country":"","distance":6,"gpsCity":"","isFriend":true,"lang":""},"2":{"gender":"男","nickName":"鱼缸","openId":"social13","pictureLarge":"http:\/\/q.qlogo.cn\/qqapp\/1104681464\/922156A3A81F0B6099254FA2FF3A341F\/100","pictureMiddle":"http:\/\/q.qlogo.cn\/qqapp\/1104681464\/922156A3A81F0B6099254FA2FF3A341F\/40","pictureSmall":"http:\/\/q.qlogo.cn\/qqapp\/1104681464\/922156A3A81F0B6099254FA2FF3A341F\/40","provice":"","city":"","country":"","distance":14,"gpsCity":"","isFriend":false,"lang":""},"3":{"gender":"男","nickName":"qtz10","openId":"social14","pictureLarge":"http:\/\/q.qlogo.cn\/qqapp\/1104681464\/29FDB5A5711CD42192A14A4A81E02016\/100","pictureMiddle":"http:\/\/q.qlogo.cn\/qqapp\/1104681464\/29FDB5A5711CD42192A14A4A81E02016\/40","pictureSmall":"http:\/\/q.qlogo.cn\/qqapp\/1104681464\/29FDB5A5711CD42192A14A4A81E02016\/40","provice":"","city":"","country":"","distance":34,"gpsCity":"","isFriend":false,"lang":""}}}'
--     print("-------先测试-----------------")
--     local data = json.decode(friends)
--     local friend_data_handle = getGameData():getFriendDataHandler()
--     friend_data_handle:setNeatFriends(data.msg)
-- end

fillLabelSize = function(show_spr, show_lab, offset_n, lab_is_child_b)
	offset_n = offset_n or 10
	local spr_width = show_spr:getContentSize().width
	local lab_width = show_lab:getContentSize().width
	local spr_anch = show_spr:getAnchorPoint()
	local lab_anch = show_lab:getAnchorPoint()
	local spr_scale_x = show_spr:getScaleX()
	local lab_scale_x = show_lab:getScaleX()
	local spr_pos_x = show_spr:getPosition()
	local lab_pos_x = show_lab:getPosition()
	if type(spr_pos_x) ~= "number" then
		spr_pos_x = spr_pos_x.x
	end
	if type(lab_pos_x) ~= "number" then
		lab_pos_x = lab_pos_x.x
	end
	local spr_left = spr_pos_x - spr_scale_x * spr_anch.x * spr_width + offset_n
	local spr_right = spr_pos_x + spr_scale_x * (1 - spr_anch.x) * spr_width - offset_n
	if lab_is_child_b then
		spr_left = -1 * spr_anch.x * spr_width + offset_n
		spr_right = (1 - spr_anch.x) * spr_width - offset_n
	end

	local lab_left = lab_pos_x - lab_anch.x * lab_width
	local lab_right = lab_pos_x + (1 - lab_anch.x) * lab_width
	if lab_is_child_b then
		lab_left = lab_pos_x - lab_anch.x * lab_width
		lab_right = lab_pos_x + (1 - lab_anch.x) * lab_width
	end

	local scale_left = 1
	if lab_left < spr_left then
		scale_left = (lab_pos_x - spr_left)/(lab_pos_x - lab_left)
	end
	local scale_right = 1
	if lab_right > spr_right then
		scale_right = (spr_right - lab_pos_x)/(lab_right - lab_pos_x)
	end
	local scale_n = math.min(scale_right, scale_left)
	if scale_n < lab_scale_x then
		--print("lab_is_child_b = ", tostring(lab_is_child_b), "scale_n = ", scale_n,", spr_width=", spr_width, ", lab_width=",lab_width," lab_pos_x=", lab_pos_x, " spr_left=", spr_left," spr_right=",spr_right, " lab_left=", lab_left, " lab_right=",lab_right)
		show_lab:setScaleX(scale_n)
	end
end

--用于自动适应到一个精灵的左右， target_spr：不动的那个， chang_spr:
adaptSpriteLeftOrRight = function(target_spr, change_spr, is_left_b, offset_n, change_spr_is_child_b)
	offset_n = offset_n or 0
	local target_width = target_spr:getContentSize().width
	local change_width = change_spr:getContentSize().width
	local target_scale_x = target_spr:getScaleX()
	local change_scale_x = change_spr:getScaleX()
	local target_pos_x, target_pos_y = target_spr:getPosition()
	local change_pos_x, change_pos_y = change_spr:getPosition()
	local target_anch_x = target_spr:getAnchorPoint().x
	local change_anch_x = change_spr:getAnchorPoint().x

	if type(target_pos_x) ~= "number" then
		target_pos_y = target_pos_x.y
		target_pos_x = target_pos_x.x
	end
	if type(change_pos_x) ~= "number" then
		change_pos_y = change_pos_x.y
		change_pos_x = change_pos_x.x
	end

	local chang_spr_x = nil
	if change_spr_is_child_b then
		if is_left_b then
			local target_left = -1 * target_width * target_anch_x
			local change_right = change_scale_x * change_width * (1 - change_anch_x) + change_pos_x
			chang_spr_x = change_pos_x + target_left - change_right - offset_n
		else
			local target_right = target_width * (1 - target_anch_x)
			local change_left = -1 * change_scale_x * change_width * change_anch_x + change_pos_x
			chang_spr_x = change_pos_x + target_right - change_left + offset_n
		end
	else
		if is_left_b then
			local target_left = -1 * target_width * target_scale_x * target_anch_x + target_pos_x
			local change_right = change_scale_x * change_width * (1 - change_anch_x) + change_pos_x
			chang_spr_x = change_pos_x + target_left - change_right - offset_n
		else
			local target_right = target_width * target_scale_x * (1 - target_anch_x) + target_pos_x
			local change_left = -1 * change_scale_x * change_width * change_anch_x + change_pos_x
			chang_spr_x = change_pos_x + target_right - change_left + offset_n
		end
	end
	change_spr:setPosition(ccp(chang_spr_x, change_pos_y))
end

local math_pow = math.pow
getNumBitValue = function(num, bit)
	local cut_num = math_pow(2, bit - 1)
	return Math.floor(num/cut_num)%2
end

GROUP_MEMBER_LEVEL_CHAIRMAN = 10    --会长
GROUP_MEMBER_LEVEL_VICE_CHAIRMAN = 9 -- 副会长
GROUP_MEMBER_LEVEL_DEACONRY = 5  -- 执事
GROUP_MEMBER_LEVEL_MEMBER = 1  -- 会员

returnProfessionStr = function(authority)
	local  str = ""
	local ui_word = require("game_config/ui_word")
	if authority == GROUP_MEMBER_LEVEL_CHAIRMAN then
		str = ui_word.STR_GUILD_GROUP_MEMBER_LEVEL_CHAIRMAN
	elseif authority == GROUP_MEMBER_LEVEL_VICE_CHAIRMAN then
		str = ui_word.STR_GUILD_GROUP_MEMBER_LEVEL_VICE_CHAIRMAN
	elseif authority == GROUP_MEMBER_LEVEL_DEACONRY then
		str = ui_word.STR_GUILD_GROUP_MEMBER_LEVEL_DEACONRY
	else
		str = ui_word.STR_GUILD_GROUP_MEMBER_LEVEL_MEMBER
	end

	return str
end

-- ITEM_INDEX_MATERIAL = 1             --材料
-- ITEM_INDEX_DARWING = 2              --图纸
-- ITEM_INDEX_EQUIP = 3                --装备
-- ITEM_INDEX_GOODS = 4                --物品
-- ITEM_INDEX_CASH = 5                 --银币
-- ITEM_INDEX_EXP = 6                  --经验
-- ITEM_INDEX_GOLD = 7                 --金币
-- ITEM_INDEX_TILI = 8                 --体力
-- ITEM_INDEX_HONOUR = 9               --荣誉
-- ITEM_INDEX_BAOWU = 10  --宝物
-- ITEM_INDEX_ARENA = 11  --竞技场点数
-- ITEM_INDEX_SAILOR = 12  --水手
-- ITEM_INDEX_NO = 13  --
-- ITEM_INDEX_KEEPSAKE = 14--信物
-- ITEM_INDEX_PROP = 15--道具
-- ITEM_INDEX_TITLE = 22 --称号
-- ITEM_INDEX_BOAT 23 --船舶
-- ITEM_INDEX_REPUTATION = 24是声望

--奖励显示优先级
REWARD_SHOW_PRIORITY = {
	[ITEM_INDEX_EXP] = 1,
	[ITEM_INDEX_REPUTATION] = 2,
	[ITEM_INDEX_CASH] = 3,
	[ITEM_INDEX_HONOUR] = 4,
	[ITEM_INDEX_GOLD] = 5,
	[ITEM_INDEX_MATERIAL] = 6,
	[ITEM_INDEX_PROP] = 7
}

--将资源名带"#"去掉
convertResources = function(str_res)
	if str_res == nil then
		return nil
	end
	return string.gsub(str_res, '#', '')
end

getCommonRewardIcon = function(rewardItem)
	local icoStr, amount, scale = nil, 0, 1
	local diTuStr = nil
	local name = ""
	local armature_res = nil
	local pic_local = false
	--兼容服务端发的奖励字段
	rewardItem.key = rewardItem.key or rewardItem.type
	rewardItem.value = rewardItem.value or rewardItem.amount
	local color = 1

	if rewardItem.key == ITEM_INDEX_MATERIAL then
		local equip_material = require("game_config/boat/equip_material_info")
		if equip_material[rewardItem.id] then
			icoStr = equip_material[rewardItem.id].res
			name = equip_material[rewardItem.id].name
			color = equip_material[rewardItem.id].level
			desc = equip_material[rewardItem.id].desc
		end
		amount = rewardItem.value
		scale = 0.5
	-- elseif rewardItem.key == ITEM_INDEX_DARWING then
	--     local config = require("game_config/equip/equip_drawing_info")
	--     if config and config[rewardItem.id] then
	--         iconStr = config[rewardItem.id].res
	--         name = config[rewardItem.id].name
	--     end
	elseif rewardItem.key == ITEM_INDEX_GOLD then
		icoStr = "#common_icon_diamond.png"
		amount = rewardItem.value
		name = ui_word.MAIN_GOLD
		scale = 0.6
		color = 3
	elseif rewardItem.key == ITEM_INDEX_TILI then
		icoStr = "#common_icon_power.png"
		amount = rewardItem.value
		name = ui_word.MAIN_POWER
		scale = 0.75
	elseif rewardItem.key == ITEM_INDEX_CASH then
		icoStr = "#common_icon_coin.png"
		amount = rewardItem.value
		name = ui_word.MAIN_CASH
		scale = 0.6
		color = 2
	elseif rewardItem.key == ITEM_INDEX_EXP then
		icoStr = "#common_icon_exp.png"
		name = ui_word.MAIN_EXP
		amount = rewardItem.value
		color = 2
	elseif rewardItem.key == ITEM_INDEX_HONOUR then
		icoStr = "#common_icon_honour.png"
		amount = rewardItem.value
		name = ui_word.MAIN_HONOUR
		color = 2
		local honour_item_id = 228
		local item_info = require("game_config/propItem/item_info")
		desc = item_info[honour_item_id].desc
	elseif rewardItem.key == ITEM_INDEX_PROP then
		local item_info = require("game_config/propItem/item_info")
		if item_info[rewardItem.id] then
			icoStr = item_info[rewardItem.id].res
			name = item_info[rewardItem.id].name
			color = item_info[rewardItem.id].quality
			desc = item_info[rewardItem.id].desc
			if item_info[rewardItem.id].shipyard_map ~= "" then
				diTuStr = item_info[rewardItem.id].shipyard_map
			end
		end
		amount = rewardItem.value
		-- if rewardItem.id == 50 then --星章特殊处理
		--     scale = 0.5
		-- else
			scale = 0.5
		-- end
	elseif rewardItem.key == ITEM_INDEX_STATUS then
		local config = require("game_config/status_info")
		local config_item = config[rewardItem.id]
		if (not config_item) and (rewardItem.memoJson) then
			local info = json.decode(rewardItem.memoJson)
			config_item = config[info[1]]
		end
		if config_item then
			icoStr = config_item.icon
			amount = rewardItem.value
			name = config_item.buff_name
			scale = 0.75
		end
	-- elseif rewardItem.key == ITEM_INDEX_KEEPSAKE then
	--     print("==========信物合并到道具表了", rewardItem.id)
	elseif rewardItem.key == ITEM_INDEX_HOTEL_REWARD then
		icoStr = "#keepsake_E.png"
		amount = rewardItem.value
		name = ui_word.HOTEL_THE_REWARD
		scale = 0.3
	elseif rewardItem.key == ITEM_INDEX_DONATE then
		icoStr = "#txt_common_icon_guild_contribution.png"
		name = ui_word.STR_GUILD_HORNOR_CONTRIBUTE
		amount = rewardItem.value
	elseif rewardItem.key == ITEM_INDEX_CONTRIBUTE then
		icoStr = "#txt_common_icon_guild_contribution.png"
		name = ui_word.STR_GUILD_INFO_CONTRIBUTION
		amount = rewardItem.value
		color = 2
	elseif rewardItem.key == ITEM_INDEX_FOOD then
		name = ui_word.REWARD_FOOD_TIPS
		amount = rewardItem.value
		icoStr = "#explore_food.png"
	elseif rewardItem.key == ITEM_INDEX_GOODS then
		local goodsInfo = require("game_config/port/goods_info")
		name = goodsInfo[rewardItem.id].name
		icoStr = goodsInfo[rewardItem.id].res
		amount = rewardItem.value
	elseif rewardItem.key ==  ITEM_INDEX_TITLE then
		local info_title = require("game_config/title/info_title")
		name = info_title[rewardItem.id].title
	elseif rewardItem.key == ITEM_INDEX_BOAT then
		local boat_info = require("game_config/boat/boat_info")
		local boat_id = tonumber(rewardItem.id)
		name = boat_info[boat_id].name
		amount = rewardItem.value
		icoStr = boat_info[boat_id].res
		scale = 0.6
	elseif rewardItem.key == ITEM_INDEX_PROSPER then
		amount = rewardItem.value
		icoStr = "#common_icon_prosper.png"
		name = ui_word.PORT_INVEST_PROSPER
	elseif rewardItem.key == ITEM_INDEX_SAILOR then
		local sailor_info = require("game_config/sailor/sailor_info")
		local sailor_id = tonumber(rewardItem.id)
		name = sailor_info[sailor_id].name
		amount = rewardItem.value
		icoStr = sailor_info[sailor_id].res

		color = sailor_info[sailor_id].star
		if sailor_info[sailor_id].star >= 5 then
			color = 5
		end
		scale = 0.2
		pic_local = true
	elseif rewardItem.key == ITEM_INDEX_GROUP_PRESTIGE then
		icoStr = "#common_icon_guild_prestige.png"
		amount = rewardItem.value
		name = ui_word.STR_GUILD_PRESTIGE
		scale = 1
	elseif rewardItem.key == ITEM_INDEX_REPUTATION then
		name = ui_word.EXPLORE_GOTO_LOOT_PRIVATE
		amount = rewardItem.value
		if rewardItem.id == 3 then
			icoStr = "#shipyard_camp_pirate.png"
		else
			icoStr = "#shipyard_camp_navy.png"
		end
	elseif rewardItem.key == ITEM_INDEX_GROUP_SUPPLY then
		name = ""
		amount = rewardItem.value
		icoStr = "#explore_food.png"
	elseif rewardItem.key == ITEM_INDEX_GROUP_BATTLE_SINGLE_POINT then
		icoStr = "#common_icon_guild_score.png"
		amount = rewardItem.value
		name = ""
		-- scale = 0.75
	elseif rewardItem.key == ITEM_INDEX_GROUP_EXP then
		icoStr = "#common_guild_exp.png"
		amount = rewardItem.value
		name = ui_word.STR_GUILD_EXP
		--scale = 0.75
	elseif rewardItem.key == ITEM_INDEX_GIFT_BAG then
		icoStr = "#common_item_gift.png"
		amount = rewardItem.value
		name = ui_word.GIFT_BAG
		--scale = 0.75
	elseif rewardItem.key == ITEM_INDEX_BOX then
		icoStr = "#common_icon_box.png"
		amount = rewardItem.value
		name = ui_word.GOLD_BOX
	end

	if rewardItem.key == ITEM_INDEX_BAOWU then
		local config = require("game_config/collect/baozang_info")
		local baow_info = config[rewardItem.id]
		if baow_info then
			icoStr = baow_info.res
			name = baow_info.name
			if baow_info.owner == "sailor" then
				if rewardItem.memoJson and rewardItem.memoJson ~= "" then--奖励有颜色
					local json_data = json.decode(rewardItem.memoJson)
					color = tonumber(json_data["color"])
				end 
			elseif baow_info.owner == "boat" then
				if baow_info.star then
					color = baow_info.star
				end
			end
		end
		amount = rewardItem.value
		scale = 0.5
	else
		if rewardItem.memoJson and rewardItem.memoJson ~= "" then--奖励有颜色
			local json_data = json.decode(rewardItem.memoJson)
			color = tonumber(json_data["color"])
		end
	end

	return icoStr, amount, scale, name, diTuStr, armature_res, color, desc, pic_local
end

--用于通用奖励的转数据
getCommonRewardData = function(reward)
	local rewardItem = {}
	rewardItem.key = ITEM_TYPE_MAP[reward.type]
	rewardItem.id = reward.id
	rewardItem.value = reward.cnt or reward.amount
	return rewardItem
end

--自动根据长度来缩放
autoScaleWithLength = function(spr, length_n)
	local size = nil
	spr:setScale(1)
	if spr.getSize then
		size = spr:getSize()
	else
		size = spr:getContentSize()
	end
	local scale_width = length_n/size.width
	local scale_height = length_n/size.height
	scale_width = math.min(scale_width, scale_height)
	spr:setScale(scale_width)
end
TYPE_SEA = "sea"
EFFECT_3D_PATH = "res/effects_3d/"
MODEL_3D_PATH = "res/model_3d/"
SHIP_3D_PATH = "res/ship_3d/"
SEA_3D_PATH = "res/sea_3d/"
FLOW_TEXTURE_PATH = "res/flowTex_3d"
ANI_3D_PATH = "res/ship_3d/skeleton/"
PARTICLE_3D_EXT = ".particlesystem"
MODELPARTICLE_EXT = ".modelparticles"
GPB_EXT = ".gpb"
ANIMATION_3D_EXT = ".animation"

MODEL_PATH = "res/3d/models/"
MATERIAL_PATH = "res/3d/materials/"
TEXTURE_PATH = "res/3d/textures/"
EFFECT_PATH = "res/3d/effects/"
ANIMATION_PATH = "res/3d/animation/"

DIANJI_YELLOW = "tx_dianji_yellow"

-- SHOP_TYPE_CASH = "silver" --银币
-- SHOP_TYPE_COLD = "gold"  --金币
-- SHOP_TYPE_POWER = "power"  --体力
-- SHOP_TYPE_HONOUR = "royal"  --荣誉
-- SHOP_TYPE_TIEM = "item"  --资材
-- SHOP_TYPE_LETTER = "letter"  --推荐信


ITEM_TYPE_LETTER = "letter"  --推荐信
ITEM_TYPE_MATERIAL = "material" --材料
ITEM_TYPE_DARWING = "darwing" --图纸（服务端也这样）
ITEM_TYPE_EQUIP = "equip" --装备
ITEM_TYPE_GOODS = "goods" --物品
ITEM_TYPE_CASH = "cash"   --银币
ITEM_TYPE_SILVER = "silver" --银币（重复，都有使用）
ITEM_TYPE_EXP = "exp" --经验
ITEM_TYPE_GOLD = "gold"  --金币
ITEM_TYPE_TILI = "tili"  --体力
ITEM_TYPE_POWER = "power"  --体力
ITEM_TYPE_HONOUR = "honour" --荣誉
ITEM_TYPE_ROYAL = "royal" --荣誉
ITEM_TYPE_BAOWU = "baowu" --宝物
ITEM_TYPE_ARENA = "arena_point"  --竞技场点数
ITEM_TYPE_SAILOR = "sailor" --水手
ITEM_TYPE_STATUS = "status"  --各种状态
ITEM_TYPE_KEEPSAKE = "keepsake"  --信物
ITEM_TYPE_TIEM = "item"  --资材
ITEM_TYPE_BAOWU_AMOUNT = "baowu_amount"
ITEM_TYPE_CONTRIBUTE = "contribute"  --贡献
ITEM_TYPE_PRESTIGE = "prestige"
ITEM_TYPE_FOOD = "food"  --食物
ITEM_TYPE_TITLE = "title"   --称号
ITEM_TYPE_BOAT = "boat"  --船舶
ITEM_TYPE_GROUP_PRESTIGE = "group_prestige"  --公会声望
ITEM_TYPE_RANDOM_SAILOR = "sailor_random"  --随机水手
ITEM_TYPE_GUILD_EXP = "group_exp"
ITEM_TYPE_VIP = "vip"
ITEM_TYPE_PROSPER = "prosper"

ITEM_TYPE_MAP = {
	[ITEM_TYPE_MATERIAL] = ITEM_INDEX_MATERIAL,
	[ITEM_TYPE_DARWING] = ITEM_INDEX_DARWING,
	[ITEM_TYPE_EQUIP] = ITEM_INDEX_EQUIP,
	[ITEM_TYPE_GOODS] = ITEM_INDEX_GOODS,
	[ITEM_TYPE_CASH] = ITEM_INDEX_CASH,
	[ITEM_TYPE_SILVER] = ITEM_INDEX_CASH,
	[ITEM_TYPE_EXP] = ITEM_INDEX_EXP,
	[ITEM_TYPE_GOLD] = ITEM_INDEX_GOLD,
	[ITEM_TYPE_TILI] = ITEM_INDEX_TILI,
	[ITEM_TYPE_POWER] = ITEM_INDEX_TILI,
	[ITEM_TYPE_HONOUR] = ITEM_INDEX_HONOUR,
	[ITEM_TYPE_ROYAL] = ITEM_INDEX_HONOUR,
	[ITEM_TYPE_BAOWU] = ITEM_INDEX_BAOWU,
	[ITEM_TYPE_ARENA] = ITEM_INDEX_ARENA,
	[ITEM_TYPE_SAILOR] = ITEM_INDEX_SAILOR,
	[ITEM_TYPE_STATUS] = ITEM_INDEX_NO,
	[ITEM_TYPE_KEEPSAKE] = ITEM_INDEX_KEEPSAKE,
	[ITEM_TYPE_TIEM] = ITEM_INDEX_PROP,
	[ITEM_TYPE_BAOWU_AMOUNT] = ITEM_INDEX_BAOWU_AMOUNT,
	[ITEM_TYPE_CONTRIBUTE] = ITEM_INDEX_CONTRIBUTE,
	[ITEM_TYPE_PRESTIGE] = ITEM_INDEX_DONATE,
	[ITEM_TYPE_FOOD] = ITEM_INDEX_FOOD,
	[ITEM_TYPE_TITLE] = ITEM_INDEX_TITLE,
	[ITEM_TYPE_BOAT] = ITEM_INDEX_BOAT,
	[ITEM_TYPE_GROUP_PRESTIGE] = ITEM_INDEX_GROUP_PRESTIGE,
	[ITEM_TYPE_GUILD_EXP] = ITEM_INDEX_GROUP_EXP,
	[ITEM_TYPE_PROSPER] = ITEM_INDEX_PROSPER
}


MAP_LAYER_NAMES = {
	bigPortLayer = "big",--大港口
	smallPortLayer = "small",--小港口
	strongHoldLayer = "stronghold",--海上据点
	relicPlaceLayer = "yiji", --遗迹
	relicDoneLayer = "yiji1", --遗迹
	whirlPoolLayer = "whirlpool", --漩涡
	mineralPlaceLayer = "mineral", --矿
	mineralDoneLayer = "mineral1", --矿
}

SAILOR_BATTLE_RELIC = 1  -- 遗迹进水手单挑
SAILOR_BATTLE_FIGHT = 2  -- 战斗进水手单挑

AREA_REWARD_NOT_COMPLETE = 0 	--海域奖励未达成
AREA_REWARD_COMPLETE = 1 		--海域奖励达成未领奖
AREA_REWARD_FINISH = 2 			--还与奖励已领取



FLEET_MAIN = "main"
FLEET_SUB = "sub"

EVNET_TAG_TRADE_MOVE = "trade_move"
EVNET_TAG_TRADE_ENTER_PORT = "trade_enter_port"

MAIN_MISSION = ui_word.MAIN_TASK

loadZhanyi = function(battleId, fightId, closeCallBack, isFromExplore)
	local battleData = getGameData():getBattleData()
	if not battleData:isEliteBattleOpen() then
		return
	end

	getUIManager():create("gameobj/battle/clsEliteBattle", {}, battleId, fightId, closeCallBack)
end

QUALITY_COLOR_STROKE = {
	[1] = COLOR_WHITE_STROKE,
	[2] = COLOR_GRASS_STROKE,
	[3] = COLOR_BLUE_STROKE,
	[4] = COLOR_PURPLE_STROKE,
	[5] = COLOR_YELLOW_STROKE,
	[6] = COLOR_ORANGE_STROKE,
	[7] = COLOR_ORANGE_STROKE,
	[8] = COLOR_ORANGE_STROKE,
}

QUALITY_COLOR_NORMAL = {
	[1] = COLOR_WHITE,
	[2] = COLOR_GRASS,
	[3] = COLOR_BLUE,
	[4] = COLOR_PURPLE,
	[5] = COLOR_YELLOW,
	[6] = COLOR_ORANGE,
	[7] = COLOR_ORANGE,
	[8] = COLOR_ORANGE,
}

RICHTEXT_COLOR_STROKE = {
	[1] = "$(c:COLOR_WHITE_STROKE)",
	[2] = "$(c:COLOR_GRASS_STROKE)",
	[3] = "$(c:COLOR_BLUE_STROKE)",
	[4] = "$(c:COLOR_PURPLE_STROKE)",
	[5] = "$(c:COLOR_YELLOW_STROKE)",
	[6] = "$(c:COLOR_ORANGE_STROKE)",
	[7] = "$(c:COLOR_ORANGE_STROKE)",
}

RICHTEXT_COLOR_NORMAL = {
	[1] = "$(c:COLOR_WHITE)",
	[2] = "$(c:COLOR_GRASS)",
	[3] = "$(c:COLOR_BLUE)",
	[4] = "$(c:COLOR_PURPLE)",
	[5] = "$(c:COLOR_YELLOW)",
	[6] = "$(c:COLOR_ORANGE)",
	[7] = "$(c:COLOR_ORANGE)",
}

ATTR_KEY_REMOTE = "remote" --远程攻击
ATTR_KEY_MELEE = "melee" --近战攻击
ATTR_KEY_DEFENSE = "defense" --防御
ATTR_KEY_DURABLE = "durable" --耐久
ATTR_KEY_HIT = "hit" --命中
ATTR_KEY_CRITS = "crits" --暴击
ATTR_KEY_ANTI_CRITS = "antiCrits" --抗暴击
ATTR_KEY_DODGE = "dodge" --闪避
ATTR_KEY_RANGE = "range" --射程
ATTR_KEY_SPEED = "speed" --速度
ATTR_KEY_DAMAGE_INCREASE = "damageIncrease" --伤害幅增
ATTR_KEY_DAMAGE_REDUCTION = "damageReduction" --伤害减免
ATTR_KEY_LOAD = "load" --载货容量

AUDIO_CHAT_FLAG = '$%(button:#chat_play_btn.png|'

ROLE_OCCUP_NAME ={
	[1] = ui_word.ROLE_OCCUP_1,
	[2] = ui_word.ROLE_OCCUP_2,
	[3] = ui_word.ROLE_OCCUP_3,
}


SAILOR_JOB_BG = {
	[1] = {["normal"] = "head_adventure_1.png", ["pressed"] = "head_adventure_2.png", ["battle"] = "head_adventure_3.png", ["mvp"] = "guild_mvp_adv.png"},
	[2] = {["normal"] = "head_navy_1.png", ["pressed"] = "head_navy_2.png", ["battle"] = "head_navy_3.png", ["mvp"] = "guild_mvp_navy.png"},
	[3] = {["normal"] = "head_pirate_1.png", ["pressed"] = "head_pirate_2.png", ["battle"] = "head_pirate_3.png", ["mvp"] = "guild_mvp_army.png"},
}

SAILOR_SKILL_BG = {
	[0] = "skill_bg_1.png",
	[1] = "skill_bg_2.png",
	[2] = "skill_bg_3.png",
	[3] = "skill_bg_4.png",
	[4] = "skill_bg_5.png",
}

TAG_TYPE = {
	CAN_BATTLE = {value = 5, text = ui_word.BACKPACK_ITEM_TAG_CAN_BATTLE, color = COLOR_WHITE_STROKE_GREEN},
	CAN_EQUIP = {value = 4, text = ui_word.BACKPACK_ITEM_TAG_CAN_EQUIP, color = COLOR_WHITE_STROKE_GREEN},
	CAN_REFINE = {value = 3, text = ui_word.BACKPACK_ITEM_TAG_CAN_REFINE, color = COLOR_WHITE_STROKE_PURPLE},
	CAN_DISMANTLE = {value = 2, text = ui_word.BACKPACK_ITEM_TAG_CAN_DISMANTLE, color = COLOR_WHITE_STROKE_GREY},
	CAN_SYNTHETISE = {value = 1, text = ui_word.BACKPACK_ITEM_TAG_CAN_SYNTHETISE, color = COLOR_WHITE_STROKE_ORANGE},
	CAN_USE = {value = 6, text = ui_word.BACKPACK_ITEM_TAG_CAN_USE, color = COLOR_WHITE_STROKE_GREEN},
}

if_else = function( exp, arg1, arg2 )
	if exp then return arg1 end
	return arg2
end

--跳转表
local jump_info = require("game_config/jump/jump_info")
for k, v in pairs(jump_info) do
	_G[k] = k
end

--事件表
--什么样的可以当成一个事件来处理，忘斟酌
local event_config = require("game_config/event/event_config")
local EVENT_NUM_BASE = 10000
for k, v in ipairs(event_config) do
	_G[v.id_str] = EVENT_NUM_BASE + k
end

compareTwoVersion = function(str1, str2)
	local tab1 = string.split(str1, ".")
	local tab2 = string.split(str2, ".")
	local len1 = #tab1
	local len2 = #tab2
	if len1 ~= len2 then 
		return len1 - len2
	end 
	
	local result = 0
	for i = 1, len1 do
		local v1 = tonumber(tab1[i])
		local v2 = tonumber(tab2[i])
		result = v1 - v2
		if result ~= 0 then 
			return result
		end 
	end 
	return result
end 

GUILD_SYSTEM_TAB = {
	GUILD_BOSS = 10,
	GUILD_TASK = 2,
	GUILD_STAR = 3,
	GUILD_STORE = 4,
	GUILD_RANK = 5,
	GUILD_APPLY_MANAGER = 6,
	GUILD_RESEARCH = 7,
}

GUILD_SYSTEM_GRADE = {
	[GUILD_SYSTEM_TAB.GUILD_BOSS] = 10,
	[GUILD_SYSTEM_TAB.GUILD_TASK] = 1,
	[GUILD_SYSTEM_TAB.GUILD_STAR] = 5,
	[GUILD_SYSTEM_TAB.GUILD_STORE] = 1,
	[GUILD_SYSTEM_TAB.GUILD_RANK] = 1,
	[GUILD_SYSTEM_TAB.GUILD_APPLY_MANAGER] = 20,
	[GUILD_SYSTEM_TAB.GUILD_RESEARCH] = 25,
}

OPEN_GUILD_RESEARCH_LEVEL = 25
OPEN_BLACK_STORE_LEVEL = 22

SAFE_TENCENT_IOS_WECHAT = 1
SAFE_TENCENT_ANDRIOD_WECHAT = 2
SAFE_TENCENT_IOS_QQ = 3
SAFE_TENCENT_ANDRIOD_QQ = 4
SAFE_TENCENT_IOS_GUEST = 5

--支付区域系数，支付给予的分区id是忧基本的加上这个系数值组装而成的
MIDAS_PAYMENT_GROW = 1000

PLATFORM_GUEST = 1
PLATFORM_QQ = 2
PLATFORM_WEIXIN = 3

LAUNCH_KIND_QQ = 1
LAUNCH_KIND_WECHAT = 2

SDK_PLATFORM_WEIXIN = 1
SDK_PLATFORM_QQ = 2
SDK_PLATFORM_IOS_GUEST = 5

CHANNEL_TENCENT_IOS = "tencent_ios"
CHANNEL_TENCENT = "tencent"

WAIT_LOGIN_TIMES = "wait_login_times"
WAIT_LOGIN_OS_TIME = "wait_login_os_time"
LOGIN_UUID_STATUS = "login_uuid_status"
LOGIN_AUTH_ROLE_INFO = "login_auth_role_info"
LOGIN_LAST_NOTICE_TIME = "login_last_notice_time"
CONNECT_FAIL_OS_TIME = "connect_fail_os_time"

STR_SERVER_NAME = "server_name"
STR_SERVER = "server"

AUTH_GUEST = "guest"
AUTH_TENCENT_QQ = "qq"
AUTH_TENCENT_WECHAT = "wechat"
AUTH_TENCENT_IOS_QQ = "qq_ios"
AUTH_TENCENT_IOS_WECHAT = "wechat_ios"
AUTH_TENCENT_IOS_GUEST = "tencent_guest"

LOGIN_TYPE_SELECT_ACCOUNT = "switch_user_login"

WAIT_LOGIN_DELAY = {10, 180, 300}
CONNECT_FAIL_DELAY_TIME = 300
PLAYER_NORMAL = 1--普通玩家
PLAYER_VIP = 2   --普通会员
PLAYER_SVIP = 3  --超级会员

SHARE_SCENE_SESSION = 0
SHARE_SCENE_ZONE = 1

SHARE_ACTION_SNS_JUMP_SHOWRANK = "WECHAT_SNS_JUMP_SHOWRANK"
SHARE_ACTION_SNS_JUMP_URL = "WECHAT_SNS_JUMP_URL"
SHARE_ACTION_SNS_JUMP_APP = "WECHAT_SNS_JUMP_APP"

SHARE_TAG_MSG_INVITE = "MSG_INVITE";     --邀请
--微信特有
SHARE_TAG_MSG_MOMENT_HIGH_SCORE = "MSG_SHARE_MOMENT_HIGH_SCORE"--分享本周最高到朋友圈
SHARE_TAG_MSG_MOMENT_BEST_SCORE = "MSG_SHARE_MOMENT_BEST_SCORE"--分享历史最高到朋友圈
SHARE_TAG_MSG_MOMENT_CROWN = "MSG_SHARE_MOMENT_CROWN"--分享金冠到朋友圈
SHARE_TAG_FRIEND_HIGH_SCORE = "MSG_SHARE_FRIEND_HIGH_SCORE"--分享本周最高给好友
SHARE_TAG_FRIEND_BEST_SCORE = "MSG_SHARE_FRIEND_BEST_SCORE"--分享历史最高给好友
SHARE_TAG_FRIEND_CROWN = "MSG_SHARE_FRIEND_CROWN"--分享金冠给好友
--QQ微信都有，但是大小写有差异
SHARE_TAG_FRIEND_EXCEED = "MSG_friend_exceed"--微信超越炫耀//QQ为"MSG_FRIEND_EXCEED" : 超越炫耀
SHARE_TAG_HEART_SEND = "MSG_heart_send"---微信送心//QQ为"MSG_HEART_SEND" : 送心
--QQ特有
SHARE_TAG_FRIEND_PVP = "MSG_SHARE_FRIEND_PVP"--送心

-- 角色技能 界面index
INITIATIVE_SKILL, ATTRIBUTE_SKILL = 1, 2
--商会研究所界面
GUILD_RESEARCH ,GUILD_STUDY = 1, 2

-- 红白名
NAME_STATE_WHITE = 0
NAME_STATE_RED = 1

-- 单人战斗
BATTLE_ONE_PLAYER = 0
-- 二人组队战斗
BATTLE_TWO_PLAYERS = 1
-- 三人组队战斗
BATTLE_MUL_PLAYERS = 2
--世界排行榜-商会类型
PRESTIGE_RANK_TYPE = 1 --声望总榜
WEALTH_RANK_TYPE = 2 --财富榜
PIRATE_RANK_TYPE = 3 --海盗榜
ADV_RANK_TYPE = 4 --冒险家声望榜
NAVY_RANK_TYPE = 5-- 海军声望榜
PIRP_RANK_TYPE = 6--雇佣军声望榜
GUILD_RANK_TYPE = 7 --商会榜
--收益找回状态
LOSE_FOUND_STATUS_UNOPEN = 1 --未开启
LOSE_FOUND_STATUS_ENABLE = 2 -- 可找回
LOSE_FOUND_STATUS_FOUND = 3 -- 已找回
--港口战活动状态
PORT_BATTLE_STATUS = {
	PRE_BATTLE_APPLY = 1,
	BUILD_DONATE = 2,
	START_WAR_1 = 3,
	START_WAR_2 = 4,
	FINISH_1 = 5,
	FINISH_2 = 0,
}