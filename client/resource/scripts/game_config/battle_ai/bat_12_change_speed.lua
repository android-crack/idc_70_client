----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_12_change_speed = class("ClsAIBat_12_change_speed", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_12_change_speed:getId()
	return "bat_12_change_speed";
end


-- AI时机
function ClsAIBat_12_change_speed:getOpportunity()
	return AI_OPPORTUNITY.FIGHT_START;
end

-- AI优先级别
function ClsAIBat_12_change_speed:getPriority()
	return 48;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[OAI变速=-O速度]
local function bat_12_change_speed_act_0( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end

	-- 宿主速度
	local OSpeed = owner:getSpeed();

	-- 公式原文:OAI变速=-O速度
	owner:setAISpeed( -OSpeed );

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"op", "", {bat_12_change_speed_act_0, }, }, 
	{"delay", "", {12000, }, }, 
}

function ClsAIBat_12_change_speed:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_12_change_speed:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_12_change_speed

----------------------- Auto Genrate End   --------------------
