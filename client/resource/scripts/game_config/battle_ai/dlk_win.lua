----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIDlk_win = class("ClsAIDlk_win", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIDlk_win:getId()
	return "dlk_win";
end


-- AI时机
function ClsAIDlk_win:getOpportunity()
	return AI_OPPORTUNITY.DEATH;
end

-- AI优先级别
function ClsAIDlk_win:getPriority()
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
	{"play_plot", "", {{7, }, }, }, 
	{"battle_stop", "", {1, }, }, 
}

function ClsAIDlk_win:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIDlk_win:getAllTargetMethod()
	return all_target_method
end

return ClsAIDlk_win

----------------------- Auto Genrate End   --------------------
