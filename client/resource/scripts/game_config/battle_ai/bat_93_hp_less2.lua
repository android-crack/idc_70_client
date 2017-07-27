----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_93_hp_less2 = class("ClsAIBat_93_hp_less2", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_93_hp_less2:getId()
	return "bat_93_hp_less2";
end


-- AI时机
function ClsAIBat_93_hp_less2:getOpportunity()
	return AI_OPPORTUNITY.HP_CHANGE;
end

-- AI优先级别
function ClsAIBat_93_hp_less2:getPriority()
	return -2;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndBat_93_hp_less2(ai_obj, target)
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
function ClsAIBat_93_hp_less2:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndBat_93_hp_less2(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"add_status", "", {"wudi", }, }, 
	{"delete_ai", "", {{"bat_93_hp_less2", }, }, }, 
}

function ClsAIBat_93_hp_less2:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_93_hp_less2:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_93_hp_less2

----------------------- Auto Genrate End   --------------------
