--
-- 五一活动数据
--
local music_info              = require("game_config/music_info")
local recharge_reward_config  = require("game_config/duanwu_activity_diamond")
local ClsAlert   			  = require("ui/tools/alert")
local on_off_info 			  = require("game_config/on_off_info")

local ClsFestivalActivityData = class("festivalActivityData")

local REWARD_PROP_TYPE		  = 15
local HEART_PROP_ID 		  = 264 		 -- 记下神奇粽子的道具Id,从道具那里拿数量

local LIST_WAITING_DURATION   = 3.5			 -- 获取列表的时间间隔定义，避免重复使劲调用

local ACTIVITY_STATUS         = 			 -- 活动状态定义
{
	WAITING					  = -1,
	NOT_YET_STARTED 		  = 0, 
	ALREDAY_STARTED  		  = 1, 
	HAS_ENDED        		  = 2
}

local VIEW_UPDATE			  =				 -- 用于简化更新界面的调用操作, 对应ClsFestivalActivityData:updateView方法中使用
{-- 更新类型		 对应方法名
	REWARD_LIST    = "updateRareList",
	SEAHEART_NUM   = "updateSeaHeartNum",
	RECHARGE_INFO  = "updateRechargeInfo",
	DAILY_ACTIVITY = "updateDailyActivity",
	CLOSE_VIEW	   = "close"
}

function ClsFestivalActivityData:ctor()
	-- btn
	self["activity_btn"]		= nil		 -- 活动按钮
	-- data
	self["activity_status"]     = ACTIVITY_STATUS.WAITING
	self["sea_heart_num"]       = 0

	self["rare_reward_list"]	= {}

	self["recharge_info"]       = 
	{
		["dailypacks"]          = {0, 0, 0}, -- 已购买的每日礼包
		["had_reward"]          = 0,         -- 是否已经兑换过每日礼包的奖励
		["total_recharge"]      = 0, 	     -- 已累计充值总数
		["received_step"]       = 0,  	     -- 已经领取到哪个阶段了
	}

	self["daily_grade"]			= 0			 -- 日常活动积分

	self["daily_activity_info"] =            -- 日常活动信息，step阶段，times完成次数
	{
		[1] = { ["step"] = 1, ["schedule"] = 0, ["target"] = 0, ["type"] = 1},
		[2] = { ["step"] = 1, ["schedule"] = 0, ["target"] = 0, ["type"] = 2 },
		[3] = { ["step"] = 1, ["schedule"] = 0, ["target"] = 0, ["type"] = 3 },
		[4] = { ["step"] = 1, ["schedule"] = 0, ["target"] = 0, ["type"] = 4 },
	}
	-- 

	self["asking_rare_time"]    = nil
end

----------- 按钮开关相关 -----------------------
-- 先判断系统状态，系统打开了，判断活动状态，活动要是NOT_YET_STARTED or ALREDAY_STARTED 按钮打开
function ClsFestivalActivityData:getBtn51Status()
	if getGameData():getOnOffData():isOpen(on_off_info.MAYDAY_ACTIVITY.value) then

		if self.activity_status == ACTIVITY_STATUS.NOT_YET_STARTED 
			or self.activity_status == ACTIVITY_STATUS.ALREDAY_STARTED then
			return true
		else
			return false
		end

	else
		return false
	end
end

function ClsFestivalActivityData:removeBtn()
	local port_layer = getUIManager():get("ClsPortLayer")
    if not tolua.isnull(port_layer) then
        port_layer:removeBtn51()
    end
end
---------------------------------------------------
-- 提供给UI的getter --

-- 获取活动状态
function ClsFestivalActivityData:getActivityStatus()
	return self.activity_status or  ACTIVITY_STATUS.WAITING
end

function ClsFestivalActivityData:isAlredayStarted()
	if self.activity_status == ACTIVITY_STATUS.ALREDAY_STARTED then return true 
	else return false end
end
-- 获取海洋之心数量(获取道具数量，并且更新这里的数量)
function ClsFestivalActivityData:getSeaHeartNum()
	local prop_item = getGameData():getPropDataHandler():get_propItem_by_id(HEART_PROP_ID)
	if  prop_item then
		return prop_item.count
	end
	return 0
end
-- 获取每日礼包状态
function ClsFestivalActivityData:getDailyGiftStatus()
	local buy_gift = {false, false, false}
	for k, v in ipairs(self.recharge_info.dailypacks) do
		if v == 1 then buy_gift[1] = true end
		if v == 3 then buy_gift[2] = true end
		if v == 6 then buy_gift[3] = true end
	end
	return self.recharge_info.had_reward, buy_gift
end
-- 获取充值总数
function ClsFestivalActivityData:getTotalRecharge()
	return self.recharge_info.total_recharge
end
-- 获取充值总数到达的步骤
function ClsFestivalActivityData:getRechargeCurrentStep()
	local total_recharge = self.recharge_info.total_recharge 
	for k, config in ipairs(recharge_reward_config) do
		if total_recharge < config.top_ups_num then
			return k - 1
		end
	end
	return #recharge_reward_config
end
-- 获取已经领取的step
function ClsFestivalActivityData:getRechargeReceivedStep()
	return self.recharge_info.received_step
end
-- 获取日常活动信息
function ClsFestivalActivityData:getDailyActivityInfo()
	return self.daily_activity_info
