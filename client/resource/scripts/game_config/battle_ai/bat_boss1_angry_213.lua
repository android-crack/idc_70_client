----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_boss1_angry_213 = class("ClsAIBat_boss1_angry_213", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_boss1_angry_213:getId()
	return "bat_boss1_angry_213";
end


-- AI时机
function ClsAIBat_boss1_angry_213:getOpportunity()
	return AI_OPPORTUNITY.RUN;
end

-- AI优先级别
function ClsAIBat_boss1_angry_213:getPriority()
	return -2;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[OAI远攻=O远攻*0.5]
local function bat_boss1_angry_213_act_4( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end

	-- O远攻
	local OFarAtt = owner:getAttFar(0);

	-- 公式原文:OAI远攻=O远攻*0.5
	owner:setAIFarAtt( OFarAtt*0.5 );

end

-- [备注]说话-[居然敢对我郑芝龙的儿子动手！下地狱去吧！]
local function bat_boss1_angry_213_act_0( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end




	local name = ""
	local word = T("居然敢对我郑芝龙的儿子动手！下地狱去吧！")

	target_obj:say( name, word )

end

-- [备注]设置-[OAI近攻=O近攻*0.5]
local function bat_boss1_angry_213_act_3( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end

	-- O近攻
	local ONearAtt = owner:getAttNear();

	-- 公式原文:OAI近攻=O近攻*0.5
	owner:setAINearAtt( ONearAtt*0.5 );

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"op", "", {bat_boss1_angry_213_act_0, }, }, 
	{"add_effect_to_ship", "", {2, "sf_tujin", 0, 0, 120, true, }, }, 
	{"add_skill", "", {99021, 1, }, }, 
	{"op", "", {bat_boss1_angry_213_act_3, }, }, 
	{"op", "", {bat_boss1_angry_213_act_4, }, }, 
}

function ClsAIBat_boss1_angry_213:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_boss1_angry_213:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_boss1_angry_213

----------------------- Auto Genrate End   --------------------
