----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[11→15→42]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_say4_33 = class("ClsAIBat_say4_33", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_say4_33:getId()
	return "bat_say4_33";
end


-- AI时机
function ClsAIBat_say4_33:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIBat_say4_33:getPriority()
	return 48;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndTimeis20(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- 战斗已进行时间
	local BattleTime = battleData:getBattleTime();
	-- 战斗进行时间>=20000
	if ( not (BattleTime>=20000) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIBat_say4_33:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndTimeis20(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]说话-[疾影舰，突破他们的防御阵型！]
local function bat_say4_33_act_0( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end




	local name = ""
	local word = T("疾影舰，突破他们的防御阵型！")

	target_obj:say( name, word )

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"op", "", {bat_say4_33_act_0, }, }, 
	{"show_prompt", "", {T("别让疾影舰靠近奥斯曼海盗"), }, }, 
	{"delete_ai", "", {{"bat_say4_33", }, }, }, 
}

function ClsAIBat_say4_33:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_say4_33:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_say4_33

----------------------- Auto Genrate End   --------------------
