----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_say_84_jy = class("ClsAIBat_say_84_jy", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_say_84_jy:getId()
	return "bat_say_84_jy";
end


-- AI时机
function ClsAIBat_say_84_jy:getOpportunity()
	return AI_OPPORTUNITY.FIGHT_START;
end

-- AI优先级别
function ClsAIBat_say_84_jy:getPriority()
	return 1;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]说话-[果阿永不屈服！！！]
local function bat_say_84_jy_act_1( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end




	local name = ""
	local word = T("果阿永不屈服！！！")

	target_obj:say( name, word )

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"add_effect_to_ship", "", {1, "tx_speedup", 0, 0, 120, true, }, }, 
	{"op", "", {bat_say_84_jy_act_1, }, }, 
}

function ClsAIBat_say_84_jy:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_say_84_jy:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_say_84_jy

----------------------- Auto Genrate End   --------------------
