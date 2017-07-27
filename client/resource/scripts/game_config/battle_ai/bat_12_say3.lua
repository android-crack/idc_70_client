----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_12_say3 = class("ClsAIBat_12_say3", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_12_say3:getId()
	return "bat_12_say3";
end


-- AI时机
function ClsAIBat_12_say3:getOpportunity()
	return AI_OPPORTUNITY.FIGHT_START;
end

-- AI优先级别
function ClsAIBat_12_say3:getPriority()
	return 48;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]说话-[弟兄们，让他们看看摩尔海盗的厉害！]
local function bat_12_say3_act_0( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end




	local name = ""
	local word = T("弟兄们，让他们看看摩尔海盗的厉害！")

	target_obj:say( name, word )

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"op", "", {bat_12_say3_act_0, }, }, 
}

function ClsAIBat_12_say3:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_12_say3:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_12_say3

----------------------- Auto Genrate End   --------------------
