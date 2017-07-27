----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIDead_2_153 = class("ClsAIDead_2_153", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIDead_2_153:getId()
	return "dead_2_153";
end


-- AI时机
function ClsAIDead_2_153:getOpportunity()
	return AI_OPPORTUNITY.DEATH;
end

-- AI优先级别
function ClsAIDead_2_153:getPriority()
	return 48;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"battle_stop", "", {1, }, }, 
}

function ClsAIDead_2_153:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIDead_2_153:getAllTargetMethod()
	return all_target_method
end

return ClsAIDead_2_153

----------------------- Auto Genrate End   --------------------
