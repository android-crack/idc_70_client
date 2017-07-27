----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_93_shiva_say = class("ClsAIBat_93_shiva_say", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_93_shiva_say:getId()
	return "bat_93_shiva_say";
end


-- AI时机
function ClsAIBat_93_shiva_say:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIBat_93_shiva_say:getPriority()
	return -2;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]说话-[按计划进行，分头拖住敌军，一定要让他们成功逃脱！]
local function bat_93_shiva_say_act_0( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end




	local name = ""
	local word = T("按计划进行，分头拖住敌军，一定要让他们成功逃脱！")

	target_obj:say( name, word )

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"op", "", {bat_93_shiva_say_act_0, }, }, 
	{"delete_ai", "", {{"bat_93_shiva_say", }, }, }, 
}

function ClsAIBat_93_shiva_say:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_93_shiva_say:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_93_shiva_say

----------------------- Auto Genrate End   --------------------
