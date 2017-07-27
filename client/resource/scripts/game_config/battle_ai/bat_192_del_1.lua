----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_192_del_1 = class("ClsAIBat_192_del_1", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_192_del_1:getId()
	return "bat_192_del_1";
end


-- AI时机
function ClsAIBat_192_del_1:getOpportunity()
	return AI_OPPORTUNITY.RUN;
end

-- AI优先级别
function ClsAIBat_192_del_1:getPriority()
	return -2;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[O加怒=200]
local function bat_192_del_1_act_6( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end


	-- 公式原文:O加怒=200
	owner:addAnger( 200 );

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"delete_ai", "", {{"bat_192_ack_1", }, }, }, 
	{"delete_ai", "", {{"bat_192_ack_2", }, }, }, 
	{"delete_ai", "", {{"bat_192_ack_3", }, }, }, 
	{"delete_ai", "", {{"bat_192_ack_4", }, }, }, 
	{"delete_ai", "", {{"bat_192_add_ack", }, }, }, 
	{"add_skill", "", {1123, 5, }, }, 
	{"op", "", {bat_192_del_1_act_6, }, }, 
	{"use_skill", "", {1303, }, }, 
}

function ClsAIBat_192_del_1:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_192_del_1:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_192_del_1

----------------------- Auto Genrate End   --------------------
