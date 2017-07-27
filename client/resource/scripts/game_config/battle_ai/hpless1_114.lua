----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[5]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIHpless1_114 = class("ClsAIHpless1_114", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIHpless1_114:getId()
	return "hpless1_114";
end


-- AI时机
function ClsAIHpless1_114:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIHpless1_114:getPriority()
	return 1;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndHpless80(ai_obj, target)
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
function ClsAIHpless1_114:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndHpless80(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]说话-[回头看看吧！]
local function hpless1_114_act_3( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end




	local name = ""
	local word = T("回头看看吧！")

	target_obj:say( name, word )

end

-- [备注]说话-[我陈祖义，“义”字你懂吗？你觉得我的手下真的投降了？]
local function hpless1_114_act_0( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end




	local name = ""
	local word = T("我陈祖义，“义”字你懂吗？你觉得我的手下真的投降了？")

	target_obj:say( name, word )

end

-- [备注]设置-[num1=num1+1]
local function hpless1_114_act_1( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end

	-- 计数1
	local num1 = battleData:GetData("num1") or 0;

	-- 公式原文:num1=num1+1
	battleData:planningSetData("num1", num1+1);

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"op", "", {hpless1_114_act_0, }, }, 
	{"op", "", {hpless1_114_act_1, }, }, 
	{"delay", "", {1000, }, }, 
	{"op", "", {hpless1_114_act_3, }, }, 
	{"add_skill", "", {1202, 1, }, }, 
	{"delete_ai", "", {{"hpless1_114", }, }, }, 
}

function ClsAIHpless1_114:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIHpless1_114:getAllTargetMethod()
	return all_target_method
end

return ClsAIHpless1_114

----------------------- Auto Genrate End   --------------------
