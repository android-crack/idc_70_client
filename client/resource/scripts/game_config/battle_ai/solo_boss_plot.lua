----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[高级海盗进场延迟2秒说话]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAISolo_boss_plot = class("ClsAISolo_boss_plot", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAISolo_boss_plot:getId()
	return "solo_boss_plot";
end


-- AI时机
function ClsAISolo_boss_plot:getOpportunity()
	return AI_OPPORTUNITY.FIGHT_START;
end

-- AI优先级别
function ClsAISolo_boss_plot:getPriority()
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
	{"play_plot", "", {{5, 6, 7, 8, }, }, }, 
}

function ClsAISolo_boss_plot:getActions()
	return actions
end

local all_target_method = {
}

function ClsAISolo_boss_plot:getAllTargetMethod()
	return all_target_method
end

return ClsAISolo_boss_plot

----------------------- Auto Genrate End   --------------------
