----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[伏兵首领讲两句]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_say1_182 = class("ClsAIBat_say1_182", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_say1_182:getId()
	return "bat_say1_182";
end


-- AI时机
function ClsAIBat_say1_182:getOpportunity()
	return AI_OPPORTUNITY.FIGHT_START;
end

-- AI优先级别
function ClsAIBat_say1_182:getPriority()
	return 48;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]说话-[你已经无路可逃了！我们上！包围他！]
local function bat_say1_182_act_0( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end




	local name = ""
	local word = T("你已经无路可逃了！我们上！包围他！")

	target_obj:say( name, word )

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"op", "", {bat_say1_182_act_0, }, }, 
}

function ClsAIBat_say1_182:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_say1_182:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_say1_182

----------------------- Auto Genrate End   --------------------
