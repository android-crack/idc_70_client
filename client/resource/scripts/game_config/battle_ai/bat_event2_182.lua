----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[抵达目标区域2]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_event2_182 = class("ClsAIBat_event2_182", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_event2_182:getId()
	return "bat_event2_182";
end


-- AI时机
function ClsAIBat_event2_182:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIBat_event2_182:getPriority()
	return 48;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]进入范围
local function cndIn_area2(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- 玩家到达标记
	local player_arrive = battleData:GetData("player_arrive") or 0;
	-- 玩家到达==2
	if ( not (player_arrive==2) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIBat_event2_182:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndIn_area2(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"play_plot", "", {{9, 10, }, }, }, 
	{"battle_stop", "", {1, }, }, 
}

function ClsAIBat_event2_182:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_event2_182:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_event2_182

----------------------- Auto Genrate End   --------------------
