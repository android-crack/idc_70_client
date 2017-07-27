----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_enter_151 = class("ClsAIBat_enter_151", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_enter_151:getId()
	return "bat_enter_151";
end


-- AI时机
function ClsAIBat_enter_151:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIBat_enter_151:getPriority()
	return 1;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndDie(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- 战场测试变量
	local DEAD = battleData:GetData("__dead") or 0;
	-- 死亡数量==5
	if ( not (DEAD==5) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIBat_enter_151:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndDie(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[触发AI=触发AI+1]
local function bat_enter_151_act_0( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end

	-- 战场测试变量
	local AI = battleData:GetData("__ai") or 0;

	-- 公式原文:触发AI=触发AI+1
	battleData:planningSetData("__ai", AI+1);

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"op", "", {bat_enter_151_act_0, }, }, 
	{"delete_ai", "", {{"bat_enter_151", }, }, }, 
}

function ClsAIBat_enter_151:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_enter_151:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_enter_151

----------------------- Auto Genrate End   --------------------
