----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_effect1_103 = class("ClsAIBat_effect1_103", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_effect1_103:getId()
	return "bat_effect1_103";
end


-- AI时机
function ClsAIBat_effect1_103:getOpportunity()
	return AI_OPPORTUNITY.FIGHT_START;
end

-- AI优先级别
function ClsAIBat_effect1_103:getPriority()
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
	{"add_effect_to_ship", "", {1, "sf_tujin", 0, 0, 120, true, }, }, 
}

function ClsAIBat_effect1_103:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_effect1_103:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_effect1_103

----------------------- Auto Genrate End   --------------------
