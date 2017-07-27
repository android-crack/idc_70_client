----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[player]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_enter1_132 = class("ClsAIBat_enter1_132", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_enter1_132:getId()
	return "bat_enter1_132";
end


-- AI时机
function ClsAIBat_enter1_132:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIBat_enter1_132:getPriority()
	return 1;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndNum1is3(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- 计数1
	local num1 = battleData:GetData("num1") or 0;
	-- num1==3
	if ( not (num1==3) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIBat_enter1_132:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndNum1is3(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[num1=num1-3]
local function bat_enter1_132_act_5( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end

	-- 计数1
	local num1 = battleData:GetData("num1") or 0;

	-- 公式原文:num1=num1-3
	battleData:planningSetData("num1", num1-3);

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"delay", "", {15000, }, }, 
	{"enter_scene", "", {2, }, }, 
	{"enter_scene", "", {3, }, }, 
	{"enter_scene", "", {4, }, }, 
	{"show_prompt", "", {T("全歼冲锋船时，需要在十五秒内消灭剩余敌军"), }, }, 
	{"op", "", {bat_enter1_132_act_5, }, }, 
	{"delete_ai", "", {{"bat_enter1_132", }, }, }, 
	{"add_ai", "", {{"bat_enter1_132", }, }, }, 
}

function ClsAIBat_enter1_132:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_enter1_132:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_enter1_132

----------------------- Auto Genrate End   --------------------
