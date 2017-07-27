----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[2]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_move1_33 = class("ClsAIBat_move1_33", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_move1_33:getId()
	return "bat_move1_33";
end


-- AI时机
function ClsAIBat_move1_33:getOpportunity()
	return AI_OPPORTUNITY.FIGHT_START;
end

-- AI优先级别
function ClsAIBat_move1_33:getPriority()
	return 48;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[OAI变速=4]
local function bat_move1_33_act_1( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end


	-- 公式原文:OAI变速=4
	owner:setAISpeed( 4 );

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"move_to", "", {2300, 640, 50, }, }, 
	{"op", "", {bat_move1_33_act_1, }, }, 
}

function ClsAIBat_move1_33:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_move1_33:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_move1_33

----------------------- Auto Genrate End   --------------------
