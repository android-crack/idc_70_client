----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_win_112 = class("ClsAIBat_win_112", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_win_112:getId()
	return "bat_win_112";
end


-- AI时机
function ClsAIBat_win_112:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIBat_win_112:getPriority()
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
function ClsAIBat_win_112:checkCondition()
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
	{"play_plot", "", {{8, 6, 7, }, }, }, 
	{"battle_stop", "", {1, }, }, 
	{"delete_ai", "", {{"bat_win_112", }, }, }, 
}

function ClsAIBat_win_112:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_win_112:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_win_112

----------------------- Auto Genrate End   --------------------
