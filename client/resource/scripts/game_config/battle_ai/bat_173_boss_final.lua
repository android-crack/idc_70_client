----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_173_boss_final = class("ClsAIBat_173_boss_final", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_173_boss_final:getId()
	return "bat_173_boss_final";
end


-- AI时机
function ClsAIBat_173_boss_final:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIBat_173_boss_final:getPriority()
	return -2;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndHpless40(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- O耐久百分比
	local OHpRate = owner:getHpRate() * 100;
	-- O耐久百分比<40
	if ( not (OHpRate<40) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIBat_173_boss_final:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndHpless40(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[OAI变速=50]
local function bat_173_boss_final_act_2( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end


	-- 公式原文:OAI变速=50
	owner:setAISpeed( 50 );

end

-- [备注]说话-[别躲了……]
local function bat_173_boss_final_act_3( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end




	local name = ""
	local word = T("别躲了……")

	target_obj:say( name, word )

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"forge_weather", "", {120, }, }, 
	{"add_effect_to_ship", "", {1, "sf_tujin", 0, 0, 120, true, }, }, 
	{"op", "", {bat_173_boss_final_act_2, }, }, 
	{"op", "", {bat_173_boss_final_act_3, }, }, 
	{"add_skill", "", {3501, 1, }, }, 
	{"delete_ai", "", {{"bat_173_boss_final", }, }, }, 
}

function ClsAIBat_173_boss_final:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_173_boss_final:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_173_boss_final

----------------------- Auto Genrate End   --------------------
