----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_16_tiao = class("ClsAIBat_16_tiao", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_16_tiao:getId()
	return "bat_16_tiao";
end


-- AI时机
function ClsAIBat_16_tiao:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIBat_16_tiao:getPriority()
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
	{"add_skill", "", {4201, 1, "passive", }, }, 
	{"use_skill", "", {4201, }, }, 
	{"delay", "", {1000, }, }, 
	{"add_skill", "", {10003, 1, "passive", }, }, 
	{"use_skill", "", {10003, }, }, 
	{"delay", "", {1000, }, }, 
	{"add_skill", "", {10001, 1, "passive", }, }, 
	{"use_skill", "", {10001, }, }, 
	{"delay", "", {1000, }, }, 
	{"add_skill", "", {10002, 1, "passive", }, }, 
	{"use_skill", "", {10002, }, }, 
}

function ClsAIBat_16_tiao:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_16_tiao:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_16_tiao

----------------------- Auto Genrate End   --------------------
