----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIZh_begin = class("ClsAIZh_begin", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIZh_begin:getId()
	return "zh_begin";
end


-- AI时机
function ClsAIZh_begin:getOpportunity()
	return AI_OPPORTUNITY.FIGHT_START;
end

-- AI优先级别
function ClsAIZh_begin:getPriority()
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
	{"play_plot", "", {{1, 2, 3, 4, 5, }, }, }, 
	{"show_prompt", "", {T("击败郑和，小心增援！"), }, }, 
}

function ClsAIZh_begin:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIZh_begin:getAllTargetMethod()
	return all_target_method
end

return ClsAIZh_begin

----------------------- Auto Genrate End   --------------------
