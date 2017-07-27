----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_63_boss_skill = class("ClsAIBat_63_boss_skill", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_63_boss_skill:getId()
	return "bat_63_boss_skill";
end


-- AI时机
function ClsAIBat_63_boss_skill:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIBat_63_boss_skill:getPriority()
	return 1;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndHpless50(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- O耐久百分比
	local OHpRate = owner:getHpRate() * 100;
	-- O耐久百分比<=50
	if ( not (OHpRate<=50) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIBat_63_boss_skill:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndHpless50(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]说话-[别以为能这么轻松获胜！]
local function bat_63_boss_skill_act_1( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end




	local name = ""
	local word = T("别以为能这么轻松获胜！")

	target_obj:say( name, word )

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"add_skill", "", {1213, 1, }, }, 
	{"op", "", {bat_63_boss_skill_act_1, }, }, 
}

function ClsAIBat_63_boss_skill:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_63_boss_skill:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_63_boss_skill

----------------------- Auto Genrate End   --------------------
