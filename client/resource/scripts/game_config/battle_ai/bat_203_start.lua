----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_203_start = class("ClsAIBat_203_start", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_203_start:getId()
	return "bat_203_start";
end


-- AI时机
function ClsAIBat_203_start:getOpportunity()
	return AI_OPPORTUNITY.FIGHT_START;
end

-- AI优先级别
function ClsAIBat_203_start:getPriority()
	return 10;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"play_plot", "", {{1, 2, 3, }, }, }, 
	{"show_prompt", "", {T("张保仔与郑石氏之间生命共享"), }, }, 
}

function ClsAIBat_203_start:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_203_start:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_203_start

----------------------- Auto Genrate End   --------------------
