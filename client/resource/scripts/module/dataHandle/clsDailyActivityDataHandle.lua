--每日任务数据（包括每日竞赛，投资奖励）
-- Author: Ltian
-- Date: 2015-07-21 11:35:40
--

local error_info = require("game_config/error_info")
local on_off_info=require("game_config/on_off_info")
local scheduler = CCDirector:sharedDirector():getScheduler()

local ClsDailyActivityDataHandle = class("ClsDailActivityDataHandle")
function ClsDailyActivityDataHandle:ctor()
	self._isReward = false --是否有奖励标志
	self._reward_info = nil   --奖励列表
	self._status = -1  --活动状态
	self._type = 0  --活动类型
	self._rank_list = {} --积分排名
	self._is_show = false --
	self._reward_rank = 0
	self._invest_reward_status = -1 --投资奖励领奖状态
	self._cur_scheduler = nil
	self._open_time = 0  --投资奖励开始时间
	self._close_time = 0 --投资奖励结束时间
	self._node = nil
	self._point = 0      --拥有分数 
	self._need_point = 0  ----需要的分数 
	self._reward_step  = -1    ----奖励阶段


	---每周竞赛
	self.weekly_info = {} 

end
--------------------------------每日竞技--------------------------------------------
--获取当前任务的状态
function ClsDailyActivityDataHandle:askWeeklyRaceInfo()
	GameUtil.callRpc("rpc_server_week_competition_info", {})--, "rpc_client_week_competition_info"
end

--获取排名列表
function ClsDailyActivityDataHandle:askWeeklyRaceRankList()
	GameUtil.callRpc("rpc_server_week_competition_rank", {})--, "rpc_client_week_competition_rank"
end

---领取阶段奖励
function ClsDailyActivityDataHandle:askWeeklyRaceStepReward(step)
	GameUtil.callRpc("rpc_server_week_competition_reward", {step})
end

--获取领奖阶段按钮状态
-- function ClsDailyActivityDataHandle:askDailyActivityRewordInfo()
-- 	GameUtil.callRpc("rpc_server_dailyrace_step_reward_info", {})
-- end

function ClsDailyActivityDataHandle:setWeeklyData(data)
	self.weekly_info = data	
end
function ClsDailyActivityDataHandle:getWeeklyData()
	return self.weekly_info 	
end



function ClsDailyActivityDataHandle:getShow()
	return self._is_show
end

function ClsDailyActivityDataHandle:getNode()
	return self._node
end

--得到是否领奖
function ClsDailyActivityDataHandle:getIsReward()
	return self._isReward
end

--有奖励
function ClsDailyActivityDataHandle:hasReward()
	self._isReward = true
end

--获取奖励后重置
function ClsDailyActivityDataHandle:getReward()
	self._isReward = false
	self._reward_info = nil
end

--设置奖励信息
function ClsDailyActivityDataHandle:setRewardInfo(data)
	self._reward_info = data
	self:tryDispatchRewardRedPoint()
end

function ClsDailyActivityDataHandle:tryDispatchRewardRedPoint()
	local taskData = getGameData():getTaskData()
	local on_off_info = require("game_config/on_off_info")
	local is_open = false
	for k, v in ipairs(self._reward_info) do
		if v.statusId == 1 then
			is_open = true
			break
		end
	end
	
	taskData:setTask(on_off_info["ACTIVITY_SHOPMATCH"].value, is_open)
end

--获取奖励信息
function ClsDailyActivityDataHandle:getRewardInfo()
	return self._reward_info
end

--设置活动状态
function ClsDailyActivityDataHandle:setActivityStatus(status)
	self._status = status
end

--得到活动状态
function ClsDailyActivityDataHandle:getActivityStatus()
	return self._status
end

--设置活动类型
function ClsDailyActivityDataHandle:setActivityType(type)
	self._type = type
end

--设置活动剩余时间
function ClsDailyActivityDataHandle:setAcityityLeftTime(time)
	self._left_time = time
end

function ClsDailyActivityDataHandle:getAcityityLeftTime()
	return self._left_time or 3*24*60
end

--得到活动类型
function ClsDailyActivityDataHandle:getActivityType()
	return self._type
end

--得到积分排名列表
function ClsDailyActivityDataHandle:getRankList()
	return self._rank_list
end

