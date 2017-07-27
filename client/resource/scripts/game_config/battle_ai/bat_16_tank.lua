----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_16_tank = class("ClsAIBat_16_tank", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_16_tank:getId()
	return "bat_16_tank";
end


-- AI时机
function ClsAIBat_16_tank:getOpportunity()
	return AI_OPPORTUNITY.FIGHT_START;
end

-- AI优先级别
function ClsAIBat_16_tank:getPriority()
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
	{"add_status", "", {"unmovable", }, }, 
	{"add_status", "", {"unspeedable", }, }, 
	{"add_status", "", {"unstun", }, }, 
}

function ClsAIBat_16_tank:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_16_tank:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_16_tank

----------------------- Auto Genrate End   --------------------
