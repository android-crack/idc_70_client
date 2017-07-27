----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIHs_enter1_04 = class("ClsAIHs_enter1_04", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIHs_enter1_04:getId()
	return "hs_enter1_04";
end


-- AI时机
function ClsAIHs_enter1_04:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIHs_enter1_04:getPriority()
	return -2;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndNum1dy1(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- 计数1
	local num1 = battleData:GetData("num1") or 0;
	-- num1>=1
	if ( not (num1>=1) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIHs_enter1_04:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndNum1dy1(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[num1=num1-1]
local function hs_enter1_04_act_2( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end

	-- 计数1
	local num1 = battleData:GetData("num1") or 0;

	-- 公式原文:num1=num1-1
	battleData:planningSetData("num1", num1-1);

end

-- [备注]说话-[除非同时击沉我们……否则……]
local function hs_enter1_04_act_3( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end




	local name = ""
	local word = T("除非同时击沉我们……否则……")

	target_obj:say( name, word )

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"delay", "", {6000, }, }, 
	{"enter_scene", "", {14, 0, 0, 1, 7, 0, }, }, 
	{"op", "", {hs_enter1_04_act_2, }, }, 
	{"op", "", {hs_enter1_04_act_3, }, }, 
	{"delete_ai", "", {{"hs_enter1_04", }, }, }, 
	{"add_ai", "", {{"hs_enter1_04", }, }, }, 
}

function ClsAIHs_enter1_04:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIHs_enter1_04:getAllTargetMethod()
	return all_target_method
end

return ClsAIHs_enter1_04

----------------------- Auto Genrate End   --------------------
