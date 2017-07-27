----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[增加群体齐射技能]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_163_add_skill = class("ClsAIBat_163_add_skill", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_163_add_skill:getId()
	return "bat_163_add_skill";
end


-- AI时机
function ClsAIBat_163_add_skill:getOpportunity()
	return AI_OPPORTUNITY.FIGHT_START;
end

-- AI优先级别
function ClsAIBat_163_add_skill:getPriority()
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
	{"add_skill", "", {10003, 1, "passive", }, }, 
	{"play_plot", "", {{1, 2, 3, 4, }, }, }, 
	{"show_prompt", "", {T("如果近战攻击到巴巴罗萨，他会施放群体齐射。"), }, }, 
}

function ClsAIBat_163_add_skill:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_163_add_skill:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_163_add_skill

----------------------- Auto Genrate End   --------------------
