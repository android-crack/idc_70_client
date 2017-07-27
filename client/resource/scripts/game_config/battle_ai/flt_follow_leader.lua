----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[航海士跟随旗舰AI]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIFlt_follow_leader = class("ClsAIFlt_follow_leader", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIFlt_follow_leader:getId()
	return "flt_follow_leader";
end


-- AI时机
function ClsAIFlt_follow_leader:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIFlt_follow_leader:getPriority()
	return 805;
end

-- AI停止标记
function ClsAIFlt_follow_leader:getStopOtherFlg()
	return 805;
end

-- AI删除标记
function ClsAIFlt_follow_leader:getDeleteOtherFlg()
	return 805;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[追随目标=O旗舰]
local function flt_follow_leader_act_0( ai_obj, act_obj, target, delta_time )
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
	{"op", "", {flt_follow_leader_act_0, }, }, 
	{"follow", "", {299, }, }, 
	{"add_ai", "", {{"sys_dodge", }, }, }, 
}

function ClsAIFlt_follow_leader:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIFlt_follow_leader:getAllTargetMethod()
	return all_target_method
end

return ClsAIFlt_follow_leader

----------------------- Auto Genrate End   --------------------
