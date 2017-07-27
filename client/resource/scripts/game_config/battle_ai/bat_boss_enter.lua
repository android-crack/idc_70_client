----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[海盗死亡数达到10时，进场1只高级海盗]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_boss_enter = class("ClsAIBat_boss_enter", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_boss_enter:getId()
	return "bat_boss_enter";
end


-- AI时机
function ClsAIBat_boss_enter:getOpportunity()
	return AI_OPPORTUNITY.RUN;
end

-- AI优先级别
function ClsAIBat_boss_enter:getPriority()
	return -2;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]海盗死亡数达到9时，进场1只高级海盗
local function cndEnter_2(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- 战场测试变量
	local PirateCnt = battleData:GetData("__pirate_cnt") or 0;
	-- 海盗数量==10
	if ( not (PirateCnt==10) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIBat_boss_enter:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndEnter_2(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"enter_scene", "", {7, 0, 0, 0, 7, 3, }, }, 
}

function ClsAIBat_boss_enter:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_boss_enter:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_boss_enter

----------------------- Auto Genrate End   --------------------
