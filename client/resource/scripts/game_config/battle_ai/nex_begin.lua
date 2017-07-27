----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[播放剧情]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAINex_begin = class("ClsAINex_begin", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAINex_begin:getId()
	return "nex_begin";
end


-- AI时机
function ClsAINex_begin:getOpportunity()
	return AI_OPPORTUNITY.FIGHT_START;
end

-- AI优先级别
function ClsAINex_begin:getPriority()
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
	{"play_plot", "", {{1, 2, 3, 4, 5, }, }, }, 
	{"show_prompt", "", {T("纳尔逊耐久低于50%后会有新增援军"), }, }, 
}

function ClsAINex_begin:getActions()
	return actions
end

local all_target_method = {
}

function ClsAINex_begin:getAllTargetMethod()
	return all_target_method
end

return ClsAINex_begin

----------------------- Auto Genrate End   --------------------
