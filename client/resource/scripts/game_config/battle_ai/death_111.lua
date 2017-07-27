----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIDeath_111 = class("ClsAIDeath_111", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIDeath_111:getId()
	return "death_111";
end


-- AI时机
function ClsAIDeath_111:getOpportunity()
	return AI_OPPORTUNITY.DEATH;
end

-- AI优先级别
function ClsAIDeath_111:getPriority()
	return -2;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[死亡数=死亡数+1]
local function death_111_act_0( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end

	-- 计数1
	local DeathCnt = battleData:GetData("death") or 0;

	-- 公式原文:死亡数=死亡数+1
	battleData:planningSetData("death", DeathCnt+1);

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"op", "", {death_111_act_0, }, }, 
}

function ClsAIDeath_111:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIDeath_111:getAllTargetMethod()
	return all_target_method
end

return ClsAIDeath_111

----------------------- Auto Genrate End   --------------------
