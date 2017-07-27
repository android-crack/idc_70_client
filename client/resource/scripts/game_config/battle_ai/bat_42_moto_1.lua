----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_42_moto_1 = class("ClsAIBat_42_moto_1", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_42_moto_1:getId()
	return "bat_42_moto_1";
end


-- AI时机
function ClsAIBat_42_moto_1:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIBat_42_moto_1:getPriority()
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
	{"move_to", "", {1212, 187, 60, }, }, 
	{"move_to", "", {500, 300, 60, }, }, 
}

function ClsAIBat_42_moto_1:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_42_moto_1:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_42_moto_1

----------------------- Auto Genrate End   --------------------
