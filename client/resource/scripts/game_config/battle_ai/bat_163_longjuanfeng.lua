----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_163_longjuanfeng = class("ClsAIBat_163_longjuanfeng", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_163_longjuanfeng:getId()
	return "bat_163_longjuanfeng";
end


-- AI时机
function ClsAIBat_163_longjuanfeng:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIBat_163_longjuanfeng:getPriority()
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
	{"delay", "", {10000, }, }, 
	{"enter_scene", "", {3, 1, 1, 0, 1, 0, }, }, 
}

function ClsAIBat_163_longjuanfeng:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_163_longjuanfeng:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_163_longjuanfeng

----------------------- Auto Genrate End   --------------------
