----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_202_enter = class("ClsAIBat_202_enter", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_202_enter:getId()
	return "bat_202_enter";
end


-- AI时机
function ClsAIBat_202_enter:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIBat_202_enter:getPriority()
	return 48;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndEnter(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- 战斗已进行时间
	local BattleTime = battleData:getBattleTime();
	-- 战场测试变量
	local DEAD = battleData:GetData("__dead") or 0;
	-- 战斗进行时间>=40000  or  死亡数==4
	if ( not (BattleTime>=40000  or  DEAD==4) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIBat_202_enter:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndEnter(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[触发AI=1]
local function bat_202_enter_act_9( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end


	-- 公式原文:触发AI=1
	battleData:planningSetData("__ai", 1);

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"enter_scene", "", {2, 0, 0, 1, 3, 0, }, }, 
	{"enter_scene", "", {7, }, }, 
	{"enter_scene", "", {8, }, }, 
	{"enter_scene", "", {9, }, }, 
	{"enter_scene", "", {10, }, }, 
	{"enter_scene", "", {11, }, }, 
	{"enter_scene", "", {12, }, }, 
	{"play_plot", "", {{5, 6, 3, 4, }, }, }, 
	{"show_prompt", "", {T("拦截敌方船只，掩护友军撤退"), }, }, 
	{"op", "", {bat_202_enter_act_9, }, }, 
	{"delete_ai", "", {{"bat_202_enter", }, }, }, 
}

function ClsAIBat_202_enter:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_202_enter:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_202_enter

----------------------- Auto Genrate End   --------------------
