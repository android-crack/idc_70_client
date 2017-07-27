----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBusiness_62 = class("ClsAIBusiness_62", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBusiness_62:getId()
	return "business_62";
end


-- AI时机
function ClsAIBusiness_62:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIBusiness_62:getPriority()
	return 1;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndTimeis2(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- 战斗已进行时间
	local BattleTime = battleData:getBattleTime();
	-- 战斗进行时间>=2000
	if ( not (BattleTime>=2000) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIBusiness_62:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndTimeis2(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]说话-[快救救我们，海盗劫持了我们。]
local function business_62_act_0( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end




	local name = ""
	local word = T("快救救我们，海盗劫持了我们。")

	target_obj:say( name, word )

end

-- [备注]设置-[O耐久=O耐久上限*0.3]
local function business_62_act_1( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end

	-- O耐久上限
	local OHpMax = owner:getMaxHp();

	-- 公式原文:O耐久=O耐久上限*0.3
	owner:AIsetHp( OHpMax*0.3 );

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"op", "", {business_62_act_0, }, }, 
	{"op", "", {business_62_act_1, }, }, 
	{"delete_ai", "", {{"business_62", }, }, }, 
}

function ClsAIBusiness_62:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBusiness_62:getAllTargetMethod()
	return all_target_method
end

return ClsAIBusiness_62

----------------------- Auto Genrate End   --------------------