end
-- 获取日常活动积分
function ClsFestivalActivityData:getDialyActivityGrade()
	return self.daily_grade
end
-- 获取稀有奖励获取玩家列表
function ClsFestivalActivityData:getRareRewardList()
	return self.rare_reward_list
end
----------------------一些特殊的接口-------------------------
function ClsFestivalActivityData:receiveHeart()   -- 获取到海洋之心之后（以任何方式兑换海洋之心之后，把这里的数量跟新的道具数量比较，弹框提示差值，然后更新界面）
	local receive_num = self:getSeaHeartNum() - self.sea_heart_num
	
	if receive_num >0 then
		ClsAlert:showCommonReward({
			[1] = {
				["id"] = HEART_PROP_ID,
				["amount"] = receive_num,
				["type"] = REWARD_PROP_TYPE,
			}
		})
	end

	self.sea_heart_num = self:getSeaHeartNum()
	self:updateView(VIEW_UPDATE.SEAHEART_NUM)
end
----------------- update ----------------------

-- 更新界面的一些东西(仅仅是为了把代码提出来，简化调用，工具方法)
function ClsFestivalActivityData:updateView(method_name, params)
	local view = getUIManager():get("ClsFestivalActivityMain")
	if view and not tolua.isnull(view) then
		view[method_name](view, params)
	end
end

-- 更新活动状态
function ClsFestivalActivityData:updateActivityStatus(status)
	self.activity_status = status
	self.sea_heart_num 	 = self:getSeaHeartNum()
	-- 游戏中收到关闭按钮？关闭界面，关掉按钮
	if status == ACTIVITY_STATUS.HAS_ENDED then
		self:removeBtn()
	end
end
-- 更新数目（getSeaHeartNum里已经设置了新的数目）
function ClsFestivalActivityData:updateHeartNum()
	self.sea_heart_num = self:getSeaHeartNum()
	self:updateView(VIEW_UPDATE.SEAHEART_NUM)
end

-- 更新稀有奖励获取玩家列表
function ClsFestivalActivityData:updateRareRewardList(list)
	self.rare_reward_list = list

	self:updateView(VIEW_UPDATE.REWARD_LIST)
end
-- 更新充值信息
function ClsFestivalActivityData:updateRechargeInfo(info)
	self.recharge_info = info
	
	self:updateView(VIEW_UPDATE.RECHARGE_INFO)
end
-- 更新每日礼包领取状态
function ClsFestivalActivityData:updateDailyGiftHadReward(had_reward)
	self.recharge_info.had_reward = had_reward

	self:updateView(VIEW_UPDATE.RECHARGE_INFO)
end
-- 更新累计充值已领取的阶段
function ClsFestivalActivityData:updateReceivedStep()
	self.recharge_info.received_step = self:getRechargeCurrentStep()

	self:updateView(VIEW_UPDATE.RECHARGE_INFO)
end
-- 更新日常活动信息
function ClsFestivalActivityData:updateDailyActivityInfo(grade, info)
	self.daily_grade = grade

	self.daily_activity_info = info

	self:updateView(VIEW_UPDATE.DAILY_ACTIVITY)
end
-- 更新日常任务的积分
function ClsFestivalActivityData:updateDailyActivityGrade(grade)
	self.daily_grade = grade

	self:updateView(VIEW_UPDATE.DAILY_ACTIVITY)
end
----------------

-- 接口调用 --
-- ask ....

function ClsFestivalActivityData:askOpenGoddessBox()
	GameUtil.callRpc("rpc_server_open_ocean_heart", {})
end

-- 获取每日礼包的信息
-- 获取充值送礼的信息
function ClsFestivalActivityData:askRechargeInfo()
	GameUtil.callRpc("rpc_server_goddess_recharge_info", {})
end

-- 获取日常活动的信息
function ClsFestivalActivityData:askDailyActivityInfo()
	GameUtil.callRpc("rpc_server_goddess_daily_activities_info", {})
end

-- 领取每日礼包的海洋之心
function ClsFestivalActivityData:askDailypacksReward()
	self.sea_heart_num = self:getSeaHeartNum()
	GameUtil.callRpc("rpc_server_goddess_dailypacks_reward", {})
end

-- 领取累计充值的海洋之心
function ClsFestivalActivityData:askAccumulatedRechargeReward()
	self.sea_heart_num = self:getSeaHeartNum()
	GameUtil.callRpc("rpc_server_goddess_accumulated_recharge_reward", {})
end

-- 活动积分兑换海洋之心
function ClsFestivalActivityData:askExchangeDailyActivityGrade()
	self.sea_heart_num = self:getSeaHeartNum()
	GameUtil.callRpc("rpc_server_goddess_box_exchange", {})
end

-- 获取稀有获取玩家列表
function ClsFestivalActivityData:askRareReardList()
	-- 没有call过，或者已经call了3.5s没反应，就call
	if ( not self.asking_rare_time ) or ( CCTime:getmillistimeofCocos2d() - self.asking_rare_time > LIST_WAITING_DURATION * 1000 ) then
		GameUtil.callRpc("rpc_server_goddess_box_list", {})
		self.asking_rare_time = CCTime:getmillistimeofCocos2d()
	end
end
--------------

return ClsFestivalActivityData
