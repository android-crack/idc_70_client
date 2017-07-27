----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[10]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIArrive_102 = class("ClsAIArrive_102", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIArrive_102:getId()
	return "arrive_102";
end


-- AI时机
function ClsAIArrive_102:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIArrive_102:getPriority()
	return 1;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndIn_area1(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- math.abs(370 - OX) < 80
	if ( not (math.abs(370 - owner:getPositionX()) < 80) ) then  return false end

	-- math.abs(858 - OY) < 80
	if ( not (math.abs(858 - owner:getPositionY()) < 80) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIArrive_102:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndIn_area1(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]说话-[别开炮！是我！]
local function arrive_102_act_0( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end




	local name = ""
	local word = T("别开炮！是我！")

	target_obj:say( name, word )

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"op", "", {arrive_102_act_0, }, }, 
	{"delete_ai", "", {{"arrive_102", }, }, }, 
}

function ClsAIArrive_102:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIArrive_102:getAllTargetMethod()
	return all_target_method
end

return ClsAIArrive_102

----------------------- Auto Genrate End   --------------------
