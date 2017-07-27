----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_53_enter = class("ClsAIBat_53_enter", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_53_enter:getId()
	return "bat_53_enter";
end


-- AI时机
function ClsAIBat_53_enter:getOpportunity()
	return AI_OPPORTUNITY.FIGHT_START;
end

-- AI优先级别
function ClsAIBat_53_enter:getPriority()
	return 48;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"forge_weather", "", {120, }, }, 
	{"play_plot", "", {{1, 2, 3, 4, 5, }, }, }, 
	{"show_prompt", "", {T("先攻击护卫船，瓦解他们防线，最后围歼“雄鹰”"), }, }, 
}

function ClsAIBat_53_enter:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_53_enter:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_53_enter

----------------------- Auto Genrate End   --------------------
