----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[BOSS死亡则胜利]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_172_boss_dead = class("ClsAIBat_172_boss_dead", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_172_boss_dead:getId()
	return "bat_172_boss_dead";
end


-- AI时机
function ClsAIBat_172_boss_dead:getOpportunity()
	return AI_OPPORTUNITY.DEATH;
end

-- AI优先级别
function ClsAIBat_172_boss_dead:getPriority()
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
	{"battle_stop", "", {1, }, }, 
}

function ClsAIBat_172_boss_dead:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_172_boss_dead:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_172_boss_dead

----------------------- Auto Genrate End   --------------------
