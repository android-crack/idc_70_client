----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_11_shark = class("ClsAIBat_11_shark", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_11_shark:getId()
	return "bat_11_shark";
end


-- AI时机
function ClsAIBat_11_shark:getOpportunity()
	return AI_OPPORTUNITY.RUN;
end

-- AI优先级别
function ClsAIBat_11_shark:getPriority()
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
	{"enter_scene", "", {5, 1, 0, 0, 6, 0, }, }, 
	{"enter_scene", "", {6, 1, 0, 0, 8, 0, }, }, 
	{"enter_scene", "", {7, 1, 0, 0, 6, 0, }, }, 
	{"enter_scene", "", {8, 1, 0, 0, 8, 0, }, }, 
}

function ClsAIBat_11_shark:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_11_shark:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_11_shark

----------------------- Auto Genrate End   --------------------
