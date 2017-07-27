----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[出阵形3]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAICity01_soldier_C = class("ClsAICity01_soldier_C", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAICity01_soldier_C:getId()
	return "city01_soldier_C";
end


-- AI时机
function ClsAICity01_soldier_C:getOpportunity()
	return AI_OPPORTUNITY.RUN;
end

-- AI优先级别
function ClsAICity01_soldier_C:getPriority()
	return 1;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]4选3
local function cnd4xuan3(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- 记录随机数
	local RandomCnt = battleData:GetData("__random_cnt") or 0;
	-- 记录随机数>=500
	if ( not (RandomCnt>=500) ) then  return false end

	-- 记录随机数<750
	if ( not (RandomCnt<750) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAICity01_soldier_C:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cnd4xuan3(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"enter_scene", "", {9, }, }, 
	{"enter_scene", "", {10, }, }, 
	{"enter_scene", "", {11, }, }, 
}

function ClsAICity01_soldier_C:getActions()
	return actions
end

local all_target_method = {
}

function ClsAICity01_soldier_C:getAllTargetMethod()
	return all_target_method
end

return ClsAICity01_soldier_C

----------------------- Auto Genrate End   --------------------
