----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[分身技能医疗舰]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAISk_fenshen_5 = class("ClsAISk_fenshen_5", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAISk_fenshen_5:getId()
	return "sk_fenshen_5";
end


-- AI时机
function ClsAISk_fenshen_5:getOpportunity()
	return AI_OPPORTUNITY.RUN;
end

-- AI优先级别
function ClsAISk_fenshen_5:getPriority()
	return 1;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"add_skill", "", {1903, 1, }, }, 
}

function ClsAISk_fenshen_5:getActions()
	return actions
end

local all_target_method = {
}

function ClsAISk_fenshen_5:getAllTargetMethod()
	return all_target_method
end

return ClsAISk_fenshen_5

----------------------- Auto Genrate End   --------------------
