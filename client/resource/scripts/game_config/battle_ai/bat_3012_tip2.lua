----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_3012_tip2 = class("ClsAIBat_3012_tip2", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_3012_tip2:getId()
	return "bat_3012_tip2";
end


-- AI时机
function ClsAIBat_3012_tip2:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIBat_3012_tip2:getPriority()
	return 48;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndDead1(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- 战场测试变量
	local dead1 = battleData:GetData("dead1") or 0;
	-- dead1>=5
	if ( not (dead1>=5) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIBat_3012_tip2:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndDead1(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[O耐久=O耐久+O耐久上限]
local function bat_3012_tip2_act_0( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end

	-- O耐久
	local OHp = owner:getHp();
	-- O耐久上限
	local OHpMax = owner:getMaxHp();

	-- 公式原文:O耐久=O耐久+O耐久上限
	owner:AIsetHp( OHp+OHpMax );

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"op", "", {bat_3012_tip2_act_0, }, }, 
	{"delete_ai", "", {{"bat_3012_tip2", }, }, }, 
}

function ClsAIBat_3012_tip2:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_3012_tip2:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_3012_tip2

----------------------- Auto Genrate End   --------------------
