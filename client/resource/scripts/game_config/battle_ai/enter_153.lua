----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIEnter_153 = class("ClsAIEnter_153", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIEnter_153:getId()
	return "enter_153";
end


-- AI时机
function ClsAIEnter_153:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIEnter_153:getPriority()
	return 48;
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
function ClsAIEnter_153:checkCondition()
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
	{"enter_scene", "", {2, 0, 0, 1, 3, 0, }, }, 
	{"run_ai", "", {{"leave_153", }, }, }, 
	{"play_plot", "", {{3, 4, }, }, }, 
	{"delete_ai", "", {{"enter_153", }, }, }, 
}

function ClsAIEnter_153:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIEnter_153:getAllTargetMethod()
	return all_target_method
end

return ClsAIEnter_153

----------------------- Auto Genrate End   --------------------
