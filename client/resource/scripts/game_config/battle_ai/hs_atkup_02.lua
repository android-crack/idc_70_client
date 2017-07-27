----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIHs_atkup_02 = class("ClsAIHs_atkup_02", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIHs_atkup_02:getId()
	return "hs_atkup_02";
end


-- AI时机
function ClsAIHs_atkup_02:getOpportunity()
	return AI_OPPORTUNITY.RUN;
end

-- AI优先级别
function ClsAIHs_atkup_02:getPriority()
	return -2;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[OAI近攻=O近攻*0.1]
local function hs_atkup_02_act_1( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end

	-- O近攻
	local ONearAtt = owner:getAttNear();

	-- 公式原文:OAI近攻=O近攻*0.1
	owner:setAINearAtt( ONearAtt*0.1 );

end

-- [备注]设置-[OAI远攻=O远攻*0.1]
local function hs_atkup_02_act_0( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end

	-- O远攻
	local OFarAtt = owner:getAttFar(0);

	-- 公式原文:OAI远攻=O远攻*0.1
	owner:setAIFarAtt( OFarAtt*0.1 );

end

-- [备注]说话-[伙计们加把劲，填充火炮！]
local function hs_atkup_02_act_3( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end




	local name = ""
	local word = T("伙计们加把劲，填充火炮！")

	target_obj:say( name, word )

end

-- [备注]设置-[OAI防御=O防御*0.1]
local function hs_atkup_02_act_2( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end

	-- 宿主防御
	local ODefense = owner:getDefense();

	-- 公式原文:OAI防御=O防御*0.1
	owner:setAIDefense( ODefense*0.1 );

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"op", "", {hs_atkup_02_act_0, }, }, 
	{"op", "", {hs_atkup_02_act_1, }, }, 
	{"op", "", {hs_atkup_02_act_2, }, }, 
	{"op", "", {hs_atkup_02_act_3, }, }, 
}

function ClsAIHs_atkup_02:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIHs_atkup_02:getAllTargetMethod()
	return all_target_method
end

return ClsAIHs_atkup_02

----------------------- Auto Genrate End   --------------------
