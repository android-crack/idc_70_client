----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIHs_enter1_05 = class("ClsAIHs_enter1_05", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIHs_enter1_05:getId()
	return "hs_enter1_05";
end


-- AI时机
function ClsAIHs_enter1_05:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIHs_enter1_05:getPriority()
	return 1;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndTimeis5(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- 战斗已进行时间
	local BattleTime = battleData:getBattleTime();
	-- 战斗进行时间>=5000
	if ( not (BattleTime>=5000) ) then  return false end

	-- 计数5
	local num5 = battleData:GetData("num5") or 0;
	-- num5<1
	if ( not (num5<1) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIHs_enter1_05:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndTimeis5(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[num5=1]
local function hs_enter1_05_act_4( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end


	-- 公式原文:num5=1
	battleData:planningSetData("num5", 1);

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"enter_scene", "", {5, }, }, 
	{"enter_scene", "", {6, }, }, 
	{"enter_scene", "", {7, }, }, 
	{"enter_scene", "", {8, }, }, 
	{"op", "", {hs_enter1_05_act_4, }, }, 
	{"delete_ai", "", {{"hs_enter1_05", }, }, }, 
}

function ClsAIHs_enter1_05:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIHs_enter1_05:getAllTargetMethod()
	return all_target_method
end

return ClsAIHs_enter1_05

----------------------- Auto Genrate End   --------------------
