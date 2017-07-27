----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_12_clear_cd = class("ClsAIBat_12_clear_cd", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_12_clear_cd:getId()
	return "bat_12_clear_cd";
end


-- AI时机
function ClsAIBat_12_clear_cd:getOpportunity()
	return AI_OPPORTUNITY.RUN;
end

-- AI优先级别
function ClsAIBat_12_clear_cd:getPriority()
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
	{"clear_cd", "", {1, }, }, 
	{"clear_cd", "", {2, }, }, 
	{"clear_cd", "", {3, }, }, 
}

function ClsAIBat_12_clear_cd:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_12_clear_cd:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_12_clear_cd

----------------------- Auto Genrate End   --------------------
