----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_173_enter_range_2_A = class("ClsAIBat_173_enter_range_2_A", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_173_enter_range_2_A:getId()
	return "bat_173_enter_range_2_A";
end


-- AI时机
function ClsAIBat_173_enter_range_2_A:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIBat_173_enter_range_2_A:getPriority()
	return 1;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndBat_173_enter_range(ai_obj, target)
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
function ClsAIBat_173_enter_range_2_A:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndBat_173_enter_range(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]说话-[发现敌军]
local function bat_173_enter_range_2_A_act_2( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end




	local name = ""
	local word = T("发现敌军")

	target_obj:say( name, word )

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"stop_ai", "", {{"bat_173_add_move_to5", }, }, }, 
	{"delete_ai", "", {{"bat_173_add_move_to5", }, }, }, 
	{"op", "", {bat_173_enter_range_2_A_act_2, }, }, 
	{"add_skill", "", {1213, 1, }, }, 
	{"add_ai", "", {{"bat_173_hp", }, }, }, 
	{"delete_ai", "", {{"bat_173_enter_range_2_A", }, }, }, 
}

function ClsAIBat_173_enter_range_2_A:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_173_enter_range_2_A:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_173_enter_range_2_A

----------------------- Auto Genrate End   --------------------
