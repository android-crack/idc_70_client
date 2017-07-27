----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[高级海盗进场延迟2秒说话]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAISolo_boss_talk = class("ClsAISolo_boss_talk", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAISolo_boss_talk:getId()
	return "solo_boss_talk";
end


-- AI时机
function ClsAISolo_boss_talk:getOpportunity()
	return AI_OPPORTUNITY.FIGHT_START;
end

-- AI优先级别
function ClsAISolo_boss_talk:getPriority()
	return 2;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]说话-[就凭你们也想追上我？]
local function solo_boss_talk_act_1( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end




	local name = ""
	local word = T("就凭你们也想追上我？")

	target_obj:say( name, word )

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"delay", "", {2000, }, }, 
	{"op", "", {solo_boss_talk_act_1, }, }, 
}

function ClsAISolo_boss_talk:getActions()
	return actions
end

local all_target_method = {
}

function ClsAISolo_boss_talk:getAllTargetMethod()
	return all_target_method
end

return ClsAISolo_boss_talk

----------------------- Auto Genrate End   --------------------
