----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[加速逃离]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIAddskil_speed_181 = class("ClsAIAddskil_speed_181", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIAddskil_speed_181:getId()
	return "addskil_speed_181";
end


-- AI时机
function ClsAIAddskil_speed_181:getOpportunity()
	return AI_OPPORTUNITY.FIGHT_START;
end

-- AI优先级别
function ClsAIAddskil_speed_181:getPriority()
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
	{"add_skill", "", {1208, 2, }, }, 
}

function ClsAIAddskil_speed_181:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIAddskil_speed_181:getAllTargetMethod()
	return all_target_method
end

return ClsAIAddskil_speed_181

----------------------- Auto Genrate End   --------------------
