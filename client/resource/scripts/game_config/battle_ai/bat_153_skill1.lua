----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_153_skill1 = class("ClsAIBat_153_skill1", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_153_skill1:getId()
	return "bat_153_skill1";
end


-- AI时机
function ClsAIBat_153_skill1:getOpportunity()
	return AI_OPPORTUNITY.FIGHT_START;
end

-- AI优先级别
function ClsAIBat_153_skill1:getPriority()
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
	{"add_skill", "", {1125, 2, }, }, 
}

function ClsAIBat_153_skill1:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_153_skill1:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_153_skill1

----------------------- Auto Genrate End   --------------------
