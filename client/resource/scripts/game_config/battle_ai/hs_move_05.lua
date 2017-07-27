----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIHs_move_05 = class("ClsAIHs_move_05", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIHs_move_05:getId()
	return "hs_move_05";
end


-- AI时机
function ClsAIHs_move_05:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIHs_move_05:getPriority()
	return 48;
end

-- AI停止标记
function ClsAIHs_move_05:getStopOtherFlg()
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
	{"move_to", "", {1280, 640, 100, }, }, 
	{"run_ai", "", {{"hs_enter2_05", }, }, }, 
	{"move_to", "", {1280, 1152, 50, }, }, 
	{"stop_ai", "", {{"hs_move_05", }, }, }, 
	{"delete_ai", "", {{"hs_move_05", }, }, }, 
}

function ClsAIHs_move_05:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIHs_move_05:getAllTargetMethod()
	return all_target_method
end

return ClsAIHs_move_05

----------------------- Auto Genrate End   --------------------
