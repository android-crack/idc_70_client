----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[25]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_move9_33 = class("ClsAIBat_move9_33", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_move9_33:getId()
	return "bat_move9_33";
end


-- AI时机
function ClsAIBat_move9_33:getOpportunity()
	return AI_OPPORTUNITY.FIGHT_START;
end

-- AI优先级别
function ClsAIBat_move9_33:getPriority()
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
	{"move_to", "", {2550, 640, 50, }, }, 
}

function ClsAIBat_move9_33:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_move9_33:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_move9_33

----------------------- Auto Genrate End   --------------------
