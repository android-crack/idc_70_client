----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[每只海盗死亡有10%几率进场高级海盗]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_boss_death_2 = class("ClsAIBat_boss_death_2", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_boss_death_2:getId()
	return "bat_boss_death_2";
end


-- AI时机
function ClsAIBat_boss_death_2:getOpportunity()
	return AI_OPPORTUNITY.DEATH;
end

-- AI优先级别
function ClsAIBat_boss_death_2:getPriority()
	return -2;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]每只海盗死亡有10%几率进场高级海盗
local function cndEnter(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- 重置随机数<= 100
	if ( not (ai_obj:resetRandom()<= 100) ) then  return false end

	-- 战场测试变量
	local PirateLeaveCnt = battleData:GetData("__pirate_leave_cnt") or 0;
	-- 离场数量<14
	if ( not (PirateLeaveCnt<14) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIBat_boss_death_2:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndEnter(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"enter_scene", "", {7, 0, 0, 0, 7, 3, }, }, 
}

function ClsAIBat_boss_death_2:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_boss_death_2:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_boss_death_2

----------------------- Auto Genrate End   --------------------
