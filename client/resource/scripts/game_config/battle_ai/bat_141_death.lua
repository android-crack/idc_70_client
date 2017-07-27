----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[18]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_141_death = class("ClsAIBat_141_death", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_141_death:getId()
	return "bat_141_death";
end


-- AI时机
function ClsAIBat_141_death:getOpportunity()
	return AI_OPPORTUNITY.DEATH;
end

-- AI优先级别
function ClsAIBat_141_death:getPriority()
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
	{"play_plot", "", {{5, 6, 7, }, }, }, 
	{"battle_stop", "", {1, }, }, 
}

function ClsAIBat_141_death:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_141_death:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_141_death

----------------------- Auto Genrate End   --------------------
