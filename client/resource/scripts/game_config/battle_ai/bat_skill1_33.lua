----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[48]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_skill1_33 = class("ClsAIBat_skill1_33", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_skill1_33:getId()
	return "bat_skill1_33";
end


-- AI时机
function ClsAIBat_skill1_33:getOpportunity()
	return AI_OPPORTUNITY.FIGHT_START;
end

-- AI优先级别
function ClsAIBat_skill1_33:getPriority()
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
	{"add_skill", "", {1010, 1, }, }, 
}

function ClsAIBat_skill1_33:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_skill1_33:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_skill1_33

----------------------- Auto Genrate End   --------------------