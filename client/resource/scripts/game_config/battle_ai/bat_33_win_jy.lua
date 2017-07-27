----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_33_win_jy = class("ClsAIBat_33_win_jy", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_33_win_jy:getId()
	return "bat_33_win_jy";
end


-- AI时机
function ClsAIBat_33_win_jy:getOpportunity()
	return AI_OPPORTUNITY.DEATH;
end

-- AI优先级别
function ClsAIBat_33_win_jy:getPriority()
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
	{"play_plot", "", {{20, 21, 22, }, }, }, 
	{"battle_stop", "", {1, }, }, 
}

function ClsAIBat_33_win_jy:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_33_win_jy:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_33_win_jy

----------------------- Auto Genrate End   --------------------
