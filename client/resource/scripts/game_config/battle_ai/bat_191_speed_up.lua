----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_191_speed_up = class("ClsAIBat_191_speed_up", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_191_speed_up:getId()
	return "bat_191_speed_up";
end


-- AI时机
function ClsAIBat_191_speed_up:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIBat_191_speed_up:getPriority()
	return 1;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[OAI变速=100]
local function bat_191_speed_up_act_0( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end


	-- 公式原文:OAI变速=100
	owner:setAISpeed( 100 );

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"op", "", {bat_191_speed_up_act_0, }, }, 
}

function ClsAIBat_191_speed_up:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_191_speed_up:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_191_speed_up

----------------------- Auto Genrate End   --------------------
