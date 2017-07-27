----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_152_end = class("ClsAIBat_152_end", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_152_end:getId()
	return "bat_152_end";
end


-- AI时机
function ClsAIBat_152_end:getOpportunity()
	return AI_OPPORTUNITY.RUN;
end

-- AI优先级别
function ClsAIBat_152_end:getPriority()
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
	{"play_plot", "", {{5, 4, }, }, }, 
}

function ClsAIBat_152_end:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_152_end:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_152_end

----------------------- Auto Genrate End   --------------------
