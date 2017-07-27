----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_enter2_31_jy = class("ClsAIBat_enter2_31_jy", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_enter2_31_jy:getId()
	return "bat_enter2_31_jy";
end


-- AI时机
function ClsAIBat_enter2_31_jy:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIBat_enter2_31_jy:getPriority()
	return 48;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndNum1is7(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- 战场测试变量
	local num1 = battleData:GetData("num1") or 0;
	-- num1==7
	if ( not (num1==7) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIBat_enter2_31_jy:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndNum1is7(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"play_plot", "", {{8, }, }, }, 
	{"enter_scene", "", {2, 0, 0, 1, 4, 0, }, }, 
	{"enter_scene", "", {3, 0, 0, 0, 4, 0, }, }, 
	{"enter_scene", "", {4, 0, 0, 0, 4, 0, }, }, 
	{"enter_scene", "", {6, 0, 0, 0, 3, 0, }, }, 
	{"enter_scene", "", {7, 0, 0, 0, 3, 0, }, }, 
	{"enter_scene", "", {12, 0, 0, 0, 6, 0, }, }, 
	{"enter_scene", "", {13, 0, 0, 0, 6, 0, }, }, 
	{"delete_ai", "", {{"bat_enter2_31_jy", }, }, }, 
}

function ClsAIBat_enter2_31_jy:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_enter2_31_jy:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_enter2_31_jy

----------------------- Auto Genrate End   --------------------
