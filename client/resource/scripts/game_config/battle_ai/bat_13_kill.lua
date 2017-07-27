----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_13_kill = class("ClsAIBat_13_kill", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_13_kill:getId()
	return "bat_13_kill";
end


-- AI时机
function ClsAIBat_13_kill:getOpportunity()
	return AI_OPPORTUNITY.RUN;
end

-- AI优先级别
function ClsAIBat_13_kill:getPriority()
	return -3;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"add_skill", "", {1213, 10, "passive", }, }, 
	{"use_skill", "", {1213, }, }, 
}

function ClsAIBat_13_kill:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_13_kill:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_13_kill

----------------------- Auto Genrate End   --------------------
