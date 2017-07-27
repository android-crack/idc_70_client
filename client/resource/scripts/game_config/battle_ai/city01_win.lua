----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[胜利]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAICity01_win = class("ClsAICity01_win", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAICity01_win:getId()
	return "city01_win";
end


-- AI时机
function ClsAICity01_win:getOpportunity()
	return AI_OPPORTUNITY.DEATH;
end

-- AI优先级别
function ClsAICity01_win:getPriority()
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
	{"battle_stop", "", {1, }, }, 
}

function ClsAICity01_win:getActions()
	return actions
end

local all_target_method = {
}

function ClsAICity01_win:getAllTargetMethod()
	return all_target_method
end

return ClsAICity01_win

----------------------- Auto Genrate End   --------------------
