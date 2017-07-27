----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIHs_hpless20_04 = class("ClsAIHs_hpless20_04", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIHs_hpless20_04:getId()
	return "hs_hpless20_04";
end


-- AI时机
function ClsAIHs_hpless20_04:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIHs_hpless20_04:getPriority()
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
	-- O耐久百分比<=20
	if ( not (OHpRate<=20) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIHs_hpless20_04:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndHpless30(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]说话-[没想到会被逼到这种地步！]
local function hs_hpless20_04_act_0( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end




	local name = ""
	local word = T("没想到会被逼到这种地步！")

	target_obj:say( name, word )

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"op", "", {hs_hpless20_04_act_0, }, }, 
	{"add_skill", "", {4101, 5, "passive", }, }, 
	{"use_skill", "", {4101, }, }, 
	{"delete_ai", "", {{"hs_hpless20_04", }, }, }, 
}

function ClsAIHs_hpless20_04:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIHs_hpless20_04:getAllTargetMethod()
	return all_target_method
end

return ClsAIHs_hpless20_04

----------------------- Auto Genrate End   --------------------