--设置积分排名
function ClsDailyActivityDataHandle:setRankList(list)
	self._rank_list = list
end

---每周竞赛自己的排名
function ClsDailyActivityDataHandle:getMyRank(  )
	if #self._rank_list <= 0 then return 0	end
	local uid = getGameData():getPlayerData():getUid()

	local rank = 0
	for k,v in pairs(self._rank_list) do
		if v.uid == uid then
			rank = v.rank
		end
	end
	return rank
end

function ClsDailyActivityDataHandle:setRewardRank(reward_rank)
	self._reward_rank = reward_rank
end

function ClsDailyActivityDataHandle:getRewardRank()
	return self._reward_rank
end

--设置每日任务弹框
function ClsDailyActivityDataHandle:setAlertStatus()
	self._alert_status = true
end

function ClsDailyActivityDataHandle:getAlertStatus()
	if self._alert_status then
		 self._alert_status = false
		return true
	else
		return false
	end
end


--设置拥有分数
function ClsDailyActivityDataHandle:setHavePoint(point)
	self._point = point
end
--得到拥有分数
function ClsDailyActivityDataHandle:getHavePoint()
	return self._point 
end
----------------------------------------------
--设置需要分数
function ClsDailyActivityDataHandle:setNeedPoint(point)
	self._need_point = point
end
--得到需要分数
function ClsDailyActivityDataHandle:getNeedPoint()
	return self._need_point 
end

--设置领奖阶段
function ClsDailyActivityDataHandle:setRewardStep(step)
	 self._reward_step = step
end
----领奖阶段
function ClsDailyActivityDataHandle:getRewardStep()
	return self._reward_step
end

-------------------------------------投资奖励-------------------------------

function ClsDailyActivityDataHandle:getInvestRewardStatus()
	return self._invest_reward_status
end

function ClsDailyActivityDataHandle:setInvestRewardStatus(invest_rewrard_status)
	self._invest_reward_status = invest_rewrard_status
end

function ClsDailyActivityDataHandle:schedulerRedTaskCB()
	local curTime = os.time()
end

function ClsDailyActivityDataHandle:setOpenTime(time)
	local cur_time = os.time()
	self._open_time = cur_time + time
end

function ClsDailyActivityDataHandle:getOpenTime()
	return self._open_time
end

function ClsDailyActivityDataHandle:setCloseTime(time)
	local cur_time = os.time()
	self._close_time = cur_time + time
end

function ClsDailyActivityDataHandle:getCloseTime()
	return self._close_time
end

--设置传奇活动类型
function ClsDailyActivityDataHandle:setLegendActivityInfo(type, id, time)
	self.legend_activity_type = type
	self.legend_id = id
	self.legend_time = time + 1
end

--得到传奇活动类型
function ClsDailyActivityDataHandle:getLegendActivityInfo()
	local info = {
		type = self.legend_activity_type,
		id = self.legend_id,
		time = self.legend_time,
	}
	return info
end

function ClsDailyActivityDataHandle:setLegendTime(time)
	self.legend_time = time
end

--设置传奇活动奖励数据列表
function ClsDailyActivityDataHandle:setLegendActivityRewardList(type, list)
	self.legend_activity_type = type
	self.legend_reward_list = list
end

function ClsDailyActivityDataHandle:getLegendRewardList()
	return self.legend_reward_list
end

function ClsDailyActivityDataHandle:askForLegendData()
	-- GameUtil.callRpc("rpc_server_mjms_huodong_info", {}, "rpc_client_mjms_huodong_info")
end

--请求名舰名仕活动奖励信息列表
function ClsDailyActivityDataHandle:askForLegendReward()
	GameUtil.callRpc("rpc_server_mjms_huodong_reward_list", {}, "rpc_client_mjms_huodong_reward_list")
end

--请求领取名舰名仕活动奖励
function ClsDailyActivityDataHandle:askGetLegendReward(reward_id)
	GameUtil.callRpc("rpc_server_mjms_huodong_reward_take", {reward_id}, "rpc_client_mjms_huodong_reward_take")
end

------------------------------------------ 协议请求 -------------------------------

--领取奖励
function ClsDailyActivityDataHandle:receiveReward()
	GameUtil.callRpc("rpc_server_time_limit_get_reward", {}, "rpc_client_time_limit_get_reward")
end

------------------------------------------------------------------------------------

return ClsDailyActivityDataHandle

