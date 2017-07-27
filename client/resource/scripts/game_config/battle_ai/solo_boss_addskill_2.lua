----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAISolo_boss_addskill_2 = class("ClsAISolo_boss_addskill_2", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAISolo_boss_addskill_2:getId()
	return "solo_boss_addskill_2";
end


-- AI时机
function ClsAISolo_boss_addskill_2:getOpportunity()
	return AI_OPPORTUNITY.FIGHT_START;
end

-- AI优先级别
function ClsAISolo_boss_addskill_2:getPriority()
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
	{"add_skill", "", {5201, 1, }, }, 
	{"add_skill", "", {5202, 8, }, }, 
	{"add_skill", "", {5201, 15, }, }, 
	{"add_skill", "", {5301, 1, }, }, 
	{"add_skill", "", {5302, 8, }, }, 
	{"add_skill", "", {5303, 15, }, }, 
}

function ClsAISolo_boss_addskill_2:getActions()
	return actions
end

local all_target_method = {
}

function ClsAISolo_boss_addskill_2:getAllTargetMethod()
	return all_target_method
end

return ClsAISolo_boss_addskill_2

----------------------- Auto Genrate End   --------------------
