----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIHs_boss_angry_02 = class("ClsAIHs_boss_angry_02", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIHs_boss_angry_02:getId()
	return "hs_boss_angry_02";
end


-- AI时机
function ClsAIHs_boss_angry_02:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIHs_boss_angry_02:getPriority()
	return 48;
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
function ClsAIHs_boss_angry_02:checkCondition()
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
	{"add_effect_to_ship", "", {1, "sf_tujin", 0, 0, 120, true, }, }, 
	{"delete_ai", "", {{"hs_boss_angry_02", }, }, }, 
}

function ClsAIHs_boss_angry_02:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIHs_boss_angry_02:getAllTargetMethod()
	return all_target_method
end

return ClsAIHs_boss_angry_02

----------------------- Auto Genrate End   --------------------
