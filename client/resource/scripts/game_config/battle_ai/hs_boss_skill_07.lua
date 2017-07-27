----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIHs_boss_skill_07 = class("ClsAIHs_boss_skill_07", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIHs_boss_skill_07:getId()
	return "hs_boss_skill_07";
end


-- AI时机
function ClsAIHs_boss_skill_07:getOpportunity()
	return AI_OPPORTUNITY.FIGHT_START;
end

-- AI优先级别
function ClsAIHs_boss_skill_07:getPriority()
	return 2;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"add_skill", "", {3101, 10, }, }, 
	{"add_skill", "", {3102, 10, }, }, 
}

function ClsAIHs_boss_skill_07:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIHs_boss_skill_07:getAllTargetMethod()
	return all_target_method
end

return ClsAIHs_boss_skill_07

----------------------- Auto Genrate End   --------------------
