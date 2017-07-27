----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[进场从3阵型选择1种]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_173_enter_formation_b_A = class("ClsAIBat_173_enter_formation_b_A", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_173_enter_formation_b_A:getId()
	return "bat_173_enter_formation_b_A";
end


-- AI时机
function ClsAIBat_173_enter_formation_b_A:getOpportunity()
	return AI_OPPORTUNITY.RUN;
end

-- AI优先级别
function ClsAIBat_173_enter_formation_b_A:getPriority()
	return -2;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndBat_173_enter_formation_b(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- 战场测试变量
	local Text_Cnt = battleData:GetData("_text_cnt") or 0;
	-- 记录随机数>333
	if ( not (Text_Cnt>333) ) then  return false end

	-- 记录随机数<= 666
	if ( not (Text_Cnt<= 666) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIBat_173_enter_formation_b_A:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndBat_173_enter_formation_b(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"enter_scene", "", {7, }, }, 
}

function ClsAIBat_173_enter_formation_b_A:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_173_enter_formation_b_A:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_173_enter_formation_b_A

----------------------- Auto Genrate End   --------------------
