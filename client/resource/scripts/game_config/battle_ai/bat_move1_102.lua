----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[25]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_move1_102 = class("ClsAIBat_move1_102", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_move1_102:getId()
	return "bat_move1_102";
end


-- AI时机
function ClsAIBat_move1_102:getOpportunity()
	return AI_OPPORTUNITY.FIGHT_START;
end

-- AI优先级别
function ClsAIBat_move1_102:getPriority()
	return 1;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[OAI变速=-O速度]
local function bat_move1_102_act_1( ai_obj, act_obj, target, delta_time )
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
	{"move_to", "", {1230, 645, 100, }, }, 
	{"op", "", {bat_move1_102_act_1, }, }, 
	{"delay", "", {120000, }, }, 
}

function ClsAIBat_move1_102:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_move1_102:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_move1_102

----------------------- Auto Genrate End   --------------------
