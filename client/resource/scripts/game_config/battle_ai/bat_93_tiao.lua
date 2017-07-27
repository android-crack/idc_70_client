----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_93_tiao = class("ClsAIBat_93_tiao", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_93_tiao:getId()
	return "bat_93_tiao";
end


-- AI时机
function ClsAIBat_93_tiao:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIBat_93_tiao:getPriority()
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
	{"add_skill", "", {1212, 1, "passive", }, }, 
	{"use_skill", "", {1212, }, }, 
}

function ClsAIBat_93_tiao:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_93_tiao:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_93_tiao

----------------------- Auto Genrate End   --------------------
