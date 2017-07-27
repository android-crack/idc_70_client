----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIHs_win_04 = class("ClsAIHs_win_04", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIHs_win_04:getId()
	return "hs_win_04";
end


-- AI时机
function ClsAIHs_win_04:getOpportunity()
	return AI_OPPORTUNITY.DEATH;
end

-- AI优先级别
function ClsAIHs_win_04:getPriority()
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
	{"play_plot", "", {{5, }, }, }, 
	{"battle_stop", "", {1, }, }, 
}

function ClsAIHs_win_04:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIHs_win_04:getAllTargetMethod()
	return all_target_method
end

return ClsAIHs_win_04

----------------------- Auto Genrate End   --------------------
