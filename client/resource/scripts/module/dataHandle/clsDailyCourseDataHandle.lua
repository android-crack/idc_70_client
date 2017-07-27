--
-- Author: Ltian
-- Date: 2015-07-01 13:26:48
--

local syllabus_mission = require("game_config/daily_activity/syllabus_mission")
local on_off_info=require("game_config/on_off_info")
local ClsDailyCourseDataHandle = class("ClsDailyCourseDataHandle")

local LOCK_STATE = 0
local UNFINISH_STATE = 1
local FINISH_STATE = 2
local COURSE_MISSION_ID = 1     --课程表
local HOTEL_MISSION_ID = 2      --招募
local BOAT_UP_MISSION_ID = 3    --装备升级
local BATTLE_MISSION_ID = 4     ---战役
local JJC_MISSION_ID = 5        ---竞技场
local MARKE_MISSION_ID = 6      ---交易所
local TREAT_MISSION_ID = 7      ---悬赏
local PLUNDER_MISSION_ID = 8    ---掠夺
local GONGHUI_MISSION_ID = 11   ---公会
local TOWN_MISSION_ID = 13      ---港口投资

function ClsDailyCourseDataHandle:ctor()
	self._no_reward_list = nil --为领奖的
	self._activity_course_list = {}
	self._race_course_list = {}
	self._liveness = 0
	self.reward = {}
	self._type = 0   ---活动类型
	self.mission_reward = {}  ---任务阶段奖励
	self._liveness_level = {} --领奖阶段
end

-- 请求每日目标数据
function ClsDailyCourseDataHandle:requestDailyTarget()
	GameUtil.callRpc("rpc_server_dailytarget_mission_list", {}, "rpc_client_dailytarget_mission_list")
end

-- 请求每日活跃度数据
function ClsDailyCourseDataHandle:requestDailyLiveness()
	GameUtil.callRpc("rpc_server_dailytarget_liveness_info", {}, "rpc_client_dailytarget_liveness_info")
end

-- 请求活动类型? 应该指某一活动的吧
function ClsDailyCourseDataHandle:requestDailyActivityType()
	GameUtil.callRpc("rpc_server_get_dailyrace_id", {})
end

-- 请求领取每日活跃奖励
function ClsDailyCourseDataHandle:askReward(bid)
	GameUtil.callRpc("rpc_server_get_dailytarget_liveness_reward", {bid+1}, "rpc_client_get_dailytarget_liveness_reward")
end

-- 是否开放该功能
function ClsDailyCourseDataHandle:isOpen(mission_id)
	local onOffData = getGameData():getOnOffData()
	if mission_id == COURSE_MISSION_ID then
		return onOffData:isOpen(on_off_info.MAIN_REWARD.value) or false
	elseif mission_id == HOTEL_MISSION_ID then --招募
		local investData = getGameData():getInvestData()
		local enabled = investData:isUnlock()
		if enabled then
			return onOffData:isOpen(on_off_info.PORT_HOTEL.value)
		end

		return false
	elseif mission_id == BOAT_UP_MISSION_ID then --装备强化
		return true
	elseif mission_id == BATTLE_MISSION_ID then --战役
		local battleData = getGameData():getBattleData()
		if not battleData:getBattleInfo() or not battleData:getBattleAble() then
		   return false
		else
			return true
		end
	elseif mission_id == JJC_MISSION_ID then --竞技场
		return onOffData:isOpen(on_off_info.PORT_QUAY_JJC.value) or false
	elseif mission_id == MARKE_MISSION_ID then --交易所
		local investData = getGameData():getInvestData()
		if not investData:isUnlock() or not onOffData:isOpen(on_off_info.PORT_MARKET.value) then
			return false
		else
			return true
		end
	elseif mission_id == TREAT_MISSION_ID then --悬赏
		return onOffData:isOpen(on_off_info.PORT_HOTEL_TREAT.value) or false

	elseif mission_id == PLUNDER_MISSION_ID then --掠夺船队
		return true
	elseif mission_id == GONGHUI_MISSION_ID then --公会
		local guild_info_data = getGameData():getGuildInfoData()
		local guild_id = guild_info_data:getGuildId()
		if guild_info_data:hasGuild() then
			return true
		else
			return false
		end
	elseif mission_id == TOWN_MISSION_ID then ---港口投资
		return onOffData:isOpen(on_off_info.PORT_TOWN.value) or false
	else
		return true
	end
