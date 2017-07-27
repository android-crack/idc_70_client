----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_71_jy_enter = class("ClsAIBat_71_jy_enter", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_71_jy_enter:getId()
	return "bat_71_jy_enter";
end


-- AI时机
function ClsAIBat_71_jy_enter:getOpportunity()
	return AI_OPPORTUNITY.FIGHT_START;
end

-- AI优先级别
function ClsAIBat_71_jy_enter:getPriority()
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
	{"play_plot", "", {{1, 2, 3, 7, 4, }, }, }, 
	{"show_prompt", "", {T("主舰靠近非洲船，救出非洲船。"), }, }, 
}

function ClsAIBat_71_jy_enter:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_71_jy_enter:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_71_jy_enter

----------------------- Auto Genrate End   --------------------
