----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_23_gyb_enter = class("ClsAIBat_23_gyb_enter", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_23_gyb_enter:getId()
	return "bat_23_gyb_enter";
end


-- AI时机
function ClsAIBat_23_gyb_enter:getOpportunity()
	return AI_OPPORTUNITY.FIGHT_START;
end

-- AI优先级别
function ClsAIBat_23_gyb_enter:getPriority()
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
	{"forge_weather", "", {120, }, }, 
	{"play_plot", "", {{1, 2, 3, 5, 6, }, }, }, 
	{"show_prompt", "", {T("在绿色轨迹目标点埋伏，在海盗首领进入射程后，释放技能"), }, }, 
	{"guide_point", "", {500, 500, }, }, 
}

function ClsAIBat_23_gyb_enter:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_23_gyb_enter:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_23_gyb_enter

----------------------- Auto Genrate End   --------------------
