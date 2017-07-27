----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_201_win = class("ClsAIBat_201_win", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_201_win:getId()
	return "bat_201_win";
end


-- AI时机
function ClsAIBat_201_win:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIBat_201_win:getPriority()
	return 1;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndWin(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- 战场测试变量
	local AI2 = battleData:GetData("__ai_2") or 0;
	-- 触发2==16
	if ( not (AI2==16) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIBat_201_win:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndWin(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"play_plot", "", {{4, }, }, }, 
	{"battle_stop", "", {1, }, }, 
}

function ClsAIBat_201_win:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_201_win:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_201_win

----------------------- Auto Genrate End   --------------------
