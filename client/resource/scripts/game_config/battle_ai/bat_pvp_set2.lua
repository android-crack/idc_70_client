----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_pvp_set2 = class("ClsAIBat_pvp_set2", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_pvp_set2:getId()
	return "bat_pvp_set2";
end


-- AI时机
function ClsAIBat_pvp_set2:getOpportunity()
	return AI_OPPORTUNITY.RUN;
end

-- AI优先级别
function ClsAIBat_pvp_set2:getPriority()
	return 48;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndSet2(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- 记录随机数
	local RandomCnt = battleData:GetData("__random_cnt") or 0;
	-- 记录随机数>333
	if ( not (RandomCnt>333) ) then  return false end

	-- 记录随机数<=666
	if ( not (RandomCnt<=666) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIBat_pvp_set2:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndSet2(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"enter_scene", "", {8, 1, 0, 0, 1, 0, }, }, 
	{"enter_scene", "", {9, 1, 0, 0, 1, 0, }, }, 
	{"enter_scene", "", {10, 1, 0, 0, 1, 0, }, }, 
	{"enter_scene", "", {11, 1, 0, 0, 1, 0, }, }, 
	{"enter_scene", "", {12, 1, 0, 0, 1, 0, }, }, 
	{"enter_scene", "", {13, 1, 0, 0, 1, 0, }, }, 
}

function ClsAIBat_pvp_set2:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_pvp_set2:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_pvp_set2

----------------------- Auto Genrate End   --------------------
