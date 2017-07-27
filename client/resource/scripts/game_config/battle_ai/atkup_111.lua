----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIAtkup_111 = class("ClsAIAtkup_111", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIAtkup_111:getId()
	return "atkup_111";
end


-- AI时机
function ClsAIAtkup_111:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIAtkup_111:getPriority()
	return 1;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndTimeis17(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- 战斗已进行时间
	local BattleTime = battleData:getBattleTime();
	-- 战斗进行时间>=12000
	if ( not (BattleTime>=12000) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIAtkup_111:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndTimeis17(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"delay", "", {2000, }, }, 
	{"run_ai", "", {{"atk_near_111", }, }, }, 
	{"run_ai", "", {{"atk_far_111", }, }, }, 
	{"stop_ai", "", {{"atkup_111", }, }, }, 
	{"delete_ai", "", {{"atkup_111", }, }, }, 
	{"add_ai", "", {{"atkup_111", }, }, }, 
}

function ClsAIAtkup_111:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIAtkup_111:getAllTargetMethod()
	return all_target_method
end

return ClsAIAtkup_111

----------------------- Auto Genrate End   --------------------
