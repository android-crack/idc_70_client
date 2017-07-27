----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAITime_153 = class("ClsAITime_153", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAITime_153:getId()
	return "time_153";
end


-- AI时机
function ClsAITime_153:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAITime_153:getPriority()
	return 48;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndTime(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- 战斗已进行时间
	local BattleTime = battleData:getBattleTime();
	-- 战场测试变量
	local DEAD = battleData:GetData("__dead") or 0;
	-- 战斗进行时间>=20000 or 死亡数量>=4
	if ( not (BattleTime>=20000 or DEAD>=4) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAITime_153:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndTime(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[触发AI=触发AI+1]
local function time_153_act_0( ai_obj, act_obj, target, delta_time )
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
	{"op", "", {time_153_act_0, }, }, 
	{"show_prompt", "", {T("击败罗伯茨"), }, }, 
	{"delete_ai", "", {{"time_153", }, }, }, 
}

function ClsAITime_153:getActions()
	return actions
end

local all_target_method = {
}

function ClsAITime_153:getAllTargetMethod()
	return all_target_method
end

return ClsAITime_153

----------------------- Auto Genrate End   --------------------
