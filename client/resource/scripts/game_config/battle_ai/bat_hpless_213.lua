----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_hpless_213 = class("ClsAIBat_hpless_213", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_hpless_213:getId()
	return "bat_hpless_213";
end


-- AI时机
function ClsAIBat_hpless_213:getOpportunity()
	return AI_OPPORTUNITY.HP_CHANGE;
end

-- AI优先级别
function ClsAIBat_hpless_213:getPriority()
	return -2;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndHpless70(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- O耐久百分比
	local OHpRate = owner:getHpRate() * 100;
	-- O耐久百分比<=70
	if ( not (OHpRate<=70) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIBat_hpless_213:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndHpless70(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[hp70=hp70+1]
local function bat_hpless_213_act_0( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end

	-- 
	local hp70 = battleData:GetData("hp70") or 0;

	-- 公式原文:hp70=hp70+1
	battleData:planningSetData("hp70", hp70+1);

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"op", "", {bat_hpless_213_act_0, }, }, 
	{"delete_ai", "", {{"bat_hpless_213", }, }, }, 
}

function ClsAIBat_hpless_213:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_hpless_213:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_hpless_213

----------------------- Auto Genrate End   --------------------
