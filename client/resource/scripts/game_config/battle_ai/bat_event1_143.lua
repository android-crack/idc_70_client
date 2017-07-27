----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_event1_143 = class("ClsAIBat_event1_143", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_event1_143:getId()
	return "bat_event1_143";
end


-- AI时机
function ClsAIBat_event1_143:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIBat_event1_143:getPriority()
	return 48;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndNum1is1(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- 计数1
	local num1 = battleData:GetData("num1") or 0;
	-- num1==1
	if ( not (num1==1) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIBat_event1_143:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndNum1is1(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"enter_scene", "", {8, 0, 0, 0, 2, 3, }, }, 
	{"enter_scene", "", {9, 0, 0, 0, 2, 3, }, }, 
	{"enter_scene", "", {10, 0, 0, 1, 2, 3, }, }, 
	{"enter_scene", "", {11, 0, 0, 0, 2, 3, }, }, 
	{"enter_scene", "", {12, 0, 0, 0, 2, 3, }, }, 
	{"enter_scene", "", {13, 0, 0, 0, 2, 3, }, }, 
	{"enter_scene", "", {14, 0, 0, 0, 2, 3, }, }, 
	{"enter_scene", "", {15, 0, 0, 0, 2, 3, }, }, 
	{"enter_scene", "", {16, 0, 0, 0, 2, 3, }, }, 
	{"play_plot", "", {{11, 5, 6, 7, 8, 9, }, }, }, 
	{"show_prompt", "", {T("和贝拉米联手击退政府军，并且保护贝拉米旗舰。"), }, }, 
	{"delete_ai", "", {{"bat_event1_143", }, }, }, 
}

function ClsAIBat_event1_143:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_event1_143:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_event1_143

----------------------- Auto Genrate End   --------------------
