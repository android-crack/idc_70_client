----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_11_start = class("ClsAIBat_11_start", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_11_start:getId()
	return "bat_11_start";
end


-- AI时机
function ClsAIBat_11_start:getOpportunity()
	return AI_OPPORTUNITY.FIGHT_START;
end

-- AI优先级别
function ClsAIBat_11_start:getPriority()
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
	{"story_mode", "", {}, }, 
	{"play_plot", "", {{1, }, }, }, 
	{"hide_ship_ui", "", {}, }, 
}

function ClsAIBat_11_start:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_11_start:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_11_start

----------------------- Auto Genrate End   --------------------
