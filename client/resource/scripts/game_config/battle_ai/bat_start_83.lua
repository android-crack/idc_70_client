----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[1]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_start_83 = class("ClsAIBat_start_83", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_start_83:getId()
	return "bat_start_83";
end


-- AI时机
function ClsAIBat_start_83:getOpportunity()
	return AI_OPPORTUNITY.FIGHT_START;
end

-- AI优先级别
function ClsAIBat_start_83:getPriority()
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
	{"play_plot", "", {{1, 2, 3, 4, }, }, }, 
	{"show_prompt", "", {T("护送6艘平民船安全逃离，平民船死亡数量不能超过6"), }, }, 
}

function ClsAIBat_start_83:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_start_83:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_start_83

----------------------- Auto Genrate End   --------------------
