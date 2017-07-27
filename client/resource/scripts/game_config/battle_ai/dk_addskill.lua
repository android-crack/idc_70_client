----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIDk_addskill = class("ClsAIDk_addskill", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIDk_addskill:getId()
	return "dk_addskill";
end


-- AI时机
function ClsAIDk_addskill:getOpportunity()
	return AI_OPPORTUNITY.RUN;
end

-- AI优先级别
function ClsAIDk_addskill:getPriority()
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
	{"add_skill", "", {4101, 10, }, }, 
	{"add_skill", "", {4501, 10, }, }, 
	{"add_skill", "", {99021, 10, }, }, 
	{"add_skill", "", {99024, 10, }, }, 
	{"add_skill", "", {3501, 10, }, }, 
}

function ClsAIDk_addskill:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIDk_addskill:getAllTargetMethod()
	return all_target_method
end

return ClsAIDk_addskill

----------------------- Auto Genrate End   --------------------
