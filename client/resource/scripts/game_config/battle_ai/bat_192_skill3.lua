----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_192_skill3 = class("ClsAIBat_192_skill3", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_192_skill3:getId()
	return "bat_192_skill3";
end


-- AI时机
function ClsAIBat_192_skill3:getOpportunity()
	return AI_OPPORTUNITY.FIGHT_START;
end

-- AI优先级别
function ClsAIBat_192_skill3:getPriority()
	return 48;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[O加怒=200]
local function bat_192_skill3_act_0( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end


	-- 公式原文:O加怒=200
	owner:addAnger( 200 );

end

-- [备注]设置-[O无视船只碰撞=是]
local function bat_192_skill3_act_8( ai_obj, act_obj, target, delta_time )
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
	{"op", "", {bat_192_skill3_act_0, }, }, 
	{"add_skill", "", {2005, 1, }, }, 
	{"add_skill", "", {1202, 5, }, }, 
	{"add_skill", "", {1213, 1, }, }, 
	{"add_effect_to_ship", "", {3, "tx_HitIce", 0, 30, 60, true, }, }, 
	{"add_effect_to_ship", "", {3, "tx_HitIce", 0, 50, 60, true, }, }, 
	{"add_effect_to_ship", "", {3, "tx_HitIce", 0, 70, 60, true, }, }, 
	{"add_effect_to_ship", "", {3, "tx_HitIce", 0, 90, 60, true, }, }, 
	{"op", "", {bat_192_skill3_act_8, }, }, 
}

function ClsAIBat_192_skill3:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_192_skill3:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_192_skill3

----------------------- Auto Genrate End   --------------------
