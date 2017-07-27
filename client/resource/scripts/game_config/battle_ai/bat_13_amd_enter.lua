----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_13_amd_enter = class("ClsAIBat_13_amd_enter", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_13_amd_enter:getId()
	return "bat_13_amd_enter";
end


-- AI时机
function ClsAIBat_13_amd_enter:getOpportunity()
	return AI_OPPORTUNITY.RUN;
end

-- AI优先级别
function ClsAIBat_13_amd_enter:getPriority()
	return -3;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"enter_scene", "", {7, 0, 0, 1, 7, 3, }, }, 
	{"enter_scene", "", {8, 0, 0, 0, 7, 3, }, }, 
	{"enter_scene", "", {9, 0, 0, 0, 7, 3, }, }, 
	{"enter_scene", "", {10, 0, 0, 0, 7, 3, }, }, 
	{"enter_scene", "", {11, 0, 0, 0, 7, 3, }, }, 
	{"enter_scene", "", {12, 0, 0, 0, 7, 3, }, }, 
	{"enter_scene", "", {13, 0, 0, 0, 7, 3, }, }, 
	{"run_ai", "", {{"bat_13_boss_enter_1", }, }, }, 
}

function ClsAIBat_13_amd_enter:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_13_amd_enter:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_13_amd_enter

----------------------- Auto Genrate End   --------------------
