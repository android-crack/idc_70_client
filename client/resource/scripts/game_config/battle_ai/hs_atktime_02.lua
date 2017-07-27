----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIHs_atktime_02 = class("ClsAIHs_atktime_02", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIHs_atktime_02:getId()
	return "hs_atktime_02";
end


-- AI时机
function ClsAIHs_atktime_02:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIHs_atktime_02:getPriority()
	return 48;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndDelay2(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- 战斗已进行时间
	local BattleTime = battleData:getBattleTime();
	-- 记录时间用
	local record_time = battleData:GetData("record_time") or 0;
	-- 战斗进行时间 - 记录战斗时间 >= 5000
	if ( not (BattleTime - record_time >= 5000) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIHs_atktime_02:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndDelay2(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[记录战斗时间=战斗进行时间]
local function hs_atktime_02_act_2( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end

	-- 战斗已进行时间
	local BattleTime = battleData:getBattleTime();

	-- 公式原文:记录战斗时间=战斗进行时间
	battleData:planningSetData("record_time", BattleTime);

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"run_ai", "", {{"hs_atkup_02", }, }, }, 
	{"stop_ai", "", {{"hs_atktime_02", }, }, }, 
	{"op", "", {hs_atktime_02_act_2, }, }, 
}

function ClsAIHs_atktime_02:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIHs_atktime_02:getAllTargetMethod()
	return all_target_method
end

return ClsAIHs_atktime_02

----------------------- Auto Genrate End   --------------------
