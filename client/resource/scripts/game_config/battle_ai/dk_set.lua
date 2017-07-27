----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIDk_set = class("ClsAIDk_set", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIDk_set:getId()
	return "dk_set";
end


-- AI时机
function ClsAIDk_set:getOpportunity()
	return AI_OPPORTUNITY.FIGHT_START;
end

-- AI优先级别
function ClsAIDk_set:getPriority()
	return 2;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"change_ship_flow", "", {"texture_flow2", }, }, 
}

function ClsAIDk_set:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIDk_set:getAllTargetMethod()
	return all_target_method
end

return ClsAIDk_set

----------------------- Auto Genrate End   --------------------
