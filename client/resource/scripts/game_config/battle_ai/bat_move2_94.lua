----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_move2_94 = class("ClsAIBat_move2_94", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_move2_94:getId()
	return "bat_move2_94";
end


-- AI时机
function ClsAIBat_move2_94:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIBat_move2_94:getPriority()
	return 48;
end

-- AI停止标记
function ClsAIBat_move2_94:getStopOtherFlg()
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
	{"move_to", "", {1000, 375, 50, }, }, 
	{"play_plot", "", {{7, }, }, }, 
	{"battle_stop", "", {0, }, }, 
	{"delete_ai", "", {{"bat_move2_94", }, }, }, 
}

function ClsAIBat_move2_94:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_move2_94:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_move2_94

----------------------- Auto Genrate End   --------------------
