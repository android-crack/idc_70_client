----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_152_status = class("ClsAIBat_152_status", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_152_status:getId()
	return "bat_152_status";
end


-- AI时机
function ClsAIBat_152_status:getOpportunity()
	return AI_OPPORTUNITY.RUN;
end

-- AI优先级别
function ClsAIBat_152_status:getPriority()
	return -2;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[OAI防御=-O防御*0.8]
local function bat_152_status_act_5( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end

	-- 宿主防御
	local ODefense = owner:getDefense();

	-- 公式原文:OAI防御=-O防御*0.8
	owner:setAIDefense( -ODefense*0.8 );

end

-- [备注]设置-[OAI远攻=O远攻*10]
local function bat_152_status_act_4( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end

	-- O远攻
	local OFarAtt = owner:getAttFar(0);

	-- 公式原文:OAI远攻=O远攻*10
	owner:setAIFarAtt( OFarAtt*10 );

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"add_effect_to_ship", "", {1, "tx_yanhua_up", -70, 70, 150, true, }, }, 
	{"add_effect_to_ship", "", {2, "tx_yanhua_up", -70, -70, 150, true, }, }, 
	{"add_effect_to_ship", "", {3, "tx_yanhua_up", 70, -70, 150, true, }, }, 
	{"add_effect_to_ship", "", {4, "tx_yanhua_up", 70, 70, 150, true, }, }, 
	{"op", "", {bat_152_status_act_4, }, }, 
	{"op", "", {bat_152_status_act_5, }, }, 
	{"add_skill", "", {1013, 1, }, }, 
}

function ClsAIBat_152_status:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_152_status:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_152_status

----------------------- Auto Genrate End   --------------------
