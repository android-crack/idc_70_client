----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_skill_71_jy = class("ClsAIBat_skill_71_jy", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_skill_71_jy:getId()
	return "bat_skill_71_jy";
end


-- AI时机
function ClsAIBat_skill_71_jy:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIBat_skill_71_jy:getPriority()
	return 1;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndBat_71_jy_time(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- 战斗已进行时间
	local BattleTime = battleData:getBattleTime();
	-- 战斗进行时间>=3000
	if ( not (BattleTime>=3000) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIBat_skill_71_jy:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndBat_71_jy_time(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"add_skill", "", {1029, 1, }, }, 
	{"delete_ai", "", {{"bat_skill_71_jy", }, }, }, 
}

function ClsAIBat_skill_71_jy:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_skill_71_jy:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_skill_71_jy

----------------------- Auto Genrate End   --------------------
