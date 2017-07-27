----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_192_die = class("ClsAIBat_192_die", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_192_die:getId()
	return "bat_192_die";
end


-- AI时机
function ClsAIBat_192_die:getOpportunity()
	return AI_OPPORTUNITY.DEATH;
end

-- AI优先级别
function ClsAIBat_192_die:getPriority()
	return -2;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[触发AI=1]
local function bat_192_die_act_0( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end


	-- 公式原文:触发AI=1
	battleData:planningSetData("__ai", 1);

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"op", "", {bat_192_die_act_0, }, }, 
}

function ClsAIBat_192_die:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_192_die:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_192_die

----------------------- Auto Genrate End   --------------------
