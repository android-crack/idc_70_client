----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[玩家手动操作旗舰]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAISys_user_hand = class("ClsAISys_user_hand", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAISys_user_hand:getId()
	return "sys_user_hand";
end


-- AI时机
function ClsAISys_user_hand:getOpportunity()
	return AI_OPPORTUNITY.RUN;
end

-- AI优先级别
function ClsAISys_user_hand:getPriority()
	return 55;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"stop_ai", "", {{"sys_lock_far", "sys_lock_near", "sys_dodge", "sys_youyi", }, }, }, 
	{"delete_ai", "", {{"sys_dodge", "sys_youyi", "sys_lock_far", "sys_lock_near", "sys_autoskill", }, }, }, 
}

function ClsAISys_user_hand:getActions()
	return actions
end

local all_target_method = {
}

function ClsAISys_user_hand:getAllTargetMethod()
	return all_target_method
end

return ClsAISys_user_hand

----------------------- Auto Genrate End   --------------------
