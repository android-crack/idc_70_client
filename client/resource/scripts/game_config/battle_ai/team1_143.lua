----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAITeam1_143 = class("ClsAITeam1_143", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAITeam1_143:getId()
	return "team1_143";
end


-- AI时机
function ClsAITeam1_143:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAITeam1_143:getPriority()
	return -2;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndNum1is1(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- 计数1
	local num1 = battleData:GetData("num1") or 0;
	-- num1==1
	if ( not (num1==1) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAITeam1_143:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndNum1is1(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[O阵营=1]
local function team1_143_act_0( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end


	-- 公式原文:O阵营=1
	battleData:changeTeam(owner, 1 );

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"op", "", {team1_143_act_0, }, }, 
	{"delete_ai", "", {{"team1_143", }, }, }, 
}

function ClsAITeam1_143:getActions()
	return actions
end

local all_target_method = {
}

function ClsAITeam1_143:getAllTargetMethod()
	return all_target_method
end

return ClsAITeam1_143

----------------------- Auto Genrate End   --------------------
