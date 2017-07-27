----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[2]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIHpless2_114 = class("ClsAIHpless2_114", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIHpless2_114:getId()
	return "hpless2_114";
end


-- AI时机
function ClsAIHpless2_114:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIHpless2_114:getPriority()
	return 1;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndHpless50(ai_obj, target)
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

	-- 计数1
	local num1 = battleData:GetData("num1") or 0;
	-- num1==0
	if ( not (num1==0) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIHpless2_114:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndHpless50(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]说话-[别打了，我们投降！]
local function hpless2_114_act_1( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end




	local name = ""
	local word = T("别打了，我们投降！")

	target_obj:say( name, word )

end

-- [备注]设置-[O阵营=3]
local function hpless2_114_act_0( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end


	-- 公式原文:O阵营=3
	battleData:changeTeam(owner, 3 );

end

-- [备注]设置-[num2=num2+1]
local function hpless2_114_act_3( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end

	-- 计数2
	local num2 = battleData:GetData("num2") or 1;

	-- 公式原文:num2=num2+1
	battleData:planningSetData("num2", num2+1);

end

-- [备注]设置-[OAI变速=-O速度]
local function hpless2_114_act_2( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end

	-- 宿主速度
	local OSpeed = owner:getSpeed();

	-- 公式原文:OAI变速=-O速度
	owner:setAISpeed( -OSpeed );

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"op", "", {hpless2_114_act_0, }, }, 
	{"op", "", {hpless2_114_act_1, }, }, 
	{"op", "", {hpless2_114_act_2, }, }, 
	{"op", "", {hpless2_114_act_3, }, }, 
	{"delete_ai", "", {{"hpless2_114", }, }, }, 
}

function ClsAIHpless2_114:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIHpless2_114:getAllTargetMethod()
	return all_target_method
end

return ClsAIHpless2_114

----------------------- Auto Genrate End   --------------------
