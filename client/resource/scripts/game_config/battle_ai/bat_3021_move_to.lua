----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_3021_move_to = class("ClsAIBat_3021_move_to", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_3021_move_to:getId()
	return "bat_3021_move_to";
end


-- AI时机
function ClsAIBat_3021_move_to:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIBat_3021_move_to:getPriority()
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
	{"move_to", "", {1400, 850, 50, }, }, 
}

function ClsAIBat_3021_move_to:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_3021_move_to:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_3021_move_to

----------------------- Auto Genrate End   --------------------