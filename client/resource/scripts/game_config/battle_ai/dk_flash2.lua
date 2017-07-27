----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIDk_flash2 = class("ClsAIDk_flash2", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIDk_flash2:getId()
	return "dk_flash2";
end


-- AI时机
function ClsAIDk_flash2:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIDk_flash2:getPriority()
	return -2;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndDk_flash2(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- O耐久百分比
	local OHpRate = owner:getHpRate() * 100;
	-- O耐久百分比<50
	if ( not (OHpRate<50) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIDk_flash2:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndDk_flash2(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[OAI远攻=0.5*O远攻]
local function dk_flash2_act_3( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end

	-- O远攻
	local OFarAtt = owner:getAttFar(0);

	-- 公式原文:OAI远攻=0.5*O远攻
	owner:setAIFarAtt( 0.5*OFarAtt );

end

-- [备注]设置-[OAI近攻=0.5*O近攻]
local function dk_flash2_act_2( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end

	-- O近攻
	local ONearAtt = owner:getAttNear();

	-- 公式原文:OAI近攻=0.5*O近攻
	owner:setAINearAtt( 0.5*ONearAtt );

end

-- [备注]设置-[OX=2300;OY=640]
local function dk_flash2_act_5( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end


	-- 公式原文:OX=2300
	owner:setPositionX( 2300 );
	-- 公式原文:OY=640
	owner:setPositionY( 640 );

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"add_effect_to_ship", "", {2, "tx_0171", 0, 0, 3, false, }, }, 
	{"add_effect_to_ship", "", {2, "sf_tujin", 0, 0, 120, true, }, }, 
	{"op", "", {dk_flash2_act_2, }, }, 
	{"op", "", {dk_flash2_act_3, }, }, 
	{"delay", "", {1000, }, }, 
	{"op", "", {dk_flash2_act_5, }, }, 
	{"run_ai", "", {{"dk_addskill", }, }, }, 
	{"delete_ai", "", {{"dk_flash2", }, }, }, 
}

function ClsAIDk_flash2:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIDk_flash2:getAllTargetMethod()
	return all_target_method
end

return ClsAIDk_flash2

----------------------- Auto Genrate End   --------------------
