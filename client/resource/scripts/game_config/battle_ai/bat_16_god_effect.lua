----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_16_god_effect = class("ClsAIBat_16_god_effect", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_16_god_effect:getId()
	return "bat_16_god_effect";
end


-- AI时机
function ClsAIBat_16_god_effect:getOpportunity()
	return AI_OPPORTUNITY.FIGHT_START;
end

-- AI优先级别
function ClsAIBat_16_god_effect:getPriority()
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
	{"add_effect_to_ship", "", {1, "tx_attack_up", 0, 0, 120, true, }, }, 
	{"add_effect_to_ship", "", {2, "tx_attack_up", 0, 0, 120, true, }, }, 
	{"add_effect_to_ship", "", {3, "tx_attack_up", 0, 0, 120, true, }, }, 
	{"add_effect_to_ship", "", {4, "sf_tujin", 0, 0, 120, true, }, }, 
	{"add_effect_to_ship", "", {5, "sf_tujin", 0, 0, 120, true, }, }, 
	{"add_effect_to_ship", "", {6, "sf_tujin", 0, 0, 120, true, }, }, 
}

function ClsAIBat_16_god_effect:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_16_god_effect:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_16_god_effect

----------------------- Auto Genrate End   --------------------
