----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_13_player_dead = class("ClsAIBat_13_player_dead", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_13_player_dead:getId()
	return "bat_13_player_dead";
end


-- AI时机
function ClsAIBat_13_player_dead:getOpportunity()
	return AI_OPPORTUNITY.DEATH;
end

-- AI优先级别
function ClsAIBat_13_player_dead:getPriority()
	return -4;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[目标坐标X=OX]
local function bat_13_player_dead_act_1( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end


	-- 公式原文:目标坐标X=OX
	battleData:planningSetData("PX", owner:getPositionX());

end

-- [备注]设置-[玩家狗带=玩家狗带+1]
local function bat_13_player_dead_act_0( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end

	-- 战场测试变量
	local player_godie = battleData:GetData("player_godie") or 0;

	-- 公式原文:玩家狗带=玩家狗带+1
	battleData:planningSetData("player_godie", player_godie+1);

end

-- [备注]设置-[目标坐标Y=OY]
local function bat_13_player_dead_act_2( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end


	-- 公式原文:目标坐标Y=OY
	battleData:planningSetData("PY", owner:getPositionY());

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"op", "", {bat_13_player_dead_act_0, }, }, 
	{"op", "", {bat_13_player_dead_act_1, }, }, 
	{"op", "", {bat_13_player_dead_act_2, }, }, 
}

function ClsAIBat_13_player_dead:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_13_player_dead:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_13_player_dead

----------------------- Auto Genrate End   --------------------
