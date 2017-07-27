----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_dead_71_jy = class("ClsAIBat_dead_71_jy", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_dead_71_jy:getId()
	return "bat_dead_71_jy";
end


-- AI时机
function ClsAIBat_dead_71_jy:getOpportunity()
	return AI_OPPORTUNITY.DEATH;
end

-- AI优先级别
function ClsAIBat_dead_71_jy:getPriority()
	return -2;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[死亡=死亡+1]
local function bat_dead_71_jy_act_0( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end

	-- 战场测试变量
	local Death_Cnt = battleData:GetData("_death_cnt") or 0;

	-- 公式原文:死亡=死亡+1
	battleData:planningSetData("_death_cnt", Death_Cnt+1);

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"op", "", {bat_dead_71_jy_act_0, }, }, 
}

function ClsAIBat_dead_71_jy:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_dead_71_jy:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_dead_71_jy

----------------------- Auto Genrate End   --------------------
