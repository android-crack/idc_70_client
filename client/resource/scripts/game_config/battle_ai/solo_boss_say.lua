----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAISolo_boss_say = class("ClsAISolo_boss_say", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAISolo_boss_say:getId()
	return "solo_boss_say";
end


-- AI时机
function ClsAISolo_boss_say:getOpportunity()
	return AI_OPPORTUNITY.FIGHT_START;
end

-- AI优先级别
function ClsAISolo_boss_say:getPriority()
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
	{"add_skill", "", {1216, 1, }, }, 
	{"add_skill", "", {1216, 1, }, }, 
	{"add_skill", "", {1216, 1, }, }, 
}

function ClsAISolo_boss_say:getActions()
	return actions
end

local all_target_method = {
}

function ClsAISolo_boss_say:getAllTargetMethod()
	return all_target_method
end

return ClsAISolo_boss_say

----------------------- Auto Genrate End   --------------------
