----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[低于60%]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_163_boss_hp = class("ClsAIBat_163_boss_hp", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_163_boss_hp:getId()
	return "bat_163_boss_hp";
end


-- AI时机
function ClsAIBat_163_boss_hp:getOpportunity()
	return AI_OPPORTUNITY.HP_CHANGE;
end

-- AI优先级别
function ClsAIBat_163_boss_hp:getPriority()
	return -2;
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
	-- O耐久百分比<60
	if ( not (OHpRate<60) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIBat_163_boss_hp:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndHpless60(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[BOSS血量记录=1]
local function bat_163_boss_hp_act_4( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end


	-- 公式原文:BOSS血量记录=1
	battleData:planningSetData("_boss_cnt", 1);

end

-- [备注]离场-[]
local function bat_163_boss_hp_act_8( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end


	target_obj:release(false, true)

end

-- [备注]说话-[挺能干的嘛，让双子星来陪你们玩玩！]
local function bat_163_boss_hp_act_1( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end




	local name = ""
	local word = T("挺能干的嘛，让双子星来陪你们玩玩！")

	target_obj:say( name, word )

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"add_status", "", {"wudi", }, }, 
	{"op", "", {bat_163_boss_hp_act_1, }, }, 
	{"show_prompt", "", {T("双子星被击破的时间间隔不能超过6秒"), }, }, 
	{"add_effect_to_ship", "", {1, "tx_0171", 0, 0, 3, true, }, }, 
	{"op", "", {bat_163_boss_hp_act_4, }, }, 
	{"enter_scene", "", {11, 0, 0, 1, 7, 0, }, }, 
	{"enter_scene", "", {12, 0, 0, 1, 7, 0, }, }, 
	{"delay", "", {1000, }, }, 
	{"op", "", {bat_163_boss_hp_act_8, }, }, 
	{"delete_ai", "", {{"bat_163_hp", "bat_163_speed_2", "bat_163_boss_hp", }, }, }, 
}

function ClsAIBat_163_boss_hp:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_163_boss_hp:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_163_boss_hp

----------------------- Auto Genrate End   --------------------
