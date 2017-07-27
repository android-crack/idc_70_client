----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_16_speed = class("ClsAIBat_16_speed", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_16_speed:getId()
	return "bat_16_speed";
end


-- AI时机
function ClsAIBat_16_speed:getOpportunity()
	return AI_OPPORTUNITY.RUN;
end

-- AI优先级别
function ClsAIBat_16_speed:getPriority()
	return 48;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[OAI变速=80]
local function bat_16_speed_act_0( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end


	-- 公式原文:OAI变速=80
	owner:setAISpeed( 80 );

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"op", "", {bat_16_speed_act_0, }, }, 
}

function ClsAIBat_16_speed:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_16_speed:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_16_speed

----------------------- Auto Genrate End   --------------------
