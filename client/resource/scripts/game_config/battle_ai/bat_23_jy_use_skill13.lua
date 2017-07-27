----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_23_jy_use_skill13 = class("ClsAIBat_23_jy_use_skill13", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_23_jy_use_skill13:getId()
	return "bat_23_jy_use_skill13";
end


-- AI时机
function ClsAIBat_23_jy_use_skill13:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIBat_23_jy_use_skill13:getPriority()
	return 1;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndTimeis100(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- 战斗已进行时间
	local BattleTime = battleData:getBattleTime();
	-- 战斗进行时间>=100000
	if ( not (BattleTime>=100000) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIBat_23_jy_use_skill13:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndTimeis100(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"use_skill", "", {1026, }, }, 
	{"delete_ai", "", {{"bat_23_jy_use_skill13", }, }, }, 
}

function ClsAIBat_23_jy_use_skill13:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_23_jy_use_skill13:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_23_jy_use_skill13

----------------------- Auto Genrate End   --------------------
