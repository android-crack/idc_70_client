----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[龙卷风随即几个坐标出现]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIDk_random = class("ClsAIDk_random", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIDk_random:getId()
	return "dk_random";
end


-- AI时机
function ClsAIDk_random:getOpportunity()
	return AI_OPPORTUNITY.FIGHT_START;
end

-- AI优先级别
function ClsAIDk_random:getPriority()
	return 2;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[记录随机数=重置随机数]
local function dk_random_act_0( ai_obj, act_obj, target, delta_time )
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
	{"op", "", {dk_random_act_0, }, }, 
	{"run_ai", "", {{"dk_tornado_1", }, }, }, 
	{"run_ai", "", {{"dk_tornado_2", }, }, }, 
	{"run_ai", "", {{"dk_tornado_3", }, }, }, 
	{"run_ai", "", {{"dk_tornado_4", }, }, }, 
}

function ClsAIDk_random:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIDk_random:getAllTargetMethod()
	return all_target_method
end

return ClsAIDk_random

----------------------- Auto Genrate End   --------------------
