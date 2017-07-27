----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_41_enter = class("ClsAIBat_41_enter", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_41_enter:getId()
	return "bat_41_enter";
end


-- AI时机
function ClsAIBat_41_enter:getOpportunity()
	return AI_OPPORTUNITY.FIGHT_START;
end

-- AI优先级别
function ClsAIBat_41_enter:getPriority()
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
	{"play_plot", "", {{1, 2, 3, 4, }, }, }, 
}

function ClsAIBat_41_enter:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_41_enter:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_41_enter

----------------------- Auto Genrate End   --------------------
