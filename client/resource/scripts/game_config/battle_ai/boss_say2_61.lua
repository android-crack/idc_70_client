----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[21]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBoss_say2_61 = class("ClsAIBoss_say2_61", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBoss_say2_61:getId()
	return "boss_say2_61";
end


-- AI时机
function ClsAIBoss_say2_61:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIBoss_say2_61:getPriority()
	return 1;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndTimeis30(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- 战斗已进行时间
	local BattleTime = battleData:getBattleTime();
	-- 战斗进行时间>=30000
	if ( not (BattleTime>=30000) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIBoss_say2_61:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndTimeis30(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]说话-[快跟上，别让他们跑了！]
local function boss_say2_61_act_0( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end




	local name = ""
	local word = T("快跟上，别让他们跑了！")

	target_obj:say( name, word )

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"op", "", {boss_say2_61_act_0, }, }, 
	{"delete_ai", "", {{"boss_say2_61", }, }, }, 
}

function ClsAIBoss_say2_61:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBoss_say2_61:getAllTargetMethod()
	return all_target_method
end

return ClsAIBoss_say2_61

----------------------- Auto Genrate End   --------------------
