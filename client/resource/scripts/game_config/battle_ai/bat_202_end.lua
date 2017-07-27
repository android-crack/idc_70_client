----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_202_end = class("ClsAIBat_202_end", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_202_end:getId()
	return "bat_202_end";
end


-- AI时机
function ClsAIBat_202_end:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIBat_202_end:getPriority()
	return 48;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndAi(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- 战斗已进行时间
	local BattleTime = battleData:getBattleTime();
	-- 战场测试变量
	local DEAD = battleData:GetData("__dead") or 0;
	-- 战斗进行时间>=40000  or  死亡数==4
	if ( not (BattleTime>=40000  or  DEAD==4) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIBat_202_end:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndAi(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[OAI近攻=-O近攻]
local function bat_202_end_act_2( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end

	-- O近攻
	local ONearAtt = owner:getAttNear();

	-- 公式原文:OAI近攻=-O近攻
	owner:setAINearAtt( -ONearAtt );

end

-- [备注]设置-[OAI远攻=-O远攻]
local function bat_202_end_act_1( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end

	-- O远攻
	local OFarAtt = owner:getAttFar(0);

	-- 公式原文:OAI远攻=-O远攻
	owner:setAIFarAtt( -OFarAtt );

end

-- [备注]设置-[O加怒=-200]
local function bat_202_end_act_0( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end


	-- 公式原文:O加怒=-200
	owner:addAnger( -200 );

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"op", "", {bat_202_end_act_0, }, }, 
	{"op", "", {bat_202_end_act_1, }, }, 
	{"op", "", {bat_202_end_act_2, }, }, 
	{"stop_ai", "", {{"bat_202_fol1", }, }, }, 
	{"delete_ai", "", {{"bat_202_fol1", }, }, }, 
	{"add_ai", "", {{"bat_202_move_1", }, }, }, 
	{"add_ai", "", {{"bat_202_move_2", }, }, }, 
	{"add_ai", "", {{"bat_202_move_3", }, }, }, 
	{"add_ai", "", {{"bat_202_move_4", }, }, }, 
	{"delete_ai", "", {{"bat_202_end", }, }, }, 
}

function ClsAIBat_202_end:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_202_end:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_202_end

----------------------- Auto Genrate End   --------------------
