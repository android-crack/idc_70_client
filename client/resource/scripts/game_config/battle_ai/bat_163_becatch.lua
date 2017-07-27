----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[被碰撞放技能，减星]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_163_becatch = class("ClsAIBat_163_becatch", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_163_becatch:getId()
	return "bat_163_becatch";
end


-- AI时机
function ClsAIBat_163_becatch:getOpportunity()
	return AI_OPPORTUNITY.BECATCH;
end

-- AI优先级别
function ClsAIBat_163_becatch:getPriority()
	return 1;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[O加怒=200]
local function bat_163_becatch_act_0( ai_obj, act_obj, target, delta_time )
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

-- [备注]说话-[离我远一点，虫子。]
local function bat_163_becatch_act_2( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end




	local name = ""
	local word = T("离我远一点，虫子。")

	target_obj:say( name, word )

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"op", "", {bat_163_becatch_act_0, }, }, 
	{"use_skill", "", {10003, }, }, 
	{"op", "", {bat_163_becatch_act_2, }, }, 
	{"change_star", "", {1, }, }, 
}

function ClsAIBat_163_becatch:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_163_becatch:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_163_becatch

----------------------- Auto Genrate End   --------------------
