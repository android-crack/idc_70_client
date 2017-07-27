----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_201_zibao = class("ClsAIBat_201_zibao", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_201_zibao:getId()
	return "bat_201_zibao";
end


-- AI时机
function ClsAIBat_201_zibao:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIBat_201_zibao:getPriority()
	return -2;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndZibao(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- O耐久百分比
	local OHpRate = owner:getHpRate() * 100;
	-- O耐久百分比<=30
	if ( not (OHpRate<=30) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIBat_201_zibao:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndZibao(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[O耐久=0]
local function bat_201_zibao_act_2( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end


	-- 公式原文:O耐久=0
	owner:AIsetHp( 0 );

end

-- [备注]设置-[OAI近攻=O近攻*1.5]
local function bat_201_zibao_act_0( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end

	-- O近攻
	local ONearAtt = owner:getAttNear();

	-- 公式原文:OAI近攻=O近攻*1.5
	owner:setAINearAtt( ONearAtt*1.5 );

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"op", "", {bat_201_zibao_act_0, }, }, 
	{"use_skill", "", {1213, }, }, 
	{"op", "", {bat_201_zibao_act_2, }, }, 
}

function ClsAIBat_201_zibao:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_201_zibao:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_201_zibao

----------------------- Auto Genrate End   --------------------
