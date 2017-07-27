----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_43_add_skill = class("ClsAIBat_43_add_skill", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_43_add_skill:getId()
	return "bat_43_add_skill";
end


-- AI时机
function ClsAIBat_43_add_skill:getOpportunity()
	return AI_OPPORTUNITY.FIGHT_START;
end

-- AI优先级别
function ClsAIBat_43_add_skill:getPriority()
	return 48;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[OAI变速=-52]
local function bat_43_add_skill_act_1( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end


	-- 公式原文:OAI变速=-52
	owner:setAISpeed( -52 );

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"add_skill", "", {1029, 1, }, }, 
	{"op", "", {bat_43_add_skill_act_1, }, }, 
	{"delay", "", {120000, }, }, 
}

function ClsAIBat_43_add_skill:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_43_add_skill:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_43_add_skill

----------------------- Auto Genrate End   --------------------
