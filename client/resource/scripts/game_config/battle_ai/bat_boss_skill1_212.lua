----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_boss_skill1_212 = class("ClsAIBat_boss_skill1_212", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_boss_skill1_212:getId()
	return "bat_boss_skill1_212";
end


-- AI时机
function ClsAIBat_boss_skill1_212:getOpportunity()
	return AI_OPPORTUNITY.FIGHT_START;
end

-- AI优先级别
function ClsAIBat_boss_skill1_212:getPriority()
	return 1;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[O加怒=100]
local function bat_boss_skill1_212_act_0( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end


	-- 公式原文:O加怒=100
	owner:addAnger( 100 );

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"op", "", {bat_boss_skill1_212_act_0, }, }, 
	{"add_skill", "", {1029, 2, }, }, 
}

function ClsAIBat_boss_skill1_212:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_boss_skill1_212:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_boss_skill1_212

----------------------- Auto Genrate End   --------------------
