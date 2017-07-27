----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[戴肯释法]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_13_dk_sf = class("ClsAIBat_13_dk_sf", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_13_dk_sf:getId()
	return "bat_13_dk_sf";
end


-- AI时机
function ClsAIBat_13_dk_sf:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIBat_13_dk_sf:getPriority()
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
	{"add_skill", "", {10003, 1, "passive", }, }, 
	{"use_skill", "", {10003, }, }, 
	{"delay", "", {1000, }, }, 
	{"add_skill", "", {3501, 1, "passive", }, }, 
	{"use_skill", "", {3501, }, }, 
}

function ClsAIBat_13_dk_sf:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_13_dk_sf:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_13_dk_sf

----------------------- Auto Genrate End   --------------------
