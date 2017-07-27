----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[爆破小队]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAICity01_boom = class("ClsAICity01_boom", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAICity01_boom:getId()
	return "city01_boom";
end


-- AI时机
function ClsAICity01_boom:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAICity01_boom:getPriority()
	return 1;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]爆破小队血量低于70
local function cndBoomhp70(ai_obj, target)
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
function ClsAICity01_boom:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndBoomhp70(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[记录随机数=重置随机数]
local function city01_boom_act_0( ai_obj, act_obj, target, delta_time )
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
	{"op", "", {city01_boom_act_0, }, }, 
	{"run_ai", "", {{"city01_boom_1", }, }, }, 
	{"run_ai", "", {{"city01_boom_2", }, }, }, 
	{"run_ai", "", {{"city01_boom_3", }, }, }, 
	{"run_ai", "", {{"city01_boom_4", }, }, }, 
	{"delete_ai", "", {{"city01_boom", }, }, }, 
}

function ClsAICity01_boom:getActions()
	return actions
end

local all_target_method = {
}

function ClsAICity01_boom:getAllTargetMethod()
	return all_target_method
end

return ClsAICity01_boom

----------------------- Auto Genrate End   --------------------
