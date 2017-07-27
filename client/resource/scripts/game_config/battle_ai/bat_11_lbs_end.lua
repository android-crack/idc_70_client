----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[拉比斯移动]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_11_lbs_end = class("ClsAIBat_11_lbs_end", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_11_lbs_end:getId()
	return "bat_11_lbs_end";
end


-- AI时机
function ClsAIBat_11_lbs_end:getOpportunity()
	return AI_OPPORTUNITY.RUN;
end

-- AI优先级别
function ClsAIBat_11_lbs_end:getPriority()
	return 48;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[OAI变速=70]
local function bat_11_lbs_end_act_0( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end


	-- 公式原文:OAI变速=70
	owner:setAISpeed( 70 );

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"op", "", {bat_11_lbs_end_act_0, }, }, 
	{"move_to", "", {1300, 640, 190, }, }, 
	{"play_plot", "", {{8, 9, 10, 11, 12, }, }, }, 
	{"battle_stop", "", {1, }, }, 
}

function ClsAIBat_11_lbs_end:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_11_lbs_end:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_11_lbs_end

----------------------- Auto Genrate End   --------------------
