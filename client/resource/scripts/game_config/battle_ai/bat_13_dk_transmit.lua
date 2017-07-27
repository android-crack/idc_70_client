----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[戴肯传送]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_13_dk_transmit = class("ClsAIBat_13_dk_transmit", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_13_dk_transmit:getId()
	return "bat_13_dk_transmit";
end


-- AI时机
function ClsAIBat_13_dk_transmit:getOpportunity()
	return AI_OPPORTUNITY.FIGHT_START;
end

-- AI优先级别
function ClsAIBat_13_dk_transmit:getPriority()
	return 48;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[OY=目标坐标Y]
local function bat_13_dk_transmit_act_1( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end

	-- 
	local PY = battleData:GetData("PY");

	-- 公式原文:OY=目标坐标Y
	owner:setPositionY( PY );

end

-- [备注]设置-[OX=目标坐标X]
local function bat_13_dk_transmit_act_0( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end

	-- 
	local PX = battleData:GetData("PX");

	-- 公式原文:OX=目标坐标X
	owner:setPositionX( PX );

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"op", "", {bat_13_dk_transmit_act_0, }, }, 
	{"op", "", {bat_13_dk_transmit_act_1, }, }, 
	{"delay", "", {500, }, }, 
	{"camera_follow", "", {14, 0, 1, 100, }, }, 
	{"add_effect_to_ship", "", {1, "sf_tujin", 0, 0, 120, true, }, }, 
}

function ClsAIBat_13_dk_transmit:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_13_dk_transmit:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_13_dk_transmit

----------------------- Auto Genrate End   --------------------
