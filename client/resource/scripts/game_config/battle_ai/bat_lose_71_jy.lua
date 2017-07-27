----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_lose_71_jy = class("ClsAIBat_lose_71_jy", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_lose_71_jy:getId()
	return "bat_lose_71_jy";
end


-- AI时机
function ClsAIBat_lose_71_jy:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIBat_lose_71_jy:getPriority()
	return 1;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndDeathcntis2(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- 战场测试变量
	local Death_Cnt = battleData:GetData("_death_cnt") or 0;
	-- 死亡==2
	if ( not (Death_Cnt==2) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIBat_lose_71_jy:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndDeathcntis2(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"play_plot", "", {{8, }, }, }, 
	{"battle_stop", "", {0, }, }, 
}

function ClsAIBat_lose_71_jy:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_lose_71_jy:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_lose_71_jy

----------------------- Auto Genrate End   --------------------
