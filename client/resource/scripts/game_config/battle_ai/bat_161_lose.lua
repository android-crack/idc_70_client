----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[海盗逃跑数量大于5时，战斗失败]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_161_lose = class("ClsAIBat_161_lose", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_161_lose:getId()
	return "bat_161_lose";
end


-- AI时机
function ClsAIBat_161_lose:getOpportunity()
	return AI_OPPORTUNITY.RUN;
end

-- AI优先级别
function ClsAIBat_161_lose:getPriority()
	return -2;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndBat_161_lose(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- 战场测试变量
	local HD_RunCnt = battleData:GetData("__hd_run_cnt") or 0;
	-- 海盗逃跑>=5
	if ( not (HD_RunCnt>=5) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIBat_161_lose:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndBat_161_lose(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"battle_stop", "", {0, }, }, 
}

function ClsAIBat_161_lose:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_161_lose:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_161_lose

----------------------- Auto Genrate End   --------------------
