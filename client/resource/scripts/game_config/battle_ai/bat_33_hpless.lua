----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_33_hpless = class("ClsAIBat_33_hpless", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_33_hpless:getId()
	return "bat_33_hpless";
end


-- AI时机
function ClsAIBat_33_hpless:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIBat_33_hpless:getPriority()
	return -2;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndHpless30(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- O耐久百分比
	local OHpRate = owner:getHpRate() * 100;
	-- O耐久百分比<30
	if ( not (OHpRate<30) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIBat_33_hpless:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndHpless30(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[OAI近攻=0.2*O近攻]
local function bat_33_hpless_act_1( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end

	-- O近攻
	local ONearAtt = owner:getAttNear();

	-- 公式原文:OAI近攻=0.2*O近攻
	owner:setAINearAtt( 0.2*ONearAtt );

end

-- [备注]说话-[我要亲手轰碎你们的船！]
local function bat_33_hpless_act_3( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end




	local name = ""
	local word = T("我要亲手轰碎你们的船！")

	target_obj:say( name, word )

end

-- [备注]设置-[OAI远攻=0.2*O远攻]
local function bat_33_hpless_act_2( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end

	-- O远攻
	local OFarAtt = owner:getAttFar(0);

	-- 公式原文:OAI远攻=0.2*O远攻
	owner:setAIFarAtt( 0.2*OFarAtt );

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"add_effect_to_ship", "", {1, "sf_tujin", 0, 0, 120, true, }, }, 
	{"op", "", {bat_33_hpless_act_1, }, }, 
	{"op", "", {bat_33_hpless_act_2, }, }, 
	{"op", "", {bat_33_hpless_act_3, }, }, 
	{"delete_ai", "", {{"bat_33_hpless", }, }, }, 
}

function ClsAIBat_33_hpless:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_33_hpless:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_33_hpless

----------------------- Auto Genrate End   --------------------
