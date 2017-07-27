----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[10]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_dead_63 = class("ClsAIBat_dead_63", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_dead_63:getId()
	return "bat_dead_63";
end


-- AI时机
function ClsAIBat_dead_63:getOpportunity()
	return AI_OPPORTUNITY.DEATH;
end

-- AI优先级别
function ClsAIBat_dead_63:getPriority()
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
	{"battle_stop", "", {0, }, }, 
}

function ClsAIBat_dead_63:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_dead_63:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_dead_63

----------------------- Auto Genrate End   --------------------
