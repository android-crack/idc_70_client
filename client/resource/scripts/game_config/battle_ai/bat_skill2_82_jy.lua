----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[new]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_skill2_82_jy = class("ClsAIBat_skill2_82_jy", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_skill2_82_jy:getId()
	return "bat_skill2_82_jy";
end


-- AI时机
function ClsAIBat_skill2_82_jy:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIBat_skill2_82_jy:getPriority()
	return 1;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndDeathcntis6(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- 死亡数量
	local death_cnt = battleData:GetData("death_cnt") or 0;
	-- 死亡==6
	if ( not (death_cnt==6) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIBat_skill2_82_jy:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndDeathcntis6(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"add_skill", "", {1213, 1, }, }, 
	{"delete_ai", "", {{"bat_skill2_82_jy", }, }, }, 
}

function ClsAIBat_skill2_82_jy:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_skill2_82_jy:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_skill2_82_jy

----------------------- Auto Genrate End   --------------------
