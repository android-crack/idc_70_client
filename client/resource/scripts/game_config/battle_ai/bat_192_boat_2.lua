----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_192_boat_2 = class("ClsAIBat_192_boat_2", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_192_boat_2:getId()
	return "bat_192_boat_2";
end


-- AI时机
function ClsAIBat_192_boat_2:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIBat_192_boat_2:getPriority()
	return -2;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndAi(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- 战场测试变量
	local LET_AI = battleData:GetData("__ai") or 0;
	-- 触发AI==1
	if ( not (LET_AI==1) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIBat_192_boat_2:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndAi(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"play_plot", "", {{4, }, }, }, 
	{"del_effect_from_ship", "", {2, }, }, 
	{"run_ai", "", {{"bat_192_blood_1", }, }, }, 
	{"run_ai", "", {{"bat_192_blood_2", }, }, }, 
	{"run_ai", "", {{"bat_192_del_2", }, }, }, 
	{"delete_ai", "", {{"bat_192_boat_2", }, }, }, 
	{"add_ai", "", {{"bat_192_add_ai_2", }, }, }, 
}

function ClsAIBat_192_boat_2:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_192_boat_2:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_192_boat_2

----------------------- Auto Genrate End   --------------------
