----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[16]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_131_enter = class("ClsAIBat_131_enter", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_131_enter:getId()
	return "bat_131_enter";
end


-- AI时机
function ClsAIBat_131_enter:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIBat_131_enter:getPriority()
	return 1;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndNum1is4(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- 计数1
	local num1 = battleData:GetData("num1") or 0;
	-- num1==4
	if ( not (num1==4) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIBat_131_enter:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndNum1is4(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"enter_scene", "", {12, }, }, 
	{"delete_ai", "", {{"bat_131_enter", }, }, }, 
}

function ClsAIBat_131_enter:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_131_enter:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_131_enter

----------------------- Auto Genrate End   --------------------
