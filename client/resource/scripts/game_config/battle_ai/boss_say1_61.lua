----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[19]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBoss_say1_61 = class("ClsAIBoss_say1_61", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBoss_say1_61:getId()
	return "boss_say1_61";
end


-- AI时机
function ClsAIBoss_say1_61:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIBoss_say1_61:getPriority()
	return 1;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndHpless100(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- O耐久百分比
	local OHpRate = owner:getHpRate() * 100;
	-- O耐久百分比<=100
	if ( not (OHpRate<=100) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIBoss_say1_61:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndHpless100(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]说话-[尽情攻击我吧，不痛不痒，哈哈哈]
local function boss_say1_61_act_0( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end




	local name = ""
	local word = T("尽情攻击我吧，不痛不痒，哈哈哈")

	target_obj:say( name, word )

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"op", "", {boss_say1_61_act_0, }, }, 
	{"delete_ai", "", {{"boss_say1_61", }, }, }, 
}

function ClsAIBoss_say1_61:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBoss_say1_61:getAllTargetMethod()
	return all_target_method
end

return ClsAIBoss_say1_61

----------------------- Auto Genrate End   --------------------
