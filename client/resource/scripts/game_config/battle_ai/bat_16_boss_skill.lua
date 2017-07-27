----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_16_boss_skill = class("ClsAIBat_16_boss_skill", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_16_boss_skill:getId()
	return "bat_16_boss_skill";
end


-- AI时机
function ClsAIBat_16_boss_skill:getOpportunity()
	return AI_OPPORTUNITY.FIGHT_START;
end

-- AI优先级别
function ClsAIBat_16_boss_skill:getPriority()
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
	{"del_skill", "", {1, }, }, 
	{"del_skill", "", {2, }, }, 
	{"add_skill", "", {99003, 1, }, }, 
	{"add_skill", "", {99004, 1, }, }, 
}

function ClsAIBat_16_boss_skill:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_16_boss_skill:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_16_boss_skill

----------------------- Auto Genrate End   --------------------
