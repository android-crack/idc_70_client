----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[战斗结束]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBattle_end = class("ClsAIBattle_end", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBattle_end:getId()
	return "battle_end";
end


-- AI时机
function ClsAIBattle_end:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIBattle_end:getPriority()
	return 1;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]战斗结束
local function cndDead15(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- 战场测试变量
	local death = battleData:GetData("death") or 0;
	-- 死亡==15
	if ( not (death==15) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIBattle_end:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndDead15(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"battle_stop", "", {1, }, }, 
	{"delete_ai", "", {{"battle_end", }, }, }, 
}

function ClsAIBattle_end:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBattle_end:getAllTargetMethod()
	return all_target_method
end

return ClsAIBattle_end

----------------------- Auto Genrate End   --------------------
