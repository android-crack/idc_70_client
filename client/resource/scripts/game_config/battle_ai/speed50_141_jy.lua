----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[18]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAISpeed50_141_jy = class("ClsAISpeed50_141_jy", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAISpeed50_141_jy:getId()
	return "speed50_141_jy";
end


-- AI时机
function ClsAISpeed50_141_jy:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAISpeed50_141_jy:getPriority()
	return 1;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndHpless50(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- O耐久百分比
	local OHpRate = owner:getHpRate() * 100;
	-- O耐久百分比<50
	if ( not (OHpRate<50) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAISpeed50_141_jy:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndHpless50(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[O阵营=1]
local function speed50_141_jy_act_0( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end


	-- 公式原文:O阵营=1
	battleData:changeTeam(owner, 1 );

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"op", "", {speed50_141_jy_act_0, }, }, 
	{"play_plot", "", {{5, 6, 7, }, }, }, 
	{"battle_stop", "", {1, }, }, 
}

function ClsAISpeed50_141_jy:getActions()
	return actions
end

local all_target_method = {
}

function ClsAISpeed50_141_jy:getAllTargetMethod()
	return all_target_method
end

return ClsAISpeed50_141_jy

----------------------- Auto Genrate End   --------------------
