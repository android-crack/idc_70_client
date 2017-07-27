----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_effect1_213 = class("ClsAIBat_effect1_213", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_effect1_213:getId()
	return "bat_effect1_213";
end


-- AI时机
function ClsAIBat_effect1_213:getOpportunity()
	return AI_OPPORTUNITY.RUN;
end

-- AI优先级别
function ClsAIBat_effect1_213:getPriority()
	return -2;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[OAI变速=50]
local function bat_effect1_213_act_1( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end


	-- 公式原文:OAI变速=50
	owner:setAISpeed( 50 );

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"add_effect_to_ship", "", {1, "tx_speedup", 0, 0, 120, true, }, }, 
	{"op", "", {bat_effect1_213_act_1, }, }, 
}

function ClsAIBat_effect1_213:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_effect1_213:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_effect1_213

----------------------- Auto Genrate End   --------------------
