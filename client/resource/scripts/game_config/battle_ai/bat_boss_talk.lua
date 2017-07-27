----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[高级海盗进场延迟2秒说话]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_boss_talk = class("ClsAIBat_boss_talk", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_boss_talk:getId()
	return "bat_boss_talk";
end


-- AI时机
function ClsAIBat_boss_talk:getOpportunity()
	return AI_OPPORTUNITY.FIGHT_START;
end

-- AI优先级别
function ClsAIBat_boss_talk:getPriority()
	return 1;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]说话-[就凭你们也想追上我？]
local function bat_boss_talk_act_2( ai_obj, act_obj, target, delta_time )
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

-- [备注]设置-[离场数量=离场数量-1]
local function bat_boss_talk_act_0( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end

	-- 战场测试变量
	local PirateLeaveCnt = battleData:GetData("__pirate_leave_cnt") or 0;

	-- 公式原文:离场数量=离场数量-1
	battleData:SetData("__pirate_leave_cnt", PirateLeaveCnt-1);

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"op", "", {bat_boss_talk_act_0, }, }, 
	{"delay", "", {2000, }, }, 
	{"op", "", {bat_boss_talk_act_2, }, }, 
}

function ClsAIBat_boss_talk:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_boss_talk:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_boss_talk

----------------------- Auto Genrate End   --------------------
