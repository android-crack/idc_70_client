----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIWorld_del_skill = class("ClsAIWorld_del_skill", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIWorld_del_skill:getId()
	return "world_del_skill";
end


-- AI时机
function ClsAIWorld_del_skill:getOpportunity()
	return AI_OPPORTUNITY.FIGHT_START;
end

-- AI优先级别
function ClsAIWorld_del_skill:getPriority()
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
	{"del_skill", "", {2, }, }, 
}

function ClsAIWorld_del_skill:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIWorld_del_skill:getAllTargetMethod()
	return all_target_method
end

return ClsAIWorld_del_skill

----------------------- Auto Genrate End   --------------------
