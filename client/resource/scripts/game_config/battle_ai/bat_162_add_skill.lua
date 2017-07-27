----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_162_add_skill = class("ClsAIBat_162_add_skill", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_162_add_skill:getId()
	return "bat_162_add_skill";
end


-- AI时机
function ClsAIBat_162_add_skill:getOpportunity()
	return AI_OPPORTUNITY.FIGHT_START;
end

-- AI优先级别
function ClsAIBat_162_add_skill:getPriority()
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
	{"add_skill", "", {1209, 1, "passive", }, }, 
	{"stop_ai", "", {{"sys_lock_far", }, }, }, 
	{"delete_ai", "", {{"sys_lock_far", }, }, }, 
}

function ClsAIBat_162_add_skill:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_162_add_skill:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_162_add_skill

----------------------- Auto Genrate End   --------------------
