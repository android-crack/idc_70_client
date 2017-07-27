----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_3021_time = class("ClsAIBat_3021_time", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_3021_time:getId()
	return "bat_3021_time";
end


-- AI时机
function ClsAIBat_3021_time:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIBat_3021_time:getPriority()
	return 1;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndBat_21_time(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- 战斗已进行时间
	local BattleTime = battleData:getBattleTime();
	-- 战斗进行时间>20000
	if ( not (BattleTime>20000) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIBat_3021_time:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndBat_21_time(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]说话-[有敌人偷袭！水手们，拿起武器应战]
local function bat_3021_time_act_0( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end




	local name = ""
	local word = T("有敌人偷袭！水手们，拿起武器应战")

	target_obj:say( name, word )

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"op", "", {bat_3021_time_act_0, }, }, 
	{"delete_ai", "", {{"bat_3021_time", }, }, }, 
}

function ClsAIBat_3021_time:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_3021_time:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_3021_time

----------------------- Auto Genrate End   --------------------
