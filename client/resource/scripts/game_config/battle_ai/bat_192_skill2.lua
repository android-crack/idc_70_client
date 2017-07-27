----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_192_skill2 = class("ClsAIBat_192_skill2", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_192_skill2:getId()
	return "bat_192_skill2";
end


-- AI时机
function ClsAIBat_192_skill2:getOpportunity()
	return AI_OPPORTUNITY.FIGHT_START;
end

-- AI优先级别
function ClsAIBat_192_skill2:getPriority()
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
	{"add_skill", "", {1010, 1, }, }, 
	{"add_skill", "", {1303, 1, "passive", }, }, 
}

function ClsAIBat_192_skill2:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_192_skill2:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_192_skill2

----------------------- Auto Genrate End   --------------------
