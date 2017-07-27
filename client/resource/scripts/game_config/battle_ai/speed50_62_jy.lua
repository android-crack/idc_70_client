----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAISpeed50_62_jy = class("ClsAISpeed50_62_jy", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAISpeed50_62_jy:getId()
	return "speed50_62_jy";
end


-- AI时机
function ClsAISpeed50_62_jy:getOpportunity()
	return AI_OPPORTUNITY.FIGHT_START;
end

-- AI优先级别
function ClsAISpeed50_62_jy:getPriority()
	return 1;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[OAI变速=-O速度*0.5]
local function speed50_62_jy_act_0( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end

	-- 宿主速度
	local OSpeed = owner:getSpeed();

	-- 公式原文:OAI变速=-O速度*0.5
	owner:setAISpeed( -OSpeed*0.5 );

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"op", "", {speed50_62_jy_act_0, }, }, 
}

function ClsAISpeed50_62_jy:getActions()
	return actions
end

local all_target_method = {
}

function ClsAISpeed50_62_jy:getAllTargetMethod()
	return all_target_method
end

return ClsAISpeed50_62_jy

----------------------- Auto Genrate End   --------------------
