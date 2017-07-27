----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_93_jy_moto_10 = class("ClsAIBat_93_jy_moto_10", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_93_jy_moto_10:getId()
	return "bat_93_jy_moto_10";
end


-- AI时机
function ClsAIBat_93_jy_moto_10:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIBat_93_jy_moto_10:getPriority()
	return 1;
end

-- AI停止标记
function ClsAIBat_93_jy_moto_10:getStopOtherFlg()
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
	{"move_to", "", {550, 540, 60, }, }, 
	{"delete_ai", "", {{"bat_93_jy_moto_10", }, }, }, 
}

function ClsAIBat_93_jy_moto_10:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_93_jy_moto_10:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_93_jy_moto_10

----------------------- Auto Genrate End   --------------------
