----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[清除系统AI]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAISys_clear = class("ClsAISys_clear", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAISys_clear:getId()
	return "sys_clear";
end


-- AI时机
function ClsAISys_clear:getOpportunity()
	return AI_OPPORTUNITY.RUN;
end

-- AI优先级别
function ClsAISys_clear:getPriority()
	return 53;
end

-- AI停止标记
function ClsAISys_clear:getStopOtherFlg()
	return 53;
end

-- AI删除标记
function ClsAISys_clear:getDeleteOtherFlg()
	return 53;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

--------------------------- 动作函数区结束 ------------------------------

local actions = {
}

function ClsAISys_clear:getActions()
	return actions
end

local all_target_method = {
}

function ClsAISys_clear:getAllTargetMethod()
	return all_target_method
end

return ClsAISys_clear

----------------------- Auto Genrate End   --------------------
