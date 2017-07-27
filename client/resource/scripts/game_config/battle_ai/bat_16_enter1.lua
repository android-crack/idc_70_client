----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_16_enter1 = class("ClsAIBat_16_enter1", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_16_enter1:getId()
	return "bat_16_enter1";
end


-- AI时机
function ClsAIBat_16_enter1:getOpportunity()
	return AI_OPPORTUNITY.RUN;
end

-- AI优先级别
function ClsAIBat_16_enter1:getPriority()
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
	{"enter_scene", "", {5, 0, 0, 1, 3, 0, }, }, 
	{"enter_scene", "", {6, 0, 0, 1, 4, 0, }, }, 
	{"enter_scene", "", {7, 0, 0, 1, 5, 0, }, }, 
	{"enter_scene", "", {8, 0, 0, 1, 6, 0, }, }, 
	{"enter_scene", "", {9, 0, 0, 1, 8, 0, }, }, 
	{"enter_scene", "", {10, 0, 0, 1, 1, 0, }, }, 
	{"enter_scene", "", {11, 0, 0, 1, 2, 0, }, }, 
	{"delay", "", {500, }, }, 
	{"play_plot", "", {{10, }, }, }, 
	{"run_ai", "", {{"bat_16_angry", }, }, }, 
}

function ClsAIBat_16_enter1:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_16_enter1:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_16_enter1

----------------------- Auto Genrate End   --------------------
