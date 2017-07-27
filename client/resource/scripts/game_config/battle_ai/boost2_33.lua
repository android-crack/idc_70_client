----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[43]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBoost2_33 = class("ClsAIBoost2_33", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBoost2_33:getId()
	return "boost2_33";
end


-- AI时机
function ClsAIBoost2_33:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIBoost2_33:getPriority()
	return 48;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndTimeis15(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- 战斗已进行时间
	local BattleTime = battleData:getBattleTime();
	-- 战斗进行时间>=15000
	if ( not (BattleTime>=15000) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIBoost2_33:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndTimeis15(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[OAI变速=10]
local function boost2_33_act_0( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end


	-- 公式原文:OAI变速=10
	owner:setAISpeed( 10 );

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"op", "", {boost2_33_act_0, }, }, 
	{"delete_ai", "", {{"boost2_33", }, }, }, 
}

function ClsAIBoost2_33:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBoost2_33:getAllTargetMethod()
	return all_target_method
end

return ClsAIBoost2_33

----------------------- Auto Genrate End   --------------------
