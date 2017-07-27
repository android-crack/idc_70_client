----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_192_add_ack = class("ClsAIBat_192_add_ack", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_192_add_ack:getId()
	return "bat_192_add_ack";
end


-- AI时机
function ClsAIBat_192_add_ack:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIBat_192_add_ack:getPriority()
	return 48;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]说话-[血量越低，远程伤害越强]
local function bat_192_add_ack_act_1( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end




	local name = ""
	local word = T("血量越低，远程伤害越强")

	target_obj:say( name, word )

end

-- [备注]设置-[OAI远攻=O远攻/50*(100-O耐久百分比)]
local function bat_192_add_ack_act_0( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end

	-- O远攻
	local OFarAtt = owner:getAttFar(0);
	-- O耐久百分比
	local OHpRate = owner:getHpRate() * 100;

	-- 公式原文:OAI远攻=O远攻/50*(100-O耐久百分比)
	owner:setAIFarAtt( OFarAtt/50*(100-OHpRate) );

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"op", "", {bat_192_add_ack_act_0, }, }, 
	{"op", "", {bat_192_add_ack_act_1, }, }, 
}

function ClsAIBat_192_add_ack:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_192_add_ack:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_192_add_ack

----------------------- Auto Genrate End   --------------------
