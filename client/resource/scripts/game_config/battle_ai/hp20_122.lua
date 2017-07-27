----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[2]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIHp20_122 = class("ClsAIHp20_122", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIHp20_122:getId()
	return "hp20_122";
end


-- AI时机
function ClsAIHp20_122:getOpportunity()
	return AI_OPPORTUNITY.FIGHT_START;
end

-- AI优先级别
function ClsAIHp20_122:getPriority()
	return 1;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[O耐久=0.2*O耐久]
local function hp20_122_act_0( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end

	-- O耐久
	local OHp = owner:getHp();

	-- 公式原文:O耐久=0.2*O耐久
	owner:AIsetHp( 0.2*OHp );

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"op", "", {hp20_122_act_0, }, }, 
}

function ClsAIHp20_122:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIHp20_122:getAllTargetMethod()
	return all_target_method
end

return ClsAIHp20_122

----------------------- Auto Genrate End   --------------------
