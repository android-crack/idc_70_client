----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_43_moto = class("ClsAIBat_43_moto", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_43_moto:getId()
	return "bat_43_moto";
end


-- AI时机
function ClsAIBat_43_moto:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIBat_43_moto:getPriority()
	return 48;
end

-- AI停止标记
function ClsAIBat_43_moto:getStopOtherFlg()
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
	{"move_to", "", {1980, 840, 50, }, }, 
	{"move_to", "", {2380, 840, 50, }, }, 
	{"move_to", "", {2380, 440, 50, }, }, 
	{"move_to", "", {1980, 440, 50, }, }, 
}

function ClsAIBat_43_moto:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_43_moto:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_43_moto

----------------------- Auto Genrate End   --------------------
