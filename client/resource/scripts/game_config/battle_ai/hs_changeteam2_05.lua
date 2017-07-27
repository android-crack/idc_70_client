----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIHs_changeteam2_05 = class("ClsAIHs_changeteam2_05", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIHs_changeteam2_05:getId()
	return "hs_changeteam2_05";
end


-- AI时机
function ClsAIHs_changeteam2_05:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIHs_changeteam2_05:getPriority()
	return 48;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndNum3is1(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- 计数3
	local num3 = battleData:GetData("num3") or 0;
	-- num3==1
	if ( not (num3==1) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIHs_changeteam2_05:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndNum3is1(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[O阵营=2]
local function hs_changeteam2_05_act_0( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end


	-- 公式原文:O阵营=2
	battleData:changeTeam(owner, 2 );

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"op", "", {hs_changeteam2_05_act_0, }, }, 
	{"delete_ai", "", {{"hs_changeteam2_05", }, }, }, 
}

function ClsAIHs_changeteam2_05:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIHs_changeteam2_05:getAllTargetMethod()
	return all_target_method
end

return ClsAIHs_changeteam2_05

----------------------- Auto Genrate End   --------------------
