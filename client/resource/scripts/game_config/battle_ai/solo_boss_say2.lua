----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAISolo_boss_say2 = class("ClsAISolo_boss_say2", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAISolo_boss_say2:getId()
	return "solo_boss_say2";
end


-- AI时机
function ClsAISolo_boss_say2:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAISolo_boss_say2:getPriority()
	return 2;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]海盗数量大于5时，召唤另一批海盗
local function cndNumber5(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- 战场测试变量
	local PirateLeaveCnt = battleData:GetData("__pirate_leave_cnt") or 0;
	-- 离场数量==5 or 离场数量==10
	if ( not (PirateLeaveCnt==5 or PirateLeaveCnt==10) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAISolo_boss_say2:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndNumber5(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]说话-[哼，敌人太弱了。]
local function solo_boss_say2_act_0( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end




	local name = ""
	local word = T("哼，敌人太弱了。")

	target_obj:say( name, word )

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"op", "", {solo_boss_say2_act_0, }, }, 
	{"delete_ai", "", {{"solo_boss_say2", }, }, }, 
}

function ClsAISolo_boss_say2:getActions()
	return actions
end

local all_target_method = {
}

function ClsAISolo_boss_say2:getAllTargetMethod()
	return all_target_method
end

return ClsAISolo_boss_say2

----------------------- Auto Genrate End   --------------------
