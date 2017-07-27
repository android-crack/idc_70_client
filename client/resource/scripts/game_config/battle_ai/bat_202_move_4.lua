----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_202_move_4 = class("ClsAIBat_202_move_4", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_202_move_4:getId()
	return "bat_202_move_4";
end


-- AI时机
function ClsAIBat_202_move_4:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIBat_202_move_4:getPriority()
	return -1;
end

-- AI停止标记
function ClsAIBat_202_move_4:getStopOtherFlg()
	return -1;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndMove_4(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- OX<1280
	if ( not (owner:getPositionX()<1280) ) then  return false end

	-- OY>=640
	if ( not (owner:getPositionY()>=640) ) then  return false end

	-- 战场测试变量
	local LET_AI = battleData:GetData("__ai") or 0;
	-- 触发AI==1
	if ( not (LET_AI==1) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIBat_202_move_4:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndMove_4(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[触发AI=0]
local function bat_202_move_4_act_3( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end


	-- 公式原文:触发AI=0
	battleData:planningSetData("__ai", 0);

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"delete_ai", "", {{"bat_202_move_1", }, }, }, 
	{"delete_ai", "", {{"bat_202_move_2", }, }, }, 
	{"delete_ai", "", {{"bat_202_move_3", }, }, }, 
	{"op", "", {bat_202_move_4_act_3, }, }, 
	{"guide_point", "", {2500, 0, }, }, 
	{"move_to", "", {2500, 0, 50, }, }, 
	{"play_plot", "", {{7, }, }, }, 
	{"battle_stop", "", {1, }, }, 
	{"delete_ai", "", {{"bat_202_move_4", }, }, }, 
}

function ClsAIBat_202_move_4:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_202_move_4:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_202_move_4

----------------------- Auto Genrate End   --------------------
