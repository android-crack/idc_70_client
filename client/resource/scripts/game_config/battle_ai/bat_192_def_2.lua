----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_192_def_2 = class("ClsAIBat_192_def_2", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_192_def_2:getId()
	return "bat_192_def_2";
end


-- AI时机
function ClsAIBat_192_def_2:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIBat_192_def_2:getPriority()
	return 48;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndDef_effect_2(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- O耐久百分比
	local OHpRate = owner:getHpRate() * 100;
	-- O耐久百分比<60
	if ( not (OHpRate<60) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIBat_192_def_2:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndDef_effect_2(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"add_effect_to_ship", "", {2, "sf_tujin", 0, 0, 600, true, }, }, 
	{"delete_ai", "", {{"bat_192_def_2", }, }, }, 
}

function ClsAIBat_192_def_2:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_192_def_2:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_192_def_2

----------------------- Auto Genrate End   --------------------
