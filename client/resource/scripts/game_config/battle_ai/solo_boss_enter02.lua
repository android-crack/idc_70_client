----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAISolo_boss_enter02 = class("ClsAISolo_boss_enter02", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAISolo_boss_enter02:getId()
	return "solo_boss_enter02";
end


-- AI时机
function ClsAISolo_boss_enter02:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAISolo_boss_enter02:getPriority()
	return 1;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndNumber14(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- 战场测试变量
	local PirateCnt = battleData:GetData("__pirate_cnt") or 0;
	-- 海盗数量>=14
	if ( not (PirateCnt>=14) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAISolo_boss_enter02:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndNumber14(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"enter_scene", "", {12, 0, 0, 0, 7, 3, }, }, 
	{"enter_scene", "", {13, }, }, 
	{"play_plot", "", {{1, 2, 3, }, }, }, 
	{"delete_ai", "", {{"solo_boss_enter02", }, }, }, 
}

function ClsAISolo_boss_enter02:getActions()
	return actions
end

local all_target_method = {
}

function ClsAISolo_boss_enter02:getAllTargetMethod()
	return all_target_method
end

return ClsAISolo_boss_enter02

----------------------- Auto Genrate End   --------------------
