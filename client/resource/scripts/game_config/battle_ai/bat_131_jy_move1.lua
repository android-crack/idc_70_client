----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[3=19]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_131_jy_move1 = class("ClsAIBat_131_jy_move1", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_131_jy_move1:getId()
	return "bat_131_jy_move1";
end


-- AI时机
function ClsAIBat_131_jy_move1:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIBat_131_jy_move1:getPriority()
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
	{"move_to", "", {2450, 640, 50, }, }, 
	{"play_plot", "", {{1, 6, }, }, }, 
	{"battle_stop", "", {0, }, }, 
	{"delete_ai", "", {{"bat_131_jy_move1", }, }, }, 
}

function ClsAIBat_131_jy_move1:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_131_jy_move1:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_131_jy_move1

----------------------- Auto Genrate End   --------------------
