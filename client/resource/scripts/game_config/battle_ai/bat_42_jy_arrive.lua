----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_42_jy_arrive = class("ClsAIBat_42_jy_arrive", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_42_jy_arrive:getId()
	return "bat_42_jy_arrive";
end


-- AI时机
function ClsAIBat_42_jy_arrive:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIBat_42_jy_arrive:getPriority()
	return 1;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndBat_42_jy_arrive(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- math.abs(1275 - OX) <300
	if ( not (math.abs(1275 - owner:getPositionX()) <300) ) then  return false end

	-- math.abs(1275 - OX) <300
	if ( not (math.abs(1275 - owner:getPositionX()) <300) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIBat_42_jy_arrive:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndBat_42_jy_arrive(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]说话-[可敢与我一战！]
local function bat_42_jy_arrive_act_0( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end




	local name = ""
	local word = T("可敢与我一战！")

	target_obj:say( name, word )

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"op", "", {bat_42_jy_arrive_act_0, }, }, 
	{"delete_ai", "", {{"bat_42_jy_arrive", }, }, }, 
}

function ClsAIBat_42_jy_arrive:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_42_jy_arrive:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_42_jy_arrive

----------------------- Auto Genrate End   --------------------
