----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[防御反弹]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIHs_skill6_05 = class("ClsAIHs_skill6_05", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIHs_skill6_05:getId()
	return "hs_skill6_05";
end


-- AI时机
function ClsAIHs_skill6_05:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIHs_skill6_05:getPriority()
	return 48;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndNum4is1(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- 计数4
	local num4 = battleData:GetData("num4") or 0;
	-- num4==1
	if ( not (num4==1) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIHs_skill6_05:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndNum4is1(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"add_skill", "", {1128, 1, }, }, 
	{"delete_ai", "", {{"hs_skill6_05", }, }, }, 
}

function ClsAIHs_skill6_05:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIHs_skill6_05:getAllTargetMethod()
	return all_target_method
end

return ClsAIHs_skill6_05

----------------------- Auto Genrate End   --------------------
