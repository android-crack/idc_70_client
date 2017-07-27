----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_172_plot = class("ClsAIBat_172_plot", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_172_plot:getId()
	return "bat_172_plot";
end


-- AI时机
function ClsAIBat_172_plot:getOpportunity()
	return AI_OPPORTUNITY.FIGHT_START;
end

-- AI优先级别
function ClsAIBat_172_plot:getPriority()
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
	{"play_plot", "", {{1, 2, 3, 4, 5, 6, }, }, }, 
	{"show_prompt", "", {T("击沉敌方防御舰来削弱德雷克副手的防御"), }, }, 
}

function ClsAIBat_172_plot:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_172_plot:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_172_plot

----------------------- Auto Genrate End   --------------------
