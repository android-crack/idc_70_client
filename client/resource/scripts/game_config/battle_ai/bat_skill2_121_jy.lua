----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[10]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_skill2_121_jy = class("ClsAIBat_skill2_121_jy", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_skill2_121_jy:getId()
	return "bat_skill2_121_jy";
end


-- AI时机
function ClsAIBat_skill2_121_jy:getOpportunity()
	return AI_OPPORTUNITY.FIGHT_START;
end

-- AI优先级别
function ClsAIBat_skill2_121_jy:getPriority()
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
	{"add_skill", "", {1018, 1, }, }, 
}

function ClsAIBat_skill2_121_jy:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_skill2_121_jy:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_skill2_121_jy

----------------------- Auto Genrate End   --------------------
