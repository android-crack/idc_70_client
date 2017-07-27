----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIWorld_enter = class("ClsAIWorld_enter", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIWorld_enter:getId()
	return "world_enter";
end


-- AI时机
function ClsAIWorld_enter:getOpportunity()
	return AI_OPPORTUNITY.RUN;
end

-- AI优先级别
function ClsAIWorld_enter:getPriority()
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
	{"enter_scene", "", {3, 1, 0, 0, 7, 0, }, }, 
	{"enter_scene", "", {4, 1, 0, 0, 7, 0, }, }, 
	{"enter_scene", "", {5, 1, 0, 0, 7, 0, }, }, 
	{"enter_scene", "", {6, 1, 0, 0, 7, 0, }, }, 
}

function ClsAIWorld_enter:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIWorld_enter:getAllTargetMethod()
	return all_target_method
end

return ClsAIWorld_enter

----------------------- Auto Genrate End   --------------------
