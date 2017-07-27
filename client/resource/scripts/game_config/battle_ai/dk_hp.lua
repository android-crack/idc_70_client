----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[龙卷风每秒减少气血上限5%的气血]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIDk_hp = class("ClsAIDk_hp", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIDk_hp:getId()
	return "dk_hp";
end


-- AI时机
function ClsAIDk_hp:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIDk_hp:getPriority()
	return 2;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[O耐久=O耐久-O耐久上限*0.05]
local function dk_hp_act_0( ai_obj, act_obj, target, delta_time )
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

	-- 公式原文:O耐久=O耐久-O耐久上限*0.05
	owner:AIsetHp( OHp-OHpMax*0.05 );

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"op", "", {dk_hp_act_0, }, }, 
	{"delete_ai", "", {{"dk_hp", }, }, }, 
}

function ClsAIDk_hp:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIDk_hp:getAllTargetMethod()
	return all_target_method
end

return ClsAIDk_hp

----------------------- Auto Genrate End   --------------------
