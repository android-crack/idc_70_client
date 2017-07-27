----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIDk_flash3 = class("ClsAIDk_flash3", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIDk_flash3:getId()
	return "dk_flash3";
end


-- AI时机
function ClsAIDk_flash3:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIDk_flash3:getPriority()
	return -2;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndDk_flash3(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- O耐久百分比
	local OHpRate = owner:getHpRate() * 100;
	-- O耐久百分比<30
	if ( not (OHpRate<30) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIDk_flash3:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndDk_flash3(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[OX=2300;OY=640]
local function dk_flash3_act_2( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end


	-- 公式原文:OX=2300
	owner:setPositionX( 2300 );
	-- 公式原文:OY=640
	owner:setPositionY( 640 );

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"add_effect_to_ship", "", {4, "tx_0171", 0, 0, 3, false, }, }, 
	{"delay", "", {1000, }, }, 
	{"op", "", {dk_flash3_act_2, }, }, 
	{"delete_ai", "", {{"dk_flash3", }, }, }, 
}

function ClsAIDk_flash3:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIDk_flash3:getAllTargetMethod()
	return all_target_method
end

return ClsAIDk_flash3

----------------------- Auto Genrate End   --------------------
