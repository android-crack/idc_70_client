----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_73_enter = class("ClsAIBat_73_enter", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_73_enter:getId()
	return "bat_73_enter";
end


-- AI时机
function ClsAIBat_73_enter:getOpportunity()
	return AI_OPPORTUNITY.FIGHT_START;
end

-- AI优先级别
function ClsAIBat_73_enter:getPriority()
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
	{"play_plot", "", {{1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, }, }, }, 
	{"show_prompt", "", {T("避开危险的耶稣号，击败霍金斯，霍金斯血量不足会逃跑到耶稣号身边补给。"), }, }, 
}

function ClsAIBat_73_enter:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_73_enter:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_73_enter

----------------------- Auto Genrate End   --------------------
