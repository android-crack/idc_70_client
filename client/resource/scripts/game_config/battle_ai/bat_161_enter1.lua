----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[第二波进场]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_161_enter1 = class("ClsAIBat_161_enter1", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_161_enter1:getId()
	return "bat_161_enter1";
end


-- AI时机
function ClsAIBat_161_enter1:getOpportunity()
	return AI_OPPORTUNITY.RUN;
end

-- AI优先级别
function ClsAIBat_161_enter1:getPriority()
	return -2;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndBat_161_enter1(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- 战场测试变量
	local DeathCnt = battleData:GetData("__death_cnt") or 0;
	-- 总死亡==5
	if ( not (DeathCnt==5) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIBat_161_enter1:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndBat_161_enter1(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"enter_scene", "", {7, 0, 0, 1, 2, 0, }, }, 
	{"enter_scene", "", {8, }, }, 
	{"enter_scene", "", {9, }, }, 
	{"enter_scene", "", {10, }, }, 
	{"enter_scene", "", {11, }, }, 
}

function ClsAIBat_161_enter1:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_161_enter1:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_161_enter1

----------------------- Auto Genrate End   --------------------
