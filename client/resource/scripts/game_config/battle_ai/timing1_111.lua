----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAITiming1_111 = class("ClsAITiming1_111", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAITiming1_111:getId()
	return "timing1_111";
end


-- AI时机
function ClsAITiming1_111:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAITiming1_111:getPriority()
	return 1;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndTimeis10(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- 战斗已进行时间
	local BattleTime = battleData:getBattleTime();
	-- 战斗进行时间>=5000
	if ( not (BattleTime>=5000) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAITiming1_111:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndTimeis10(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"enter_scene", "", {2, }, }, 
	{"show_prompt", "", {T("敌人战斗时间越长，伤害越高，尽快解决所有敌人。"), }, }, 
	{"delete_ai", "", {{"timing1_111", }, }, }, 
}

function ClsAITiming1_111:getActions()
	return actions
end

local all_target_method = {
}

function ClsAITiming1_111:getAllTargetMethod()
	return all_target_method
end

return ClsAITiming1_111

----------------------- Auto Genrate End   --------------------
