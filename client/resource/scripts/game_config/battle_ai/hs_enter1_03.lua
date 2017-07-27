----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIHs_enter1_03 = class("ClsAIHs_enter1_03", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIHs_enter1_03:getId()
	return "hs_enter1_03";
end


-- AI时机
function ClsAIHs_enter1_03:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIHs_enter1_03:getPriority()
	return 2;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndNum1is4(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- 计数1
	local num1 = battleData:GetData("num1") or 0;
	-- num1==4
	if ( not (num1==4) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIHs_enter1_03:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndNum1is4(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]说话-[坚持住！钩索船马上就来！]
local function hs_enter1_03_act_0( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end




	local name = ""
	local word = T("坚持住！钩索船马上就来！")

	target_obj:say( name, word )

end

-- [备注]设置-[num1=num1-4]
local function hs_enter1_03_act_7( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end

	-- 计数1
	local num1 = battleData:GetData("num1") or 0;

	-- 公式原文:num1=num1-4
	battleData:planningSetData("num1", num1-4);

end

-- [备注]说话-[哈哈哈哈！钩索船只来了，上！]
local function hs_enter1_03_act_6( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end




	local name = ""
	local word = T("哈哈哈哈！钩索船只来了，上！")

	target_obj:say( name, word )

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"op", "", {hs_enter1_03_act_0, }, }, 
	{"delay", "", {6000, }, }, 
	{"enter_scene", "", {3, }, }, 
	{"enter_scene", "", {4, }, }, 
	{"enter_scene", "", {5, }, }, 
	{"enter_scene", "", {6, }, }, 
	{"op", "", {hs_enter1_03_act_6, }, }, 
	{"op", "", {hs_enter1_03_act_7, }, }, 
	{"delete_ai", "", {{"hs_enter1_03", }, }, }, 
	{"add_ai", "", {{"hs_enter1_03", }, }, }, 
}

function ClsAIHs_enter1_03:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIHs_enter1_03:getAllTargetMethod()
	return all_target_method
end

return ClsAIHs_enter1_03

----------------------- Auto Genrate End   --------------------
