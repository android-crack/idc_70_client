----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[结局]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_13_amd_end = class("ClsAIBat_13_amd_end", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_13_amd_end:getId()
	return "bat_13_amd_end";
end


-- AI时机
function ClsAIBat_13_amd_end:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIBat_13_amd_end:getPriority()
	return -2;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndHpless30(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- O耐久百分比
	local OHpRate = owner:getHpRate() * 100;
	-- O耐久百分比<=30
	if ( not (OHpRate<=30) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIBat_13_amd_end:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndHpless30(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"add_effect_to_ship", "", {1, "tx_judian_boom", 0, 0, 3, false, }, }, 
	{"play_plot", "", {{12, 11, 13, 14, 16, 17, 18, }, }, }, 
	{"battle_stop", "", {1, }, }, 
	{"delete_ai", "", {{"bat_13_amd_end", }, }, }, 
}

function ClsAIBat_13_amd_end:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_13_amd_end:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_13_amd_end

----------------------- Auto Genrate End   --------------------
