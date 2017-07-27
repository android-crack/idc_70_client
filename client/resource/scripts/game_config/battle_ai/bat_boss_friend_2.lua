----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[33%几率出现2号商会守护]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_boss_friend_2 = class("ClsAIBat_boss_friend_2", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_boss_friend_2:getId()
	return "bat_boss_friend_2";
end


-- AI时机
function ClsAIBat_boss_friend_2:getOpportunity()
	return AI_OPPORTUNITY.FIGHT_START;
end

-- AI优先级别
function ClsAIBat_boss_friend_2:getPriority()
	return 1;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndBat_boss_friend_1(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- 重置随机数<= 500
	if ( not (ai_obj:resetRandom()<= 500) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIBat_boss_friend_2:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndBat_boss_friend_1(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"delay", "", {1000, }, }, 
	{"enter_scene", "", {9, 1, 0, 0, 3, 1, }, }, 
	{"enter_scene", "", {16, 1, 1, 0, 3, 1, }, }, 
}

function ClsAIBat_boss_friend_2:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_boss_friend_2:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_boss_friend_2

----------------------- Auto Genrate End   --------------------
