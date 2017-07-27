----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[8]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_behit_141_jy = class("ClsAIBat_behit_141_jy", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_behit_141_jy:getId()
	return "bat_behit_141_jy";
end


-- AI时机
function ClsAIBat_behit_141_jy:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIBat_behit_141_jy:getPriority()
	return 1;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndHpless100(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- O耐久百分比
	local OHpRate = owner:getHpRate() * 100;
	-- O耐久百分比<100
	if ( not (OHpRate<100) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIBat_behit_141_jy:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndHpless100(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[OAI变速=O速度]
local function bat_behit_141_jy_act_1( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end

	-- 宿主速度
	local OSpeed = owner:getSpeed();

	-- 公式原文:OAI变速=O速度
	owner:setAISpeed( OSpeed );

end

-- [备注]设置-[num1=num1+1]
local function bat_behit_141_jy_act_0( ai_obj, act_obj, target, delta_time )
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

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"op", "", {bat_behit_141_jy_act_0, }, }, 
	{"op", "", {bat_behit_141_jy_act_1, }, }, 
	{"delete_ai", "", {{"bat_behit_141_jy", }, }, }, 
}

function ClsAIBat_behit_141_jy:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_behit_141_jy:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_behit_141_jy

----------------------- Auto Genrate End   --------------------
