----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[6→8]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_event1_31 = class("ClsAIBat_event1_31", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_event1_31:getId()
	return "bat_event1_31";
end


-- AI时机
function ClsAIBat_event1_31:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIBat_event1_31:getPriority()
	return 1;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndTime1(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- 战斗已进行时间
	local BattleTime = battleData:getBattleTime();
	-- 战斗进行时间>=7000
	if ( not (BattleTime>=7000) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIBat_event1_31:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndTime1(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[OAI变速=60]
local function bat_event1_31_act_1( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end


	-- 公式原文:OAI变速=60
	owner:setAISpeed( 60 );

end

-- [备注]设置-[O阵营=2]
local function bat_event1_31_act_0( ai_obj, act_obj, target, delta_time )
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
	{"op", "", {bat_event1_31_act_0, }, }, 
	{"op", "", {bat_event1_31_act_1, }, }, 
	{"delete_ai", "", {{"bat_event1_31", }, }, }, 
}

function ClsAIBat_event1_31:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_event1_31:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_event1_31

----------------------- Auto Genrate End   --------------------
