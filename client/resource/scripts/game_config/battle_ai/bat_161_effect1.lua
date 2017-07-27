----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[增加轨迹特效]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_161_effect1 = class("ClsAIBat_161_effect1", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_161_effect1:getId()
	return "bat_161_effect1";
end


-- AI时机
function ClsAIBat_161_effect1:getOpportunity()
	return AI_OPPORTUNITY.FIGHT_START;
end

-- AI优先级别
function ClsAIBat_161_effect1:getPriority()
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
	{"guide_point", "", {291, 595, }, }, 
}

function ClsAIBat_161_effect1:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_161_effect1:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_161_effect1

----------------------- Auto Genrate End   --------------------
