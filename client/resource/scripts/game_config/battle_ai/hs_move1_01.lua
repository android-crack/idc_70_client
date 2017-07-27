----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIHs_move1_01 = class("ClsAIHs_move1_01", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIHs_move1_01:getId()
	return "hs_move1_01";
end


-- AI时机
function ClsAIHs_move1_01:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIHs_move1_01:getPriority()
	return 1;
end

-- AI停止标记
function ClsAIHs_move1_01:getStopOtherFlg()
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
	{"move_to", "", {560, 300, 50, }, }, 
	{"move_to", "", {560, 1000, 50, }, }, 
}

function ClsAIHs_move1_01:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIHs_move1_01:getAllTargetMethod()
	return all_target_method
end

return ClsAIHs_move1_01

----------------------- Auto Genrate End   --------------------
