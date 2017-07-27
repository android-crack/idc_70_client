----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_12_move = class("ClsAIBat_12_move", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_12_move:getId()
	return "bat_12_move";
end


-- AI时机
function ClsAIBat_12_move:getOpportunity()
	return AI_OPPORTUNITY.FIGHT_START;
end

-- AI优先级别
function ClsAIBat_12_move:getPriority()
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
	{"move_to", "", {1480, 960, 50, }, }, 
}

function ClsAIBat_12_move:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_12_move:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_12_move

----------------------- Auto Genrate End   --------------------
