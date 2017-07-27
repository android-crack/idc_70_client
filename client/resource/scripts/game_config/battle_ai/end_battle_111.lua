----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIEnd_battle_111 = class("ClsAIEnd_battle_111", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIEnd_battle_111:getId()
	return "end_battle_111";
end


-- AI时机
function ClsAIEnd_battle_111:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIEnd_battle_111:getPriority()
	return 1;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndEnd_battle_111(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- 计数1
	local DeathCnt = battleData:GetData("death") or 0;
	-- 死亡数>=6
	if ( not (DeathCnt>=6) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIEnd_battle_111:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndEnd_battle_111(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"battle_stop", "", {1, }, }, 
}

function ClsAIEnd_battle_111:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIEnd_battle_111:getAllTargetMethod()
	return all_target_method
end

return ClsAIEnd_battle_111

----------------------- Auto Genrate End   --------------------
