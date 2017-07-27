----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[8]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIEnter3_83 = class("ClsAIEnter3_83", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIEnter3_83:getId()
	return "enter3_83";
end


-- AI时机
function ClsAIEnter3_83:getOpportunity()
	return AI_OPPORTUNITY.DEATH;
end

-- AI优先级别
function ClsAIEnter3_83:getPriority()
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
	{"enter_scene", "", {6, }, }, 
}

function ClsAIEnter3_83:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIEnter3_83:getAllTargetMethod()
	return all_target_method
end

return ClsAIEnter3_83

----------------------- Auto Genrate End   --------------------
