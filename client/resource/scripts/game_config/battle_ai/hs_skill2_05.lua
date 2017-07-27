----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[链弹]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIHs_skill2_05 = class("ClsAIHs_skill2_05", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIHs_skill2_05:getId()
	return "hs_skill2_05";
end


-- AI时机
function ClsAIHs_skill2_05:getOpportunity()
	return AI_OPPORTUNITY.FIGHT_START;
end

-- AI优先级别
function ClsAIHs_skill2_05:getPriority()
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
	{"add_skill", "", {1011, 1, }, }, 
}

function ClsAIHs_skill2_05:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIHs_skill2_05:getAllTargetMethod()
	return all_target_method
end

return ClsAIHs_skill2_05

----------------------- Auto Genrate End   --------------------
