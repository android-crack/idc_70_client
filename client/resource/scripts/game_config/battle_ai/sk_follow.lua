----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[嘲讽技能专用]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAISk_follow = class("ClsAISk_follow", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAISk_follow:getId()
	return "sk_follow";
end


-- AI时机
function ClsAISk_follow:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAISk_follow:getPriority()
	return -1;
end

-- AI停止标记
function ClsAISk_follow:getStopOtherFlg()
	return -1;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"follow", "", {100, }, }, 
}

function ClsAISk_follow:getActions()
	return actions
end

local all_target_method = {
}

function ClsAISk_follow:getAllTargetMethod()
	return all_target_method
end

return ClsAISk_follow

----------------------- Auto Genrate End   --------------------
