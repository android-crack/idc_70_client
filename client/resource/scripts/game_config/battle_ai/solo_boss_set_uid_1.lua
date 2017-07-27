----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAISolo_boss_set_uid_1 = class("ClsAISolo_boss_set_uid_1", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAISolo_boss_set_uid_1:getId()
	return "solo_boss_set_uid_1";
end


-- AI时机
function ClsAISolo_boss_set_uid_1:getOpportunity()
	return AI_OPPORTUNITY.FIGHT_START;
end

-- AI优先级别
function ClsAISolo_boss_set_uid_1:getPriority()
	return 2;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[ONPC唯一ID=1]
local function solo_boss_set_uid_1_act_0( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end


	-- 公式原文:ONPC唯一ID=1
	owner:setData("__my_uid", 1);

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"op", "", {solo_boss_set_uid_1_act_0, }, }, 
}

function ClsAISolo_boss_set_uid_1:getActions()
	return actions
end

local all_target_method = {
}

function ClsAISolo_boss_set_uid_1:getAllTargetMethod()
	return all_target_method
end

return ClsAISolo_boss_set_uid_1

----------------------- Auto Genrate End   --------------------
