----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_23_gyb_move2 = class("ClsAIBat_23_gyb_move2", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_23_gyb_move2:getId()
	return "bat_23_gyb_move2";
end


-- AI时机
function ClsAIBat_23_gyb_move2:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIBat_23_gyb_move2:getPriority()
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
function ClsAIBat_23_gyb_move2:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndHpless100(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[OAI变速=0]
local function bat_23_gyb_move2_act_4( ai_obj, act_obj, target, delta_time )
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

-- [备注]说话-[喜欢突袭！不按套路来的咯？]
local function bat_23_gyb_move2_act_5( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end




	local name = ""
	local word = T("喜欢突袭！不按套路来的咯？")

	target_obj:say( name, word )

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"stop_ai", "", {{"bat_23_gyb_speed0", }, }, }, 
	{"delete_ai", "", {{"bat_23_gyb_speed0", }, }, }, 
	{"delete_ai", "", {{"bat_23_gyb_move", }, }, }, 
	{"delete_ai", "", {{"bat_23_gyb_say", }, }, }, 
	{"op", "", {bat_23_gyb_move2_act_4, }, }, 
	{"op", "", {bat_23_gyb_move2_act_5, }, }, 
	{"delete_ai", "", {{"bat_23_gyb_move2", }, }, }, 
}

function ClsAIBat_23_gyb_move2:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_23_gyb_move2:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_23_gyb_move2

----------------------- Auto Genrate End   --------------------
