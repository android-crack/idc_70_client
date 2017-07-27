----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[15]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_win_63 = class("ClsAIBat_win_63", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_win_63:getId()
	return "bat_win_63";
end


-- AI时机
function ClsAIBat_win_63:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIBat_win_63:getPriority()
	return 1;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndDeadis9(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- 战场测试变量
	local Death_Cnt = battleData:GetData("_death_cnt") or 0;
	-- 死亡==9
	if ( not (Death_Cnt==9) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIBat_win_63:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndDeadis9(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"battle_stop", "", {1, }, }, 
}

function ClsAIBat_win_63:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_win_63:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_win_63

----------------------- Auto Genrate End   --------------------
