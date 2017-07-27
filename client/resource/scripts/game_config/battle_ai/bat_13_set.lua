----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_13_set = class("ClsAIBat_13_set", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_13_set:getId()
	return "bat_13_set";
end


-- AI时机
function ClsAIBat_13_set:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIBat_13_set:getPriority()
	return 48;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndPlayerdead(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- 战场测试变量
	local player_godie = battleData:GetData("player_godie") or 0;
	-- 玩家狗带==1
	if ( not (player_godie==1) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIBat_13_set:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndPlayerdead(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[TAI变速=80]
local function bat_13_set_act_0( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end


	-- 公式原文:TAI变速=80
	target_obj:setAISpeed( 80 );

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"op", "", {bat_13_set_act_0, }, }, 
	{"delete_ai", "", {{"bat_13_follow", }, }, }, 
	{"add_ai", "", {{"bat_13_follow_player", }, }, }, 
	{"delete_ai", "", {{"bat_13_set", }, }, }, 
}

function ClsAIBat_13_set:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_13_set:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_13_set

----------------------- Auto Genrate End   --------------------
