----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[突击船进场]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_enter2_183 = class("ClsAIBat_enter2_183", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_enter2_183:getId()
	return "bat_enter2_183";
end


-- AI时机
function ClsAIBat_enter2_183:getOpportunity()
	return AI_OPPORTUNITY.RUN;
end

-- AI优先级别
function ClsAIBat_enter2_183:getPriority()
	return -2;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"enter_scene", "", {7, 0, 0, 1, 4, 0, }, }, 
	{"delay", "", {500, }, }, 
	{"enter_scene", "", {8, }, }, 
	{"delay", "", {500, }, }, 
	{"enter_scene", "", {9, }, }, 
	{"delay", "", {500, }, }, 
	{"enter_scene", "", {10, }, }, 
	{"delay", "", {500, }, }, 
}

function ClsAIBat_enter2_183:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_enter2_183:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_enter2_183

----------------------- Auto Genrate End   --------------------
