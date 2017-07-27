----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_pvp_reset = class("ClsAIBat_pvp_reset", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_pvp_reset:getId()
	return "bat_pvp_reset";
end


-- AI时机
function ClsAIBat_pvp_reset:getOpportunity()
	return AI_OPPORTUNITY.RUN;
end

-- AI优先级别
function ClsAIBat_pvp_reset:getPriority()
	return 48;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]说话-[攻击属性增强！]
local function bat_pvp_reset_act_0( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end




	local name = ""
	local word = T("攻击属性增强！")

	target_obj:say( name, word )

end

-- [备注]设置-[OAI远攻=0]
local function bat_pvp_reset_act_3( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end


	-- 公式原文:OAI远攻=0
	owner:setAIFarAtt( 0 );

end

-- [备注]说话-[攻击属性恢复！]
local function bat_pvp_reset_act_2( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end




	local name = ""
	local word = T("攻击属性恢复！")

	target_obj:say( name, word )

end

-- [备注]设置-[OAI近攻=0]
local function bat_pvp_reset_act_4( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end


	-- 公式原文:OAI近攻=0
	owner:setAINearAtt( 0 );

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"op", "", {bat_pvp_reset_act_0, }, }, 
	{"delay", "", {5000, }, }, 
	{"op", "", {bat_pvp_reset_act_2, }, }, 
	{"op", "", {bat_pvp_reset_act_3, }, }, 
	{"op", "", {bat_pvp_reset_act_4, }, }, 
}

function ClsAIBat_pvp_reset:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_pvp_reset:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_pvp_reset

----------------------- Auto Genrate End   --------------------
