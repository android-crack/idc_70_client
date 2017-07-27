----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_16_angry = class("ClsAIBat_16_angry", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_16_angry:getId()
	return "bat_16_angry";
end


-- AI时机
function ClsAIBat_16_angry:getOpportunity()
	return AI_OPPORTUNITY.RUN;
end

-- AI优先级别
function ClsAIBat_16_angry:getPriority()
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
	{"play_plot", "", {{11, 12, 13, 14, 15, }, }, }, 
	{"run_ai", "", {{"bat_16_enter2", }, }, }, 
}

function ClsAIBat_16_angry:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_16_angry:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_16_angry

----------------------- Auto Genrate End   --------------------
