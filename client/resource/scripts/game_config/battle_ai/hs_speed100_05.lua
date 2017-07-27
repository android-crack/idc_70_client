----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIHs_speed100_05 = class("ClsAIHs_speed100_05", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIHs_speed100_05:getId()
	return "hs_speed100_05";
end


-- AI时机
function ClsAIHs_speed100_05:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIHs_speed100_05:getPriority()
	return 48;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndNum2is1(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- 计数2
	local num2 = battleData:GetData("num2") or 0;
	-- num2==1
	if ( not (num2==1) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIHs_speed100_05:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndNum2is1(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[OAI变速=0]
local function hs_speed100_05_act_2( ai_obj, act_obj, target, delta_time )
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
	{"stop_ai", "", {{"hs_speed0_05", }, }, }, 
	{"delete_ai", "", {{"hs_speed0_05", }, }, }, 
	{"op", "", {hs_speed100_05_act_2, }, }, 
	{"delete_ai", "", {{"hs_speed100_05", }, }, }, 
}

function ClsAIHs_speed100_05:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIHs_speed100_05:getAllTargetMethod()
	return all_target_method
end

return ClsAIHs_speed100_05

----------------------- Auto Genrate End   --------------------
