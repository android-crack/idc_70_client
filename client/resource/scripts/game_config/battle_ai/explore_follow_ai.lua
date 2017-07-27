----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIExplore_follow_ai = class("ClsAIExplore_follow_ai", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIExplore_follow_ai:getId()
	return "explore_follow_ai";
end


-- AI时机
function ClsAIExplore_follow_ai:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIExplore_follow_ai:getPriority()
	return 900;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"explore_follow", "", {80, }, }, 
}

function ClsAIExplore_follow_ai:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIExplore_follow_ai:getAllTargetMethod()
	return all_target_method
end

return ClsAIExplore_follow_ai

----------------------- Auto Genrate End   --------------------
