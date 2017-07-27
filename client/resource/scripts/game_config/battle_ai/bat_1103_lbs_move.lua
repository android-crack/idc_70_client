----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[拉比斯移动]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_1103_lbs_move = class("ClsAIBat_1103_lbs_move", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_1103_lbs_move:getId()
	return "bat_1103_lbs_move";
end


-- AI时机
function ClsAIBat_1103_lbs_move:getOpportunity()
	return AI_OPPORTUNITY.RUN;
end

-- AI优先级别
function ClsAIBat_1103_lbs_move:getPriority()
	return 1;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[OAI变速=-25]
local function bat_1103_lbs_move_act_0( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end


	-- 公式原文:OAI变速=-25
	owner:setAISpeed( -25 );

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"op", "", {bat_1103_lbs_move_act_0, }, }, 
	{"move_to", "", {1500, 800, 250, }, }, 
	{"play_plot", "", {{4, }, }, }, 
	{"move_to", "", {1500, 800, 190, }, }, 
	{"play_plot", "", {{5, 6, 7, 8, 9, }, }, }, 
	{"battle_stop", "", {1, }, }, 
}

function ClsAIBat_1103_lbs_move:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_1103_lbs_move:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_1103_lbs_move

----------------------- Auto Genrate End   --------------------
