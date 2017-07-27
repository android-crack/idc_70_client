----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[28]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIHpless4_131 = class("ClsAIHpless4_131", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIHpless4_131:getId()
	return "hpless4_131";
end


-- AI时机
function ClsAIHpless4_131:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIHpless4_131:getPriority()
	return 1;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndHpless40(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- O耐久百分比
	local OHpRate = owner:getHpRate() * 100;
	-- O耐久百分比<=40
	if ( not (OHpRate<=40) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIHpless4_131:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndHpless40(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[OAI变速=0]
local function hpless4_131_act_0( ai_obj, act_obj, target, delta_time )
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
	{"op", "", {hpless4_131_act_0, }, }, 
	{"delete_ai", "", {{"hpless4_131", }, }, }, 
}

function ClsAIHpless4_131:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIHpless4_131:getAllTargetMethod()
	return all_target_method
end

return ClsAIHpless4_131

----------------------- Auto Genrate End   --------------------
