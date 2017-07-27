----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIEnter_152 = class("ClsAIEnter_152", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIEnter_152:getId()
	return "enter_152";
end


-- AI时机
function ClsAIEnter_152:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIEnter_152:getPriority()
	return 1;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndAi_2(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- 战场测试变量
	local LET_AI2 = battleData:GetData("__ai_2") or 0;
	-- 触发2==1
	if ( not (LET_AI2==1) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIEnter_152:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndAi_2(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"enter_scene", "", {10, }, }, 
	{"enter_scene", "", {11, }, }, 
	{"enter_scene", "", {12, }, }, 
	{"enter_scene", "", {13, }, }, 
	{"enter_scene", "", {14, }, }, 
	{"run_ai", "", {{"bat_152_end", }, }, }, 
	{"delete_ai", "", {{"enter_152", }, }, }, 
}

function ClsAIEnter_152:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIEnter_152:getAllTargetMethod()
	return all_target_method
end

return ClsAIEnter_152

----------------------- Auto Genrate End   --------------------
