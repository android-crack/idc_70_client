----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_11_playermove = class("ClsAIBat_11_playermove", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_11_playermove:getId()
	return "bat_11_playermove";
end


-- AI时机
function ClsAIBat_11_playermove:getOpportunity()
	return AI_OPPORTUNITY.FIGHT_START;
end

-- AI优先级别
function ClsAIBat_11_playermove:getPriority()
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
	{"move_to", "", {800, 640, 50, }, }, 
	{"add_ai", "", {{"bat_11_stop", }, }, }, 
}

function ClsAIBat_11_playermove:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_11_playermove:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_11_playermove

----------------------- Auto Genrate End   --------------------
