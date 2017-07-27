----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIHs_summon2_04 = class("ClsAIHs_summon2_04", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIHs_summon2_04:getId()
	return "hs_summon2_04";
end


-- AI时机
function ClsAIHs_summon2_04:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIHs_summon2_04:getPriority()
	return -2;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndTimeis15(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- 战斗已进行时间
	local BattleTime = battleData:getBattleTime();
	-- 战斗进行时间>=15000
	if ( not (BattleTime>=15000) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIHs_summon2_04:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndTimeis15(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]说话-[还真顽强！自爆舰！继续！]
local function hs_summon2_04_act_0( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end




	local name = ""
	local word = T("还真顽强！自爆舰！继续！")

	target_obj:say( name, word )

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"op", "", {hs_summon2_04_act_0, }, }, 
	{"enter_scene", "", {10, }, }, 
	{"enter_scene", "", {11, }, }, 
	{"enter_scene", "", {12, }, }, 
	{"enter_scene", "", {13, }, }, 
	{"delete_ai", "", {{"hs_summon2_04", }, }, }, 
}

function ClsAIHs_summon2_04:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIHs_summon2_04:getAllTargetMethod()
	return all_target_method
end

return ClsAIHs_summon2_04

----------------------- Auto Genrate End   --------------------
