----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[出阵形4]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAICity01_soldier_D = class("ClsAICity01_soldier_D", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAICity01_soldier_D:getId()
	return "city01_soldier_D";
end


-- AI时机
function ClsAICity01_soldier_D:getOpportunity()
	return AI_OPPORTUNITY.RUN;
end

-- AI优先级别
function ClsAICity01_soldier_D:getPriority()
	return 1;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]4选4
local function cnd4xuan4(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- 记录随机数
	local RandomCnt = battleData:GetData("__random_cnt") or 0;
	-- 记录随机数>=750
	if ( not (RandomCnt>=750) ) then  return false end

	-- 记录随机数<1000
	if ( not (RandomCnt<1000) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAICity01_soldier_D:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cnd4xuan4(self, nil )
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
}

function ClsAICity01_soldier_D:getActions()
	return actions
end

local all_target_method = {
}

function ClsAICity01_soldier_D:getAllTargetMethod()
	return all_target_method
end

return ClsAICity01_soldier_D

----------------------- Auto Genrate End   --------------------
