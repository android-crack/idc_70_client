----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[船只死亡5只或离场达到5只，重新进场一批]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAISolo_boss_enter01 = class("ClsAISolo_boss_enter01", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAISolo_boss_enter01:getId()
	return "solo_boss_enter01";
end


-- AI时机
function ClsAISolo_boss_enter01:getOpportunity()
	return AI_OPPORTUNITY.RUN;
end

-- AI优先级别
function ClsAISolo_boss_enter01:getPriority()
	return 2;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]海盗数量大于5时，召唤另一批海盗
local function cndNumber5(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- 战场测试变量
	local PirateLeaveCnt = battleData:GetData("__pirate_leave_cnt") or 0;
	-- 离场数量==5 or 离场数量==10
	if ( not (PirateLeaveCnt==5 or PirateLeaveCnt==10) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAISolo_boss_enter01:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndNumber5(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"enter_scene", "", {2, 0, 0, 0, 7, 0, }, }, 
	{"enter_scene", "", {3, 0, 0, 0, 7, 0, }, }, 
	{"enter_scene", "", {4, 0, 0, 0, 7, 0, }, }, 
	{"enter_scene", "", {5, 0, 0, 0, 7, 0, }, }, 
	{"enter_scene", "", {6, 0, 0, 0, 7, 0, }, }, 
}

function ClsAISolo_boss_enter01:getActions()
	return actions
end

local all_target_method = {
}

function ClsAISolo_boss_enter01:getAllTargetMethod()
	return all_target_method
end

return ClsAISolo_boss_enter01

----------------------- Auto Genrate End   --------------------
