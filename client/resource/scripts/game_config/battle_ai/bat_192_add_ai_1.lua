----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_192_add_ai_1 = class("ClsAIBat_192_add_ai_1", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_192_add_ai_1:getId()
	return "bat_192_add_ai_1";
end


-- AI时机
function ClsAIBat_192_add_ai_1:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIBat_192_add_ai_1:getPriority()
	return 48;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[OAI远攻=60000]
local function bat_192_add_ai_1_act_1( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end


	-- 公式原文:OAI远攻=60000
	owner:setAIFarAtt( 60000 );

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"delay", "", {1000, }, }, 
	{"op", "", {bat_192_add_ai_1_act_1, }, }, 
	{"add_effect_to_ship", "", {1, "jn_xuli", 0, 0, 600, true, }, }, 
	{"delete_ai", "", {{"bat_192_add_ai_1", }, }, }, 
}

function ClsAIBat_192_add_ai_1:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_192_add_ai_1:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_192_add_ai_1

----------------------- Auto Genrate End   --------------------
