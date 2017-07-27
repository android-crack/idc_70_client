----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[气血低于50%时再次召唤小兵,自己使用二次分身技能]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAINex_angry = class("ClsAINex_angry", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAINex_angry:getId()
	return "nex_angry";
end


-- AI时机
function ClsAINex_angry:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAINex_angry:getPriority()
	return -2;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndNex_hp_less(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- O耐久百分比
	local OHpRate = owner:getHpRate() * 100;
	-- O耐久百分比<50
	if ( not (OHpRate<50) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAINex_angry:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndNex_hp_less(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]说话-[可恶，我需要治疗。]
local function nex_angry_act_1( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end




	local name = ""
	local word = T("可恶，我需要治疗。")

	target_obj:say( name, word )

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"show_prompt", "", {T("击败纳尔逊"), }, }, 
	{"op", "", {nex_angry_act_1, }, }, 
	{"run_ai", "", {{"nex_very_angry", }, }, }, 
	{"run_ai", "", {{"nex_time", }, }, }, 
	{"delete_ai", "", {{"nex_angry", }, }, }, 
}

function ClsAINex_angry:getActions()
	return actions
end

local all_target_method = {
}

function ClsAINex_angry:getAllTargetMethod()
	return all_target_method
end

return ClsAINex_angry

----------------------- Auto Genrate End   --------------------
