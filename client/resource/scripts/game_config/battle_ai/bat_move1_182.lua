----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[巡逻路线1]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_move1_182 = class("ClsAIBat_move1_182", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_move1_182:getId()
	return "bat_move1_182";
end


-- AI时机
function ClsAIBat_move1_182:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIBat_move1_182:getPriority()
	return 48;
end

-- AI停止标记
function ClsAIBat_move1_182:getStopOtherFlg()
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
	{"move_to", "", {1260, 960, 50, }, }, 
	{"move_to", "", {460, 960, 50, }, }, 
}

function ClsAIBat_move1_182:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_move1_182:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_move1_182

----------------------- Auto Genrate End   --------------------
