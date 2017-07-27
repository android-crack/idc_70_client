----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_3012_tip4 = class("ClsAIBat_3012_tip4", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_3012_tip4:getId()
	return "bat_3012_tip4";
end


-- AI时机
function ClsAIBat_3012_tip4:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIBat_3012_tip4:getPriority()
	return 48;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndDead3(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- 战场测试变量
	local dead1 = battleData:GetData("dead1") or 0;
	-- dead1>=8
	if ( not (dead1>=8) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIBat_3012_tip4:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndDead3(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"enter_scene", "", {14, 0, 0, 1, 6, 5, }, }, 
	{"enter_scene", "", {15, 0, 0, 0, 6, 3, }, }, 
	{"enter_scene", "", {16, 0, 0, 0, 6, 3, }, }, 
	{"enter_scene", "", {17, 0, 0, 0, 6, 3, }, }, 
	{"enter_scene", "", {18, 0, 0, 0, 6, 3, }, }, 
	{"show_prompt", "", {T("前往目的地与海盗首领展开决战！"), }, }, 
	{"delete_ai", "", {{"bat_3012_tip4", }, }, }, 
}

function ClsAIBat_3012_tip4:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_3012_tip4:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_3012_tip4

----------------------- Auto Genrate End   --------------------
