----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_dead2_62 = class("ClsAIBat_dead2_62", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_dead2_62:getId()
	return "bat_dead2_62";
end


-- AI时机
function ClsAIBat_dead2_62:getOpportunity()
	return AI_OPPORTUNITY.DEATH;
end

-- AI优先级别
function ClsAIBat_dead2_62:getPriority()
	return -2;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[死亡2=死亡2+1]
local function bat_dead2_62_act_0( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end

	-- 战场测试变量
	local Death_Cnt2 = battleData:GetData("_death_cnt2") or 0;

	-- 公式原文:死亡2=死亡2+1
	battleData:planningSetData("_death_cnt2", Death_Cnt2+1);

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"op", "", {bat_dead2_62_act_0, }, }, 
}

function ClsAIBat_dead2_62:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_dead2_62:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_dead2_62

----------------------- Auto Genrate End   --------------------
