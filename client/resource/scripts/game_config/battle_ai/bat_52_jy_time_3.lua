----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[未使用]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_52_jy_time_3 = class("ClsAIBat_52_jy_time_3", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_52_jy_time_3:getId()
	return "bat_52_jy_time_3";
end


-- AI时机
function ClsAIBat_52_jy_time_3:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIBat_52_jy_time_3:getPriority()
	return 1;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndBat_52_jy_time_3(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- 战斗已进行时间
	local BattleTime = battleData:getBattleTime();
	-- 战斗进行时间>=11000
	if ( not (BattleTime>=11000) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIBat_52_jy_time_3:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndBat_52_jy_time_3(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[OAI变速=0]
local function bat_52_jy_time_3_act_1( ai_obj, act_obj, target, delta_time )
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

-- [备注]说话-[兄弟们,主角都到了]
local function bat_52_jy_time_3_act_0( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end




	local name = T("兄弟们")
	local word = T("主角都到了")

	target_obj:say( name, word )

end

-- [备注]离场-[]
local function bat_52_jy_time_3_act_3( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end


	target_obj:release(false, true)

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"op", "", {bat_52_jy_time_3_act_0, }, }, 
	{"op", "", {bat_52_jy_time_3_act_1, }, }, 
	{"move_to", "", {2400, 1100, 100, }, }, 
	{"op", "", {bat_52_jy_time_3_act_3, }, }, 
	{"delete_ai", "", {{"bat_52_jy_time_3", }, }, }, 
}

function ClsAIBat_52_jy_time_3:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_52_jy_time_3:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_52_jy_time_3

----------------------- Auto Genrate End   --------------------
