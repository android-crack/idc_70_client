----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_191_con_1 = class("ClsAIBat_191_con_1", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_191_con_1:getId()
	return "bat_191_con_1";
end


-- AI时机
function ClsAIBat_191_con_1:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIBat_191_con_1:getPriority()
	return -2;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndTime_out(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- 战场测试变量
	local TIME = battleData:GetData("__time") or 0;
	-- 时间>=20
	if ( not (TIME>=20) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIBat_191_con_1:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndTime_out(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[时间=时间-20]
local function bat_191_con_1_act_3( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end

	-- 战场测试变量
	local TIME = battleData:GetData("__time") or 0;

	-- 公式原文:时间=时间-20
	battleData:planningSetData("__time", TIME-20);

end

-- [备注]设置-[召唤次数=召唤次数+1]
local function bat_191_con_1_act_4( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end

	-- 战场测试变量
	local call = battleData:GetData("__call") or 0;

	-- 公式原文:召唤次数=召唤次数+1
	battleData:planningSetData("__call", call+1);

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"show_prompt", "", {T("敌方补给船靠近敌军首领时，会大幅度增加海盗首领防御能力"), }, }, 
	{"run_ai", "", {{"bat_191_enter", }, }, }, 
	{"run_ai", "", {{"bat_191_wudi", }, }, }, 
	{"op", "", {bat_191_con_1_act_3, }, }, 
	{"op", "", {bat_191_con_1_act_4, }, }, 
}

function ClsAIBat_191_con_1:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_191_con_1:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_191_con_1

----------------------- Auto Genrate End   --------------------
