----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[海怪受伤效果]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_11_boss_effect = class("ClsAIBat_11_boss_effect", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_11_boss_effect:getId()
	return "bat_11_boss_effect";
end


-- AI时机
function ClsAIBat_11_boss_effect:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIBat_11_boss_effect:getPriority()
	return 48;
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
	-- O耐久百分比<100
	if ( not (OHpRate<100) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIBat_11_boss_effect:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndHpless100(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"add_effect_to_scene", "", {1, "tx_chuxue", 0, 0, 100, 1, true, }, }, 
	{"add_effect_to_scene", "", {2, "tx_shuibo", 0, 0, 100, 1, true, }, }, 
	{"delete_ai", "", {{"bat_11_boss_effect", }, }, }, 
}

function ClsAIBat_11_boss_effect:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_11_boss_effect:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_11_boss_effect

----------------------- Auto Genrate End   --------------------
