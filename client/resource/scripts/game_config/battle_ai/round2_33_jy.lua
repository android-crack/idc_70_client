----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIRound2_33_jy = class("ClsAIRound2_33_jy", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIRound2_33_jy:getId()
	return "round2_33_jy";
end


-- AI时机
function ClsAIRound2_33_jy:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIRound2_33_jy:getPriority()
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
	{"move_to", "", {1250, 50, }, }, 
	{"stop_ai", "", {{"round2_33_jy", }, }, }, 
	{"delete_ai", "", {{"round2_33_jy", }, }, }, 
	{"add_ai", "", {{"follow_33_jy", }, }, }, 
}

function ClsAIRound2_33_jy:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIRound2_33_jy:getAllTargetMethod()
	return all_target_method
end

return ClsAIRound2_33_jy

----------------------- Auto Genrate End   --------------------
