----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAITiming2_112 = class("ClsAITiming2_112", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAITiming2_112:getId()
	return "timing2_112";
end


-- AI时机
function ClsAITiming2_112:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAITiming2_112:getPriority()
	return 1;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndTimeis10(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- 战斗已进行时间
	local BattleTime = battleData:getBattleTime();
	-- 战斗进行时间>6000
	if ( not (BattleTime>6000) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAITiming2_112:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndTimeis10(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[OAI变速=50]
local function timing2_112_act_3( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end


	-- 公式原文:OAI变速=50
	owner:setAISpeed( 50 );

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"stop_ai", "", {{"bat_move1_112", }, }, }, 
	{"delete_ai", "", {{"bat_move1_112", }, }, }, 
	{"delete_ai", "", {{"behit_112", }, }, }, 
	{"op", "", {timing2_112_act_3, }, }, 
	{"add_ai", "", {{"hpless90_112", }, }, }, 
	{"add_ai", "", {{"hpless50_112", }, }, }, 
	{"add_ai", "", {{"del_wudi_112_2", }, }, }, 
	{"stop_ai", "", {{"timing2_112", }, }, }, 
	{"delete_ai", "", {{"timing2_112", }, }, }, 
}

function ClsAITiming2_112:getActions()
	return actions
end

local all_target_method = {
}

function ClsAITiming2_112:getAllTargetMethod()
	return all_target_method
end

return ClsAITiming2_112

----------------------- Auto Genrate End   --------------------
