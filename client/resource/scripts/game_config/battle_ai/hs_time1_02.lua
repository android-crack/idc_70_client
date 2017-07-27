----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIHs_time1_02 = class("ClsAIHs_time1_02", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIHs_time1_02:getId()
	return "hs_time1_02";
end


-- AI时机
function ClsAIHs_time1_02:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIHs_time1_02:getPriority()
	return 48;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndTimeis80(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- 战斗已进行时间
	local BattleTime = battleData:getBattleTime();
	-- 战斗进行时间>=80000
	if ( not (BattleTime>=80000) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIHs_time1_02:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndTimeis80(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[OAI变速=0]
local function hs_time1_02_act_1( ai_obj, act_obj, target, delta_time )
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
	{"stop_ai", "", {{"hs_speed0_02", }, }, }, 
	{"op", "", {hs_time1_02_act_1, }, }, 
	{"play_plot", "", {{1, 3, }, }, }, 
	{"delete_ai", "", {{"hs_hpless1_02", }, }, }, 
	{"delete_ai", "", {{"hs_time1_02", }, }, }, 
}

function ClsAIHs_time1_02:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIHs_time1_02:getAllTargetMethod()
	return all_target_method
end

return ClsAIHs_time1_02

----------------------- Auto Genrate End   --------------------
