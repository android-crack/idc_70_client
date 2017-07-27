----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIDestiny_153 = class("ClsAIDestiny_153", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIDestiny_153:getId()
	return "destiny_153";
end


-- AI时机
function ClsAIDestiny_153:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIDestiny_153:getPriority()
	return -2;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndAi_2(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- 战场测试变量
	local AI2 = battleData:GetData("__ai_2") or 0;
	-- 触发2==1
	if ( not (AI2==1) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIDestiny_153:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndAi_2(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]说话-[让你们试试我新船的厉害]
local function destiny_153_act_1( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end




	local name = ""
	local word = T("让你们试试我新船的厉害")

	target_obj:say( name, word )

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"enter_scene", "", {11, 0, 0, 1, 3, 0, }, }, 
	{"op", "", {destiny_153_act_1, }, }, 
	{"run_ai", "", {{"bat_153_angry", }, }, }, 
	{"show_prompt", "", {T("不要击沉命运号,巴沙洛缪·罗伯茨死亡战斗胜利"), }, }, 
	{"delete_ai", "", {{"destiny_153", }, }, }, 
}

function ClsAIDestiny_153:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIDestiny_153:getAllTargetMethod()
	return all_target_method
end

return ClsAIDestiny_153

----------------------- Auto Genrate End   --------------------
