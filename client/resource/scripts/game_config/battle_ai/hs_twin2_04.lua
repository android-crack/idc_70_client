----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIHs_twin2_04 = class("ClsAIHs_twin2_04", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIHs_twin2_04:getId()
	return "hs_twin2_04";
end


-- AI时机
function ClsAIHs_twin2_04:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIHs_twin2_04:getPriority()
	return -2;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndHpless35(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- O耐久百分比
	local OHpRate = owner:getHpRate() * 100;
	-- O耐久百分比<=35
	if ( not (OHpRate<=35) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIHs_twin2_04:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndHpless35(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]说话-[可恶！双子星！来掩护我！]
local function hs_twin2_04_act_5( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end




	local name = ""
	local word = T("可恶！双子星！来掩护我！")

	target_obj:say( name, word )

end

-- [备注]设置-[OAI近攻=0.5*O近攻]
local function hs_twin2_04_act_1( ai_obj, act_obj, target, delta_time )
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

-- [备注]设置-[OAI远攻=0.5*O远攻]
local function hs_twin2_04_act_2( ai_obj, act_obj, target, delta_time )
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

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"add_effect_to_ship", "", {1, "sf_tujin", 0, 0, 120, true, }, }, 
	{"op", "", {hs_twin2_04_act_1, }, }, 
	{"op", "", {hs_twin2_04_act_2, }, }, 
	{"add_skill", "", {3501, 10, }, }, 
	{"add_skill", "", {10001, 10, }, }, 
	{"op", "", {hs_twin2_04_act_5, }, }, 
	{"show_prompt", "", {T("双子星被消灭的时间间隔不能超过6秒，否则。。。"), }, }, 
	{"enter_scene", "", {14, 0, 0, 1, 7, 0, }, }, 
	{"enter_scene", "", {15, 0, 0, 1, 7, 0, }, }, 
	{"delete_ai", "", {{"hs_twin1_04", }, }, }, 
	{"delete_ai", "", {{"hs_twin2_04", }, }, }, 
}

function ClsAIHs_twin2_04:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIHs_twin2_04:getAllTargetMethod()
	return all_target_method
end

return ClsAIHs_twin2_04

----------------------- Auto Genrate End   --------------------
