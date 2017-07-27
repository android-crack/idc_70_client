----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_deadcnt_101 = class("ClsAIBat_deadcnt_101", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_deadcnt_101:getId()
	return "bat_deadcnt_101";
end


-- AI时机
function ClsAIBat_deadcnt_101:getOpportunity()
	return AI_OPPORTUNITY.DEATH;
end

-- AI优先级别
function ClsAIBat_deadcnt_101:getPriority()
	return -2;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[num1=num1+1]
local function bat_deadcnt_101_act_0( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end

	-- 计数1
	local num1 = battleData:GetData("num1") or 0;

	-- 公式原文:num1=num1+1
	battleData:planningSetData("num1", num1+1);

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"op", "", {bat_deadcnt_101_act_0, }, }, 
}

function ClsAIBat_deadcnt_101:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_deadcnt_101:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_deadcnt_101

----------------------- Auto Genrate End   --------------------
