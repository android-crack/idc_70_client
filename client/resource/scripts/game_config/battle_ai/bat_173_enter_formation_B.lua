----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[第一波自爆舰]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_173_enter_formation_B = class("ClsAIBat_173_enter_formation_B", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_173_enter_formation_B:getId()
	return "bat_173_enter_formation_B";
end


-- AI时机
function ClsAIBat_173_enter_formation_B:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIBat_173_enter_formation_B:getPriority()
	return 1;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[记录随机数=重置随机数]
local function bat_173_enter_formation_B_act_0( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end


	-- 公式原文:记录随机数=重置随机数
	battleData:planningSetData("_text_cnt", ai_obj:resetRandom());

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"op", "", {bat_173_enter_formation_B_act_0, }, }, 
	{"delay", "", {5000, }, }, 
	{"run_ai", "", {{"bat_173_enter_formation_a_B", }, }, }, 
	{"run_ai", "", {{"bat_173_enter_formation_b_B", }, }, }, 
	{"run_ai", "", {{"bat_173_enter_formation_c_B", }, }, }, 
}

function ClsAIBat_173_enter_formation_B:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_173_enter_formation_B:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_173_enter_formation_B

----------------------- Auto Genrate End   --------------------
