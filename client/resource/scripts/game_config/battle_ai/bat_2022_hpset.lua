----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_2022_hpset = class("ClsAIBat_2022_hpset", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_2022_hpset:getId()
	return "bat_2022_hpset";
end


-- AI时机
function ClsAIBat_2022_hpset:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIBat_2022_hpset:getPriority()
	return 1;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- 本AI的判定条件
function ClsAIBat_2022_hpset:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	
	return (bat_22_time1)
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[O耐久=O耐久*0.7]
local function bat_2022_hpset_act_0( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end

	-- O耐久
	local OHp = owner:getHp();

	-- 公式原文:O耐久=O耐久*0.7
	owner:AIsetHp( OHp*0.7 );

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"op", "", {bat_2022_hpset_act_0, }, }, 
	{"delete_ai", "", {{"bat_2022_hpset", }, }, }, 
}

function ClsAIBat_2022_hpset:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_2022_hpset:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_2022_hpset

----------------------- Auto Genrate End   --------------------
