----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_203_escape = class("ClsAIBat_203_escape", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_203_escape:getId()
	return "bat_203_escape";
end


-- AI时机
function ClsAIBat_203_escape:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIBat_203_escape:getPriority()
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
	-- O耐久百分比<=30
	if ( not (OHpRate<=30) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIBat_203_escape:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndHpless60(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]说话-[难道红旗帮会在这里全军覆灭吗。。。]
local function bat_203_escape_act_0( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end




	local name = ""
	local word = T("难道红旗帮会在这里全军覆灭吗。。。")

	target_obj:say( name, word )

end

-- [备注]设置-[OAI变速=50]
local function bat_203_escape_act_4( ai_obj, act_obj, target, delta_time )
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

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"op", "", {bat_203_escape_act_0, }, }, 
	{"stop_ai", "", {{"bat_203_follow_boss1", }, }, }, 
	{"delete_ai", "", {{"bat_203_follow_boss1", }, }, }, 
	{"add_effect_to_ship", "", {1, "sf_tujin", 0, 0, 120, true, }, }, 
	{"op", "", {bat_203_escape_act_4, }, }, 
	{"show_prompt", "", {T("阻止郑石氏逃跑！"), }, }, 
	{"move_to", "", {2200, 500, 50, }, }, 
	{"play_plot", "", {{8, }, }, }, 
	{"battle_stop", "", {0, }, }, 
	{"delete_ai", "", {{"bat_203_escape", }, }, }, 
}

function ClsAIBat_203_escape:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_203_escape:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_203_escape

----------------------- Auto Genrate End   --------------------
