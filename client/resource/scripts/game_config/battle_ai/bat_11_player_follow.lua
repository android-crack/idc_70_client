----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_11_player_follow = class("ClsAIBat_11_player_follow", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_11_player_follow:getId()
	return "bat_11_player_follow";
end


-- AI时机
function ClsAIBat_11_player_follow:getOpportunity()
	return AI_OPPORTUNITY.RUN;
end

-- AI优先级别
function ClsAIBat_11_player_follow:getPriority()
	return 48;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[OAI变速=70]
local function bat_11_player_follow_act_1( ai_obj, act_obj, target, delta_time )
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
	{"delete_ai", "", {{"bat_11_stop", }, }, }, 
	{"op", "", {bat_11_player_follow_act_1, }, }, 
	{"move_to", "", {1500, 640, 190, }, }, 
}

function ClsAIBat_11_player_follow:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_11_player_follow:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_11_player_follow

----------------------- Auto Genrate End   --------------------
