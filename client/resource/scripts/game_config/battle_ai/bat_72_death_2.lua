----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_72_death_2 = class("ClsAIBat_72_death_2", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_72_death_2:getId()
	return "bat_72_death_2";
end


-- AI时机
function ClsAIBat_72_death_2:getOpportunity()
	return AI_OPPORTUNITY.DEATH;
end

-- AI优先级别
function ClsAIBat_72_death_2:getPriority()
	return -2;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[敌人2死亡=敌人2死亡+1]
local function bat_72_death_2_act_0( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end

	-- 战场测试变量
	local Death_Cnt_2 = battleData:GetData("_death_cnt_2") or 0;

	-- 公式原文:敌人2死亡=敌人2死亡+1
	battleData:planningSetData("_death_cnt_2", Death_Cnt_2+1);

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"op", "", {bat_72_death_2_act_0, }, }, 
}

function ClsAIBat_72_death_2:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_72_death_2:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_72_death_2

----------------------- Auto Genrate End   --------------------
