----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_53_tip = class("ClsAIBat_53_tip", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_53_tip:getId()
	return "bat_53_tip";
end


-- AI时机
function ClsAIBat_53_tip:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIBat_53_tip:getPriority()
	return 48;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndTip(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- 战场测试变量
	local Death_Cnt = battleData:GetData("_death_cnt") or 0;
	-- 死亡<5
	if ( not (Death_Cnt<5) ) then  return false end

	-- 战斗已进行时间
	local BattleTime = battleData:getBattleTime();
	-- 战斗进行时间>=20000
	if ( not (BattleTime>=20000) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIBat_53_tip:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndTip(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"play_plot", "", {{8, }, }, }, 
	{"delete_ai", "", {{"bat_53_tip", }, }, }, 
}

function ClsAIBat_53_tip:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_53_tip:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_53_tip

----------------------- Auto Genrate End   --------------------
