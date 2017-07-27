----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[20]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIEnter3_102 = class("ClsAIEnter3_102", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIEnter3_102:getId()
	return "enter3_102";
end


-- AI时机
function ClsAIEnter3_102:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIEnter3_102:getPriority()
	return 1;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndTimeis30(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- 战斗已进行时间
	local BattleTime = battleData:getBattleTime();
	-- 战斗进行时间>=30000
	if ( not (BattleTime>=30000) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIEnter3_102:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndTimeis30(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"enter_scene", "", {9, }, }, 
	{"delete_ai", "", {{"enter3_102", }, }, }, 
}

function ClsAIEnter3_102:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIEnter3_102:getAllTargetMethod()
	return all_target_method
end

return ClsAIEnter3_102

----------------------- Auto Genrate End   --------------------
