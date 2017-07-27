----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIHs_win_03 = class("ClsAIHs_win_03", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIHs_win_03:getId()
	return "hs_win_03";
end


-- AI时机
function ClsAIHs_win_03:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIHs_win_03:getPriority()
	return -2;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndHpless5(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- O耐久百分比
	local OHpRate = owner:getHpRate() * 100;
	-- O耐久百分比<5
	if ( not (OHpRate<5) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIHs_win_03:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndHpless5(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"play_plot", "", {{7, }, }, }, 
	{"battle_stop", "", {1, }, }, 
	{"delete_ai", "", {{"hs_win_03", }, }, }, 
}

function ClsAIHs_win_03:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIHs_win_03:getAllTargetMethod()
	return all_target_method
end

return ClsAIHs_win_03

----------------------- Auto Genrate End   --------------------
