----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_202_skill4 = class("ClsAIBat_202_skill4", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_202_skill4:getId()
	return "bat_202_skill4";
end


-- AI时机
function ClsAIBat_202_skill4:getOpportunity()
	return AI_OPPORTUNITY.FIGHT_START;
end

-- AI优先级别
function ClsAIBat_202_skill4:getPriority()
	return 48;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[O加怒=200]
local function bat_202_skill4_act_0( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end


	-- 公式原文:O加怒=200
	owner:addAnger( 200 );

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"op", "", {bat_202_skill4_act_0, }, }, 
	{"add_skill", "", {1026, 1, }, }, 
	{"add_skill", "", {1207, 1, }, }, 
}

function ClsAIBat_202_skill4:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_202_skill4:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_202_skill4

----------------------- Auto Genrate End   --------------------
