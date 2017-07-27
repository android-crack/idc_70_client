----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[爆破3号上场]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAICity01_dead_3 = class("ClsAICity01_dead_3", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAICity01_dead_3:getId()
	return "city01_dead_3";
end


-- AI时机
function ClsAICity01_dead_3:getOpportunity()
	return AI_OPPORTUNITY.DEATH;
end

-- AI优先级别
function ClsAICity01_dead_3:getPriority()
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
	{"enter_scene", "", {17, }, }, 
}

function ClsAICity01_dead_3:getActions()
	return actions
end

local all_target_method = {
}

function ClsAICity01_dead_3:getAllTargetMethod()
	return all_target_method
end

return ClsAICity01_dead_3

----------------------- Auto Genrate End   --------------------
