----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_191_out = class("ClsAIBat_191_out", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_191_out:getId()
	return "bat_191_out";
end


-- AI时机
function ClsAIBat_191_out:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIBat_191_out:getPriority()
	return -2;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndOut_1(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- 战场测试变量
	local AI1 = battleData:GetData("__ai_1") or 0;
	-- 触发1>=1
	if ( not (AI1>=1) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIBat_191_out:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndOut_1(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]离场-[]
local function bat_191_out_act_2( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end


	target_obj:release(false, true)

end

-- [备注]设置-[次数1=次数1+1]
local function bat_191_out_act_0( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end

	-- 战场测试变量
	local TIMES1 = battleData:GetData("__times_1") or 0;

	-- 公式原文:次数1=次数1+1
	battleData:planningSetData("__times_1", TIMES1+1);

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"op", "", {bat_191_out_act_0, }, }, 
	{"delay", "", {1000, }, }, 
	{"op", "", {bat_191_out_act_2, }, }, 
}

function ClsAIBat_191_out:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_191_out:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_191_out

----------------------- Auto Genrate End   --------------------
