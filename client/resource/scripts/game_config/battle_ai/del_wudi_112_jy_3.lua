----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIDel_wudi_112_jy_3 = class("ClsAIDel_wudi_112_jy_3", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIDel_wudi_112_jy_3:getId()
	return "del_wudi_112_jy_3";
end


-- AI时机
function ClsAIDel_wudi_112_jy_3:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIDel_wudi_112_jy_3:getPriority()
	return 1;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndDel_wudi_112_jy_3(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- 战斗已进行时间
	local BattleTime = battleData:getBattleTime();
	-- 战斗进行时间>15000
	if ( not (BattleTime>15000) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIDel_wudi_112_jy_3:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndDel_wudi_112_jy_3(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"del_status", "", {"wudi", }, }, 
}

function ClsAIDel_wudi_112_jy_3:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIDel_wudi_112_jy_3:getAllTargetMethod()
	return all_target_method
end

return ClsAIDel_wudi_112_jy_3

----------------------- Auto Genrate End   --------------------
