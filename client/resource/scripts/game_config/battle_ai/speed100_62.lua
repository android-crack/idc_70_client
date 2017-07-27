----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAISpeed100_62 = class("ClsAISpeed100_62", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAISpeed100_62:getId()
	return "speed100_62";
end


-- AI时机
function ClsAISpeed100_62:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAISpeed100_62:getPriority()
	return 1;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndHpless95(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- O耐久百分比
	local OHpRate = owner:getHpRate() * 100;
	-- O耐久百分比<=95
	if ( not (OHpRate<=95) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAISpeed100_62:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndHpless95(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[OAI变速=O速度*0.5]
local function speed100_62_act_0( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end

	-- 宿主速度
	local OSpeed = owner:getSpeed();

	-- 公式原文:OAI变速=O速度*0.5
	owner:setAISpeed( OSpeed*0.5 );

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"op", "", {speed100_62_act_0, }, }, 
	{"delete_ai", "", {{"speed100_62", }, }, }, 
}

function ClsAISpeed100_62:getActions()
	return actions
end

local all_target_method = {
}

function ClsAISpeed100_62:getAllTargetMethod()
	return all_target_method
end

return ClsAISpeed100_62

----------------------- Auto Genrate End   --------------------
