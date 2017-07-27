----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_3012_add_skill = class("ClsAIBat_3012_add_skill", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_3012_add_skill:getId()
	return "bat_3012_add_skill";
end


-- AI时机
function ClsAIBat_3012_add_skill:getOpportunity()
	return AI_OPPORTUNITY.RUN;
end

-- AI优先级别
function ClsAIBat_3012_add_skill:getPriority()
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
	{"add_skill", "", {4501, 10, "", 4, 1, }, }, 
}

function ClsAIBat_3012_add_skill:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_3012_add_skill:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_3012_add_skill

----------------------- Auto Genrate End   --------------------
