----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_23_turn = class("ClsAIBat_23_turn", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_23_turn:getId()
	return "bat_23_turn";
end


-- AI时机
function ClsAIBat_23_turn:getOpportunity()
	return AI_OPPORTUNITY.RUN;
end

-- AI优先级别
function ClsAIBat_23_turn:getPriority()
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
	{"move_to", "", {1140, 865, 50, }, }, 
	{"move_to", "", {1185, 600, 100, }, }, 
	{"move_to", "", {850, 600, 100, }, }, 
}

function ClsAIBat_23_turn:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_23_turn:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_23_turn

----------------------- Auto Genrate End   --------------------
