----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[播放剧情]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_161_plot = class("ClsAIBat_161_plot", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_161_plot:getId()
	return "bat_161_plot";
end


-- AI时机
function ClsAIBat_161_plot:getOpportunity()
	return AI_OPPORTUNITY.FIGHT_START;
end

-- AI优先级别
function ClsAIBat_161_plot:getPriority()
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
	{"show_prompt", "", {T("海盗逃跑数量不能超过5艘，击沉首领，其它敌人将停止逃跑"), }, }, 
}

function ClsAIBat_161_plot:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_161_plot:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_161_plot

----------------------- Auto Genrate End   --------------------
