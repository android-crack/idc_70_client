----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAITeam1_103 = class("ClsAITeam1_103", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAITeam1_103:getId()
	return "team1_103";
end


-- AI时机
function ClsAITeam1_103:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAITeam1_103:getPriority()
	return 48;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndNum2is2(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- 计数2
	local num2 = battleData:GetData("num2") or 0;
	-- num2==2
	if ( not (num2==2) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAITeam1_103:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndNum2is2(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[O阵营=1]
local function team1_103_act_0( ai_obj, act_obj, target, delta_time )
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
	{"op", "", {team1_103_act_0, }, }, 
	{"delete_ai", "", {{"team1_103", }, }, }, 
}

function ClsAITeam1_103:getActions()
	return actions
end

local all_target_method = {
}

function ClsAITeam1_103:getAllTargetMethod()
	return all_target_method
end

return ClsAITeam1_103

----------------------- Auto Genrate End   --------------------
