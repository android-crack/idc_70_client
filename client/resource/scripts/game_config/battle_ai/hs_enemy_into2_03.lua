----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIHs_enemy_into2_03 = class("ClsAIHs_enemy_into2_03", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIHs_enemy_into2_03:getId()
	return "hs_enemy_into2_03";
end


-- AI时机
function ClsAIHs_enemy_into2_03:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIHs_enemy_into2_03:getPriority()
	return 2;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]进入范围2
local function cndIn_area2(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- math.abs(2304 - OX) < 160
	if ( not (math.abs(2304 - owner:getPositionX()) < 160) ) then  return false end

	-- math.abs(576 - OY) < 160
	if ( not (math.abs(576 - owner:getPositionY()) < 160) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIHs_enemy_into2_03:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndIn_area2(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[OAI变速=-0.8*O速度]
local function hs_enemy_into2_03_act_0( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end

	-- 宿主速度
	local OSpeed = owner:getSpeed();

	-- 公式原文:OAI变速=-0.8*O速度
	owner:setAISpeed( -0.8*OSpeed );

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"op", "", {hs_enemy_into2_03_act_0, }, }, 
}

function ClsAIHs_enemy_into2_03:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIHs_enemy_into2_03:getAllTargetMethod()
	return all_target_method
end

return ClsAIHs_enemy_into2_03

----------------------- Auto Genrate End   --------------------
