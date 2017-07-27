----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[统计普通海盗死亡数]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_boss_death = class("ClsAIBat_boss_death", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_boss_death:getId()
	return "bat_boss_death";
end


-- AI时机
function ClsAIBat_boss_death:getOpportunity()
	return AI_OPPORTUNITY.DEATH;
end

-- AI优先级别
function ClsAIBat_boss_death:getPriority()
	return -2;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[海盗数量=海盗数量+1]
local function bat_boss_death_act_0( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end

	-- 战场测试变量
	local PirateCnt = battleData:GetData("__pirate_cnt") or 0;

	-- 公式原文:海盗数量=海盗数量+1
	battleData:SetData("__pirate_cnt", PirateCnt+1);

end

-- [备注]设置-[离场数量=离场数量+1]
local function bat_boss_death_act_1( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end

	-- 战场测试变量
	local PirateLeaveCnt = battleData:GetData("__pirate_leave_cnt") or 0;

	-- 公式原文:离场数量=离场数量+1
	battleData:SetData("__pirate_leave_cnt", PirateLeaveCnt+1);

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"op", "", {bat_boss_death_act_0, }, }, 
	{"op", "", {bat_boss_death_act_1, }, }, 
	{"run_ai", "", {{"bat_boss_enter", }, }, }, 
	{"run_ai", "", {{"bat_boat_enter01", }, }, }, 
	{"run_ai", "", {{"bat_boat_enter02", }, }, }, 
}

function ClsAIBat_boss_death:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_boss_death:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_boss_death

----------------------- Auto Genrate End   --------------------
