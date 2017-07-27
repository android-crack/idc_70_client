----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_93_jy_battle_win = class("ClsAIBat_93_jy_battle_win", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_93_jy_battle_win:getId()
	return "bat_93_jy_battle_win";
end


-- AI时机
function ClsAIBat_93_jy_battle_win:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIBat_93_jy_battle_win:getPriority()
	return -2;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]进入范围
local function cndBat_93_jy_in_area(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- 玩家到达标记
	local player_arrive = battleData:GetData("player_arrive") or 0;
	-- 玩家到达==1
	if ( not (player_arrive==1) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIBat_93_jy_battle_win:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndBat_93_jy_in_area(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"battle_stop", "", {1, }, }, 
}

function ClsAIBat_93_jy_battle_win:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_93_jy_battle_win:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_93_jy_battle_win

----------------------- Auto Genrate End   --------------------
