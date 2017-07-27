----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIHs_say1_03 = class("ClsAIHs_say1_03", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIHs_say1_03:getId()
	return "hs_say1_03";
end


-- AI时机
function ClsAIHs_say1_03:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIHs_say1_03:getPriority()
	return 2;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndTimeis4(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- 战斗已进行时间
	local BattleTime = battleData:getBattleTime();
	-- 战斗进行时间>=4000
	if ( not (BattleTime>=4000) ) then  return false end

	-- 战斗进行时间<=9000
	if ( not (BattleTime<=9000) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIHs_say1_03:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndTimeis4(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]说话-[遵命！]
local function hs_say1_03_act_0( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end




	local name = ""
	local word = T("遵命！")

	target_obj:say( name, word )

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"op", "", {hs_say1_03_act_0, }, }, 
	{"delete_ai", "", {{"hs_say1_03", }, }, }, 
}

function ClsAIHs_say1_03:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIHs_say1_03:getAllTargetMethod()
	return all_target_method
end

return ClsAIHs_say1_03

----------------------- Auto Genrate End   --------------------
