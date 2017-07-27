----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_91_jy_moto_13 = class("ClsAIBat_91_jy_moto_13", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_91_jy_moto_13:getId()
	return "bat_91_jy_moto_13";
end


-- AI时机
function ClsAIBat_91_jy_moto_13:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIBat_91_jy_moto_13:getPriority()
	return 1;
end

-- AI停止标记
function ClsAIBat_91_jy_moto_13:getStopOtherFlg()
	return 1;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]离场-[]
local function bat_91_jy_moto_13_act_2( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end


	target_obj:release(false, true)

end

-- [备注]设置-[逃跑=逃跑+1;离场数量=离场数量+1]
local function bat_91_jy_moto_13_act_1( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end

	-- 战场测试变量
	local Leave_Cnt = battleData:GetData("_leave_cnt") or 0;
	-- 战场测试变量
	local Death_Cnt = battleData:GetData("_death_cnt") or 0;

	-- 公式原文:逃跑=逃跑+1
	battleData:planningSetData("_leave_cnt", Leave_Cnt+1);
	-- 公式原文:离场数量=离场数量+1
	battleData:planningSetData("_death_cnt", Death_Cnt+1);

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"move_to", "", {1700, 540, 60, }, }, 
	{"op", "", {bat_91_jy_moto_13_act_1, }, }, 
	{"op", "", {bat_91_jy_moto_13_act_2, }, }, 
}

function ClsAIBat_91_jy_moto_13:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_91_jy_moto_13:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_91_jy_moto_13

----------------------- Auto Genrate End   --------------------
