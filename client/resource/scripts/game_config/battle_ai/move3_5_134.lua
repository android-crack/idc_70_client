----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIMove3_5_134 = class("ClsAIMove3_5_134", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIMove3_5_134:getId()
	return "move3_5_134";
end


-- AI时机
function ClsAIMove3_5_134:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIMove3_5_134:getPriority()
	return 48;
end

-- AI停止标记
function ClsAIMove3_5_134:getStopOtherFlg()
	return 48;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndNum1is5(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- 计数1
	local num1 = battleData:GetData("num1") or 0;
	-- num1==5
	if ( not (num1==5) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIMove3_5_134:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndNum1is5(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[OAI变速=-0.5*O速度]
local function move3_5_134_act_2( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end

	-- 宿主速度
	local OSpeed = owner:getSpeed();

	-- 公式原文:OAI变速=-0.5*O速度
	owner:setAISpeed( -0.5*OSpeed );

end

-- [备注]设置-[OAI变速=0]
local function move3_5_134_act_0( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end


	-- 公式原文:OAI变速=0
	owner:setAISpeed( 0 );

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"op", "", {move3_5_134_act_0, }, }, 
	{"move_to", "", {800, 400, 50, }, }, 
	{"op", "", {move3_5_134_act_2, }, }, 
	{"delete_ai", "", {{"move3_5_134", }, }, }, 
}

function ClsAIMove3_5_134:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIMove3_5_134:getAllTargetMethod()
	return all_target_method
end

return ClsAIMove3_5_134

----------------------- Auto Genrate End   --------------------
