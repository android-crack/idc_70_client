----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAINex_very_angry = class("ClsAINex_very_angry", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAINex_very_angry:getId()
	return "nex_very_angry";
end


-- AI时机
function ClsAINex_very_angry:getOpportunity()
	return AI_OPPORTUNITY.RUN;
end

-- AI优先级别
function ClsAINex_very_angry:getPriority()
	return -2;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[OAI远攻=0.5*O远攻]
local function nex_very_angry_act_2( ai_obj, act_obj, target, delta_time )
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
local function nex_very_angry_act_1( ai_obj, act_obj, target, delta_time )
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

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"add_effect_to_ship", "", {1, "sf_tujin", 0, 0, 120, true, }, }, 
	{"op", "", {nex_very_angry_act_1, }, }, 
	{"op", "", {nex_very_angry_act_2, }, }, 
	{"add_skill", "", {4301, 10, }, }, 
	{"add_skill", "", {4501, 10, }, }, 
	{"add_skill", "", {4101, 10, }, }, 
	{"add_skill", "", {5201, 10, }, }, 
	{"add_skill", "", {5202, 10, }, }, 
}

function ClsAINex_very_angry:getActions()
	return actions
end

local all_target_method = {
}

function ClsAINex_very_angry:getAllTargetMethod()
	return all_target_method
end

return ClsAINex_very_angry

----------------------- Auto Genrate End   --------------------
