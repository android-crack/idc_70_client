----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBoss_skill_42_jy = class("ClsAIBoss_skill_42_jy", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBoss_skill_42_jy:getId()
	return "boss_skill_42_jy";
end


-- AI时机
function ClsAIBoss_skill_42_jy:getOpportunity()
	return AI_OPPORTUNITY.FIGHT_START;
end

-- AI优先级别
function ClsAIBoss_skill_42_jy:getPriority()
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
	{"add_skill", "", {1039, 1, }, }, 
}

function ClsAIBoss_skill_42_jy:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBoss_skill_42_jy:getAllTargetMethod()
	return all_target_method
end

return ClsAIBoss_skill_42_jy

----------------------- Auto Genrate End   --------------------
