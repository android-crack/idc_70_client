----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_start_213 = class("ClsAIBat_start_213", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_start_213:getId()
	return "bat_start_213";
end


-- AI时机
function ClsAIBat_start_213:getOpportunity()
	return AI_OPPORTUNITY.FIGHT_START;
end

-- AI优先级别
function ClsAIBat_start_213:getPriority()
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
	{"play_plot", "", {{1, 2, 3, }, }, }, 
	{"show_prompt", "", {T("击败郑芝龙"), }, }, 
}

function ClsAIBat_start_213:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_start_213:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_start_213

----------------------- Auto Genrate End   --------------------
