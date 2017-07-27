----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_191_skill_3 = class("ClsAIBat_191_skill_3", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_191_skill_3:getId()
	return "bat_191_skill_3";
end


-- AI时机
function ClsAIBat_191_skill_3:getOpportunity()
	return AI_OPPORTUNITY.FIGHT_START;
end

-- AI优先级别
function ClsAIBat_191_skill_3:getPriority()
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
	{"add_effect_to_ship", "", {6, "tx_HitIce", 0, 30, 60, true, }, }, 
	{"add_effect_to_ship", "", {7, "tx_HitIce", 0, 50, 60, true, }, }, 
	{"add_effect_to_ship", "", {8, "tx_HitIce", 0, 70, 60, true, }, }, 
}

function ClsAIBat_191_skill_3:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_191_skill_3:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_191_skill_3

----------------------- Auto Genrate End   --------------------
