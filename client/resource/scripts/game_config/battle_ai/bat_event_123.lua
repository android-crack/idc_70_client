----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_event_123 = class("ClsAIBat_event_123", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_event_123:getId()
	return "bat_event_123";
end


-- AI时机
function ClsAIBat_event_123:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIBat_event_123:getPriority()
	return 48;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndPhase2(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- 计数1
	local num1 = battleData:GetData("num1") or 0;
	-- O耐久百分比
	local OHpRate = owner:getHpRate() * 100;
	-- num1==2 or O耐久百分比<100
	if ( not (num1==2 or OHpRate<100) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIBat_event_123:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndPhase2(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"del_effect_from_scene", "", {1, }, }, 
	{"del_effect_from_scene", "", {2, }, }, 
	{"add_effect_to_scene", "", {3, "tx_wind", 1100, 300, 120, 90, false, }, }, 
	{"add_effect_to_scene", "", {4, "tx_wind", 1100, 1000, 120, 90, false, }, }, 
	{"add_effect_to_scene", "", {5, "tx_wind", 1100, 640, 120, 90, false, }, }, 
	{"run_ai", "", {{"enter_123", }, }, }, 
	{"add_effect_to_ship", "", {1, "sf_tujin", 0, 0, 120, true, }, }, 
	{"add_skill", "", {3501, 1, }, }, 
	{"camera_follow", "", {5, 0, 1, }, }, 
	{"play_plot", "", {{8, 9, }, }, }, 
	{"delete_ai", "", {{"bat_event_123", }, }, }, 
}

function ClsAIBat_event_123:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_event_123:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_event_123

----------------------- Auto Genrate End   --------------------
