----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[11]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_enter4_61_jy = class("ClsAIBat_enter4_61_jy", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_enter4_61_jy:getId()
	return "bat_enter4_61_jy";
end


-- AI时机
function ClsAIBat_enter4_61_jy:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIBat_enter4_61_jy:getPriority()
	return 1;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndHpless50(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- O耐久百分比
	local OHpRate = owner:getHpRate() * 100;
	-- O耐久百分比<=50
	if ( not (OHpRate<=50) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIBat_enter4_61_jy:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndHpless50(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[num2=num2+1]
local function bat_enter4_61_jy_act_0( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end

	-- 战场测试变量
	local num2 = battleData:GetData("num2") or 0;

	-- 公式原文:num2=num2+1
	battleData:planningSetData("num2", num2+1);

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"op", "", {bat_enter4_61_jy_act_0, }, }, 
	{"enter_scene", "", {5, }, }, 
	{"enter_scene", "", {6, }, }, 
	{"enter_scene", "", {19, }, }, 
	{"enter_scene", "", {20, }, }, 
	{"delete_ai", "", {{"bat_enter4_61_jy", }, }, }, 
}

function ClsAIBat_enter4_61_jy:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_enter4_61_jy:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_enter4_61_jy

----------------------- Auto Genrate End   --------------------
