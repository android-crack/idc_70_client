----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_11_lbsmove = class("ClsAIBat_11_lbsmove", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_11_lbsmove:getId()
	return "bat_11_lbsmove";
end


-- AI时机
function ClsAIBat_11_lbsmove:getOpportunity()
	return AI_OPPORTUNITY.FIGHT_START;
end

-- AI优先级别
function ClsAIBat_11_lbsmove:getPriority()
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
	{"move_to", "", {900, 640, 5, }, }, 
	{"add_ai", "", {{"bat_11_stop", }, }, }, 
	{"run_ai", "", {{"bat_11_camera", }, }, }, 
}

function ClsAIBat_11_lbsmove:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_11_lbsmove:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_11_lbsmove

----------------------- Auto Genrate End   --------------------
