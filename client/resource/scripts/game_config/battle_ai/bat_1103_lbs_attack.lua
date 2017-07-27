----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[拉比斯齐射鲨鱼]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_1103_lbs_attack = class("ClsAIBat_1103_lbs_attack", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_1103_lbs_attack:getId()
	return "bat_1103_lbs_attack";
end


-- AI时机
function ClsAIBat_1103_lbs_attack:getOpportunity()
	return AI_OPPORTUNITY.FIGHT_START;
end

-- AI优先级别
function ClsAIBat_1103_lbs_attack:getPriority()
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
	{"add_skill", "", {3201, 10, "passive", }, }, 
	{"move_to", "", {935, 800, 50, }, }, 
	{"use_skill", "", {3201, }, }, 
}

function ClsAIBat_1103_lbs_attack:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_1103_lbs_attack:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_1103_lbs_attack

----------------------- Auto Genrate End   --------------------
