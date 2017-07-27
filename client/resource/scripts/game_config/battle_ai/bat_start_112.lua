----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_start_112 = class("ClsAIBat_start_112", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_start_112:getId()
	return "bat_start_112";
end


-- AI时机
function ClsAIBat_start_112:getOpportunity()
	return AI_OPPORTUNITY.FIGHT_START;
end

-- AI优先级别
function ClsAIBat_start_112:getPriority()
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
	{"show_prompt", "", {T("守株待兔，消灭前来探查的部队为主，别让魏臻发现。"), }, }, 
}

function ClsAIBat_start_112:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_start_112:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_start_112

----------------------- Auto Genrate End   --------------------
