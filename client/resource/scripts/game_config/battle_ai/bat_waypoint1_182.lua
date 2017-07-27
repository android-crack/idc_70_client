----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[指引路径1]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_waypoint1_182 = class("ClsAIBat_waypoint1_182", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_waypoint1_182:getId()
	return "bat_waypoint1_182";
end


-- AI时机
function ClsAIBat_waypoint1_182:getOpportunity()
	return AI_OPPORTUNITY.RUN;
end

-- AI优先级别
function ClsAIBat_waypoint1_182:getPriority()
	return -2;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"guide_point", "", {1600, 640, }, }, 
}

function ClsAIBat_waypoint1_182:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_waypoint1_182:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_waypoint1_182

----------------------- Auto Genrate End   --------------------
