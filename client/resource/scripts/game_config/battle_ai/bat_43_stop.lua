----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_43_stop = class("ClsAIBat_43_stop", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_43_stop:getId()
	return "bat_43_stop";
end


-- AI时机
function ClsAIBat_43_stop:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIBat_43_stop:getPriority()
	return 48;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndBat_43_hp_less(ai_obj, target)
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
function ClsAIBat_43_stop:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndBat_43_hp_less(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"stop_ai", "", {{"bat_43_moto", }, }, }, 
	{"delete_ai", "", {{"bat_43_moto", }, }, }, 
}

function ClsAIBat_43_stop:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_43_stop:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_43_stop

----------------------- Auto Genrate End   --------------------
