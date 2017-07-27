----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[进场冲刺]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAINex_set_speed_3 = class("ClsAINex_set_speed_3", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAINex_set_speed_3:getId()
	return "nex_set_speed_3";
end


-- AI时机
function ClsAINex_set_speed_3:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAINex_set_speed_3:getPriority()
	return 2;
end

-- AI停止标记
function ClsAINex_set_speed_3:getStopOtherFlg()
	return 2;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndNex_move(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- 宿主变量
	local iMove = owner:getData( "__move" ) or 0;
	-- 移动==0
	if ( not (iMove==0) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAINex_set_speed_3:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndNex_move(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[OAI变速=0]
local function nex_set_speed_3_act_2( ai_obj, act_obj, target, delta_time )
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

-- [备注]设置-[OAI变速=O速度*1.5]
local function nex_set_speed_3_act_0( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end

	-- 宿主速度
	local OSpeed = owner:getSpeed();

	-- 公式原文:OAI变速=O速度*1.5
	owner:setAISpeed( OSpeed*1.5 );

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"op", "", {nex_set_speed_3_act_0, }, }, 
	{"move_to", "", {700, 520, 50, }, }, 
	{"op", "", {nex_set_speed_3_act_2, }, }, 
	{"delete_ai", "", {{"nex_set_speed_3", }, }, }, 
}

function ClsAINex_set_speed_3:getActions()
	return actions
end

local all_target_method = {
}

function ClsAINex_set_speed_3:getAllTargetMethod()
	return all_target_method
end

return ClsAINex_set_speed_3

----------------------- Auto Genrate End   --------------------
