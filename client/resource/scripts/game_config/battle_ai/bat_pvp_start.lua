----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_pvp_start = class("ClsAIBat_pvp_start", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_pvp_start:getId()
	return "bat_pvp_start";
end


-- AI时机
function ClsAIBat_pvp_start:getOpportunity()
	return AI_OPPORTUNITY.FIGHT_START;
end

-- AI优先级别
function ClsAIBat_pvp_start:getPriority()
	return 48;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[记录随机数=重置随机数]
local function bat_pvp_start_act_2( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end


	-- 公式原文:记录随机数=重置随机数
	battleData:planningSetData("__random_cnt", ai_obj:resetRandom());

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"enter_scene", "", {20, 1, 0, 0, 1, 0, }, }, 
	{"enter_scene", "", {21, 1, 0, 0, 1, 0, }, }, 
	{"op", "", {bat_pvp_start_act_2, }, }, 
	{"run_ai", "", {{"bat_pvp_set1", }, }, }, 
	{"run_ai", "", {{"bat_pvp_set2", }, }, }, 
	{"run_ai", "", {{"bat_pvp_set3", }, }, }, 
}

function ClsAIBat_pvp_start:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_pvp_start:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_pvp_start

----------------------- Auto Genrate End   --------------------
