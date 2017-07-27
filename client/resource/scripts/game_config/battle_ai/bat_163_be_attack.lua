----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[气血降低进入死亡]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_163_be_attack = class("ClsAIBat_163_be_attack", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_163_be_attack:getId()
	return "bat_163_be_attack";
end


-- AI时机
function ClsAIBat_163_be_attack:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIBat_163_be_attack:getPriority()
	return 1;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndBat_163_be_attack(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- O耐久百分比
	local OHpRate = owner:getHpRate() * 100;
	-- O耐久百分比<90
	if ( not (OHpRate<90) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIBat_163_be_attack:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndBat_163_be_attack(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[O耐久=0]
local function bat_163_be_attack_act_0( ai_obj, act_obj, target, delta_time )
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

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"op", "", {bat_163_be_attack_act_0, }, }, 
}

function ClsAIBat_163_be_attack:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_163_be_attack:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_163_be_attack

----------------------- Auto Genrate End   --------------------
