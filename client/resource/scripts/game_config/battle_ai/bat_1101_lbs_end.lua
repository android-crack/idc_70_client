----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[拉比斯被阿芒德一伙抓住，剧情结束]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_1101_lbs_end = class("ClsAIBat_1101_lbs_end", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_1101_lbs_end:getId()
	return "bat_1101_lbs_end";
end


-- AI时机
function ClsAIBat_1101_lbs_end:getOpportunity()
	return AI_OPPORTUNITY.RUN;
end

-- AI优先级别
function ClsAIBat_1101_lbs_end:getPriority()
	return 1;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[OAI变速=-O速度;O禁止转动=true]
local function bat_1101_lbs_end_act_2( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end

	-- 宿主速度
	local OSpeed = owner:getSpeed();

	-- 公式原文:OAI变速=-O速度
	owner:setAISpeed( -OSpeed );
	-- 公式原文:O禁止转动=true
	owner.body.is_ban_turn = true;

end

-- [备注]设置-[OAI变速=-35]
local function bat_1101_lbs_end_act_0( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end


	-- 公式原文:OAI变速=-35
	owner:setAISpeed( -35 );

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"op", "", {bat_1101_lbs_end_act_0, }, }, 
	{"move_to", "", {1500, 800, 150, }, }, 
	{"op", "", {bat_1101_lbs_end_act_2, }, }, 
	{"play_plot", "", {{7, 8, 9, }, }, }, 
	{"battle_stop", "", {1, }, }, 
}

function ClsAIBat_1101_lbs_end:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_1101_lbs_end:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_1101_lbs_end

----------------------- Auto Genrate End   --------------------
