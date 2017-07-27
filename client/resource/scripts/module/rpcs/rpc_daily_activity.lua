--
-- Author: Ltian
-- Date: 2015-07-22 14:21:47
--
local error_info=require("game_config/error_info")
local ui_word = require("game_config/ui_word")
local Alert = require("ui/tools/alert")
local element_mgr = require("base/element_mgr")
local on_off_info=require("game_config/on_off_info")
local mjms_reward = require("game_config/activity/mjms_reward")
local mjms_activity_reward = require("game_config/activity/mjms_activity_reward")

-----每周竞赛信息
function rpc_client_week_competition_info(activity_type, competition_level, point, step_data, remain_time)
	--print("===========每周竞赛信息=========",activity_type, competition_level, point, remain_time)
	local weekly_info = {}
	weekly_info.type = activity_type
	weekly_info.point = point
	weekly_info.level = competition_level
	weekly_info.remain_time = remain_time
	weekly_info.step_data = step_data
	local daily_activity_data = getGameData():getDailyActivityData()
	daily_activity_data:setWeeklyData(weekly_info)

	local ClsWeeklyRace = getUIManager():get("ClsWeeklyRace")
	if not tolua.isnull(ClsWeeklyRace) then
		ClsWeeklyRace:handleData()
	end

end

---每周竞赛排名
function rpc_client_week_competition_rank(list)
	-- print("----------------竞赛排名")
	-- table.print(list)
	local daily_activity_data = getGameData():getDailyActivityData()
	for k,v in pairs(list) do
		list[k].rank = k
	end	
	daily_activity_data:setRankList(list)

	local ClsDailyActivityTeamRank = getUIManager():get("ClsWeeklyRace"):getRegChild("ClsDailyActivityTeamRank")
	if not tolua.isnull(ClsDailyActivityTeamRank) then
		ClsDailyActivityTeamRank:mkListView()
	end

	-- local ClsWeeklyRace = getUIManager():get("ClsWeeklyRace")
	-- if not tolua.isnull(ClsWeeklyRace) then
	-- 	ClsWeeklyRace:handleData()
	-- end

end

---每周竞赛领奖
function rpc_client_week_competition_reward(rewards)
	if rewards then
		Alert:showCommonReward(rewards)
	end
	local ClsWeeklyRace = getUIManager():get("ClsWeeklyRace")
	if not tolua.isnull(ClsWeeklyRace) then
		ClsWeeklyRace:updateBtn()
	end	
end


-- function rpc_client_get_dailyrace_status(status, result, error)
-- 	local daily_activity_data = getGameData():getDailyActivityData()
-- 	daily_activity_data:setActivityStatus(status.statusId) ---活动状态
-- 	daily_activity_data:setActivityType(status.typeId)   ---活动类型
-- 	daily_activity_data:setAcityityLeftTime(status.left_time) --活动剩余时间
-- 	local is_show = daily_activity_data:getShow()
-- 	if result == 1 then --
-- 		if status.statusId == 1 then  --活动进行时状态，继续请求排名列表
-- 			daily_activity_data:askWeeklyRaceRankList()   --排名
--         else
--         	daily_activity_data:setRankList(nil)
--         	local element = getUIManager():get("ClsWeeklyRace")
--         	if element then
--         		element:handleData()
--         	end
--     	end	
-- 	else
-- 		Alert:warning({msg = error_info[error].message, size = 26})
-- 		local element = getUIManager():get("ClsWeeklyRace")
-- 		if element and not tolua.isnull(element) then 
-- 			element:close()
-- 		end
-- 	end	
-- end

--
-- function rpc_client_dailyrace_rank(result, list, error)
-- 	local daily_activity_data = getGameData():getDailyActivityData()
--     local activity_type = daily_activity_data:getActivityType()  ---活动类型
-- 	--增加排行
-- 	for k,v in pairs(list) do
-- 		list[k].rank = k
-- 	end
-- 	daily_activity_data:setRankList(list)
-- 	local element = getUIManager():get("ClsWeeklyRace")
-- 	if not tolua.isnull(element) then
-- 		if activity_type == 0 then
-- 			if error then
-- 				Alert:warning({msg = error_info[error].message, size = 26})
-- 			end
--         else
--         	element:handleData()
-- 		end
		
-- 	end
	
-- end

