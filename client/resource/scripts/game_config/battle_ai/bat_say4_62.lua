----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_say4_62 = class("ClsAIBat_say4_62", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_say4_62:getId()
	return "bat_say4_62";
end


-- AI时机
function ClsAIBat_say4_62:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIBat_say4_62:getPriority()
	return 1;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndHpless90(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- O耐久百分比
	local OHpRate = owner:getHpRate() * 100;
	-- O耐久百分比<=90
	if ( not (OHpRate<=90) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIBat_say4_62:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndHpless90(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]说话-[真愁今天的收获少呢，你们就来啦！]
local function bat_say4_62_act_0( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end




	local name = ""
	local word = T("真愁今天的收获少呢，你们就来啦！")

	target_obj:say( name, word )

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"op", "", {bat_say4_62_act_0, }, }, 
	{"delete_ai", "", {{"bat_say4_62", }, }, }, 
}

function ClsAIBat_say4_62:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_say4_62:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_say4_62

----------------------- Auto Genrate End   --------------------
