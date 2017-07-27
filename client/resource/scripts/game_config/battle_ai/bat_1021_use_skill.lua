----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_1021_use_skill = class("ClsAIBat_1021_use_skill", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_1021_use_skill:getId()
	return "bat_1021_use_skill";
end


-- AI时机
function ClsAIBat_1021_use_skill:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIBat_1021_use_skill:getPriority()
	return 1;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndBat_21_hp_less_3(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- O耐久百分比
	local OHpRate = owner:getHpRate() * 100;
	-- O耐久百分比<=50
	if ( not (OHpRate<=50) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIBat_1021_use_skill:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndBat_21_hp_less_3(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"use_skill", "", {1002, }, }, 
	{"stop_ai", "", {{"bat_1021_use_skill", }, }, }, 
	{"delete_ai", "", {{"bat_1021_use_skill", }, }, }, 
}

function ClsAIBat_1021_use_skill:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_1021_use_skill:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_1021_use_skill

----------------------- Auto Genrate End   --------------------
