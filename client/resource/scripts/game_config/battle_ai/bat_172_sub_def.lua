----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[死一只减少10%防御]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_172_sub_def = class("ClsAIBat_172_sub_def", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_172_sub_def:getId()
	return "bat_172_sub_def";
end


-- AI时机
function ClsAIBat_172_sub_def:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAIBat_172_sub_def:getPriority()
	return 1;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndBat_172_sub_def(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- 战场测试变量
	local Die_Cnt = battleData:GetData("_die_cnt") or 0;
	-- 死亡数量~=0
	if ( not (Die_Cnt~=0) ) then  return false end

	-- 死亡数量<6
	if ( not (Die_Cnt<6) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAIBat_172_sub_def:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndBat_172_sub_def(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[OAI防御=记录防御-记录防御*(死亡数量/5)]
local function bat_172_sub_def_act_0( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end

	-- 战场测试变量
	local Def_Notes = battleData:GetData("_def_notes") or 0;
	-- 战场测试变量
	local Die_Cnt = battleData:GetData("_die_cnt") or 0;

	-- 公式原文:OAI防御=记录防御-记录防御*(死亡数量/5)
	owner:setAIDefense( Def_Notes-Def_Notes*(Die_Cnt/5) );

end

-- [备注]说话-[不，我的防御舰队！（防御下降）]
local function bat_172_sub_def_act_1( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end




	local name = ""
	local word = T("不，我的防御舰队！（防御下降）")

	target_obj:say( name, word )

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"op", "", {bat_172_sub_def_act_0, }, }, 
	{"op", "", {bat_172_sub_def_act_1, }, }, 
	{"delete_ai", "", {{"bat_172_sub_def", }, }, }, 
}

function ClsAIBat_172_sub_def:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_172_sub_def:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_172_sub_def

----------------------- Auto Genrate End   --------------------
