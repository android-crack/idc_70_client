----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[行走至某个点]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_161_goto1 = class("ClsAIBat_161_goto1", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_161_goto1:getId()
	return "bat_161_goto1";
end


-- AI时机
function ClsAIBat_161_goto1:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIBat_161_goto1:getPriority()
	return 48;
end

-- AI停止标记
function ClsAIBat_161_goto1:getStopOtherFlg()
	return 48;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]离场-[]
local function bat_161_goto1_act_3( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end


	target_obj:release(false, true)

end

-- [备注]设置-[海盗逃跑=海盗逃跑+1]
local function bat_161_goto1_act_1( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end

	-- 战场测试变量
	local HD_RunCnt = battleData:GetData("__hd_run_cnt") or 0;

	-- 公式原文:海盗逃跑=海盗逃跑+1
	battleData:planningSetData("__hd_run_cnt", HD_RunCnt+1);

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"move_to", "", {291, 595, 100, }, }, 
	{"op", "", {bat_161_goto1_act_1, }, }, 
	{"run_ai", "", {{"bat_161_lose", }, }, }, 
	{"op", "", {bat_161_goto1_act_3, }, }, 
	{"run_ai", "", {{"bat_161_add_data", }, }, }, 
	{"run_ai", "", {{"bat_161_add_data2", }, }, }, 
	{"run_ai", "", {{"bat_161_add_data3", }, }, }, 
	{"run_ai", "", {{"bat_161_say", }, }, }, 
}

function ClsAIBat_161_goto1:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_161_goto1:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_161_goto1

----------------------- Auto Genrate End   --------------------
