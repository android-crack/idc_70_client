----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_52_change_speed = class("ClsAIBat_52_change_speed", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_52_change_speed:getId()
	return "bat_52_change_speed";
end


-- AI时机
function ClsAIBat_52_change_speed:getOpportunity()
	return AI_OPPORTUNITY.FIGHT_START;
end

-- AI优先级别
function ClsAIBat_52_change_speed:getPriority()
	return 1;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[OAI变速=-57]
local function bat_52_change_speed_act_0( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end


	-- 公式原文:OAI变速=-57
	owner:setAISpeed( -57 );

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"op", "", {bat_52_change_speed_act_0, }, }, 
}

function ClsAIBat_52_change_speed:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_52_change_speed:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_52_change_speed

----------------------- Auto Genrate End   --------------------
