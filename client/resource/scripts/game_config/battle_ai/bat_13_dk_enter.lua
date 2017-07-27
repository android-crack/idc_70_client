----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_13_dk_enter = class("ClsAIBat_13_dk_enter", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_13_dk_enter:getId()
	return "bat_13_dk_enter";
end


-- AI时机
function ClsAIBat_13_dk_enter:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIBat_13_dk_enter:getPriority()
	return -10;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndPlayerdead(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- 战场测试变量
	local player_godie = battleData:GetData("player_godie") or 0;
	-- 玩家狗带==1
	if ( not (player_godie==1) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIBat_13_dk_enter:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndPlayerdead(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"delay", "", {2000, }, }, 
	{"enter_scene", "", {14, 0, 0, 1, 3, 0, }, }, 
	{"story_mode", "", {}, }, 
	{"play_plot", "", {{8, }, }, }, 
	{"delete_ai", "", {{"bat_13_dk_enter", }, }, }, 
}

function ClsAIBat_13_dk_enter:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_13_dk_enter:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_13_dk_enter

----------------------- Auto Genrate End   --------------------
