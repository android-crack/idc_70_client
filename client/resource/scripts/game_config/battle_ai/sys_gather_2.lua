----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[设置追随目标]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAISys_gather_2 = class("ClsAISys_gather_2", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAISys_gather_2:getId()
	return "sys_gather_2";
end


-- AI时机
function ClsAISys_gather_2:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAISys_gather_2:getPriority()
	return 56;
end

-- AI停止标记
function ClsAISys_gather_2:getStopOtherFlg()
	return 56;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[追随目标=O旗舰;]
local function sys_gather_2_act_0( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end

	-- 宿主旗舰
	local OLeaderId = owner:getLeaderId();

	-- 公式原文:追随目标=O旗舰
	ai_obj:setData( "__follow_target_id", OLeaderId );

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"op", "", {sys_gather_2_act_0, }, }, 
	{"run_ai", "", {{"sys_del_gather", }, }, }, 
	{"follow", "", {125, }, }, 
	{"run_ai", "", {{"sys_del_gather", }, }, }, 
}

function ClsAISys_gather_2:getActions()
	return actions
end

local all_target_method = {
}

function ClsAISys_gather_2:getAllTargetMethod()
	return all_target_method
end

return ClsAISys_gather_2

----------------------- Auto Genrate End   --------------------
