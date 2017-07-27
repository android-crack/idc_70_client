----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[1→40]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_start_33_jy = class("ClsAIBat_start_33_jy", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_start_33_jy:getId()
	return "bat_start_33_jy";
end


-- AI时机
function ClsAIBat_start_33_jy:getOpportunity()
	return AI_OPPORTUNITY.FIGHT_START;
end

-- AI优先级别
function ClsAIBat_start_33_jy:getPriority()
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
	{"forge_weather", "", {120, }, }, 
	{"play_plot", "", {{1, 2, 3, 4, 5, 6, 7, 8, }, }, }, 
	{"show_prompt", "", {T("保护奥斯曼海盗，奥斯曼海盗不能死亡。"), }, }, 
}

function ClsAIBat_start_33_jy:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_start_33_jy:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_start_33_jy

----------------------- Auto Genrate End   --------------------
