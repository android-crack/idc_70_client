----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[敌主舰逞英雄]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_say2_181 = class("ClsAIBat_say2_181", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_say2_181:getId()
	return "bat_say2_181";
end


-- AI时机
function ClsAIBat_say2_181:getOpportunity()
	return AI_OPPORTUNITY.RUN;
end

-- AI优先级别
function ClsAIBat_say2_181:getPriority()
	return -2;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]说话-[可恶的海盗！我来拖住他们，大家快逃！]
local function bat_say2_181_act_0( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end




	local name = ""
	local word = T("可恶的海盗！我来拖住他们，大家快逃！")

	target_obj:say( name, word )

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"op", "", {bat_say2_181_act_0, }, }, 
}

function ClsAIBat_say2_181:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_say2_181:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_say2_181

----------------------- Auto Genrate End   --------------------
