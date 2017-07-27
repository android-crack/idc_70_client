----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_1021_event = class("ClsAIBat_1021_event", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_1021_event:getId()
	return "bat_1021_event";
end


-- AI时机
function ClsAIBat_1021_event:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIBat_1021_event:getPriority()
	return 1;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndBat_21_time_3(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- 战斗已进行时间
	local BattleTime = battleData:getBattleTime();
	-- 战斗进行时间>2000
	if ( not (BattleTime>2000) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIBat_1021_event:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndBat_21_time_3(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"play_plot", "", {{6, 7, }, }, }, 
	{"delete_ai", "", {{"bat_1021_event", }, }, }, 
}

function ClsAIBat_1021_event:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_1021_event:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_1021_event

----------------------- Auto Genrate End   --------------------
