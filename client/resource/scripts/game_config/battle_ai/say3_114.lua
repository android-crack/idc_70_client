----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[21]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAISay3_114 = class("ClsAISay3_114", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAISay3_114:getId()
	return "say3_114";
end


-- AI时机
function ClsAISay3_114:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAISay3_114:getPriority()
	return 1;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndNum1is1(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- 计数1
	local num1 = battleData:GetData("num1") or 0;
	-- num1==1
	if ( not (num1==1) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAISay3_114:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndNum1is1(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]说话-[时机成熟！目标“俞红袖”]
local function say3_114_act_1( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end




	local name = ""
	local word = T("时机成熟！目标“俞红袖”")

	target_obj:say( name, word )

end

-- [备注]设置-[O阵营=2]
local function say3_114_act_0( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end


	-- 公式原文:O阵营=2
	battleData:changeTeam(owner, 2 );

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"op", "", {say3_114_act_0, }, }, 
	{"op", "", {say3_114_act_1, }, }, 
	{"delete_ai", "", {{"say3_114", }, }, }, 
}

function ClsAISay3_114:getActions()
	return actions
end

local all_target_method = {
}

function ClsAISay3_114:getAllTargetMethod()
	return all_target_method
end

return ClsAISay3_114

----------------------- Auto Genrate End   --------------------
