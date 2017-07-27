----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[new]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIHpless100_33 = class("ClsAIHpless100_33", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIHpless100_33:getId()
	return "hpless100_33";
end


-- AI时机
function ClsAIHpless100_33:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIHpless100_33:getPriority()
	return 48;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndHpless100(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- O耐久百分比
	local OHpRate = owner:getHpRate() * 100;
	-- O耐久百分比<100
	if ( not (OHpRate<100) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIHpless100_33:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndHpless100(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"camera_follow", "", {2, 0, 1, 3, }, }, 
	{"play_plot", "", {{18, }, }, }, 
	{"delete_ai", "", {{"hpless100_33", }, }, }, 
}

function ClsAIHpless100_33:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIHpless100_33:getAllTargetMethod()
	return all_target_method
end

return ClsAIHpless100_33

----------------------- Auto Genrate End   --------------------
