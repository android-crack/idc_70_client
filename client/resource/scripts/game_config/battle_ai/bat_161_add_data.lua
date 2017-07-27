----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[离场增加“死亡”变量]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_161_add_data = class("ClsAIBat_161_add_data", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_161_add_data:getId()
	return "bat_161_add_data";
end


-- AI时机
function ClsAIBat_161_add_data:getOpportunity()
	return AI_OPPORTUNITY.RUN;
end

-- AI优先级别
function ClsAIBat_161_add_data:getPriority()
	return -2;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[总死亡=总死亡+1]
local function bat_161_add_data_act_0( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end

	-- 战场测试变量
	local DeathCnt = battleData:GetData("__death_cnt") or 0;

	-- 公式原文:总死亡=总死亡+1
	battleData:planningSetData("__death_cnt", DeathCnt+1);

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"op", "", {bat_161_add_data_act_0, }, }, 
	{"run_ai", "", {{"bat_161_enter1", }, }, }, 
	{"run_ai", "", {{"bat_161_enter2", }, }, }, 
}

function ClsAIBat_161_add_data:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_161_add_data:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_161_add_data

----------------------- Auto Genrate End   --------------------
