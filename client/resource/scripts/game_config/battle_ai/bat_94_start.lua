----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_94_start = class("ClsAIBat_94_start", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_94_start:getId()
	return "bat_94_start";
end


-- AI时机
function ClsAIBat_94_start:getOpportunity()
	return AI_OPPORTUNITY.FIGHT_START;
end

-- AI优先级别
function ClsAIBat_94_start:getPriority()
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
	{"play_plot", "", {{1, 2, 3, 4, 5, 6, }, }, }, 
	{"show_prompt", "", {T("阻止运输货船逃离！"), }, }, 
	{"add_effect_to_scene", "", {1, "jiantou", 1000, 629, 150, 1, }, }, 
	{"add_effect_to_scene", "", {2, "jiantou", 1000, 375, 150, 1, }, }, 
}

function ClsAIBat_94_start:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_94_start:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_94_start

----------------------- Auto Genrate End   --------------------
