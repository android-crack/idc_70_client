----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_final_phase_221 = class("ClsAIBat_final_phase_221", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_final_phase_221:getId()
	return "bat_final_phase_221";
end


-- AI时机
function ClsAIBat_final_phase_221:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIBat_final_phase_221:getPriority()
	return -2;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndDead6(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- 
	local dead = battleData:GetData("dead") or 0;
	-- 死亡==6
	if ( not (dead==6) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIBat_final_phase_221:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndDead6(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"run_ai", "", {{"bat_event2_221", }, }, }, 
	{"delete_ai", "", {{"bat_final_phase_221", }, }, }, 
}

function ClsAIBat_final_phase_221:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_final_phase_221:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_final_phase_221

----------------------- Auto Genrate End   --------------------
