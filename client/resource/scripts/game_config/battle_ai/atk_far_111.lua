----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIAtk_far_111 = class("ClsAIAtk_far_111", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIAtk_far_111:getId()
	return "atk_far_111";
end


-- AI时机
function ClsAIAtk_far_111:getOpportunity()
	return AI_OPPORTUNITY.RUN;
end

-- AI优先级别
function ClsAIAtk_far_111:getPriority()
	return -2;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[OAI近攻=O近攻*0.05]
local function atk_far_111_act_0( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end

	-- O近攻
	local ONearAtt = owner:getAttNear();

	-- 公式原文:OAI近攻=O近攻*0.05
	owner:setAINearAtt( ONearAtt*0.05 );

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"op", "", {atk_far_111_act_0, }, }, 
}

function ClsAIAtk_far_111:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIAtk_far_111:getAllTargetMethod()
	return all_target_method
end

return ClsAIAtk_far_111

----------------------- Auto Genrate End   --------------------
