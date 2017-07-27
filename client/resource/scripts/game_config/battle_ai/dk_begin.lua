----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIDk_begin = class("ClsAIDk_begin", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIDk_begin:getId()
	return "dk_begin";
end


-- AI时机
function ClsAIDk_begin:getOpportunity()
	return AI_OPPORTUNITY.FIGHT_START;
end

-- AI优先级别
function ClsAIDk_begin:getPriority()
	return 2;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"play_plot", "", {{1, 2, 3, }, }, }, 
	{"show_prompt", "", {T("避开龙卷风，战斗时间越久，龙卷风数量越多。"), }, }, 
}

function ClsAIDk_begin:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIDk_begin:getAllTargetMethod()
	return all_target_method
end

return ClsAIDk_begin

----------------------- Auto Genrate End   --------------------
