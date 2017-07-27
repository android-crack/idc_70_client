----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_start_101 = class("ClsAIBat_start_101", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_start_101:getId()
	return "bat_start_101";
end


-- AI时机
function ClsAIBat_start_101:getOpportunity()
	return AI_OPPORTUNITY.FIGHT_START;
end

-- AI优先级别
function ClsAIBat_start_101:getPriority()
	return 1;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]说话-[消灭掉炮塔前的守卫舰，侧边我来掩护。]
local function bat_start_101_act_3( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end




	local name = ""
	local word = T("消灭掉炮塔前的守卫舰，侧边我来掩护。")

	target_obj:say( name, word )

end

-- [备注]说话-[来吧，你们面对的是斯帕罗船长！]
local function bat_start_101_act_5( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end




	local name = ""
	local word = T("来吧，你们面对的是斯帕罗船长！")

	target_obj:say( name, word )

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"play_plot", "", {{1, 2, 3, }, }, }, 
	{"play_plot", "", {{4, 5, 6, 7, 8, }, }, }, 
	{"show_prompt", "", {T("击沉炮塔前的亚齐守卫舰"), }, }, 
	{"op", "", {bat_start_101_act_3, }, }, 
	{"move_to", "", {1369, 746, 50, }, }, 
	{"op", "", {bat_start_101_act_5, }, }, 
	{"add_ai", "", {{"bat_moto_101", }, }, }, 
}

function ClsAIBat_start_101:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_start_101:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_start_101

----------------------- Auto Genrate End   --------------------
