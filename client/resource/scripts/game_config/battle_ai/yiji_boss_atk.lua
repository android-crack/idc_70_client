----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIYiji_boss_atk = class("ClsAIYiji_boss_atk", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIYiji_boss_atk:getId()
	return "yiji_boss_atk";
end


-- AI时机
function ClsAIYiji_boss_atk:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIYiji_boss_atk:getPriority()
	return -2;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndHpless40(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- O耐久百分比
	local OHpRate = owner:getHpRate() * 100;
	-- O耐久百分比<=40
	if ( not (OHpRate<=40) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIYiji_boss_atk:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndHpless40(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]说话-[小的们！跟着我冲入敌阵！]
local function yiji_boss_atk_act_1( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end




	local name = ""
	local word = T("小的们！跟着我冲入敌阵！")

	target_obj:say( name, word )

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"add_skill", "", {4501, 10, }, }, 
	{"op", "", {yiji_boss_atk_act_1, }, }, 
	{"delete_ai", "", {{"yiji_boss_atk", }, }, }, 
}

function ClsAIYiji_boss_atk:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIYiji_boss_atk:getAllTargetMethod()
	return all_target_method
end

return ClsAIYiji_boss_atk

----------------------- Auto Genrate End   --------------------
