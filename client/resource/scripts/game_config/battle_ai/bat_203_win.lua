----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_203_win = class("ClsAIBat_203_win", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_203_win:getId()
	return "bat_203_win";
end


-- AI时机
function ClsAIBat_203_win:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIBat_203_win:getPriority()
	return -2;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndBossdead(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- 
	local bossdead = battleData:GetData("bossdead") or 0;
	-- boss死亡==2
	if ( not (bossdead==2) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIBat_203_win:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndBossdead(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"play_plot", "", {{4, 5, 6, 7, }, }, }, 
	{"battle_stop", "", {1, }, }, 
}

function ClsAIBat_203_win:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_203_win:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_203_win

----------------------- Auto Genrate End   --------------------
