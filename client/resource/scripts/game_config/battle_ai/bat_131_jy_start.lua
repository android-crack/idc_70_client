----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[20]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_131_jy_start = class("ClsAIBat_131_jy_start", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_131_jy_start:getId()
	return "bat_131_jy_start";
end


-- AI时机
function ClsAIBat_131_jy_start:getOpportunity()
	return AI_OPPORTUNITY.FIGHT_START;
end

-- AI优先级别
function ClsAIBat_131_jy_start:getPriority()
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
	{"show_cloud", "", {120, 300, 640, 2450, 640, }, }, 
	{"play_plot", "", {{7, 8, }, }, }, 
	{"show_prompt", "", {T("敌人气血越低速度越快，别让走私船逃向目的地，漩涡会将船只摧毁"), }, }, 
	{"add_effect_to_scene", "", {1, "jiantou", 2450, 640, 120, }, }, 
	{"add_effect_to_scene", "", {2, "jiantou", 2450, 320, 120, }, }, 
	{"add_effect_to_scene", "", {3, "jiantou", 2450, 960, 120, }, }, 
	{"add_effect_to_scene", "", {4, "jiantou", 2450, 440, 120, }, }, 
	{"add_effect_to_scene", "", {5, "jiantou", 2450, 840, 120, }, }, 
}

function ClsAIBat_131_jy_start:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_131_jy_start:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_131_jy_start

----------------------- Auto Genrate End   --------------------
