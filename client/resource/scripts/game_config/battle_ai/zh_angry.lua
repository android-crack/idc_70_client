----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIZh_angry = class("ClsAIZh_angry", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIZh_angry:getId()
	return "zh_angry";
end


-- AI时机
function ClsAIZh_angry:getOpportunity()
	return AI_OPPORTUNITY.RUN;
end

-- AI优先级别
function ClsAIZh_angry:getPriority()
	return -2;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[OAI近攻=0.5*O近攻]
local function zh_angry_act_2( ai_obj, act_obj, target, delta_time )
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
local function zh_angry_act_3( ai_obj, act_obj, target, delta_time )
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

-- [备注]说话-[小友！我要动真格了！]
local function zh_angry_act_0( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end




	local name = ""
	local word = T("小友！我要动真格了！")

	target_obj:say( name, word )

end

-- [备注]设置-[py=OY]
local function zh_angry_act_8( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end


	-- 公式原文:py=OY
	battleData:planningSetData("py", owner:getPositionY());

end

-- [备注]设置-[px=OX]
local function zh_angry_act_7( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end


	-- 公式原文:px=OX
	battleData:planningSetData("px", owner:getPositionX());

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"op", "", {zh_angry_act_0, }, }, 
	{"add_effect_to_ship", "", {1, "sf_tujin", 0, 0, 120, true, }, }, 
	{"op", "", {zh_angry_act_2, }, }, 
	{"op", "", {zh_angry_act_3, }, }, 
	{"add_skill", "", {99007, 2, }, }, 
	{"add_skill", "", {99009, 2, }, }, 
	{"add_skill", "", {3501, 10, }, }, 
	{"op", "", {zh_angry_act_7, }, }, 
	{"op", "", {zh_angry_act_8, }, }, 
	{"enter_scene", "", {15, 0, 0, 1, 7, 3, }, }, 
}

function ClsAIZh_angry:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIZh_angry:getAllTargetMethod()
	return all_target_method
end

return ClsAIZh_angry

----------------------- Auto Genrate End   --------------------
