----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIZh_moto_3 = class("ClsAIZh_moto_3", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIZh_moto_3:getId()
	return "zh_moto_3";
end


-- AI时机
function ClsAIZh_moto_3:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIZh_moto_3:getPriority()
	return 2;
end

-- AI停止标记
function ClsAIZh_moto_3:getStopOtherFlg()
	return 2;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"move_to", "", {1200, 840, 60, }, }, 
	{"delete_ai", "", {{"zh_moto_3", }, }, }, 
}

function ClsAIZh_moto_3:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIZh_moto_3:getAllTargetMethod()
	return all_target_method
end

return ClsAIZh_moto_3

----------------------- Auto Genrate End   --------------------
