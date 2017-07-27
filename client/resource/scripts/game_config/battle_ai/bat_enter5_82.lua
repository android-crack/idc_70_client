----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[6]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_enter5_82 = class("ClsAIBat_enter5_82", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_enter5_82:getId()
	return "bat_enter5_82";
end


-- AI时机
function ClsAIBat_enter5_82:getOpportunity()
	return AI_OPPORTUNITY.DEATH;
end

-- AI优先级别
function ClsAIBat_enter5_82:getPriority()
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
	{"enter_scene", "", {8, }, }, 
}

function ClsAIBat_enter5_82:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_enter5_82:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_enter5_82

----------------------- Auto Genrate End   --------------------
