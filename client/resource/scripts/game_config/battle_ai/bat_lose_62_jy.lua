----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_lose_62_jy = class("ClsAIBat_lose_62_jy", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_lose_62_jy:getId()
	return "bat_lose_62_jy";
end


-- AI时机
function ClsAIBat_lose_62_jy:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIBat_lose_62_jy:getPriority()
	return 1;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndNum1is2(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- 计数1
	local num1 = battleData:GetData("num1") or 0;
	-- num1==2
	if ( not (num1==2) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIBat_lose_62_jy:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndNum1is2(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"delete_ai", "", {{"bat_win_62_jy", }, }, }, 
	{"play_plot", "", {{16, }, }, }, 
	{"battle_stop", "", {0, }, }, 
	{"delete_ai", "", {{"bat_lose_62_jy", }, }, }, 
}

function ClsAIBat_lose_62_jy:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_lose_62_jy:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_lose_62_jy

----------------------- Auto Genrate End   --------------------
