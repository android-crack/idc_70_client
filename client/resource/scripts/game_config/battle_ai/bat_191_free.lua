----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_191_free = class("ClsAIBat_191_free", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_191_free:getId()
	return "bat_191_free";
end


-- AI时机
function ClsAIBat_191_free:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIBat_191_free:getPriority()
	return 1;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndEnter_time(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- 战场测试变量
	local call = battleData:GetData("__call") or 0;
	-- 召唤次数>=2
	if ( not (call>=2) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIBat_191_free:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndEnter_time(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"stop_ai", "", {{"bat_191_con_1", }, }, }, 
	{"delete_ai", "", {{"bat_191_con_1", }, }, }, 
	{"add_skill", "", {1216, 5, }, }, 
	{"play_plot", "", {{4, }, }, }, 
	{"add_ai", "", {{"bat_191_speed_up", }, }, }, 
	{"delete_ai", "", {{"bat_191_free", }, }, }, 
}

function ClsAIBat_191_free:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_191_free:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_191_free

----------------------- Auto Genrate End   --------------------
