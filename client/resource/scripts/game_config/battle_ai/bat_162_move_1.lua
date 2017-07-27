----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_162_move_1 = class("ClsAIBat_162_move_1", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_162_move_1:getId()
	return "bat_162_move_1";
end


-- AI时机
function ClsAIBat_162_move_1:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIBat_162_move_1:getPriority()
	return 48;
end

-- AI停止标记
function ClsAIBat_162_move_1:getStopOtherFlg()
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
	{"move_to", "", {1280, 980, 50, }, }, 
	{"move_to", "", {1880, 980, 50, }, }, 
	{"move_to", "", {1880, 300, 50, }, }, 
	{"move_to", "", {1280, 300, 50, }, }, 
	{"move_to", "", {680, 300, 50, }, }, 
	{"move_to", "", {680, 980, 50, }, }, 
}

function ClsAIBat_162_move_1:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_162_move_1:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_162_move_1

----------------------- Auto Genrate End   --------------------
