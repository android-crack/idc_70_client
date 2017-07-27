----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIHp_less_183 = class("ClsAIHp_less_183", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIHp_less_183:getId()
	return "hp_less_183";
end


-- AI时机
function ClsAIHp_less_183:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIHp_less_183:getPriority()
	return -2;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndHpless70(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- O耐久百分比
	local OHpRate = owner:getHpRate() * 100;
	-- O耐久百分比<=70
	if ( not (OHpRate<=70) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIHp_less_183:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndHpless70(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"run_ai", "", {{"bat_enter1_183", }, }, }, 
	{"run_ai", "", {{"bat_enter2_183", }, }, }, 
	{"play_plot", "", {{12, 8, 9, 7, }, }, }, 
	{"show_prompt", "", {T("消灭基德，注意保护拉比斯"), }, }, 
	{"delete_ai", "", {{"hp_less_183", }, }, }, 
}

function ClsAIHp_less_183:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIHp_less_183:getAllTargetMethod()
	return all_target_method
end

return ClsAIHp_less_183

----------------------- Auto Genrate End   --------------------
