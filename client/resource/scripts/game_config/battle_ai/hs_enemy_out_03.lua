----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIHs_enemy_out_03 = class("ClsAIHs_enemy_out_03", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIHs_enemy_out_03:getId()
	return "hs_enemy_out_03";
end


-- AI时机
function ClsAIHs_enemy_out_03:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIHs_enemy_out_03:getPriority()
	return 2;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]范围外
local function cndOut_area(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- math.abs(1856 - OX) > 160 or math.abs(832 - OY) > 160
	if ( not (math.abs(1856 - owner:getPositionX()) > 160 or math.abs(832 - owner:getPositionY()) > 160) ) then  return false end

	-- math.abs(2304 - OX) > 160 or math.abs(576 - OY) > 160
	if ( not (math.abs(2304 - owner:getPositionX()) > 160 or math.abs(576 - owner:getPositionY()) > 160) ) then  return false end

	-- math.abs(1280 - OX) > 160 or math.abs(256 - OY) > 160
	if ( not (math.abs(1280 - owner:getPositionX()) > 160 or math.abs(256 - owner:getPositionY()) > 160) ) then  return false end

	-- math.abs(1024 - OX) > 160 or math.abs(832 - OY) > 160
	if ( not (math.abs(1024 - owner:getPositionX()) > 160 or math.abs(832 - owner:getPositionY()) > 160) ) then  return false end

	-- math.abs(1280 - OX) > 160 or math.abs(1152 - OY) > 160
	if ( not (math.abs(1280 - owner:getPositionX()) > 160 or math.abs(1152 - owner:getPositionY()) > 160) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIHs_enemy_out_03:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndOut_area(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[OAI变速=0]
local function hs_enemy_out_03_act_0( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end


	-- 公式原文:OAI变速=0
	owner:setAISpeed( 0 );

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"op", "", {hs_enemy_out_03_act_0, }, }, 
}

function ClsAIHs_enemy_out_03:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIHs_enemy_out_03:getAllTargetMethod()
	return all_target_method
end

return ClsAIHs_enemy_out_03

----------------------- Auto Genrate End   --------------------
