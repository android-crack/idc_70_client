----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_152_add = class("ClsAIBat_152_add", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_152_add:getId()
	return "bat_152_add";
end


-- AI时机
function ClsAIBat_152_add:getOpportunity()
	return AI_OPPORTUNITY.FIGHT_START;
end

-- AI优先级别
function ClsAIBat_152_add:getPriority()
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
	{"add_skill", "", {1125, 1, }, }, 
}

function ClsAIBat_152_add:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_152_add:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_152_add

----------------------- Auto Genrate End   --------------------
