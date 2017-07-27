----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_12_wudi = class("ClsAIBat_12_wudi", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_12_wudi:getId()
	return "bat_12_wudi";
end


-- AI时机
function ClsAIBat_12_wudi:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIBat_12_wudi:getPriority()
	return 48;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- 本AI的判定条件
function ClsAIBat_12_wudi:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	
	return (hpless20)
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"add_status", "", {"wudi", }, }, 
	{"delete_ai", "", {{"bat_12_wudi", }, }, }, 
}

function ClsAIBat_12_wudi:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_12_wudi:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_12_wudi

----------------------- Auto Genrate End   --------------------
