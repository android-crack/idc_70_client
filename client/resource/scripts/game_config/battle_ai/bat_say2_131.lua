----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[13]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_say2_131 = class("ClsAIBat_say2_131", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_say2_131:getId()
	return "bat_say2_131";
end


-- AI时机
function ClsAIBat_say2_131:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIBat_say2_131:getPriority()
	return 1;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndHpless85(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- O耐久百分比
	local OHpRate = owner:getHpRate() * 100;
	-- O耐久百分比<=85
	if ( not (OHpRate<=85) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIBat_say2_131:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndHpless85(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]说话-[不像官府的军舰！什么人？]
local function bat_say2_131_act_0( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end




	local name = ""
	local word = T("不像官府的军舰！什么人？")

	target_obj:say( name, word )

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"op", "", {bat_say2_131_act_0, }, }, 
	{"delete_ai", "", {{"bat_say2_131", }, }, }, 
}

function ClsAIBat_say2_131:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_say2_131:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_say2_131

----------------------- Auto Genrate End   --------------------
