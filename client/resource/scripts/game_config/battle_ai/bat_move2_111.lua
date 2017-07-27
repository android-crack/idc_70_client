----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_move2_111 = class("ClsAIBat_move2_111", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_move2_111:getId()
	return "bat_move2_111";
end


-- AI时机
function ClsAIBat_move2_111:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIBat_move2_111:getPriority()
	return 1;
end

-- AI停止标记
function ClsAIBat_move2_111:getStopOtherFlg()
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
	{"move_to", "", {860, 300, 50, }, }, 
	{"move_to", "", {1700, 300, 50, }, }, 
	{"move_to", "", {1700, 900, 50, }, }, 
	{"move_to", "", {860, 900, 50, }, }, 
	{"add_ai", "", {{"bat_move2_111", }, }, }, 
}

function ClsAIBat_move2_111:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_move2_111:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_move2_111

----------------------- Auto Genrate End   --------------------
