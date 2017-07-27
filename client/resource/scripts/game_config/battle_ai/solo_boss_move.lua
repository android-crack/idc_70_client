----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[高级海盗出生即逃跑，逃至目标点时离场]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAISolo_boss_move = class("ClsAISolo_boss_move", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAISolo_boss_move:getId()
	return "solo_boss_move";
end


-- AI时机
function ClsAISolo_boss_move:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAISolo_boss_move:getPriority()
	return 2;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]离场-[]
local function solo_boss_move_act_1( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end


	target_obj:release(false, true)

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"move_to", "", {100, 640, 50, }, }, 
	{"op", "", {solo_boss_move_act_1, }, }, 
}

function ClsAISolo_boss_move:getActions()
	return actions
end

local all_target_method = {
}

function ClsAISolo_boss_move:getAllTargetMethod()
	return all_target_method
end

return ClsAISolo_boss_move

----------------------- Auto Genrate End   --------------------
