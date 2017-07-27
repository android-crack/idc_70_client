----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[突击技能专用，快速移动为1秒后停止表现]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAISk_follow_2 = class("ClsAISk_follow_2", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAISk_follow_2:getId()
	return "sk_follow_2";
end


-- AI时机
function ClsAISk_follow_2:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAISk_follow_2:getPriority()
	return 1;
end

-- AI停止标记
function ClsAISk_follow_2:getStopOtherFlg()
	return 1;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[突击结束]
local function sk_follow_2_act_2( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end


owner:ai_check_skill_hit()
end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"delay", "", {10, }, }, 
	{"follow", "", {10, 1300, }, }, 
	{"op", "", {sk_follow_2_act_2, }, }, 
}

function ClsAISk_follow_2:getActions()
	return actions
end

local all_target_method = {
}

function ClsAISk_follow_2:getAllTargetMethod()
	return all_target_method
end

return ClsAISk_follow_2

----------------------- Auto Genrate End   --------------------
