----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[1-21]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_start_141 = class("ClsAIBat_start_141", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_start_141:getId()
	return "bat_start_141";
end


-- AI时机
function ClsAIBat_start_141:getOpportunity()
	return AI_OPPORTUNITY.FIGHT_START;
end

-- AI优先级别
function ClsAIBat_start_141:getPriority()
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
	{"play_plot", "", {{1, 3, }, }, }, 
	{"show_prompt", "", {T("避开敌方巡逻船，直接接触敌方旗舰。"), }, }, 
}

function ClsAIBat_start_141:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_start_141:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_start_141

----------------------- Auto Genrate End   --------------------
