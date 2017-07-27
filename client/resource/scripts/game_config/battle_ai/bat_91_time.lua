----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_91_time = class("ClsAIBat_91_time", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_91_time:getId()
	return "bat_91_time";
end


-- AI时机
function ClsAIBat_91_time:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIBat_91_time:getPriority()
	return 1;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndBat_91_time(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- 战斗已进行时间
	local BattleTime = battleData:getBattleTime();
	-- 战斗进行时间>=10000
	if ( not (BattleTime>=10000) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIBat_91_time:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndBat_91_time(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"enter_scene", "", {17, 0, 0, 0, 7, 0, }, }, 
	{"enter_scene", "", {18, 0, 0, 0, 7, 0, }, }, 
	{"delete_ai", "", {{"bat_91_time", }, }, }, 
}

function ClsAIBat_91_time:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_91_time:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_91_time

----------------------- Auto Genrate End   --------------------
