----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_1301_start = class("ClsAIBat_1301_start", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_1301_start:getId()
	return "bat_1301_start";
end


-- AI时机
function ClsAIBat_1301_start:getOpportunity()
	return AI_OPPORTUNITY.FIGHT_START;
end

-- AI优先级别
function ClsAIBat_1301_start:getPriority()
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
	{"add_skill", "", {5501, 1, "", 4, }, }, 
	{"add_skill", "", {5101, 1, "", 1, }, }, 
	{"add_skill", "", {5301, 1, "", 2, }, }, 
	{"add_skill", "", {5201, 1, "", 3, }, }, 
	{"add_skill", "", {9001, 5, "", 5, }, }, 
}

function ClsAIBat_1301_start:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_1301_start:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_1301_start

----------------------- Auto Genrate End   --------------------
