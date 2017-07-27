----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[玩家自动战斗旗舰行为]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAISys_user_autofight_pve = class("ClsAISys_user_autofight_pve", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAISys_user_autofight_pve:getId()
	return "sys_user_autofight_pve";
end


-- AI时机
function ClsAISys_user_autofight_pve:getOpportunity()
	return AI_OPPORTUNITY.RUN;
end

-- AI优先级别
function ClsAISys_user_autofight_pve:getPriority()
	return 54;
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

function ClsAISys_user_autofight_pve:getActions()
	return actions
end

local all_target_method = {
}

function ClsAISys_user_autofight_pve:getAllTargetMethod()
	return all_target_method
end

return ClsAISys_user_autofight_pve

----------------------- Auto Genrate End   --------------------
