----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIAutohp_134 = class("ClsAIAutohp_134", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIAutohp_134:getId()
	return "autohp_134";
end


-- AI时机
function ClsAIAutohp_134:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIAutohp_134:getPriority()
	return 48;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[O耐久=O耐久-0.01*O耐久上限]
local function autohp_134_act_0( ai_obj, act_obj, target, delta_time )
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

	-- 公式原文:O耐久=O耐久-0.01*O耐久上限
	owner:AIsetHp( OHp-0.01*OHpMax );

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"op", "", {autohp_134_act_0, }, }, 
	{"add_skill", "", {1214, 1, "passive", }, }, 
	{"use_skill", "", {1214, }, }, 
}

function ClsAIAutohp_134:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIAutohp_134:getAllTargetMethod()
	return all_target_method
end

return ClsAIAutohp_134

----------------------- Auto Genrate End   --------------------
