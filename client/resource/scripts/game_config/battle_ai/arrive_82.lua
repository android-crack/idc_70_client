----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[15]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIArrive_82 = class("ClsAIArrive_82", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIArrive_82:getId()
	return "arrive_82";
end


-- AI时机
function ClsAIArrive_82:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIArrive_82:getPriority()
	return 1;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndIn_area1(ai_obj, target)
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
function ClsAIArrive_82:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndIn_area1(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"play_plot", "", {{5, }, }, }, 
	{"battle_stop", "", {1, }, }, 
}

function ClsAIArrive_82:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIArrive_82:getAllTargetMethod()
	return all_target_method
end

return ClsAIArrive_82

----------------------- Auto Genrate End   --------------------
