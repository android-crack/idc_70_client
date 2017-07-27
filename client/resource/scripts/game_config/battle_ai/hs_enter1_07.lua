----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIHs_enter1_07 = class("ClsAIHs_enter1_07", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIHs_enter1_07:getId()
	return "hs_enter1_07";
end


-- AI时机
function ClsAIHs_enter1_07:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIHs_enter1_07:getPriority()
	return 2;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndDeathis3(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- 战场测试变量
	local Die = battleData:GetData("_die") or 0;
	-- 死亡数量==3
	if ( not (Die==3) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIHs_enter1_07:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndDeathis3(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]说话-[只不过炸了一两只小船而已，小的们！给我上！]
local function hs_enter1_07_act_4( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end




	local name = ""
	local word = T("只不过炸了一两只小船而已，小的们！给我上！")

	target_obj:say( name, word )

end

-- [备注]设置-[死亡数量=死亡数量-3]
local function hs_enter1_07_act_3( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end

	-- 战场测试变量
	local Die = battleData:GetData("_die") or 0;

	-- 公式原文:死亡数量=死亡数量-3
	battleData:planningSetData("_die", Die-3);

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"enter_scene", "", {4, }, }, 
	{"enter_scene", "", {6, }, }, 
	{"enter_scene", "", {8, }, }, 
	{"op", "", {hs_enter1_07_act_3, }, }, 
	{"op", "", {hs_enter1_07_act_4, }, }, 
	{"delete_ai", "", {{"hs_enter1_07", }, }, }, 
	{"add_ai", "", {{"hs_enter1_07", }, }, }, 
}

function ClsAIHs_enter1_07:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIHs_enter1_07:getAllTargetMethod()
	return all_target_method
end

return ClsAIHs_enter1_07

----------------------- Auto Genrate End   --------------------
