----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_92_enemy_enter_1 = class("ClsAIBat_92_enemy_enter_1", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_92_enemy_enter_1:getId()
	return "bat_92_enemy_enter_1";
end


-- AI时机
function ClsAIBat_92_enemy_enter_1:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIBat_92_enemy_enter_1:getPriority()
	return 1;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]进入范围
local function cndBat_92_enemy_enter_1(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- math.abs(768 - OX) < 100
	if ( not (math.abs(768 - owner:getPositionX()) < 100) ) then  return false end

	-- math.abs(885 - OY) < 100
	if ( not (math.abs(885 - owner:getPositionY()) < 100) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIBat_92_enemy_enter_1:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndBat_92_enemy_enter_1(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"enter_scene", "", {6, }, }, 
	{"enter_scene", "", {7, }, }, 
	{"enter_scene", "", {8, }, }, 
	{"play_plot", "", {{10, }, }, }, 
	{"delete_ai", "", {{"bat_92_enemy_enter_1", }, }, }, 
}

function ClsAIBat_92_enemy_enter_1:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_92_enemy_enter_1:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_92_enemy_enter_1

----------------------- Auto Genrate End   --------------------
