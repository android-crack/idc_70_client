----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_71_jy_moto_2 = class("ClsAIBat_71_jy_moto_2", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_71_jy_moto_2:getId()
	return "bat_71_jy_moto_2";
end


-- AI时机
function ClsAIBat_71_jy_moto_2:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIBat_71_jy_moto_2:getPriority()
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
	{"move_to", "", {1580, 943, 100, }, }, 
	{"delete_ai", "", {{"bat_71_jy_moto_2", }, }, }, 
}

function ClsAIBat_71_jy_moto_2:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_71_jy_moto_2:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_71_jy_moto_2

----------------------- Auto Genrate End   --------------------
