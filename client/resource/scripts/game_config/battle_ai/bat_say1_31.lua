----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[3]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_say1_31 = class("ClsAIBat_say1_31", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_say1_31:getId()
	return "bat_say1_31";
end


-- AI时机
function ClsAIBat_say1_31:getOpportunity()
	return AI_OPPORTUNITY.FIGHT_START;
end

-- AI优先级别
function ClsAIBat_say1_31:getPriority()
	return 1;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]说话-[嘿嘿，来到爱琴海得先搞清楚状态。]
local function bat_say1_31_act_1( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end




	local name = ""
	local word = T("嘿嘿，来到爱琴海得先搞清楚状态。")

	target_obj:say( name, word )

end

-- [备注]离场-[]
local function bat_say1_31_act_4( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end


	target_obj:release(false, true)

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"move_to", "", {928, 969, 100, }, }, 
	{"op", "", {bat_say1_31_act_1, }, }, 
	{"show_prompt", "", {T("击杀所有奥斯曼海巡船。"), }, }, 
	{"move_to", "", {500, 1089, 100, }, }, 
	{"op", "", {bat_say1_31_act_4, }, }, 
}

function ClsAIBat_say1_31:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_say1_31:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_say1_31

----------------------- Auto Genrate End   --------------------
