----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_1022_hpset = class("ClsAIBat_1022_hpset", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_1022_hpset:getId()
	return "bat_1022_hpset";
end


-- AI时机
function ClsAIBat_1022_hpset:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIBat_1022_hpset:getPriority()
	return 1;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndBat_22_time1(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- 战斗已进行时间
	local BattleTime = battleData:getBattleTime();
	-- 战斗进行时间>3000
	if ( not (BattleTime>3000) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIBat_1022_hpset:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndBat_22_time1(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[O耐久=O耐久*0.7]
local function bat_1022_hpset_act_0( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end

	-- O耐久
	local OHp = owner:getHp();

	-- 公式原文:O耐久=O耐久*0.7
	owner:AIsetHp( OHp*0.7 );

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"op", "", {bat_1022_hpset_act_0, }, }, 
	{"delete_ai", "", {{"bat_1022_hpset", }, }, }, 
}

function ClsAIBat_1022_hpset:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_1022_hpset:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_1022_hpset

----------------------- Auto Genrate End   --------------------
