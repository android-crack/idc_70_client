----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIEve_emeny_151 = class("ClsAIEve_emeny_151", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIEve_emeny_151:getId()
	return "eve_emeny_151";
end


-- AI时机
function ClsAIEve_emeny_151:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIEve_emeny_151:getPriority()
	return -2;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndAi_1(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- 战场测试变量
	local AI = battleData:GetData("__ai") or 0;
	-- 触发AI==1
	if ( not (AI==1) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIEve_emeny_151:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndAi_1(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"run_ai", "", {{"enter_1_151", }, }, }, 
	{"delay", "", {5000, }, }, 
	{"run_ai", "", {{"enter_2_151", }, }, }, 
	{"delay", "", {5000, }, }, 
	{"run_ai", "", {{"enter_3_151", }, }, }, 
	{"delete_ai", "", {{"eve_emeny_151", }, }, }, 
}

function ClsAIEve_emeny_151:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIEve_emeny_151:getAllTargetMethod()
	return all_target_method
end

return ClsAIEve_emeny_151

----------------------- Auto Genrate End   --------------------
