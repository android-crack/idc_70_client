----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_23_win = class("ClsAIBat_23_win", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_23_win:getId()
	return "bat_23_win";
end


-- AI时机
function ClsAIBat_23_win:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIBat_23_win:getPriority()
	return 1;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndDead3(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- 
	local dead = battleData:GetData("dead") or 0;
	-- 死亡==3
	if ( not (dead==3) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIBat_23_win:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndDead3(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"enter_scene", "", {5, 0, 0, 1, 3, 0, }, }, 
	{"add_effect_to_scene", "", {1, "jiantou", 2300, 320, 100, 1, false, }, }, 
	{"delete_ai", "", {{"bat_23_win", }, }, }, 
}

function ClsAIBat_23_win:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_23_win:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_23_win

----------------------- Auto Genrate End   --------------------
