----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[10]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_dead1_83 = class("ClsAIBat_dead1_83", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_dead1_83:getId()
	return "bat_dead1_83";
end


-- AI时机
function ClsAIBat_dead1_83:getOpportunity()
	return AI_OPPORTUNITY.DEATH;
end

-- AI优先级别
function ClsAIBat_dead1_83:getPriority()
	return -2;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[num2=num2+1]
local function bat_dead1_83_act_0( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end

	-- 计数2
	local num2 = battleData:GetData("num2") or 0;

	-- 公式原文:num2=num2+1
	battleData:planningSetData("num2", num2+1);

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"op", "", {bat_dead1_83_act_0, }, }, 
}

function ClsAIBat_dead1_83:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_dead1_83:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_dead1_83

----------------------- Auto Genrate End   --------------------
