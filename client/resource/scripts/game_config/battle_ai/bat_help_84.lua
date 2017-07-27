----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_help_84 = class("ClsAIBat_help_84", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_help_84:getId()
	return "bat_help_84";
end


-- AI时机
function ClsAIBat_help_84:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIBat_help_84:getPriority()
	return 48;
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
function ClsAIBat_help_84:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndHpless40(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]说话-[掩护我，我们是果阿的最后一道防线！！！]
local function bat_help_84_act_0( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end




	local name = ""
	local word = T("掩护我，我们是果阿的最后一道防线！！！")

	target_obj:say( name, word )

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"op", "", {bat_help_84_act_0, }, }, 
	{"enter_scene", "", {11, 0, 0, 1, 7, 0, }, }, 
	{"enter_scene", "", {12, 0, 0, 1, 7, 0, }, }, 
	{"delete_ai", "", {{"bat_help_84", }, }, }, 
}

function ClsAIBat_help_84:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_help_84:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_help_84

----------------------- Auto Genrate End   --------------------
