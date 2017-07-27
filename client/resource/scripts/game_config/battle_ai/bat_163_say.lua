----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[进战斗说话]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_163_say = class("ClsAIBat_163_say", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_163_say:getId()
	return "bat_163_say";
end


-- AI时机
function ClsAIBat_163_say:getOpportunity()
	return AI_OPPORTUNITY.FIGHT_START;
end

-- AI优先级别
function ClsAIBat_163_say:getPriority()
	return 1;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]说话-[治疗舰，为我治疗！]
local function bat_163_say_act_1( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end




	local name = ""
	local word = T("治疗舰，为我治疗！")

	target_obj:say( name, word )

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"delay", "", {2000, }, }, 
	{"op", "", {bat_163_say_act_1, }, }, 
}

function ClsAIBat_163_say:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_163_say:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_163_say

----------------------- Auto Genrate End   --------------------
