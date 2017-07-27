----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[9]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAISpeed10_131_jy = class("ClsAISpeed10_131_jy", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAISpeed10_131_jy:getId()
	return "speed10_131_jy";
end


-- AI时机
function ClsAISpeed10_131_jy:getOpportunity()
	return AI_OPPORTUNITY.FIGHT_START;
end

-- AI优先级别
function ClsAISpeed10_131_jy:getPriority()
	return 1;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[OAI变速=-0.9*O速度]
local function speed10_131_jy_act_0( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end

	-- 宿主速度
	local OSpeed = owner:getSpeed();

	-- 公式原文:OAI变速=-0.9*O速度
	owner:setAISpeed( -0.9*OSpeed );

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"op", "", {speed10_131_jy_act_0, }, }, 
	{"delay", "", {99000, }, }, 
}

function ClsAISpeed10_131_jy:getActions()
	return actions
end

local all_target_method = {
}

function ClsAISpeed10_131_jy:getAllTargetMethod()
	return all_target_method
end

return ClsAISpeed10_131_jy

----------------------- Auto Genrate End   --------------------
