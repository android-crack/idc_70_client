----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIPve15_werck_effect = class("ClsAIPve15_werck_effect", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIPve15_werck_effect:getId()
	return "pve15_werck_effect";
end


-- AI时机
function ClsAIPve15_werck_effect:getOpportunity()
	return AI_OPPORTUNITY.FIGHT_START;
end

-- AI优先级别
function ClsAIPve15_werck_effect:getPriority()
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
	{"add_effect_to_ship", "", {2, "tx_0152", 0, 0, 120, true, }, }, 
}

function ClsAIPve15_werck_effect:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIPve15_werck_effect:getAllTargetMethod()
	return all_target_method
end

return ClsAIPve15_werck_effect

----------------------- Auto Genrate End   --------------------
