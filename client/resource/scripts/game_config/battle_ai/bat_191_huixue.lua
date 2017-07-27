----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_191_huixue = class("ClsAIBat_191_huixue", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_191_huixue:getId()
	return "bat_191_huixue";
end


-- AI时机
function ClsAIBat_191_huixue:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIBat_191_huixue:getPriority()
	return 1;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndHuixue(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- 战场测试变量
	local BLOOD = battleData:GetData("__blood") or 0;
	-- 回血==1
	if ( not (BLOOD==1) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIBat_191_huixue:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndHuixue(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[O耐久=O耐久+30000]
local function bat_191_huixue_act_0( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end

	-- O耐久
	local OHp = owner:getHp();

	-- 公式原文:O耐久=O耐久+30000
	owner:AIsetHp( OHp+30000 );

end

-- [备注]设置-[回血=0]
local function bat_191_huixue_act_1( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end


	-- 公式原文:回血=0
	battleData:planningSetData("__blood", 0);

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"op", "", {bat_191_huixue_act_0, }, }, 
	{"op", "", {bat_191_huixue_act_1, }, }, 
	{"add_effect_to_ship", "", {4, "jn_jiagu_health", 0, 0, 2, true, }, }, 
}

function ClsAIBat_191_huixue:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_191_huixue:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_191_huixue

----------------------- Auto Genrate End   --------------------
