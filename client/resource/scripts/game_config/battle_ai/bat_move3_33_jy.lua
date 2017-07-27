----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[17]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_move3_33_jy = class("ClsAIBat_move3_33_jy", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_move3_33_jy:getId()
	return "bat_move3_33_jy";
end


-- AI时机
function ClsAIBat_move3_33_jy:getOpportunity()
	return AI_OPPORTUNITY.FIGHT_START;
end

-- AI优先级别
function ClsAIBat_move3_33_jy:getPriority()
	return 1;
end

-- AI停止标记
function ClsAIBat_move3_33_jy:getStopOtherFlg()
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
	{"move_to", "", {2300, 900, 50, }, }, 
}

function ClsAIBat_move3_33_jy:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_move3_33_jy:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_move3_33_jy

----------------------- Auto Genrate End   --------------------
