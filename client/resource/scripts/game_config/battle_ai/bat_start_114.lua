----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[1]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_start_114 = class("ClsAIBat_start_114", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_start_114:getId()
	return "bat_start_114";
end


-- AI时机
function ClsAIBat_start_114:getOpportunity()
	return AI_OPPORTUNITY.FIGHT_START;
end

-- AI优先级别
function ClsAIBat_start_114:getPriority()
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
	{"play_plot", "", {{1, 2, 3, 4, 5, }, }, }, 
	{"show_prompt", "", {T("消灭所有敌人，注意保护俞红袖。"), }, }, 
}

function ClsAIBat_start_114:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_start_114:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_start_114

----------------------- Auto Genrate End   --------------------
