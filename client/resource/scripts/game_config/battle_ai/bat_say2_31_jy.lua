----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[5]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_say2_31_jy = class("ClsAIBat_say2_31_jy", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_say2_31_jy:getId()
	return "bat_say2_31_jy";
end


-- AI时机
function ClsAIBat_say2_31_jy:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIBat_say2_31_jy:getPriority()
	return 48;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndTime2(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- 战斗已进行时间
	local BattleTime = battleData:getBattleTime();
	-- 战斗进行时间>=10000
	if ( not (BattleTime>=10000) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIBat_say2_31_jy:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndTime2(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]说话-[竟敢在东地中海对阿芒德的“商船”出手，你们是活得不耐烦了?!]
local function bat_say2_31_jy_act_0( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end




	local name = ""
	local word = T("竟敢在东地中海对阿芒德的“商船”出手，你们是活得不耐烦了?!")

	target_obj:say( name, word )

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"op", "", {bat_say2_31_jy_act_0, }, }, 
	{"delete_ai", "", {{"bat_say2_31_jy", }, }, }, 
}

function ClsAIBat_say2_31_jy:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_say2_31_jy:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_say2_31_jy

----------------------- Auto Genrate End   --------------------
