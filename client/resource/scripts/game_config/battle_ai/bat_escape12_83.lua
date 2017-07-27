----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[49]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_escape12_83 = class("ClsAIBat_escape12_83", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_escape12_83:getId()
	return "bat_escape12_83";
end


-- AI时机
function ClsAIBat_escape12_83:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIBat_escape12_83:getPriority()
	return 1;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[num1=num1+1]
local function bat_escape12_83_act_1( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end

	-- 计数1
	local num1 = battleData:GetData("num1") or 0;

	-- 公式原文:num1=num1+1
	battleData:planningSetData("num1", num1+1);

end

-- [备注]离场-[19]
local function bat_escape12_83_act_2( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end


	target_obj:release(false, true)

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"move_to", "", {1200, 200, 100, }, }, 
	{"op", "", {bat_escape12_83_act_1, }, }, 
	{"op", "", {bat_escape12_83_act_2, }, }, 
	{"delete_ai", "", {{"bat_escape12_83", }, }, }, 
}

function ClsAIBat_escape12_83:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_escape12_83:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_escape12_83

----------------------- Auto Genrate End   --------------------