end

function ClsDailyCourseDataHandle:setMissionReward(rewards)
	self.mission_reward = rewards
end
function ClsDailyCourseDataHandle:getMissionReward()
	return self.mission_reward
end

function ClsDailyCourseDataHandle:setActivityCourseList(info)
	local list = {}
	for k,v in pairs(info) do
		list[v.missionId] = v
	end
	self._activity_course_list = list
end

function ClsDailyCourseDataHandle:getActivityCourseList()
	return self._activity_course_list
end
-----获取活动的阶段
function ClsDailyCourseDataHandle:getActivityStep(id)
	local mission_item = self._activity_course_list[id]
	local mission_info = syllabus_mission[id]   ----任务本地表
	local max_star_n = #mission_info.star_step           ----需要星星的数量
	local now_star_n
	if mission_item.status ==  2 and mission_item.star_list[1]["have_reward"] == 0 and #mission_item.star_list == max_star_n then
		 now_star_n = mission_item.cur_star
	else
		 now_star_n = mission_item.cur_star -1
	end
	return now_star_n ,max_star_n
end
function ClsDailyCourseDataHandle:setRaceCourseList(info)
	local list = {}
	for k,v in pairs(info) do
		list[v.missionId] = v
	end
	self._race_course_list = list
end

function ClsDailyCourseDataHandle:getRaceCourseList()
	return self._race_course_list
end

function ClsDailyCourseDataHandle:setLiveness(liveness)
	self._liveness = liveness
	if getUIManager():isLive("ClsActivityMain") then
		local main_tab = getUIManager():get("ClsActivityMain"):getRegChild("ClsDailyTargetTab")
		if main_tab then
			main_tab:updateView()
		end
	end
end

function ClsDailyCourseDataHandle:getLiveness()
	return self._liveness
end

function ClsDailyCourseDataHandle:setReward(reward)
	self._reward = reward

end

function ClsDailyCourseDataHandle:getReward()
	return self._reward
end

function ClsDailyCourseDataHandle:setLivenessLevel(liveness_level)
	self._liveness_level = liveness_level
end

function ClsDailyCourseDataHandle:getLivenessLevel()
	return self._liveness_level
end
-----活动类型
function ClsDailyCourseDataHandle:setActivityType(id)
	self._type = id
end
function ClsDailyCourseDataHandle:getActivityType()
	return self._type
end
function ClsDailyCourseDataHandle:updateMissionInfo(mission)
	local mission_type = mission.type
	local mission_id = mission.missionId

	self._activity_course_list[mission_id] = mission

	if getUIManager():isLive("ClsActivityMain") then
		local main_tab = getUIManager():get("ClsActivityMain"):getRegChild("ClsDailyTargetTab")
		if main_tab then
		   main_tab:updateView()
		end
	end

end




function ClsDailyCourseDataHandle:isStateLock(mission_id)
	local state_n = tonumber(self._activity_course_list[mission_id].status)
	if LOCK_STATE == state_n then
		return true
	end
	return false
end
function ClsDailyCourseDataHandle:getNowStar(mission_id)
	local star_n = 0
	local mission_item = self._activity_course_list[mission_id]
	if mission_item then
		for k, v in ipairs(mission_item.star_list) do
			if v.star > star_n then
				star_n = v.star
			end
		end
	end
	return star_n
end

return ClsDailyCourseDataHandle
