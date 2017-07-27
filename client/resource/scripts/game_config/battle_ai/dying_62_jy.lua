----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIDying_62_jy = class("ClsAIDying_62_jy", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIDying_62_jy:getId()
	return "dying_62_jy";
end


-- AI时机
function ClsAIDying_62_jy:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIDying_62_jy:getPriority()
	return 1;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[O耐久=O耐久-O耐久上限*0.016]
local function dying_62_jy_act_1( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end

	-- O耐久
	local OHp = owner:getHp();
	-- O耐久上限
	local OHpMax = owner:getMaxHp();

	-- 公式原文:O耐久=O耐久-O耐久上限*0.016
	owner:AIsetHp( OHp-OHpMax*0.016 );

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"delay", "", {5000, }, }, 
	{"op", "", {dying_62_jy_act_1, }, }, 
}

function ClsAIDying_62_jy:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIDying_62_jy:getAllTargetMethod()
	return all_target_method
end

return ClsAIDying_62_jy

----------------------- Auto Genrate End   --------------------
