----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[海盗逃跑]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_13_escape = class("ClsAIBat_13_escape", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_13_escape:getId()
	return "bat_13_escape";
end


-- AI时机
function ClsAIBat_13_escape:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIBat_13_escape:getPriority()
	return -3;
end

-- AI停止标记
function ClsAIBat_13_escape:getStopOtherFlg()
	return -3;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[OAI变速=-O速度]
local function bat_13_escape_act_0( ai_obj, act_obj, target, delta_time )
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
	{"op", "", {bat_13_escape_act_0, }, }, 
	{"move_to", "", {1100, 540, 100, }, }, 
	{"delay", "", {120000, }, }, 
}

function ClsAIBat_13_escape:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_13_escape:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_13_escape

----------------------- Auto Genrate End   --------------------
