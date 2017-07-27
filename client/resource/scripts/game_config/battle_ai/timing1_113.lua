----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAITiming1_113 = class("ClsAITiming1_113", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAITiming1_113:getId()
	return "timing1_113";
end


-- AI时机
function ClsAITiming1_113:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAITiming1_113:getPriority()
	return 1;
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
	-- 战斗进行时间>20000
	if ( not (BattleTime>20000) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAITiming1_113:checkCondition()
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
	{"enter_scene", "", {9, }, }, 
	{"delete_ai", "", {{"timing1_113", }, }, }, 
}

function ClsAITiming1_113:getActions()
	return actions
end

local all_target_method = {
}

function ClsAITiming1_113:getAllTargetMethod()
	return all_target_method
end

return ClsAITiming1_113

----------------------- Auto Genrate End   --------------------
