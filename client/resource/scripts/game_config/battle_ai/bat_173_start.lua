----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_173_start = class("ClsAIBat_173_start", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_173_start:getId()
	return "bat_173_start";
end


-- AI时机
function ClsAIBat_173_start:getOpportunity()
	return AI_OPPORTUNITY.FIGHT_START;
end

-- AI优先级别
function ClsAIBat_173_start:getPriority()
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
	{"show_prompt", "", {T("自爆死士受到攻击会自杀式袭击，尽量避开他们"), }, }, 
}

function ClsAIBat_173_start:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_173_start:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_173_start

----------------------- Auto Genrate End   --------------------
