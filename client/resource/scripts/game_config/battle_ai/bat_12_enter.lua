----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_12_enter = class("ClsAIBat_12_enter", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_12_enter:getId()
	return "bat_12_enter";
end


-- AI时机
function ClsAIBat_12_enter:getOpportunity()
	return AI_OPPORTUNITY.FIGHT_START;
end

-- AI优先级别
function ClsAIBat_12_enter:getPriority()
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
	{"play_plot", "", {{1, }, }, }, 
	{"begin_tutorials", "", {}, }, 
	{"show_prompt", "", {T("请跟随绿色箭头前往目的地"), }, }, 
	{"add_skill", "", {9001, 5, "", 5, 1, }, }, 
	{"guide_point", "", {544, 288, }, }, 
}

function ClsAIBat_12_enter:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_12_enter:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_12_enter

----------------------- Auto Genrate End   --------------------
