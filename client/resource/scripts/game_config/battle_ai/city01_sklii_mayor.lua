----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[BOSS补充技能]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAICity01_sklii_mayor = class("ClsAICity01_sklii_mayor", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAICity01_sklii_mayor:getId()
	return "city01_sklii_mayor";
end


-- AI时机
function ClsAICity01_sklii_mayor:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAICity01_sklii_mayor:getPriority()
	return 1;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]市政官血量低于70
local function cndMayorhp70(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- O耐久百分比
	local OHpRate = owner:getHpRate() * 100;
	-- O耐久百分比<70
	if ( not (OHpRate<70) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAICity01_sklii_mayor:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndMayorhp70(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[记录随机数=重置随机数]
local function city01_sklii_mayor_act_0( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end


	-- 公式原文:记录随机数=重置随机数
	battleData:planningSetData("__random_cnt", ai_obj:resetRandom());

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"op", "", {city01_sklii_mayor_act_0, }, }, 
	{"run_ai", "", {{"city01_sklii_A", }, }, }, 
	{"run_ai", "", {{"city01_sklii_B", }, }, }, 
	{"run_ai", "", {{"city01_sklii_C", }, }, }, 
	{"run_ai", "", {{"city01_sklii_D", }, }, }, 
	{"delete_ai", "", {{"city01_sklii_mayor", }, }, }, 
}

function ClsAICity01_sklii_mayor:getActions()
	return actions
end

local all_target_method = {
}

function ClsAICity01_sklii_mayor:getAllTargetMethod()
	return all_target_method
end

return ClsAICity01_sklii_mayor

----------------------- Auto Genrate End   --------------------
