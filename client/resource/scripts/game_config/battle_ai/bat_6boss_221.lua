----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_6boss_221 = class("ClsAIBat_6boss_221", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_6boss_221:getId()
	return "bat_6boss_221";
end


-- AI时机
function ClsAIBat_6boss_221:getOpportunity()
	return AI_OPPORTUNITY.RUN;
end

-- AI优先级别
function ClsAIBat_6boss_221:getPriority()
	return -2;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[O耐久=0]
local function bat_6boss_221_act_1( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end


	-- 公式原文:O耐久=0
	owner:AIsetHp( 0 );

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"add_effect_to_ship", "", {5, "jn_ZiBao", 0, 0, 1, true, }, }, 
	{"op", "", {bat_6boss_221_act_1, }, }, 
}

function ClsAIBat_6boss_221:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_6boss_221:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_6boss_221

----------------------- Auto Genrate End   --------------------
