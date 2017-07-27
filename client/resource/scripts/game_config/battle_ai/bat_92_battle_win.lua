----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_92_battle_win = class("ClsAIBat_92_battle_win", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_92_battle_win:getId()
	return "bat_92_battle_win";
end


-- AI时机
function ClsAIBat_92_battle_win:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIBat_92_battle_win:getPriority()
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
	{"move_to", "", {768, 885, 60, }, }, 
	{"move_to", "", {1122, 770, 60, }, }, 
	{"move_to", "", {1913, 515, 60, }, }, 
	{"battle_stop", "", {1, }, }, 
}

function ClsAIBat_92_battle_win:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_92_battle_win:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_92_battle_win

----------------------- Auto Genrate End   --------------------
