----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[3]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_say1_31_jy = class("ClsAIBat_say1_31_jy", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_say1_31_jy:getId()
	return "bat_say1_31_jy";
end


-- AI时机
function ClsAIBat_say1_31_jy:getOpportunity()
	return AI_OPPORTUNITY.FIGHT_START;
end

-- AI优先级别
function ClsAIBat_say1_31_jy:getPriority()
	return 48;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]离场-[]
local function bat_say1_31_jy_act_3( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end


	target_obj:release(false, true)

end

-- [备注]说话-[让你搞清楚谁才是爱琴海的老大！]
local function bat_say1_31_jy_act_1( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end




	local name = ""
	local word = T("让你搞清楚谁才是爱琴海的老大！")

	target_obj:say( name, word )

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"move_to", "", {928, 969, 100, }, }, 
	{"op", "", {bat_say1_31_jy_act_1, }, }, 
	{"move_to", "", {500, 1089, 100, }, }, 
	{"op", "", {bat_say1_31_jy_act_3, }, }, 
}

function ClsAIBat_say1_31_jy:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_say1_31_jy:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_say1_31_jy

----------------------- Auto Genrate End   --------------------
