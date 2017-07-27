----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[增加钩索]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIDlk_add_skill_3 = class("ClsAIDlk_add_skill_3", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIDlk_add_skill_3:getId()
	return "dlk_add_skill_3";
end


-- AI时机
function ClsAIDlk_add_skill_3:getOpportunity()
	return AI_OPPORTUNITY.FIGHT_START;
end

-- AI优先级别
function ClsAIDlk_add_skill_3:getPriority()
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
	{"add_skill", "", {1026, 1, }, }, 
}

function ClsAIDlk_add_skill_3:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIDlk_add_skill_3:getAllTargetMethod()
	return all_target_method
end

return ClsAIDlk_add_skill_3

----------------------- Auto Genrate End   --------------------
