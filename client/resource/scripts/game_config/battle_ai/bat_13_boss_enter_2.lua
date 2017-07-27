----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_13_boss_enter_2 = class("ClsAIBat_13_boss_enter_2", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_13_boss_enter_2:getId()
	return "bat_13_boss_enter_2";
end


-- AI时机
function ClsAIBat_13_boss_enter_2:getOpportunity()
	return AI_OPPORTUNITY.RUN;
end

-- AI优先级别
function ClsAIBat_13_boss_enter_2:getPriority()
	return -3;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

-- [备注]
local function targetEnemy( ai_obj, last_targets )
	local battleData = getGameData():getBattleDataMt()

	-- 目标选择范围
	local fanwei = "all";
	-- 目标排序方法
	local sort_key = "";
	local sort_asc = 1;
	-- 目标选择数量
	local select_cnt = 999;

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

		-- 目标阵营
		local TTeamId = target_obj:getTeamId();
		if not (TTeamId==2) then return false end

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
	{"camera_follow", "", {0, 0, 2, 0, }, }, 
	{"play_plot", "", {{5, 6, }, }, }, 
	{"delay", "", {100, }, }, 
	{"add_ai", targetEnemy, {{"bat_13_army", }, }, }, 
	{"delay", "", {1000, }, }, 
	{"play_plot", "", {{9, 10, }, }, }, 
	{"add_skill", "", {1213, 1, "passive", }, }, 
	{"use_skill", "", {1213, }, }, 
	{"delay", "", {2000, }, }, 
	{"play_plot", "", {{7, }, }, }, 
	{"run_ai", "", {{"bat_13_lbs_dead", }, }, }, 
}

function ClsAIBat_13_boss_enter_2:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_13_boss_enter_2:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_13_boss_enter_2

----------------------- Auto Genrate End   --------------------
