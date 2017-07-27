----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_72_enter = class("ClsAIBat_72_enter", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_72_enter:getId()
	return "bat_72_enter";
end


-- AI时机
function ClsAIBat_72_enter:getOpportunity()
	return AI_OPPORTUNITY.FIGHT_START;
end

-- AI优先级别
function ClsAIBat_72_enter:getPriority()
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
	{"play_plot", "", {{1, 2, 3, 4, 6, 5, }, }, }, 
	{"show_prompt", "", {T("若击沉英国军舰，奴隶船不再攻击我方。"), }, }, 
}

function ClsAIBat_72_enter:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_72_enter:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_72_enter

----------------------- Auto Genrate End   --------------------
