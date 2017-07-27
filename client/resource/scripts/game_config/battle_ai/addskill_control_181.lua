----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIAddskill_control_181 = class("ClsAIAddskill_control_181", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIAddskill_control_181:getId()
	return "addskill_control_181";
end


-- AI时机
function ClsAIAddskill_control_181:getOpportunity()
	return AI_OPPORTUNITY.FIGHT_START;
end

-- AI优先级别
function ClsAIAddskill_control_181:getPriority()
	return 1;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[T加怒=100]
local function addskill_control_181_act_0( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end


	-- 公式原文:T加怒=100
	target_obj:addAnger( 100 );

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"op", "", {addskill_control_181_act_0, }, }, 
	{"add_skill", "", {1026, 2, }, }, 
}

function ClsAIAddskill_control_181:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIAddskill_control_181:getAllTargetMethod()
	return all_target_method
end

return ClsAIAddskill_control_181

----------------------- Auto Genrate End   --------------------
