-- 课程表下发协议
-- Author: Ltian
-- Date: 2015-08-11 17:46:19
--
local ClsAlert = require("ui/tools/alert")

-- 每日目标数据
function rpc_client_dailytarget_mission_list(mission_syllabus_list)
	local course_data  = getGameData():getDailyCourseData()
	local _activity_list = {}
	for k,v in pairs(mission_syllabus_list) do
		table.insert(_activity_list, v)
	end
	course_data:setActivityCourseList(_activity_list)
	-- course_data:setRaceCourseList(_race_list)

	if getUIManager():isLive("ClsActivityMain") then
		local main_tab = getUIManager():get("ClsActivityMain"):getRegChild("ClsDailyTargetTab")
		if not tolua.isnull(main_tab) then
			main_tab:updateView()
		end
	end
end
-- 活跃值的数据
function rpc_client_dailytarget_liveness_info(liveness_info)
	local course_data  = getGameData():getDailyCourseData()
	course_data:setLiveness(liveness_info.liveness)  ---- 活跃度
	course_data:setReward(liveness_info.LevelRewards)---- 奖励表
	course_data:setLivenessLevel(liveness_info.livenessLevel)

end
-- 登录时获取活动类型
function rpc_client_get_dailyrace_id(id, result, error)
	local course_data = getGameData():getDailyCourseData()
	course_data:setActivityType(id)
end

function rpc_client_get_dailytarget_liveness_reward(bid, result, error)
	if result == 1 then
		local course_data = getGameData():getDailyCourseData()
		local reward = course_data:getReward()[bid - 1]
       	ClsAlert:showCommonReward(reward.rewards)

       	if getUIManager():isLive("ClsActivityMain") then
			local daily_target_tab = getUIManager():get("ClsActivityMain"):getRegChild("ClsDailyTargetTab")
			if not tolua.isnull(daily_target_tab) then
				daily_target_tab:updateView()
			end
		end
	end
end



function rpc_client_dailytarget_mission_info(mission_syllabus_info)
	local course_data = getGameData():getDailyCourseData()
	course_data:updateMissionInfo(mission_syllabus_info)
end
