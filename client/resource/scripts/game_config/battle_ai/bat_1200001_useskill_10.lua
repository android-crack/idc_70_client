----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_1200001_useskill_10 = class("ClsAIBat_1200001_useskill_10", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_1200001_useskill_10:getId()
	return "bat_1200001_useskill_10";
end


-- AI时机
function ClsAIBat_1200001_useskill_10:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIBat_1200001_useskill_10:getPriority()
	return -2;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndBat_1200001_time_10(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- 战斗已进行时间
	local BattleTime = battleData:getBattleTime();
	-- 战斗进行时间>60000
	if ( not (BattleTime>60000) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIBat_1200001_useskill_10:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndBat_1200001_time_10(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]说话-[@￥#*&%@！#￥#@……（听不清了……）]
local function bat_1200001_useskill_10_act_1( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end




	local name = ""
	local word = T("@￥#*&%@！#￥#@……（听不清了……）")

	target_obj:say( name, word )

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"add_status", "", {"wudi", }, }, 
	{"op", "", {bat_1200001_useskill_10_act_1, }, }, 
	{"add_effect_to_scene", "", {110101, "tx_chuxue", 0, 0, 100, 1, true, }, }, 
	{"use_skill", "", {1304, }, }, 
	{"delay", "", {1000, }, }, 
	{"use_skill", "", {1304, }, }, 
	{"del_effect_from_scene", "", {110101, }, }, 
	{"del_effect_from_scene", "", {110102, }, }, 
}

function ClsAIBat_1200001_useskill_10:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_1200001_useskill_10:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_1200001_useskill_10

----------------------- Auto Genrate End   --------------------
