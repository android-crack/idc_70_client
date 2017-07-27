----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_boss3_skill_221 = class("ClsAIBat_boss3_skill_221", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_boss3_skill_221:getId()
	return "bat_boss3_skill_221";
end


-- AI时机
function ClsAIBat_boss3_skill_221:getOpportunity()
	return AI_OPPORTUNITY.FIGHT_START;
end

-- AI优先级别
function ClsAIBat_boss3_skill_221:getPriority()
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
	{"add_skill", "", {1402, 2, }, }, 
	{"add_effect_to_ship", "", {1, "tx_longjuanfeng", 0, 0, 120, true, }, }, 
	{"add_effect_to_ship", "", {2, "tx_HitIce", 0, 30, 120, true, }, }, 
	{"add_effect_to_ship", "", {3, "tx_HitIce", 0, 50, 120, true, }, }, 
	{"add_effect_to_ship", "", {4, "tx_HitIce", 0, 70, 120, true, }, }, 
}

function ClsAIBat_boss3_skill_221:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_boss3_skill_221:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_boss3_skill_221

----------------------- Auto Genrate End   --------------------
