----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_3021_hp_less_3 = class("ClsAIBat_3021_hp_less_3", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_3021_hp_less_3:getId()
	return "bat_3021_hp_less_3";
end


-- AI时机
function ClsAIBat_3021_hp_less_3:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIBat_3021_hp_less_3:getPriority()
	return 1;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndBat_21_hp_less(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- O耐久百分比
	local OHpRate = owner:getHpRate() * 100;
	-- O耐久百分比<=99
	if ( not (OHpRate<=99) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIBat_3021_hp_less_3:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndBat_21_hp_less(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]说话-[ZZZzzz，好多金子！]
local function bat_3021_hp_less_3_act_0( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end




	local name = ""
	local word = T("ZZZzzz，好多金子！")

	target_obj:say( name, word )

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"op", "", {bat_3021_hp_less_3_act_0, }, }, 
	{"delete_ai", "", {{"bat_3021_hp_less_3", }, }, }, 
}

function ClsAIBat_3021_hp_less_3:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_3021_hp_less_3:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_3021_hp_less_3

----------------------- Auto Genrate End   --------------------
