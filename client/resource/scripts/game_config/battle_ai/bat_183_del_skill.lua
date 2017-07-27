----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_183_del_skill = class("ClsAIBat_183_del_skill", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_183_del_skill:getId()
	return "bat_183_del_skill";
end


-- AI时机
function ClsAIBat_183_del_skill:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIBat_183_del_skill:getPriority()
	return 48;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndNo_friend(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- boss2_cnt==0
	if ( not (ai_obj:targetCnt("friend_boss")==0) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIBat_183_del_skill:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndNo_friend(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"del_skill", "", {1009, }, }, 
}

function ClsAIBat_183_del_skill:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_183_del_skill:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_183_del_skill

----------------------- Auto Genrate End   --------------------
