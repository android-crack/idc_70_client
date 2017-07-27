----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_53_check_2 = class("ClsAIBat_53_check_2", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_53_check_2:getId()
	return "bat_53_check_2";
end


-- AI时机
function ClsAIBat_53_check_2:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIBat_53_check_2:getPriority()
	return 48;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndBat_53_check_2(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- 战场测试变量
	local Death_Cnt = battleData:GetData("_death_cnt") or 0;
	-- 死亡==2
	if ( not (Death_Cnt==2) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIBat_53_check_2:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndBat_53_check_2(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]说话-[右舷被护卫舰撞破，赶快紧急修理！]
local function bat_53_check_2_act_0( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end




	local name = ""
	local word = T("右舷被护卫舰撞破，赶快紧急修理！")

	target_obj:say( name, word )

end

-- [备注]设置-[O耐久=O耐久-O耐久上限*0.1]
local function bat_53_check_2_act_1( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end

	-- O耐久
	local OHp = owner:getHp();
	-- O耐久上限
	local OHpMax = owner:getMaxHp();

	-- 公式原文:O耐久=O耐久-O耐久上限*0.1
	owner:AIsetHp( OHp-OHpMax*0.1 );

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"op", "", {bat_53_check_2_act_0, }, }, 
	{"op", "", {bat_53_check_2_act_1, }, }, 
	{"delete_ai", "", {{"bat_53_check_2", }, }, }, 
}

function ClsAIBat_53_check_2:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_53_check_2:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_53_check_2

----------------------- Auto Genrate End   --------------------
