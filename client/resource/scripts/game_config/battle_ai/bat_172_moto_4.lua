----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[巡逻]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_172_moto_4 = class("ClsAIBat_172_moto_4", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_172_moto_4:getId()
	return "bat_172_moto_4";
end


-- AI时机
function ClsAIBat_172_moto_4:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIBat_172_moto_4:getPriority()
	return 1;
end

-- AI停止标记
function ClsAIBat_172_moto_4:getStopOtherFlg()
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
	{"move_to", "", {1280, 300, 50, }, }, 
	{"move_to", "", {680, 300, 50, }, }, 
	{"move_to", "", {680, 980, 50, }, }, 
	{"move_to", "", {1280, 980, 50, }, }, 
	{"move_to", "", {1880, 980, 50, }, }, 
	{"move_to", "", {1880, 300, 50, }, }, 
}

function ClsAIBat_172_moto_4:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_172_moto_4:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_172_moto_4

----------------------- Auto Genrate End   --------------------
