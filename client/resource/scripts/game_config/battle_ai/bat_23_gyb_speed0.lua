----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_23_gyb_speed0 = class("ClsAIBat_23_gyb_speed0", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_23_gyb_speed0:getId()
	return "bat_23_gyb_speed0";
end


-- AI时机
function ClsAIBat_23_gyb_speed0:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIBat_23_gyb_speed0:getPriority()
	return 1;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndSpeednot0(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- 宿主速度
	local OSpeed = owner:getSpeed();
	-- O速度>=0
	if ( not (OSpeed>=0) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIBat_23_gyb_speed0:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndSpeednot0(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[OAI变速=-10000]
local function bat_23_gyb_speed0_act_0( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end


	-- 公式原文:OAI变速=-10000
	owner:setAISpeed( -10000 );

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"op", "", {bat_23_gyb_speed0_act_0, }, }, 
}

function ClsAIBat_23_gyb_speed0:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_23_gyb_speed0:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_23_gyb_speed0

----------------------- Auto Genrate End   --------------------
