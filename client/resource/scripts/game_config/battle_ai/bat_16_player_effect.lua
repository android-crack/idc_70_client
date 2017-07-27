----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_16_player_effect = class("ClsAIBat_16_player_effect", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_16_player_effect:getId()
	return "bat_16_player_effect";
end


-- AI时机
function ClsAIBat_16_player_effect:getOpportunity()
	return AI_OPPORTUNITY.RUN;
end

-- AI优先级别
function ClsAIBat_16_player_effect:getPriority()
	return 48;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[OAI变速=60]
local function bat_16_player_effect_act_1( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end


	-- 公式原文:OAI变速=60
	owner:setAISpeed( 60 );

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"add_effect_to_ship", "", {1, "tx_speedup", 0, 0, 120, true, }, }, 
	{"op", "", {bat_16_player_effect_act_1, }, }, 
}

function ClsAIBat_16_player_effect:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_16_player_effect:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_16_player_effect

----------------------- Auto Genrate End   --------------------
