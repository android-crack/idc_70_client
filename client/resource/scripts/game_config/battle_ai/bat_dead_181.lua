----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[马铃薯被击破]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_dead_181 = class("ClsAIBat_dead_181", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_dead_181:getId()
	return "bat_dead_181";
end


-- AI时机
function ClsAIBat_dead_181:getOpportunity()
	return AI_OPPORTUNITY.DEATH;
end

-- AI优先级别
function ClsAIBat_dead_181:getPriority()
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
	{"run_ai", "", {{"bat_end_4_181", }, }, }, 
}

function ClsAIBat_dead_181:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_dead_181:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_dead_181

----------------------- Auto Genrate End   --------------------
