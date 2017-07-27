----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIAlert1_112 = class("ClsAIAlert1_112", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIAlert1_112:getId()
	return "alert1_112";
end


-- AI时机
function ClsAIAlert1_112:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIAlert1_112:getPriority()
	return 1;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndNum2ge1(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- 计数2
	local num2 = battleData:GetData("num2") or 0;
	-- num2>=1
	if ( not (num2>=1) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIAlert1_112:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndNum2ge1(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]说话-[发现敌军！！]
local function alert1_112_act_0( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end




	local name = ""
	local word = T("发现敌军！！")

	target_obj:say( name, word )

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"op", "", {alert1_112_act_0, }, }, 
	{"stop_ai", "", {{"bat_move1_112", }, }, }, 
	{"delete_ai", "", {{"bat_move1_112", }, }, }, 
	{"play_plot", "", {{9, 10, }, }, }, 
	{"battle_stop", "", {0, }, }, 
}

function ClsAIAlert1_112:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIAlert1_112:getAllTargetMethod()
	return all_target_method
end

return ClsAIAlert1_112

----------------------- Auto Genrate End   --------------------
