----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[10]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIHpless2_32 = class("ClsAIHpless2_32", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIHpless2_32:getId()
	return "hpless2_32";
end


-- AI时机
function ClsAIHpless2_32:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIHpless2_32:getPriority()
	return 1;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndHpless40(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- O耐久百分比
	local OHpRate = owner:getHpRate() * 100;
	-- O耐久百分比<=40
	if ( not (OHpRate<=40) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIHpless2_32:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndHpless40(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]说话-[早说过不要走这条航线，这下全完了！]
local function hpless2_32_act_0( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end




	local name = ""
	local word = T("早说过不要走这条航线，这下全完了！")

	target_obj:say( name, word )

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"op", "", {hpless2_32_act_0, }, }, 
	{"delete_ai", "", {{"hpless2_32", }, }, }, 
}

function ClsAIHpless2_32:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIHpless2_32:getAllTargetMethod()
	return all_target_method
end

return ClsAIHpless2_32

----------------------- Auto Genrate End   --------------------
