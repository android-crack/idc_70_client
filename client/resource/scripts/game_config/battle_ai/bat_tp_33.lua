----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_tp_33 = class("ClsAIBat_tp_33", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_tp_33:getId()
	return "bat_tp_33";
end


-- AI时机
function ClsAIBat_tp_33:getOpportunity()
	return AI_OPPORTUNITY.FIGHT_START;
end

-- AI优先级别
function ClsAIBat_tp_33:getPriority()
	return 48;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[OY=目标坐标Y]
local function bat_tp_33_act_2( ai_obj, act_obj, target, delta_time )
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
local function bat_tp_33_act_1( ai_obj, act_obj, target, delta_time )
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
	{"delay", "", {3000, }, }, 
	{"op", "", {bat_tp_33_act_1, }, }, 
	{"op", "", {bat_tp_33_act_2, }, }, 
}

function ClsAIBat_tp_33:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_tp_33:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_tp_33

----------------------- Auto Genrate End   --------------------
