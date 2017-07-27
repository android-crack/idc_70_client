----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[自爆船1死亡]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_163_death_1 = class("ClsAIBat_163_death_1", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_163_death_1:getId()
	return "bat_163_death_1";
end


-- AI时机
function ClsAIBat_163_death_1:getOpportunity()
	return AI_OPPORTUNITY.DEATH;
end

-- AI优先级别
function ClsAIBat_163_death_1:getPriority()
	return -2;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndBat_163_enter(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- 战场测试变量
	local Boss_Cnt = battleData:GetData("_boss_cnt") or 0;
	-- BOSS血量记录==0
	if ( not (Boss_Cnt==0) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIBat_163_death_1:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndBat_163_enter(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"enter_scene", "", {4, }, }, 
}

function ClsAIBat_163_death_1:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_163_death_1:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_163_death_1

----------------------- Auto Genrate End   --------------------
