----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_23_gyb_move = class("ClsAIBat_23_gyb_move", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_23_gyb_move:getId()
	return "bat_23_gyb_move";
end


-- AI时机
function ClsAIBat_23_gyb_move:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIBat_23_gyb_move:getPriority()
	return 1;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndPlayer_arrive(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- 战场测试变量
	local arrive = battleData:GetData("arrive") or 0;
	-- 抵达==1
	if ( not (arrive==1) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIBat_23_gyb_move:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndPlayer_arrive(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[OAI变速=0]
local function bat_23_gyb_move_act_3( ai_obj, act_obj, target, delta_time )
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
	{"stop_ai", "", {{"bat_23_gyb_speed0", }, }, }, 
	{"delete_ai", "", {{"bat_23_gyb_speed0", }, }, }, 
	{"delete_ai", "", {{"bat_23_gyb_move2", }, }, }, 
	{"op", "", {bat_23_gyb_move_act_3, }, }, 
	{"move_to", "", {400, 400, 100, }, }, 
	{"delete_ai", "", {{"bat_23_gyb_move", }, }, }, 
}

function ClsAIBat_23_gyb_move:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_23_gyb_move:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_23_gyb_move

----------------------- Auto Genrate End   --------------------
