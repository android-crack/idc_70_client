----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[16]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_win_84_jy = class("ClsAIBat_win_84_jy", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_win_84_jy:getId()
	return "bat_win_84_jy";
end


-- AI时机
function ClsAIBat_win_84_jy:getOpportunity()
	return AI_OPPORTUNITY.DEATH;
end

-- AI优先级别
function ClsAIBat_win_84_jy:getPriority()
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
	{"battle_stop", "", {1, }, }, 
}

function ClsAIBat_win_84_jy:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_win_84_jy:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_win_84_jy

----------------------- Auto Genrate End   --------------------
