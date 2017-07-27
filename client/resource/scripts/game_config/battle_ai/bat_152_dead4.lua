----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_152_dead4 = class("ClsAIBat_152_dead4", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_152_dead4:getId()
	return "bat_152_dead4";
end


-- AI时机
function ClsAIBat_152_dead4:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIBat_152_dead4:getPriority()
	return 1;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndEve_1(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- 战场测试变量
	local EVE = battleData:GetData("__eve") or 0;
	-- 事件标记==1
	if ( not (EVE==1) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIBat_152_dead4:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndEve_1(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"run_ai", "", {{"bat_152_die4", }, }, }, 
}

function ClsAIBat_152_dead4:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_152_dead4:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_152_dead4

----------------------- Auto Genrate End   --------------------
