----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_23_action = class("ClsAIBat_23_action", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_23_action:getId()
	return "bat_23_action";
end


-- AI时机
function ClsAIBat_23_action:getOpportunity()
	return AI_OPPORTUNITY.FIGHT_START;
end

-- AI优先级别
function ClsAIBat_23_action:getPriority()
	return 1;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[剧情镜头暂停=true]
local function bat_23_action_act_2( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end


	-- 公式原文:剧情镜头暂停=true
	ai_obj:setData( "__camera_stop", true );

end

-- [备注]离场-[]
local function bat_23_action_act_7( ai_obj, act_obj, target, delta_time )
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
	{"delay", "", {500, }, }, 
	{"story_mode", "", {}, }, 
	{"op", "", {bat_23_action_act_2, }, }, 
	{"camera_follow", "", {5, 0, 1, 10, }, }, 
	{"delay", "", {100, }, }, 
	{"play_plot", "", {{10, }, }, }, 
	{"move_to", "", {2300, 320, 50, }, }, 
	{"op", "", {bat_23_action_act_7, }, }, 
	{"battle_stop", "", {1, }, }, 
}

function ClsAIBat_23_action:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_23_action:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_23_action

----------------------- Auto Genrate End   --------------------
