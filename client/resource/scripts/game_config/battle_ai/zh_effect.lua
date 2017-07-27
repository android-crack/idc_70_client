----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIZh_effect = class("ClsAIZh_effect", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIZh_effect:getId()
	return "zh_effect";
end


-- AI时机
function ClsAIZh_effect:getOpportunity()
	return AI_OPPORTUNITY.FIGHT_START;
end

-- AI优先级别
function ClsAIZh_effect:getPriority()
	return 2;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[OX=px]
local function zh_effect_act_3( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end

	-- 
	local px = battleData:GetData("px") or 0;

	-- 公式原文:OX=px
	owner:setPositionX( px );

end

-- [备注]设置-[OY=py]
local function zh_effect_act_4( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end

	-- 
	local py = battleData:GetData("py") or 0;

	-- 公式原文:OY=py
	owner:setPositionY( py );

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"change_ship_flow", "", {"texture_flow2", }, }, 
	{"add_effect_to_ship", "", {1, "sf_tujin", 0, 0, 120, true, }, }, 
	{"add_effect_to_ship", "", {2, "tx_0171", 0, 0, 3, false, }, }, 
	{"op", "", {zh_effect_act_3, }, }, 
	{"op", "", {zh_effect_act_4, }, }, 
	{"add_skill", "", {99007, 2, }, }, 
	{"add_skill", "", {99009, 2, }, }, 
}

function ClsAIZh_effect:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIZh_effect:getAllTargetMethod()
	return all_target_method
end

return ClsAIZh_effect

----------------------- Auto Genrate End   --------------------
