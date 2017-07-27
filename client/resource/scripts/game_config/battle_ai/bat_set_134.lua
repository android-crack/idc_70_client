----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_set_134 = class("ClsAIBat_set_134", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_set_134:getId()
	return "bat_set_134";
end


-- AI时机
function ClsAIBat_set_134:getOpportunity()
	return AI_OPPORTUNITY.FIGHT_START;
end

-- AI优先级别
function ClsAIBat_set_134:getPriority()
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
	{"add_effect_to_ship", "", {1, "tx_qihuo", 0, 0, 120, true, }, }, 
	{"add_ai", "", {{"autohp_134", }, }, }, 
}

function ClsAIBat_set_134:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_set_134:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_set_134

----------------------- Auto Genrate End   --------------------
