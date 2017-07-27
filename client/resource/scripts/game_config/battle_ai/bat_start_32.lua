----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[1→30]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_start_32 = class("ClsAIBat_start_32", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_start_32:getId()
	return "bat_start_32";
end


-- AI时机
function ClsAIBat_start_32:getOpportunity()
	return AI_OPPORTUNITY.FIGHT_START;
end

-- AI优先级别
function ClsAIBat_start_32:getPriority()
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
	{"play_plot", "", {{1, 2, 6, 13, 14, 7, }, }, }, 
	{"show_prompt", "", {T("尝试着拯救商船，美人鱼可以大幅提升攻击力"), }, }, 
	{"guide_point", "", {1645, 450, }, }, 
	{"delay", "", {10000, }, }, 
	{"play_plot", "", {{15, }, }, }, 
}

function ClsAIBat_start_32:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_start_32:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_start_32

----------------------- Auto Genrate End   --------------------
