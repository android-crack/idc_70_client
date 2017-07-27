----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[战斗目标]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_goal_2_151 = class("ClsAIBat_goal_2_151", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_goal_2_151:getId()
	return "bat_goal_2_151";
end


-- AI时机
function ClsAIBat_goal_2_151:getOpportunity()
	return AI_OPPORTUNITY.RUN;
end

-- AI优先级别
function ClsAIBat_goal_2_151:getPriority()
	return -2;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"show_prompt", "", {T("不要让任何一艘敌方船只逃跑"), }, }, 
	{"add_effect_to_scene", "", {1, "jiantou", 10, 300, 120, }, }, 
	{"add_effect_to_scene", "", {2, "jiantou", 10, 600, 120, }, }, 
	{"add_effect_to_scene", "", {3, "jiantou", 10, 900, 120, }, }, 
}

function ClsAIBat_goal_2_151:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_goal_2_151:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_goal_2_151

----------------------- Auto Genrate End   --------------------
