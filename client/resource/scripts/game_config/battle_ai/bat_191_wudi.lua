----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_191_wudi = class("ClsAIBat_191_wudi", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_191_wudi:getId()
	return "bat_191_wudi";
end


-- AI时机
function ClsAIBat_191_wudi:getOpportunity()
	return AI_OPPORTUNITY.RUN;
end

-- AI优先级别
function ClsAIBat_191_wudi:getPriority()
	return -2;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]说话-[船舰防守能力大幅提升]
local function bat_191_wudi_act_2( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end




	local name = ""
	local word = T("船舰防守能力大幅提升")

	target_obj:say( name, word )

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"add_effect_to_ship", "", {1, "sf_tujin", 0, 0, 5, true, }, }, 
	{"use_skill", "", {1042, }, }, 
	{"op", "", {bat_191_wudi_act_2, }, }, 
}

function ClsAIBat_191_wudi:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_191_wudi:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_191_wudi

----------------------- Auto Genrate End   --------------------
