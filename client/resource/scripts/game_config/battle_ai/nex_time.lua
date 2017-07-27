----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[再次召唤小兵]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAINex_time = class("ClsAINex_time", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAINex_time:getId()
	return "nex_time";
end


-- AI时机
function ClsAINex_time:getOpportunity()
	return AI_OPPORTUNITY.RUN;
end

-- AI优先级别
function ClsAINex_time:getPriority()
	return -2;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]说话-[接受纳尔逊队伍的制裁吧！]
local function nex_time_act_5( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end




	local name = ""
	local word = T("接受纳尔逊队伍的制裁吧！")

	target_obj:say( name, word )

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"enter_scene", "", {3, }, }, 
	{"enter_scene", "", {4, }, }, 
	{"enter_scene", "", {5, }, }, 
	{"enter_scene", "", {6, }, }, 
	{"enter_scene", "", {9, }, }, 
	{"op", "", {nex_time_act_5, }, }, 
}

function ClsAINex_time:getActions()
	return actions
end

local all_target_method = {
}

function ClsAINex_time:getAllTargetMethod()
	return all_target_method
end

return ClsAINex_time

----------------------- Auto Genrate End   --------------------
