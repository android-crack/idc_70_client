----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIYiji_effect = class("ClsAIYiji_effect", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIYiji_effect:getId()
	return "yiji_effect";
end


-- AI时机
function ClsAIYiji_effect:getOpportunity()
	return AI_OPPORTUNITY.FIGHT_START;
end

-- AI优先级别
function ClsAIYiji_effect:getPriority()
	return 48;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"change_ship_flow", "", {"texture_flow2", }, }, 
}

function ClsAIYiji_effect:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIYiji_effect:getAllTargetMethod()
	return all_target_method
end

return ClsAIYiji_effect

----------------------- Auto Genrate End   --------------------
