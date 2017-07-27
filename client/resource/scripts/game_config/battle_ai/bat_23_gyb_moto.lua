----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_23_gyb_moto = class("ClsAIBat_23_gyb_moto", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_23_gyb_moto:getId()
	return "bat_23_gyb_moto";
end


-- AI时机
function ClsAIBat_23_gyb_moto:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIBat_23_gyb_moto:getPriority()
	return 1;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndBat_23_in_area(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- ((500 - OX) < 100) and ((500 - OX) >= 0)
	if ( not (((500 - owner:getPositionX()) < 100) and ((500 - owner:getPositionX()) >= 0)) ) then  return false end

	-- math.abs(500 - OY) <= 50
	if ( not (math.abs(500 - owner:getPositionY()) <= 50) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIBat_23_gyb_moto:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndBat_23_in_area(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[抵达=抵达+1]
local function bat_23_gyb_moto_act_0( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end

	-- 战场测试变量
	local arrive = battleData:GetData("arrive") or 0;

	-- 公式原文:抵达=抵达+1
	battleData:planningSetData("arrive", arrive+1);

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"op", "", {bat_23_gyb_moto_act_0, }, }, 
	{"del_skill", "", {2, }, }, 
	{"play_plot", "", {{8, }, }, }, 
	{"del_guide_point", "", {}, }, 
	{"add_ai", "", {{"bat_23_gyb_speed0", }, }, }, 
	{"run_ai", "", {{"bat_23_gyb_event1", }, }, }, 
	{"delete_ai", "", {{"bat_23_gyb_moto", }, }, }, 
}

function ClsAIBat_23_gyb_moto:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_23_gyb_moto:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_23_gyb_moto

----------------------- Auto Genrate End   --------------------
