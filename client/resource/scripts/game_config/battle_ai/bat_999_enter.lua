----------------------- Auto Genrate Begin --------------------


-- 自动生成AI,来源于[]

local ClsAIBase = require("gameobj/battle/ai/ai_base")

local ClsAIBat_999_enter = class("ClsAIBat_999_enter", ClsAIBase)

--------------------------- 基本属性函数开始 ------------------------------

-- AI ID
function ClsAIBat_999_enter:getId()
	return "bat_999_enter";
end


-- AI时机
function ClsAIBat_999_enter:getOpportunity()
	return AI_OPPORTUNITY.FIGHT_START;
end

-- AI优先级别
function ClsAIBat_999_enter:getPriority()
	return 48;
end

--------------------------- 基本属性函数结束 ------------------------------

--------------------------- 条件函数区开始 ------------------------------

--------------------------- 条件函数区结束 ------------------------------

--------------------------- 目标函数区开始 ------------------------------

-- [备注]
local function targetPlayer( ai_obj, last_targets )
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

		-- T玩家标记
		local TIsPlayer = target_obj:is_player();
		if not (TIsPlayer) then return false end

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
	{"story_mode", "", {}, }, 
	{"hide_ship_ui", "", {}, }, 
	{"camera_scale", "", {4, 1000, }, }, 
	{"camera_rotate", "", {-70, 1000, }, }, 
	{"delay", "", {1000, }, }, 
	{"camera_forward", targetPlayer, {450, 10000, }, }, 
	{"delay", "", {3000, }, }, 
	{"enter_scene", "", {3, 1, 0, 0, 7, 0, }, }, 
	{"forge_weather", "", {120, }, }, 
	{"delay", "", {1000, }, }, 
	{"enter_scene", "", {2, 1, 0, 0, 7, 0, }, }, 
	{"delay", "", {2000, }, }, 
	{"play_plot", "", {{1, 2, }, }, }, 
	{"camera_rotate", "", {70, 2, }, }, 
	{"show_ship_ui", "", {}, }, 
	{"play_plot", "", {{3, }, }, }, 
	{"normal_mode", "", {}, }, 
}

function ClsAIBat_999_enter:getActions()
	return actions
end

local all_target_method = {
}

function ClsAIBat_999_enter:getAllTargetMethod()
	return all_target_method
end

return ClsAIBat_999_enter

----------------------- Auto Genrate End   --------------------
