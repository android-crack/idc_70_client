----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_92_battle_lose = class("ClsAIBat_92_battle_lose", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_92_battle_lose:getId()
	return "bat_92_battle_lose";
end


-- AI时机
function ClsAIBat_92_battle_lose:getOpportunity()
	return AI_OPPORTUNITY.DEATH;
end

-- AI优先级别
function ClsAIBat_92_battle_lose:getPriority()
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
	{"battle_stop", "", {0, }, }, 
}

function ClsAIBat_92_battle_lose:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_92_battle_lose:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_92_battle_lose

----------------------- Auto Genrate End   --------------------
