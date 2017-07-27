----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIEnter_123 = class("ClsAIEnter_123", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIEnter_123:getId()
	return "enter_123";
end


-- AI时机
function ClsAIEnter_123:getOpportunity()
	return AI_OPPORTUNITY.RUN;
end

-- AI优先级别
function ClsAIEnter_123:getPriority()
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
	{"enter_scene", "", {7, }, }, 
	{"enter_scene", "", {8, }, }, 
	{"enter_scene", "", {9, }, }, 
	{"enter_scene", "", {16, }, }, 
	{"enter_scene", "", {17, }, }, 
	{"enter_scene", "", {18, }, }, 
	{"enter_scene", "", {19, }, }, 
	{"show_prompt", "", {T("自爆船爆炸会对附近所有人造成伤害，注意回避"), }, }, 
	{"delete_ai", "", {{"enter_123", }, }, }, 
}

function ClsAIEnter_123:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIEnter_123:getAllTargetMethod()
	return all_target_method
end

return ClsAIEnter_123

----------------------- Auto Genrate End   --------------------
