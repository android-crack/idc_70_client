----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_16_prophet_effect = class("ClsAIBat_16_prophet_effect", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_16_prophet_effect:getId()
	return "bat_16_prophet_effect";
end


-- AI时机
function ClsAIBat_16_prophet_effect:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIBat_16_prophet_effect:getPriority()
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
	{"add_effect_to_ship", "", {2, "tx_attack_up", 0, 0, 120, true, }, }, 
	{"add_status", "", {"wudi", }, }, 
	{"delete_ai", "", {{"bat_16_prophet_effect", }, }, }, 
}

function ClsAIBat_16_prophet_effect:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_16_prophet_effect:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_16_prophet_effect

----------------------- Auto Genrate End   --------------------
