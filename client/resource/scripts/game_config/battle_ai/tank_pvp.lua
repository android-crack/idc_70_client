----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAITank_pvp = class("ClsAITank_pvp", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAITank_pvp:getId()
	return "tank_pvp";
end


-- AI时机
function ClsAITank_pvp:getOpportunity()
	return AI_OPPORTUNITY.FIGHT_START;
end

-- AI优先级别
function ClsAITank_pvp:getPriority()
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
	{"add_status", "", {"unstun", }, }, 
	{"add_status", "", {"unspeedable", }, }, 
	{"add_status", "", {"unmovable", }, }, 
}

function ClsAITank_pvp:getActions()
	return actions
end

local all_target_method = {
}

function ClsAITank_pvp:getAllTargetMethod()
	return all_target_method
end

return ClsAITank_pvp

----------------------- Auto Genrate End   --------------------
