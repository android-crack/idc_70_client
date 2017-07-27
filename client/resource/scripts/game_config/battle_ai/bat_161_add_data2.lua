----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[首领离场增加“死亡”变量]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_161_add_data2 = class("ClsAIBat_161_add_data2", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_161_add_data2:getId()
	return "bat_161_add_data2";
end


-- AI时机
function ClsAIBat_161_add_data2:getOpportunity()
	return AI_OPPORTUNITY.RUN;
end

-- AI优先级别
function ClsAIBat_161_add_data2:getPriority()
	return -2;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndBat_161_add_data2(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- 指战役ship表第一列的ID
	local OBaseID = owner:getBaseId();
	-- OBaseID==4
	if ( not (OBaseID==4) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIBat_161_add_data2:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndBat_161_add_data2(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[首领死亡=首领死亡+1]
local function bat_161_add_data2_act_0( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end

	-- 战场测试变量
	local SW_DeathCnt = battleData:GetData("__sw_death_cnt") or 0;

	-- 公式原文:首领死亡=首领死亡+1
	battleData:planningSetData("__sw_death_cnt", SW_DeathCnt+1);

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"op", "", {bat_161_add_data2_act_0, }, }, 
}

function ClsAIBat_161_add_data2:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_161_add_data2:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_161_add_data2

----------------------- Auto Genrate End   --------------------
