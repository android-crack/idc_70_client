----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIZh_hpless1 = class("ClsAIZh_hpless1", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIZh_hpless1:getId()
	return "zh_hpless1";
end


-- AI时机
function ClsAIZh_hpless1:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIZh_hpless1:getPriority()
	return -2;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndHpless80(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- O耐久百分比
	local OHpRate = owner:getHpRate() * 100;
	-- O耐久百分比<=80
	if ( not (OHpRate<=80) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIZh_hpless1:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndHpless80(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[hp1=hp1+1]
local function zh_hpless1_act_0( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end

	-- 
	local hp1 = battleData:GetData("hp1") or 0;

	-- 公式原文:hp1=hp1+1
	battleData:planningSetData("hp1", hp1+1);

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"op", "", {zh_hpless1_act_0, }, }, 
	{"delete_ai", "", {{"zh_hpless1", }, }, }, 
}

function ClsAIZh_hpless1:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIZh_hpless1:getAllTargetMethod()
	return all_target_method
end

return ClsAIZh_hpless1

----------------------- Auto Genrate End   --------------------
