----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_93_bigboom = class("ClsAIBat_93_bigboom", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_93_bigboom:getId()
	return "bat_93_bigboom";
end


-- AI时机
function ClsAIBat_93_bigboom:getOpportunity()
	return AI_OPPORTUNITY.RUN;
end

-- AI优先级别
function ClsAIBat_93_bigboom:getPriority()
	return -2;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"add_effect_to_ship", "", {1, "tx_judian_boom", -50, 0, 3, true, }, }, 
	{"add_effect_to_ship", "", {2, "tx_judian_boom", 50, 0, 3, true, }, }, 
	{"add_effect_to_ship", "", {3, "tx_judian_boom", 0, 50, 3, true, }, }, 
	{"add_effect_to_ship", "", {4, "tx_judian_boom", 0, -50, 3, true, }, }, 
	{"add_effect_to_ship", "", {5, "tx_judian_boom", -200, 0, 3, true, }, }, 
	{"add_effect_to_ship", "", {6, "tx_judian_boom", 200, 0, 3, true, }, }, 
	{"add_effect_to_ship", "", {7, "tx_judian_boom", 0, 200, 3, true, }, }, 
	{"add_effect_to_ship", "", {8, "tx_judian_boom", 0, -200, 3, true, }, }, 
}

function ClsAIBat_93_bigboom:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_93_bigboom:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_93_bigboom

----------------------- Auto Genrate End   --------------------
