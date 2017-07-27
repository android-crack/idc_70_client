----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAITimeout_152 = class("ClsAITimeout_152", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAITimeout_152:getId()
	return "timeout_152";
end


-- AI时机
function ClsAITimeout_152:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAITimeout_152:getPriority()
	return 1;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndTimeout(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- 战斗已进行时间
	local BattleTime = battleData:getBattleTime();
	-- 战斗进行时间>=90000
	if ( not (BattleTime>=90000) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAITimeout_152:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndTimeout(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[触发2=触发2+1]
local function timeout_152_act_0( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end

	-- 战场测试变量
	local LET_AI2 = battleData:GetData("__ai_2") or 0;

	-- 公式原文:触发2=触发2+1
	battleData:planningSetData("__ai_2", LET_AI2+1);

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"op", "", {timeout_152_act_0, }, }, 
	{"delete_ai", "", {{"timeout_152", }, }, }, 
}

function ClsAITimeout_152:getActions()
	return actions
end

local all_target_method = {
}

function ClsAITimeout_152:getAllTargetMethod()
	return all_target_method
end

return ClsAITimeout_152

----------------------- Auto Genrate End   --------------------
