----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[第三波进场]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_161_enter2 = class("ClsAIBat_161_enter2", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_161_enter2:getId()
	return "bat_161_enter2";
end


-- AI时机
function ClsAIBat_161_enter2:getOpportunity()
	return AI_OPPORTUNITY.RUN;
end

-- AI优先级别
function ClsAIBat_161_enter2:getPriority()
	return -2;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndBat_161_enter2(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- 战场测试变量
	local DeathCnt = battleData:GetData("__death_cnt") or 0;
	-- 总死亡==10
	if ( not (DeathCnt==10) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIBat_161_enter2:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndBat_161_enter2(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"enter_scene", "", {12, }, }, 
	{"enter_scene", "", {13, }, }, 
	{"enter_scene", "", {14, }, }, 
	{"enter_scene", "", {15, }, }, 
	{"enter_scene", "", {16, 0, 0, 1, 2, 0, }, }, 
}

function ClsAIBat_161_enter2:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_161_enter2:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_161_enter2

----------------------- Auto Genrate End   --------------------
