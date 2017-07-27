----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[分身技能链弹舰]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAISk_fenshen_6 = class("ClsAISk_fenshen_6", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAISk_fenshen_6:getId()
	return "sk_fenshen_6";
end


-- AI时机
function ClsAISk_fenshen_6:getOpportunity()
	return AI_OPPORTUNITY.RUN;
end

-- AI优先级别
function ClsAISk_fenshen_6:getPriority()
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
	{"add_skill", "", {1902, 1, }, }, 
}

function ClsAISk_fenshen_6:getActions()
	return actions
end

local all_target_method = {
}

function ClsAISk_fenshen_6:getAllTargetMethod()
	return all_target_method
end

return ClsAISk_fenshen_6

----------------------- Auto Genrate End   --------------------
