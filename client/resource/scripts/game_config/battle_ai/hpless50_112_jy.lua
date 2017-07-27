----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIHpless50_112_jy = class("ClsAIHpless50_112_jy", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIHpless50_112_jy:getId()
	return "hpless50_112_jy";
end


-- AI时机
function ClsAIHpless50_112_jy:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIHpless50_112_jy:getPriority()
	return 1;
end

-- AI停止标记
function ClsAIHpless50_112_jy:getStopOtherFlg()
	return 1;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndHpless50(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- O耐久百分比
	local OHpRate = owner:getHpRate() * 100;
	-- O耐久百分比<30
	if ( not (OHpRate<30) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIHpless50_112_jy:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndHpless50(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[num2=num2+1]
local function hpless50_112_jy_act_2( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end

	-- 计数2
	local num2 = battleData:GetData("num2") or 0;

	-- 公式原文:num2=num2+1
	battleData:planningSetData("num2", num2+1);

end

-- [备注]说话-[敌军太强，撤退！请求支援。]
local function hpless50_112_jy_act_0( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end




	local name = ""
	local word = T("敌军太强，撤退！请求支援。")

	target_obj:say( name, word )

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"op", "", {hpless50_112_jy_act_0, }, }, 
	{"move_to", "", {2000, 640, 50, }, }, 
	{"op", "", {hpless50_112_jy_act_2, }, }, 
	{"play_plot", "", {{11, 9, 10, }, }, }, 
	{"battle_stop", "", {0, }, }, 
}

function ClsAIHpless50_112_jy:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIHpless50_112_jy:getAllTargetMethod()
	return all_target_method
end

return ClsAIHpless50_112_jy

----------------------- Auto Genrate End   --------------------
