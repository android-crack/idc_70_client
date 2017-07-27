----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[规避AI]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAISys_dodge = class("ClsAISys_dodge", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAISys_dodge:getId()
	return "sys_dodge";
end


-- AI时机
function ClsAISys_dodge:getOpportunity()
	return AI_OPPORTUNITY.TACTIC;
end

-- AI优先级别
function ClsAISys_dodge:getPriority()
	return 904;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

-- [备注]condition
local function cndDodge(ai_obj, target)
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
	-- O目标距离<=O远程攻击距离*0.6
	if ( not (OTargetDistance<=OFarRange*0.6) ) then  return false end

	-- 进入敌方射程
	local targetCntInRange = ai_obj:targetCnt("inrange");
	-- 进入敌方射程>0
	if ( not (targetCntInRange>0) ) then  return false end

	return true
end

-- 本AI的判定条件
function ClsAISys_dodge:checkCondition()
	local owner = self:getOwner()
	local battleData = getGameData():getBattleDataMt()
	return cndDodge(self, nil )
end

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

-- [备注]
local function targetInrange( ai_obj, last_targets )
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

		-- 宿主与目标的距离
		local OTargetDistance = owner:getTargetDistance();
		-- 目标的远程射程
		local TFarRange = target_obj:getFarRange();
		if not (OTargetDistance<TFarRange) then return false end

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

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"dodge", "", {}, }, 
}

function ClsAISys_dodge:getActions()
	return actions
end

local all_target_method = {
	["inrange"]=targetInrange, 
}

function ClsAISys_dodge:getAllTargetMethod()
	return all_target_method
end

return ClsAISys_dodge

----------------------- Auto Genrate End   --------------------
