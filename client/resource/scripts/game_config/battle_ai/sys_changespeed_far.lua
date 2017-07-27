----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[远程船，当目标距离在射程内，且处于0.8~1的范围里时，攻击船只减速至目标船只]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAISys_changespeed_far = class("ClsAISys_changespeed_far", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAISys_changespeed_far:getId()
	return "sys_changespeed_far";
end


-- AI时机
function ClsAISys_changespeed_far:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAISys_changespeed_far:getPriority()
	return 905;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]
local function cndSys_changespeed_far(ai_obj, target)
	local owner = ai_obj:getOwner()
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if target and target >= 0 then
		target_obj = battleData:getShipByGenID(target)
		if not target_obj then return false end
	end

	-- 宿主与目标的距离
	local OTargetDistance = owner:getTargetDistance();
	-- 宿主的远程射程
	local OFarRange = owner:getFarRange();
	-- O目标距离>O远程攻击距离*0.8
	if ( not (OTargetDistance>OFarRange*0.8) ) then  return false end

	-- O目标距离<O远程攻击距离
	if ( not (OTargetDistance<OFarRange) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAISys_changespeed_far:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndSys_changespeed_far(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

-- [备注]
local function targetSys_changespeed_far( ai_obj, last_targets )
	local battleData = getGameData():getBattleDataMt()

	-- 目标选择范围
	local fanwei = "target";
	-- 目标排序方法
	local sort_key = "";
	local sort_asc = 1;
	-- 目标选择数量
	local select_cnt = 1;

	local tmp_targets = ai_obj:selectTargets(fanwei)

	local owner = ai_obj:getOwner()

	-- sort_method
	tmp_targets = battleData:sortShipsByKey(owner, tmp_targets, sort_key, sort_asc)

	-- 目标处于状态列表
	local lst_in_buff = {}
	-- 目标不处于状态列表
	local lst_no_in_buff = {}

	local func_condition = function(ai_obj, target_obj)
		for k, v in pairs(lst_in_buff) do
			if not target_obj:hasBuff(v) then return false end
		end

		for k, v in pairs(lst_no_in_buff) do
			if target_obj:hasBuff(v) then return false end
		end

		-- 如果是条件直接调用，如果是普通条件，解析

		return true
	end

	local tmp_cnt = 0
	local targets_result = {}
	for _, target in ipairs(tmp_targets) do
		local target_obj = battleData:getShipByGenID(target)
		if target == -2 then
			target_obj = battleData
		end
		if target_obj and func_condition(ai_obj, target_obj) then
			table.insert(targets_result, target)
			tmp_cnt = tmp_cnt + 1
			if tmp_cnt >= select_cnt then break end
		end
	end

	return targets_result
end


--------------------------- 目标函数区结束 ------------------------------

--------------------------- 动作函数区开始 ------------------------------

-- [备注]设置-[OAI变速=-O速度]
local function sys_changespeed_far_act_0( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end

	-- 宿主速度
	local OSpeed = owner:getSpeed();

	-- 公式原文:OAI变速=-O速度
	owner:setAISpeed( -OSpeed );

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"op", targetSys_changespeed_far, {sys_changespeed_far_act_0, }, }, 
	{"delete_ai", "", {{"sys_changespeed_far", }, }, }, 
}

function ClsAISys_changespeed_far:getActions()
	return actions
end

local all_target_method = {
}

function ClsAISys_changespeed_far:getAllTargetMethod()
	return all_target_method
end

return ClsAISys_changespeed_far

----------------------- Auto Genrate End   --------------------
