----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_11_status = class("ClsAIBat_11_status", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_11_status:getId()
	return "bat_11_status";
end


-- AI时机
function ClsAIBat_11_status:getOpportunity()
	return AI_OPPORTUNITY.FIGHT_START;
end

-- AI优先级别
function ClsAIBat_11_status:getPriority()
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
	{"add_status", "", {"dis_turn", }, }, 
	{"add_status", "", {"unstun", }, }, 
}

function ClsAIBat_11_status:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_11_status:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_11_status

----------------------- Auto Genrate End   --------------------
