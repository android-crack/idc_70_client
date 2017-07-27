----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_92_enemy_enter_3 = class("ClsAIBat_92_enemy_enter_3", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_92_enemy_enter_3:getId()
	return "bat_92_enemy_enter_3";
end


-- AI时机
function ClsAIBat_92_enemy_enter_3:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIBat_92_enemy_enter_3:getPriority()
	return 1;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndBat_92_enemy_enter_3(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- math.abs(1662 - OX) < 100
	if ( not (math.abs(1662 - owner:getPositionX()) < 100) ) then  return false end

	-- math.abs(574 - OY) < 100
	if ( not (math.abs(574 - owner:getPositionY()) < 100) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIBat_92_enemy_enter_3:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndBat_92_enemy_enter_3(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"enter_scene", "", {12, }, }, 
	{"enter_scene", "", {13, }, }, 
	{"enter_scene", "", {14, }, }, 
	{"delete_ai", "", {{"bat_92_enemy_enter_3", }, }, }, 
}

function ClsAIBat_92_enemy_enter_3:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_92_enemy_enter_3:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_92_enemy_enter_3

----------------------- Auto Genrate End   --------------------
