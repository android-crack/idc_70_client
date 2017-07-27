----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[死4只防御，进场6只防御]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_172_enter = class("ClsAIBat_172_enter", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_172_enter:getId()
	return "bat_172_enter";
end


-- AI时机
function ClsAIBat_172_enter:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIBat_172_enter:getPriority()
	return 1;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndBat_172_enter(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- 战场测试变量
	local Die_Cnt = battleData:GetData("_die_cnt") or 0;
	-- 死亡数量==4
	if ( not (Die_Cnt==4) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIBat_172_enter:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndBat_172_enter(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]说话-[新的防御船进场了，摧毁他们，直至我们能打得动德雷克副手!]
local function bat_172_enter_act_6( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end




	local name = ""
	local word = T("新的防御船进场了，摧毁他们，直至我们能打得动德雷克副手!")

	target_obj:say( name, word )

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"enter_scene", "", {8, }, }, 
	{"enter_scene", "", {9, }, }, 
	{"enter_scene", "", {10, }, }, 
	{"enter_scene", "", {11, }, }, 
	{"enter_scene", "", {12, }, }, 
	{"enter_scene", "", {13, }, }, 
	{"op", "palyer", {bat_172_enter_act_6, }, }, 
	{"delete_ai", "", {{"bat_172_enter", }, }, }, 
}

function ClsAIBat_172_enter:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_172_enter:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_172_enter

----------------------- Auto Genrate End   --------------------
