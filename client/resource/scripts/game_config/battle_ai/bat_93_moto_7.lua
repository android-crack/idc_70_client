----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_93_moto_7 = class("ClsAIBat_93_moto_7", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_93_moto_7:getId()
	return "bat_93_moto_7";
end


-- AI时机
function ClsAIBat_93_moto_7:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIBat_93_moto_7:getPriority()
	return 48;
end

-- AI停止标记
function ClsAIBat_93_moto_7:getStopOtherFlg()
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
	{"move_to", "", {1000, 940, 60, }, }, 
	{"delete_ai", "", {{"bat_93_moto_7", }, }, }, 
}

function ClsAIBat_93_moto_7:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_93_moto_7:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_93_moto_7

----------------------- Auto Genrate End   --------------------
