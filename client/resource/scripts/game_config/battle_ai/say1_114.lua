----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[15]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAISay1_114 = class("ClsAISay1_114", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAISay1_114:getId()
	return "say1_114";
end


-- AI时机
function ClsAISay1_114:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAISay1_114:getPriority()
	return 1;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndNum2is4(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- 计数2
	local num2 = battleData:GetData("num2") or 1;
	-- num2==4
	if ( not (num2==4) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAISay1_114:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndNum2is4(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]说话-[陈祖义，你作恶多端，如今你的手下都弃暗投明离你而去，你还不束手就擒？]
local function say1_114_act_0( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end




	local name = ""
	local word = T("陈祖义，你作恶多端，如今你的手下都弃暗投明离你而去，你还不束手就擒？")

	target_obj:say( name, word )

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"op", "", {say1_114_act_0, }, }, 
	{"delete_ai", "", {{"say1_114", }, }, }, 
}

function ClsAISay1_114:getActions()
	return actions
end

local all_target_method = {
}

function ClsAISay1_114:getAllTargetMethod()
	return all_target_method
end

return ClsAISay1_114

----------------------- Auto Genrate End   --------------------
