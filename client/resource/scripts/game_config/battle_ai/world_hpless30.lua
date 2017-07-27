----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIWorld_hpless30 = class("ClsAIWorld_hpless30", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIWorld_hpless30:getId()
	return "world_hpless30";
end


-- AI时机
function ClsAIWorld_hpless30:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIWorld_hpless30:getPriority()
	return -2;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndHpless30(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- O耐久百分比
	local OHpRate = owner:getHpRate() * 100;
	-- O耐久百分比<=30
	if ( not (OHpRate<=30) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIWorld_hpless30:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndHpless30(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]说话-[看我炸飞你们！]
local function world_hpless30_act_0( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end




	local name = ""
	local word = T("看我炸飞你们！")

	target_obj:say( name, word )

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"op", "", {world_hpless30_act_0, }, }, 
	{"add_skill", "", {1213, 5, }, }, 
	{"add_skill", "", {5101, 10, }, }, 
	{"add_skill", "", {99013, 10, }, }, 
	{"delete_ai", "", {{"world_hpless30", }, }, }, 
}

function ClsAIWorld_hpless30:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIWorld_hpless30:getAllTargetMethod()
	return all_target_method
end

return ClsAIWorld_hpless30

----------------------- Auto Genrate End   --------------------
