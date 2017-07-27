----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[9]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_enter2_142 = class("ClsAIBat_enter2_142", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_enter2_142:getId()
	return "bat_enter2_142";
end


-- AI时机
function ClsAIBat_enter2_142:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIBat_enter2_142:getPriority()
	return 1;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndNum2dayu1(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- 计数2
	local num2 = battleData:GetData("num2") or 0;
	-- num2>=1
	if ( not (num2>=1) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIBat_enter2_142:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndNum2dayu1(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[num2=num2-1]
local function bat_enter2_142_act_2( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end

	-- 计数2
	local num2 = battleData:GetData("num2") or 0;

	-- 公式原文:num2=num2-1
	battleData:planningSetData("num2", num2-1);

end

-- [备注]说话-[哈哈，增援又来了]
local function bat_enter2_142_act_3( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end




	local name = ""
	local word = T("哈哈，增援又来了")

	target_obj:say( name, word )

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"delay", "", {6000, }, }, 
	{"enter_scene", "", {4, }, }, 
	{"op", "", {bat_enter2_142_act_2, }, }, 
	{"op", "", {bat_enter2_142_act_3, }, }, 
	{"delete_ai", "", {{"bat_enter2_142", }, }, }, 
	{"add_ai", "", {{"bat_enter2_142", }, }, }, 
}

function ClsAIBat_enter2_142:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_enter2_142:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_enter2_142

----------------------- Auto Genrate End   --------------------
