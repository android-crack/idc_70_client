----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_162_goal = class("ClsAIBat_162_goal", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_162_goal:getId()
	return "bat_162_goal";
end


-- AI时机
function ClsAIBat_162_goal:getOpportunity()
	return AI_OPPORTUNITY.FIGHT_START;
end

-- AI优先级别
function ClsAIBat_162_goal:getPriority()
	return 1;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"play_plot", "", {{1, 2, 3, 4, 5, }, }, }, 
	{"show_prompt", "", {T("敌人呈蛇形扎堆航行，解决他们的头领降低治疗能力。"), }, }, 
}

function ClsAIBat_162_goal:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_162_goal:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_162_goal

----------------------- Auto Genrate End   --------------------
