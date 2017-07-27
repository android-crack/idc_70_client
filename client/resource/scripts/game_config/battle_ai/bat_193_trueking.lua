----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_193_trueking = class("ClsAIBat_193_trueking", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_193_trueking:getId()
	return "bat_193_trueking";
end


-- AI时机
function ClsAIBat_193_trueking:getOpportunity()
	return AI_OPPORTUNITY.RUN;
end

-- AI优先级别
function ClsAIBat_193_trueking:getPriority()
	return -2;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[OAI远攻=O远攻*0.5]
local function bat_193_trueking_act_2( ai_obj, act_obj, target, delta_time )
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

-- [备注]设置-[OAI近攻=O近攻*0.5]
local function bat_193_trueking_act_1( ai_obj, act_obj, target, delta_time )
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
	{"add_effect_to_ship", "", {1, "sf_tujin", 0, 0, 120, true, }, }, 
	{"op", "", {bat_193_trueking_act_1, }, }, 
	{"op", "", {bat_193_trueking_act_2, }, }, 
	{"add_skill", "", {4501, 1, }, }, 
	{"add_skill", "", {1213, 1, }, }, 
	{"add_skill", "", {5101, 1, }, }, 
	{"add_skill", "", {1905, 1, }, }, 
	{"add_skill", "", {3501, 1, }, }, 
}

function ClsAIBat_193_trueking:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_193_trueking:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_193_trueking

----------------------- Auto Genrate End   --------------------
