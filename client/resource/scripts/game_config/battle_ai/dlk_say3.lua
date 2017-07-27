----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIDlk_say3 = class("ClsAIDlk_say3", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIDlk_say3:getId()
	return "dlk_say3";
end


-- AI时机
function ClsAIDlk_say3:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIDlk_say3:getPriority()
	return -2;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- 本AI的判定条件
function ClsAIDlk_say3:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	
	return (hpless70)
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]说话-[大英帝国万岁！]
local function dlk_say3_act_0( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end




	local name = ""
	local word = T("大英帝国万岁！")

	target_obj:say( name, word )

end

-- [备注]设置-[OAI变速=0.5*O速度]
local function dlk_say3_act_1( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end

	-- 宿主速度
	local OSpeed = owner:getSpeed();

	-- 公式原文:OAI变速=0.5*O速度
	owner:setAISpeed( 0.5*OSpeed );

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"op", "", {dlk_say3_act_0, }, }, 
	{"op", "", {dlk_say3_act_1, }, }, 
	{"delete_ai", "", {{"dlk_say3", }, }, }, 
}

function ClsAIDlk_say3:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIDlk_say3:getAllTargetMethod()
	return all_target_method
end

return ClsAIDlk_say3

----------------------- Auto Genrate End   --------------------
