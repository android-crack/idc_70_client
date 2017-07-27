----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_32_jy_status = class("ClsAIBat_32_jy_status", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_32_jy_status:getId()
	return "bat_32_jy_status";
end


-- AI时机
function ClsAIBat_32_jy_status:getOpportunity()
	return AI_OPPORTUNITY.FIGHT_START;
end

-- AI优先级别
function ClsAIBat_32_jy_status:getPriority()
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
	{"add_effect_to_ship", "", {2, "tx_qihuo", 0, 0, 150, true, }, }, 
}

function ClsAIBat_32_jy_status:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_32_jy_status:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_32_jy_status

----------------------- Auto Genrate End   --------------------
