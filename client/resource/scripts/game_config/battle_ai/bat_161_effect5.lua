----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[增加轨迹特效]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_161_effect5 = class("ClsAIBat_161_effect5", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_161_effect5:getId()
	return "bat_161_effect5";
end


-- AI时机
function ClsAIBat_161_effect5:getOpportunity()
	return AI_OPPORTUNITY.FIGHT_START;
end

-- AI优先级别
function ClsAIBat_161_effect5:getPriority()
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
	{"guide_point", "", {691, 195, }, }, 
}

function ClsAIBat_161_effect5:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_161_effect5:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_161_effect5

----------------------- Auto Genrate End   --------------------
