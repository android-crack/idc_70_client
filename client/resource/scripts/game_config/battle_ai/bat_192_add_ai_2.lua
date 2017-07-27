----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_192_add_ai_2 = class("ClsAIBat_192_add_ai_2", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_192_add_ai_2:getId()
	return "bat_192_add_ai_2";
end


-- AI时机
function ClsAIBat_192_add_ai_2:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIBat_192_add_ai_2:getPriority()
	return 48;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[OAI防御=0]
local function bat_192_add_ai_2_act_2( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end


	-- 公式原文:OAI防御=0
	owner:setAIDefense( 0 );

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"delay", "", {1000, }, }, 
	{"run_ai", "", {{"bat_192_enter", }, }, }, 
	{"op", "", {bat_192_add_ai_2_act_2, }, }, 
	{"delete_ai", "", {{"bat_192_add_ai_2", }, }, }, 
}

function ClsAIBat_192_add_ai_2:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_192_add_ai_2:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_192_add_ai_2

----------------------- Auto Genrate End   --------------------
