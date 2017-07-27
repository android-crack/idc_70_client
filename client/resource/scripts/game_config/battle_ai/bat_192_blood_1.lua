----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_192_blood_1 = class("ClsAIBat_192_blood_1", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_192_blood_1:getId()
	return "bat_192_blood_1";
end


-- AI时机
function ClsAIBat_192_blood_1:getOpportunity()
	return AI_OPPORTUNITY.RUN;
end

-- AI优先级别
function ClsAIBat_192_blood_1:getPriority()
	return -2;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndBlood_1(ai_obj, target)
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

	return true
end

-- 本AI的判定条件
function ClsAIBat_192_blood_1:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndBlood_1(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[O耐久=O耐久/O耐久百分比*50]
local function bat_192_blood_1_act_0( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end

	-- O耐久
	local OHp = owner:getHp();
	-- O耐久百分比
	local OHpRate = owner:getHpRate() * 100;

	-- 公式原文:O耐久=O耐久/O耐久百分比*50
	owner:AIsetHp( OHp/OHpRate*50 );

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"op", "", {bat_192_blood_1_act_0, }, }, 
	{"add_effect_to_ship", "", {1, "jn_jiagu_health", 0, 0, 2, true, }, }, 
}

function ClsAIBat_192_blood_1:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_192_blood_1:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_192_blood_1

----------------------- Auto Genrate End   --------------------
