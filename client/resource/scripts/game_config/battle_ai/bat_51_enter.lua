----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_51_enter = class("ClsAIBat_51_enter", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_51_enter:getId()
	return "bat_51_enter";
end


-- AI时机
function ClsAIBat_51_enter:getOpportunity()
	return AI_OPPORTUNITY.FIGHT_START;
end

-- AI优先级别
function ClsAIBat_51_enter:getPriority()
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
	{"show_cloud", "", {120, 700, 600, 2400, 1200, }, }, 
	{"play_plot", "", {{1, 2, 3, 4, 5, 6, 7, 11, 12, }, }, }, 
	{"show_prompt", "", {T("击沉来袭的突击船"), }, }, 
}

function ClsAIBat_51_enter:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_51_enter:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_51_enter

----------------------- Auto Genrate End   --------------------
