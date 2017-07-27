----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIZh_enter1 = class("ClsAIZh_enter1", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIZh_enter1:getId()
	return "zh_enter1";
end


-- AI时机
function ClsAIZh_enter1:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIZh_enter1:getPriority()
	return 2;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndZh_enter1(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- 战场测试变量
	local death_cnt = battleData:GetData("death_cnt") or 0;
	-- 
	local hp1 = battleData:GetData("hp1") or 0;
	-- 死亡==5 or hp1==1
	if ( not (death_cnt==5 or hp1==1) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIZh_enter1:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndZh_enter1(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"enter_scene", "", {8, 0, 0, 0, 7, 3, }, }, 
	{"enter_scene", "", {9, 0, 0, 0, 7, 3, }, }, 
	{"enter_scene", "", {10, 0, 0, 0, 7, 3, }, }, 
	{"enter_scene", "", {11, 0, 0, 0, 7, 3, }, }, 
	{"enter_scene", "", {12, 0, 0, 0, 7, 3, }, }, 
	{"delete_ai", "", {{"zh_enter1", }, }, }, 
}

function ClsAIZh_enter1:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIZh_enter1:getAllTargetMethod()
	return all_target_method
end

return ClsAIZh_enter1

----------------------- Auto Genrate End   --------------------
