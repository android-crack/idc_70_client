----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_16_enter2 = class("ClsAIBat_16_enter2", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_16_enter2:getId()
	return "bat_16_enter2";
end


-- AI时机
function ClsAIBat_16_enter2:getOpportunity()
	return AI_OPPORTUNITY.RUN;
end

-- AI优先级别
function ClsAIBat_16_enter2:getPriority()
	return 48;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

-- [备注]
local function targetGod( ai_obj, last_targets )
	local battleData = getGameData():getBattleDataMt()

	-- 目标选择范围
	local fanwei = "all";
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

		-- 指战役ship表第一列的ID
		local TBaseID = target_obj:getBaseId();
		if not (TBaseID==4) then return false end

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

-- [备注]离场-[]
local function bat_16_enter2_act_0( ai_obj, act_obj, target, delta_time )
	local owner = ai_obj:getOwner();
	local battleData = getGameData():getBattleDataMt()

	local target_obj
	if ( target and target >= 0 ) then
		target_obj = battleData:getShipByGenID(target)
		if ( not target_obj ) then return false end
	end


	target_obj:release(false, true)

end

--------------------------- 动作函数区结束 ------------------------------

local actions = {
	{"op", targetGod, {bat_16_enter2_act_0, }, }, 
	{"enter_scene", "", {12, 1, 1, 0, 1, 0, }, }, 
	{"enter_scene", "", {13, 1, 1, 0, 2, 0, }, }, 
	{"enter_scene", "", {14, 1, 1, 0, 3, 0, }, }, 
	{"enter_scene", "", {15, 1, 1, 0, 4, 0, }, }, 
	{"enter_scene", "", {16, 1, 1, 0, 5, 0, }, }, 
	{"enter_scene", "", {18, 1, 1, 0, 1, 0, }, }, 
	{"enter_scene", "", {19, 1, 1, 0, 2, 0, }, }, 
	{"enter_scene", "", {20, 1, 1, 0, 3, 0, }, }, 
	{"enter_scene", "", {21, 1, 1, 0, 4, 0, }, }, 
	{"enter_scene", "", {22, 1, 1, 0, 5, 0, }, }, 
	{"enter_scene", "", {23, 1, 1, 0, 6, 0, }, }, 
	{"enter_scene", "", {24, 1, 1, 0, 7, 0, }, }, 
	{"enter_scene", "", {25, 1, 1, 0, 8, 0, }, }, 
	{"enter_scene", "", {27, 1, 1, 0, 8, 0, }, }, 
}

function ClsAIBat_16_enter2:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_16_enter2:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_16_enter2

----------------------- Auto Genrate End   --------------------
