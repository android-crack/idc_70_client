----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAISolo_boss_end_battle = class("ClsAISolo_boss_end_battle", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAISolo_boss_end_battle:getId()
	return "solo_boss_end_battle";
end


-- AI时机
function ClsAISolo_boss_end_battle:getOpportunity()
	return AI_OPPORTUNITY.RUN;
end

-- AI优先级别
function ClsAISolo_boss_end_battle:getPriority()
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
	{"play_plot", "", {{4, }, }, }, 
	{"show_kill_rank", "", {}, }, 
	{"guide", "", {50, 650, 245, }, }, 
	{"battle_stop", "", {1, }, }, 
}

function ClsAISolo_boss_end_battle:getActions()
	return actions
end

local all_target_method = {
}

function ClsAISolo_boss_end_battle:getAllTargetMethod()
	return all_target_method
end

return ClsAISolo_boss_end_battle

----------------------- Auto Genrate End   --------------------
