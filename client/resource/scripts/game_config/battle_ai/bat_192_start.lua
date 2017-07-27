----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_192_start = class("ClsAIBat_192_start", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_192_start:getId()
	return "bat_192_start";
end


-- AI时机
function ClsAIBat_192_start:getOpportunity()
	return AI_OPPORTUNITY.FIGHT_START;
end

-- AI优先级别
function ClsAIBat_192_start:getPriority()
	return 10;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"show_prompt", "", {T("敌方旗舰血量越低，部分属性越强，优先集火其中一艘旗舰"), }, }, 
	{"play_plot", "", {{1, }, }, }, 
}

function ClsAIBat_192_start:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_192_start:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_192_start

----------------------- Auto Genrate End   --------------------
