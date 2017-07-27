----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[4]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_say2_102 = class("ClsAIBat_say2_102", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_say2_102:getId()
	return "bat_say2_102";
end


-- AI时机
function ClsAIBat_say2_102:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIBat_say2_102:getPriority()
	return 1;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndTimeis6(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- 战斗已进行时间
	local BattleTime = battleData:getBattleTime();
	-- 战斗进行时间>=6000
	if ( not (BattleTime>=6000) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIBat_say2_102:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndTimeis6(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]说话-[抱歉，老酒鬼，你得停船接受检查。]
local function bat_say2_102_act_0( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end




	local name = ""
	local word = T("抱歉，老酒鬼，你得停船接受检查。")

	target_obj:say( name, word )

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"op", "", {bat_say2_102_act_0, }, }, 
	{"delete_ai", "", {{"bat_say2_102", }, }, }, 
}

function ClsAIBat_say2_102:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_say2_102:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_say2_102

----------------------- Auto Genrate End   --------------------
