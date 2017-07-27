----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_start_143 = class("ClsAIBat_start_143", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_start_143:getId()
	return "bat_start_143";
end


-- AI时机
function ClsAIBat_start_143:getOpportunity()
	return AI_OPPORTUNITY.FIGHT_START;
end

-- AI优先级别
function ClsAIBat_start_143:getPriority()
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
	{"play_plot", "", {{4, 1, 10, 2, 3, }, }, }, 
	{"show_prompt", "", {T("让黑萨姆看看我们的实力即可，不要击破他"), }, }, 
}

function ClsAIBat_start_143:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_start_143:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_start_143

----------------------- Auto Genrate End   --------------------
