----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAISet_cloud_02 = class("ClsAISet_cloud_02", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAISet_cloud_02:getId()
	return "set_cloud_02";
end


-- AI时机
function ClsAISet_cloud_02:getOpportunity()
	return AI_OPPORTUNITY.FIGHT_START;
end

-- AI优先级别
function ClsAISet_cloud_02:getPriority()
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
	{"show_cloud", "", {80, 1728, 512, 1728, 512, }, }, 
	{"show_cloud", "", {80, 1728, 512, 1728, 512, }, }, 
	{"show_cloud", "", {80, 1728, 512, 1728, 512, }, }, 
	{"show_cloud", "", {80, 1728, 512, 1728, 512, }, }, 
	{"show_cloud", "", {80, 1728, 512, 1728, 512, }, }, 
}

function ClsAISet_cloud_02:getActions()
	return actions
end

local all_target_method = {
}

function ClsAISet_cloud_02:getAllTargetMethod()
	return all_target_method
end

return ClsAISet_cloud_02

----------------------- Auto Genrate End   --------------------
