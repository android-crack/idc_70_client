----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[11]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_event1_83 = class("ClsAIBat_event1_83", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_event1_83:getId()
	return "bat_event1_83";
end


-- AI时机
function ClsAIBat_event1_83:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIBat_event1_83:getPriority()
	return 1;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndNum1dayu3(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- 计数1
	local num1 = battleData:GetData("num1") or 0;
	-- num1>=3
	if ( not (num1>=3) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIBat_event1_83:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndNum1dayu3(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"play_plot", "", {{7, }, }, }, 
	{"delete_ai", "", {{"bat_event1_83", }, }, }, 
}

function ClsAIBat_event1_83:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_event1_83:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_event1_83

----------------------- Auto Genrate End   --------------------