---奖励的阶段
-- function  rpc_client_dailyrace_step_reward_info(point,stepList)
-- 	local daily_activity_data = getGameData():getDailyActivityData()
-- 	daily_activity_data:setHavePoint(point)    ----已有分数
-- 	daily_activity_data:setRewardInfo(stepList)      ----奖励的信息表 
-- end

-----领取阶段奖励
function rpc_client_dailyrace_get_step_reward(step_id,result)  
	if result == 1 then

		local daily_activity_data = getGameData():getDailyActivityData()
		local rewardList = daily_activity_data:getRewardInfo()
		local reward = rewardList[step_id]["reward"]
		local rewards_tab = {}
		if reward then
			Alert:showCommonReward(reward)
		end
	else

		local element = element_mgr:get_element("ClsDailyActivityPersonalReward")
		if element and  not tolua.isnull(element) then
			element:createListView()
		end
	end

end

function rpc_client_dailyrace_rank_reward(pos, reward, result, error)
	local daily_activity_data = getGameData():getDailyActivityData()
	daily_activity_data:setRewardInfo(reward)
	daily_activity_data:setRewardRank(pos)
	daily_activity_data:hasReward()
end

function rpc_client_time_limit_get_reward(result, error , reward_list)
	if result == 0 then
		Alert:warning({msg = error_info[error].message, size = 26})
		local daily_activity_data = getGameData():getDailyActivityData()
		daily_activity_data:setInvestRewardStatus(0)
		local invest_reward_ui = getUIManager():get("ClsInvestRewardView")
		if not tolua.isnull(invest_reward_ui) then
			invest_reward_ui:regCB()
		end
	else
		Alert:showCommonReward(reward_list)
		-- Alert:warning({msg = ui_word.ACTIVITY_STR6, size = 26})   ---已领取
		local daily_activity_data = getGameData():getDailyActivityData()
		daily_activity_data:setInvestRewardStatus(0) --设置领奖状态为已经领取
		local invest_reward_ui = getUIManager():get("ClsInvestRewardView")
		if not tolua.isnull(invest_reward_ui) then
			invest_reward_ui:regCB()
		end
	end
end

-- 1 是可以领， 0 是不可以领
function rpc_client_time_limit_huodong_status(is_reward)
	local daily_activity_data = getGameData():getDailyActivityData()
	daily_activity_data:setInvestRewardStatus(is_reward)
	local invest_reward_ui = getUIManager():get("ClsInvestRewardView")
	if not tolua.isnull(invest_reward_ui) then
		invest_reward_ui:regCB()
	end
end


function rpc_client_dailyrace_rank_pos(pos)
	local daily_activity_data = getGameData():getDailyActivityData()
	daily_activity_data:setRewardRank(pos)
	daily_activity_data:setAlertStatus()
end

-------------------传说活动----------------------------------

-- function rpc_client_mjms_huodong_info(type, id, remain_time)
-- 	local daily_activity_data = getGameData():getDailyActivityData()
-- 	daily_activity_data:setLegendActivityInfo(type, id, remain_time)
-- 	local legend_view = element_mgr:get_element("ClsLegendActivity")
-- 	if legend_view and not tolua.isnull(legend_view) then
-- 		legend_view:updateView()
-- 	end
-- end

-- --查询名舰名仕活动列表
-- function rpc_client_mjms_huodong_reward_list(type, list)
-- 	local daily_activity_data = getGameData():getDailyActivityData()
-- 	daily_activity_data:setLegendActivityRewardList(type, list)
-- 	local legend_view = element_mgr:get_element("ClsLegendActivity")
-- 	if legend_view and not tolua.isnull(legend_view) then
-- 		legend_view:updateRewardList()
-- 	end
-- end

-- --领取名舰名仕奖励
-- function rpc_client_mjms_huodong_reward_take(reward_id, errno)
-- 	if errno == 0 then
-- 		local reward_info = mjms_reward[reward_id]
-- 		local reward_item = mjms_activity_reward[tostring(reward_info.mjms_reward)]
-- 		Alert:showCommonReward({getCommonRewardData(reward_item)})
-- 		local legend_view = element_mgr:get_element("ClsLegendActivity")
-- 		if legend_view and not tolua.isnull(legend_view) then
-- 			legend_view:updateRewardListState(reward_id)
-- 		end
-- 	else
-- 		Alert:warning({msg = error_info[errno].message, size = 26})
-- 	end
-- end