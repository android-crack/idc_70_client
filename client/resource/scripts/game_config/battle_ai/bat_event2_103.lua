----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_event2_103 = class("ClsAIBat_event2_103", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_event2_103:getId()
	return "bat_event2_103";
end


-- AI时机
function ClsAIBat_event2_103:getOpportunity()
	return AI_OPPORTUNITY.RUN;
end

-- AI优先级别
function ClsAIBat_event2_103:getPriority()
	return -2;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"enter_scene", "", {13, 0, 0, 0, 8, 0, }, }, 
	{"enter_scene", "", {14, 0, 0, 0, 8, 0, }, }, 
	{"enter_scene", "", {15, 0, 0, 1, 8, 0, }, }, 
	{"enter_scene", "", {16, 0, 0, 0, 8, 0, }, }, 
	{"enter_scene", "", {17, 0, 0, 0, 8, 0, }, }, 
	{"play_plot", "", {{11, 12, }, }, }, 
	{"normal_mode", "", {}, }, 
	{"show_prompt", "", {T("利用被夺取的炮塔消灭敌军增援"), }, }, 
}

function ClsAIBat_event2_103:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_event2_103:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_event2_103

----------------------- Auto Genrate End   --------------------
