----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_enter2_123 = class("ClsAIBat_enter2_123", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_enter2_123:getId()
	return "bat_enter2_123";
end


-- AI时机
function ClsAIBat_enter2_123:getOpportunity()
	return AI_OPPORTUNITY.DEATH;
end

-- AI优先级别
function ClsAIBat_enter2_123:getPriority()
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
	{"enter_scene", "", {17, }, }, 
}

function ClsAIBat_enter2_123:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_enter2_123:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_enter2_123

----------------------- Auto Genrate End   --------------------
