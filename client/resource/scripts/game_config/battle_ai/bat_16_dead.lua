----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_16_dead = class("ClsAIBat_16_dead", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_16_dead:getId()
	return "bat_16_dead";
end


-- AI时机
function ClsAIBat_16_dead:getOpportunity()
	return AI_OPPORTUNITY.DEATH;
end

-- AI优先级别
function ClsAIBat_16_dead:getPriority()
	return 48;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[死亡=死亡+1]
local function bat_16_dead_act_0( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end

	-- 
	local dead = battleData:GetData("dead") or 0;

	-- 公式原文:死亡=死亡+1
	battleData:SetData("dead", dead+1);

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"op", "", {bat_16_dead_act_0, }, }, 
}

function ClsAIBat_16_dead:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_16_dead:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_16_dead

----------------------- Auto Genrate End   --------------------
