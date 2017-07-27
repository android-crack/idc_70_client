----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[穿透船只AI]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAISys_ignor_collision = class("ClsAISys_ignor_collision", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAISys_ignor_collision:getId()
	return "sys_ignor_collision";
end


-- AI时机
function ClsAISys_ignor_collision:getOpportunity()
	return AI_OPPORTUNITY.FIGHT_START;
end

-- AI优先级别
function ClsAISys_ignor_collision:getPriority()
	return 1;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[O无视船只碰撞=是]
local function sys_ignor_collision_act_0( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end


	-- 公式原文:O无视船只碰撞=是
	owner:setIgnorCollision( true );

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"op", "", {sys_ignor_collision_act_0, }, }, 
	{"run_ai", "", {{"sys_clear", }, }, }, 
}

function ClsAISys_ignor_collision:getActions()
	return actions
end

local all_target_method = {
}

function ClsAISys_ignor_collision:getAllTargetMethod()
	return all_target_method
end

return ClsAISys_ignor_collision

----------------------- Auto Genrate End   --------------------
