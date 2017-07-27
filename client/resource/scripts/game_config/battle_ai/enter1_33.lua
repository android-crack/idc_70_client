----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[44]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIEnter1_33 = class("ClsAIEnter1_33", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIEnter1_33:getId()
	return "enter1_33";
end


-- AI时机
function ClsAIEnter1_33:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIEnter1_33:getPriority()
	return 48;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndTimeis20(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- 战斗已进行时间
	local BattleTime = battleData:getBattleTime();
	-- 战斗进行时间>=20000
	if ( not (BattleTime>=20000) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIEnter1_33:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndTimeis20(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"enter_scene", "", {16, }, }, 
	{"delete_ai", "", {{"enter1_33", }, }, }, 
}

function ClsAIEnter1_33:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIEnter1_33:getAllTargetMethod()
	return all_target_method
end

return ClsAIEnter1_33

----------------------- Auto Genrate End   --------------------
