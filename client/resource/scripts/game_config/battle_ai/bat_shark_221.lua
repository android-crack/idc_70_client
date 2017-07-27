----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_shark_221 = class("ClsAIBat_shark_221", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_shark_221:getId()
	return "bat_shark_221";
end


-- AI时机
function ClsAIBat_shark_221:getOpportunity()
	return AI_OPPORTUNITY.RUN;
end

-- AI优先级别
function ClsAIBat_shark_221:getPriority()
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
	{"enter_scene", "", {25, 1, 1, 0, 1, 0, }, }, 
	{"enter_scene", "", {26, 1, 1, 0, 2, 0, }, }, 
	{"enter_scene", "", {27, 1, 1, 0, 3, 0, }, }, 
	{"enter_scene", "", {28, 1, 1, 0, 4, 0, }, }, 
	{"enter_scene", "", {29, 1, 1, 0, 5, 0, }, }, 
	{"enter_scene", "", {30, 1, 1, 0, 6, 0, }, }, 
	{"enter_scene", "", {31, 1, 1, 0, 7, 0, }, }, 
	{"enter_scene", "", {32, 1, 1, 0, 8, 0, }, }, 
}

function ClsAIBat_shark_221:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_shark_221:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_shark_221

----------------------- Auto Genrate End   --------------------
