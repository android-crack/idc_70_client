----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[10→11]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_escape_84 = class("ClsAIBat_escape_84", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_escape_84:getId()
	return "bat_escape_84";
end


-- AI时机
function ClsAIBat_escape_84:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIBat_escape_84:getPriority()
	return 48;
end

-- AI停止标记
function ClsAIBat_escape_84:getStopOtherFlg()
	return 48;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndHpless60(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- O耐久百分比
	local OHpRate = owner:getHpRate() * 100;
	-- O耐久百分比<=60
	if ( not (OHpRate<=60) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIBat_escape_84:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndHpless60(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]说话-[敌方火力太猛，我先撤退补给！]
local function bat_escape_84_act_2( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end




	local name = ""
	local word = T("敌方火力太猛，我先撤退补给！")

	target_obj:say( name, word )

end

-- [备注]设置-[OAI变速=O速度*0.5]
local function bat_escape_84_act_1( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end

	-- 宿主速度
	local OSpeed = owner:getSpeed();

	-- 公式原文:OAI变速=O速度*0.5
	owner:setAISpeed( OSpeed*0.5 );

end

-- [备注]说话-[补给完成，全都给我坚持住！]
local function bat_escape_84_act_6( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end




	local name = ""
	local word = T("补给完成，全都给我坚持住！")

	target_obj:say( name, word )

end

-- [备注]设置-[O耐久=O耐久+3000]
local function bat_escape_84_act_5( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end

	-- O耐久
	local OHp = owner:getHp();

	-- 公式原文:O耐久=O耐久+3000
	owner:AIsetHp( OHp+3000 );

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"add_effect_to_ship", "", {1, "tx_speedup", 0, 0, 120, true, }, }, 
	{"op", "", {bat_escape_84_act_1, }, }, 
	{"op", "", {bat_escape_84_act_2, }, }, 
	{"move_to", "", {2150, 650, 100, }, }, 
	{"add_effect_to_ship", "", {2, "jn_jiagu_health", 0, 0, 2, true, }, }, 
	{"op", "", {bat_escape_84_act_5, }, }, 
	{"op", "", {bat_escape_84_act_6, }, }, 
	{"delete_ai", "", {{"bat_escape_84", }, }, }, 
}

function ClsAIBat_escape_84:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_escape_84:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_escape_84

----------------------- Auto Genrate End   --------------------
