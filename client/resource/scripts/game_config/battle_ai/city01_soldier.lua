----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[小兵出场]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAICity01_soldier = class("ClsAICity01_soldier", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAICity01_soldier:getId()
	return "city01_soldier";
end


-- AI时机
function ClsAICity01_soldier:getOpportunity()
	return AI_OPPORTUNITY.FIGHT_START;
end

-- AI优先级别
function ClsAICity01_soldier:getPriority()
	return 1;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[记录随机数=重置随机数]
local function city01_soldier_act_0( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end


	-- 公式原文:记录随机数=重置随机数
	battleData:planningSetData("__random_cnt", ai_obj:resetRandom());

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"op", "", {city01_soldier_act_0, }, }, 
	{"run_ai", "", {{"city01_soldier_A", }, }, }, 
	{"run_ai", "", {{"city01_soldier_B", }, }, }, 
	{"run_ai", "", {{"city01_soldier_C", }, }, }, 
	{"run_ai", "", {{"city01_soldier_D", }, }, }, 
}

function ClsAICity01_soldier:getActions()
	return actions
end

local all_target_method = {
}

function ClsAICity01_soldier:getAllTargetMethod()
	return all_target_method
end

return ClsAICity01_soldier

----------------------- Auto Genrate End   --------------------
