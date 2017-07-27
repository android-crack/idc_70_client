----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_203_sharehp2 = class("ClsAIBat_203_sharehp2", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_203_sharehp2:getId()
	return "bat_203_sharehp2";
end


-- AI时机
function ClsAIBat_203_sharehp2:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIBat_203_sharehp2:getPriority()
	return -2;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"run_ai", "", {{"bat_203_sethp1", }, }, }, 
	{"run_ai", "", {{"bat_203_gethp1", }, }, }, 
}

function ClsAIBat_203_sharehp2:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_203_sharehp2:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_203_sharehp2

----------------------- Auto Genrate End   --------------------
