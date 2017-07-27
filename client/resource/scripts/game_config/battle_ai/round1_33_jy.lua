----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIRound1_33_jy = class("ClsAIRound1_33_jy", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIRound1_33_jy:getId()
	return "round1_33_jy";
end


-- AI时机
function ClsAIRound1_33_jy:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIRound1_33_jy:getPriority()
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
	{"move_to", "", {1250, 1100, }, }, 
	{"stop_ai", "", {{"round1_33_jy", }, }, }, 
	{"delete_ai", "", {{"round1_33_jy", }, }, }, 
	{"add_ai", "", {{"follow_33_jy", }, }, }, 
}

function ClsAIRound1_33_jy:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIRound1_33_jy:getAllTargetMethod()
	return all_target_method
end

return ClsAIRound1_33_jy

----------------------- Auto Genrate End   --------------------
