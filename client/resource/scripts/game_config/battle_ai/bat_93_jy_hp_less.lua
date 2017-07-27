----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_93_jy_hp_less = class("ClsAIBat_93_jy_hp_less", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_93_jy_hp_less:getId()
	return "bat_93_jy_hp_less";
end


-- AI时机
function ClsAIBat_93_jy_hp_less:getOpportunity()
	return AI_OPPORTUNITY.HP_CHANGE;
end

-- AI优先级别
function ClsAIBat_93_jy_hp_less:getPriority()
	return -2;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndBat_93_jy_hp_less(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- O耐久百分比
	local OHpRate = owner:getHpRate() * 100;
	-- O耐久百分比<80
	if ( not (OHpRate<80) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIBat_93_jy_hp_less:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndBat_93_jy_hp_less(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[O耐久=999999]
local function bat_93_jy_hp_less_act_7( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end


	-- 公式原文:O耐久=999999
	owner:AIsetHp( 999999 );

end

-- [备注]设置-[气血低=气血低+1]
local function bat_93_jy_hp_less_act_8( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end

	-- 战场测试变量
	local Low_Hp = battleData:GetData("_low_hp") or 0;

	-- 公式原文:气血低=气血低+1
	battleData:planningSetData("_low_hp", Low_Hp+1);

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"enter_scene", "", {19, }, }, 
	{"enter_scene", "", {20, }, }, 
	{"enter_scene", "", {21, }, }, 
	{"enter_scene", "", {16, }, }, 
	{"enter_scene", "", {17, }, }, 
	{"enter_scene", "", {18, }, }, 
	{"play_plot", "", {{5, 6, 7, 8, 9, 10, 11, 12, }, }, }, 
	{"op", "", {bat_93_jy_hp_less_act_7, }, }, 
	{"op", "", {bat_93_jy_hp_less_act_8, }, }, 
	{"show_prompt", "", {T("航行至海面指引位置离开战场。"), }, }, 
	{"enter_scene", "", {24, 1, 1, 0, 0, 0, }, }, 
	{"delete_ai", "", {{"bat_93_jy_hp_less", }, }, }, 
}

function ClsAIBat_93_jy_hp_less:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_93_jy_hp_less:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_93_jy_hp_less

----------------------- Auto Genrate End   --------------------
