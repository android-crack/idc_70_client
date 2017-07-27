----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIDk_beckon = class("ClsAIDk_beckon", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIDk_beckon:getId()
	return "dk_beckon";
end


-- AI时机
function ClsAIDk_beckon:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIDk_beckon:getPriority()
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
	{"delay", "", {10000, }, }, 
	{"enter_scene", "", {3, 1, 1, 0, 1, 0, }, }, 
}

function ClsAIDk_beckon:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIDk_beckon:getAllTargetMethod()
	return all_target_method
end

return ClsAIDk_beckon

----------------------- Auto Genrate End   --------------------
